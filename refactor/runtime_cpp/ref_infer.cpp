// ref_infer.cpp (skeleton)
#include "ref_infer.hpp"
#include "reference_quant_int8.hpp"
#include "io_utils.hpp"
#include <cstring>

static std::string join_path(const std::string& a, const std::string& b) {
    if (a.empty()) return b; if (b.empty()) return a;
    if (a.back()=='/'||a.back()=='\\') return a + b;
    return a + "/" + b;
}

bool LoadExport(const std::string& json_path, ModelIR& ir) {
    std::string text = read_file_text(json_path);
    // base dir
    auto pos = json_path.find_last_of("/\\");
    ir.base_dir = (pos==std::string::npos) ? std::string(".") : json_path.substr(0, pos);
    // crude parsing: find model params
    auto get_int = [&](const char* key, int& out){
        auto p = text.find(std::string("\"") + key + "\""); if (p==std::string::npos) return false;
        auto v = text.find(":", p); auto e = text.find_first_of(",}\n", v+1);
        out = std::stoi(text.substr(v+1, e-(v+1))); return true; };
    get_int("seq_len", ir.seq_len);
    get_int("proj_dim", ir.proj_dim);
    get_int("d_model", ir.d_model);
    get_int("n_layer", ir.n_layer);
    get_int("patch_len", ir.patch_len);
    get_int("stride", ir.stride);
    get_int("forecast_len", ir.forecast_len);

    // find head and proj layers
    std::string W, B, WS; double as=1.0; int az=0;
    LayerDesc head{}; LayerDesc proj{}; head.name="head"; proj.name="proj";
    if (json_find_layer_entry(text, "head", W, B, as, az, WS)) {
        head.type = "linear"; head.W_path = join_path(ir.base_dir, W); head.B_path = B.empty()?std::string(""):join_path(ir.base_dir, B); head.act_scale = as; head.act_zp = az; head.w_scale_path = WS.empty()?std::string(""):join_path(ir.base_dir, WS);
    }
    if (json_find_layer_entry(text, "proj", W, B, as, az, WS)) {
        proj.type = "linear"; proj.W_path = join_path(ir.base_dir, W); proj.B_path = B.empty()?std::string(""):join_path(ir.base_dir, B); proj.act_scale = as; proj.act_zp = az; proj.w_scale_path = WS.empty()?std::string(""):join_path(ir.base_dir, WS);
    }
    // in/out dims (best-effort)
    auto grab_dim = [&](const std::string& lname, const char* key, int& out){
        auto pos = text.find("\"name\"\s*:\s*\"" + lname + "\""); if (pos==std::string::npos) return;
        auto sect_end = text.find("}\n", pos); if (sect_end==std::string::npos) sect_end = text.size();
        auto sect = text.substr(pos, sect_end-pos);
        auto kpos = sect.find(std::string("\"") + key + "\""); if (kpos==std::string::npos) return;
        auto vpos = sect.find(":", kpos); auto e = sect.find_first_of(",}\n", vpos+1);
        out = std::stoi(sect.substr(vpos+1, e-(vpos+1))); };
    grab_dim("head", "in", head.in_dim); grab_dim("head", "out", head.out_dim);
    grab_dim("proj", "in", proj.in_dim); grab_dim("proj", "out", proj.out_dim);

    ir.layers.clear();
    if (!proj.W_path.empty()) ir.layers.push_back(proj);
    if (!head.W_path.empty()) ir.layers.push_back(head);
    return !ir.layers.empty();
}

bool GetLayer(const ModelIR& ir, const std::string& name, LayerDesc& out) {
    for (const auto& L : ir.layers) {
        if (L.name == name) { out = L; return true; }
    }
    return false;
}

// Minimal head-only forward: input x_ck is (C,K) float, average over K -> (C), INT8 linear(head) -> (2) float
void Forward(const ModelIR& ir, const float* x_ck, float* y_out) {
    // find head layer
    const LayerDesc* head = nullptr;
    for (auto& L : ir.layers) if (L.name == "head") { head = &L; break; }
    if (!head) throw std::runtime_error("Head layer not found in IR");

    // Load weights
    std::vector<int64_t> shpW, shpB, shpWS; std::vector<float> W, B, WS;
    load_npy_float32(head->W_path, shpW, W);
    if (!head->B_path.empty()) load_npy_float32(head->B_path, shpB, B);
    if (!head->w_scale_path.empty()) load_npy_float32(head->w_scale_path, shpWS, WS); else WS.assign(shpW[0], 1.0f);
    int out_f = static_cast<int>(shpW[0]); int in_f = static_cast<int>(shpW[1]);

    // Build input vector: avg over K
    std::vector<float> x(in_f, 0.0f);
    int C = in_f; int K = std::max(1, ir.seq_len);
    for (int c = 0; c < C; ++c) {
        double sum = 0.0; for (int k = 0; k < K; ++k) sum += x_ck[c*K + k];
        x[c] = static_cast<float>(sum / K);
    }

    // Quantize activation per-tensor asym
    const double a_scale = head->act_scale; const int a_zp = head->act_zp;
    std::vector<int8_t> x_q(in_f);
    for (int i = 0; i < in_f; ++i) x_q[i] = quant_per_tensor_asym(x[i], a_scale, a_zp, 0, 255);

    // Quantize weights per-channel symmetric using WS
    std::vector<int8_t> Wq(W.size());
    for (int o = 0; o < out_f; ++o) {
        double s = (o < (int)WS.size() ? (double)WS[o] : 1.0);
        double invs = 1.0 / s;
        for (int i = 0; i < in_f; ++i) {
            double v = (double)W[o*in_f + i] * invs;
            int64_t q = rnd_ties_to_even(v);
            q = std::min<int64_t>(127, std::max<int64_t>(-128, q));
            Wq[o*in_f + i] = static_cast<int8_t>(q);
        }
    }

    // GEMV int8xint8->int32, per-channel rescale back to float
    for (int o = 0; o < out_f; ++o) {
        int32_t acc = 0;
        for (int i = 0; i < in_f; ++i) {
            acc += (int32_t)Wq[o*in_f + i] * (int32_t)x_q[i];
        }
        double y = (double)acc * (a_scale * (double)WS[o]);
        if (!B.empty()) y += (double)B[o];
        y_out[o] = static_cast<float>(y);
    }
}
