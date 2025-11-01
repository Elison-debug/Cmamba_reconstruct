// ref_infer.cpp (skeleton)
#include "ref_infer.hpp"
#include "reference_quant_int8.hpp"
#include "io_utils.hpp"
#include <cstring>
#include <vector>
#include <cmath>

static std::string join_path(const std::string& a, const std::string& b) {
    if (a.empty()) return b; if (b.empty()) return a;
    if (a.back()=='/'||a.back()=='\\') return a + b;
    return a + "/" + b;
}

static bool json_get_int(const std::string& text, const char* key, int& out){
    auto p = text.find(std::string("\"") + key + "\""); if (p==std::string::npos) return false;
    auto v = text.find(':', p); auto e = text.find_first_of(",}\n", v+1);
    try { out = std::stoi(text.substr(v+1, e-(v+1))); } catch(...) { return false; }
    return true;
}

static bool json_get_str(const std::string& text, const char* key, std::string& out){
    auto p = text.find(std::string("\"") + key + "\""); if (p==std::string::npos) return false;
    auto v = text.find('"', text.find(':', p)+1); if (v==std::string::npos) return false;
    auto e = text.find('"', v+1); if (e==std::string::npos) return false;
    out = text.substr(v+1, e-(v+1)); return true;
}

static bool json_get_bool(const std::string& text, const char* key, bool& out){
    auto p = text.find(std::string("\"") + key + "\""); if (p==std::string::npos) return false;
    auto v = text.find(':', p); if (v==std::string::npos) return false;
    auto e = text.find_first_of(",}\n", v+1);
    auto s = text.substr(v+1, e-(v+1));
    for (auto& c: s) c = (char)tolower(c);
    if (s.find("true")!=std::string::npos) { out=true; return true; }
    if (s.find("false")!=std::string::npos) { out=false; return true; }
    return false;
}

bool LoadExport(const std::string& json_path, ModelIR& ir) {
    std::string text = read_file_text(json_path);
    // base dir
    auto pos = json_path.find_last_of("/\\");
    ir.base_dir = (pos==std::string::npos) ? std::string(".") : json_path.substr(0, pos);
    // model params
    json_get_int(text, "seq_len", ir.seq_len);
    json_get_int(text, "proj_dim", ir.proj_dim);
    json_get_int(text, "d_model", ir.d_model);
    json_get_int(text, "n_layer", ir.n_layer);
    json_get_int(text, "patch_len", ir.patch_len);
    json_get_int(text, "stride", ir.stride);
    json_get_int(text, "forecast_len", ir.forecast_len);

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

// Activation LUTs (Sigmoid/SiLU) for FPGA-like inference
struct ActLUT {
    std::vector<float> xs; // grid
    std::vector<float> sig; // sigmoid(x)
    std::vector<float> silu; // x*sigmoid(x)
    float xmin=-8.0f, xmax=8.0f; int n=4096;
    void build(float a=-8.0f, float b=8.0f, int N=4096){ xmin=a; xmax=b; n=N; xs.resize(n); sig.resize(n); silu.resize(n);
        for(int i=0;i<n;++i){ float x=a + (b-a)*i/(n-1); xs[i]=x; float s=1.0f/(1.0f+std::exp(-x)); sig[i]=s; silu[i]=x*s; } }
    inline float lerp(const std::vector<float>& v, float x) const {
        if (x<=xmin) return v.front(); if (x>=xmax) return v.back(); float t=(x - xmin)/(xmax - xmin); float f=t*(n-1); int i=(int)f; float u=f-i; return v[i]*(1.0f-u)+v[i+1]*u; }
    float sigmoid(float x) const { return lerp(sig, x); }
    float silu_fn(float x) const { return lerp(silu, x); }
};

static void rmsnorm_inplace(std::vector<float>& x, const std::vector<float>& weight){
    // x: length D, normalize across dim then multiply weight
    const int D = (int)x.size(); double m=0.0; for(int i=0;i<D;++i){ m += (double)x[i]*(double)x[i]; }
    m /= std::max(1, D); float inv = 1.0f / std::sqrt((float)m + 1e-5f); for(int i=0;i<D;++i){ x[i] = x[i]*inv * (weight.empty()?1.0f:weight[i]); }
}

// Minimal head-only forward kept for compatibility
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

// -------- Full backbone forward (float with INT8 linears) --------
struct LinearQDesc { std::string W, B, WS; double a_scale=1.0; int a_zp=0; int in_f=0, out_f=0; };
struct BlockDesc {
    LinearQDesc in_proj, out_proj, dt_proj; int d_conv=1; bool has_dw=false; std::vector<float> dw_W, dw_B; // dw: (C,1,k)
    std::vector<float> norm_weight; bool gate_off=false;
};
struct BackboneDesc {
    int d_model=0, d_inner=0, n_layer=0, num_patches=0, patch_len=0, stride=0, d_conv=1; bool pe_on=false; float pe_scale=1.0f; std::string agg_pool=""; std::string pe_path="";
    LinearQDesc patch_embed, out_flat, out_pool; std::vector<BlockDesc> blocks; std::vector<float> final_norm_weight; };

static bool load_linear_desc_any(const std::string& text, const std::string& key_prefix, LinearQDesc& L){
    std::string W,B,WS; double as=1.0; int az=0;
    if (!json_get_str(text, (key_prefix + "_W").c_str(), W)) return false;
    json_get_str(text, (key_prefix + "_B").c_str(), B);
    json_get_str(text, (key_prefix + "_WS").c_str(), WS);
    double tmp=0.0; if (json_get_str(text, (key_prefix + "_act_scale").c_str(), W)){} // no-op
    // act_scale/act_zp are present for some layers under different keys; attempt generic fetch
    double asd=1.0; if (json_get_int(text, (key_prefix + "_act_scale").c_str(), *(int*)&asd)) L.a_scale = asd; else L.a_scale = 1.0;
    int azd=0; if (json_get_int(text, (key_prefix + "_act_zp").c_str(), azd)) L.a_zp = azd; else L.a_zp = 0;
    L.W=W; L.B=B; L.WS=WS; return true;
}

static bool LoadBackbone(const std::string& bb_path, BackboneDesc& bb, const std::string& base_dir){
    std::string t = read_file_text(bb_path);
    // meta
    json_get_int(t, "d_model", bb.d_model);
    json_get_int(t, "d_inner", bb.d_inner);
    json_get_int(t, "n_layer", bb.n_layer);
    json_get_int(t, "num_patches", bb.num_patches);
    json_get_int(t, "patch_len", bb.patch_len);
    json_get_int(t, "stride", bb.stride);
    json_get_int(t, "d_conv", bb.d_conv);
    json_get_bool(t, "pe_on", bb.pe_on);
    {
        double ps=1.0; int tmp=0; if (json_get_int(t, "pe_scale", tmp)) ps = (double)tmp; bb.pe_scale=(float)ps;
    }
    json_get_str(t, "agg_pool", bb.agg_pool);
    std::string pe_rel; if (json_get_str(t, "pe", pe_rel)) bb.pe_path = join_path(base_dir, pe_rel);
    // patch embedding
    bb.patch_embed.W = join_path(base_dir, "patch_embed_W.npy"); bb.patch_embed.B = join_path(base_dir, "patch_embed_B.npy");
    std::vector<int64_t> shp; std::vector<float> tmpv;
    // blocks
    bb.blocks.resize(std::max(0, bb.n_layer));
    for (int i=0;i<bb.n_layer;++i){
        BlockDesc& bl = bb.blocks[i]; bl.d_conv = bb.d_conv;
        // in/out proj
        std::string key = "block" + std::to_string(i) + "_in_proj";
        std::string W; if (json_get_str(t, (key+"_W").c_str(), W)) {
            bl.in_proj.W = join_path(base_dir, W);
            json_get_str(t, (key+"_B").c_str(), bl.in_proj.B);
            if (!bl.in_proj.B.empty()) bl.in_proj.B = join_path(base_dir, bl.in_proj.B);
            std::string WS; if (json_get_str(t, (key+"_WS").c_str(), WS)) bl.in_proj.WS = join_path(base_dir, WS);
            int as_i=0, az_i=0; json_get_int(t, (key+"_act_scale").c_str(), as_i); json_get_int(t, (key+"_act_zp").c_str(), az_i);
            bl.in_proj.a_scale = as_i? (double)as_i : 1.0; bl.in_proj.a_zp = az_i;
        }
        key = "block" + std::to_string(i) + "_out_proj";
        if (json_get_str(t, (key+"_W").c_str(), W)) {
            bl.out_proj.W = join_path(base_dir, W);
            json_get_str(t, (key+"_B").c_str(), bl.out_proj.B);
            if (!bl.out_proj.B.empty()) bl.out_proj.B = join_path(base_dir, bl.out_proj.B);
            std::string WS; if (json_get_str(t, (key+"_WS").c_str(), WS)) bl.out_proj.WS = join_path(base_dir, WS);
            int as_i=0, az_i=0; json_get_int(t, (key+"_act_scale").c_str(), as_i); json_get_int(t, (key+"_act_zp").c_str(), az_i);
            bl.out_proj.a_scale = as_i? (double)as_i : 1.0; bl.out_proj.a_zp = az_i;
        }
        // dw conv
        std::string dwW; if (json_get_str(t, ("block"+std::to_string(i)+"_dw_W").c_str(), dwW)){
            bl.has_dw = true; load_npy_float32(join_path(base_dir, dwW), shp, bl.dw_W);
            std::string dwB; if (json_get_str(t, ("block"+std::to_string(i)+"_dw_B").c_str(), dwB)) load_npy_float32(join_path(base_dir, dwB), shp, bl.dw_B);
        }
        // dt_proj
        key = "block" + std::to_string(i) + "_dt_proj";
        if (json_get_str(t, (key+"_W").c_str(), W)){
            bl.dt_proj.W = join_path(base_dir, W);
            std::string B; if (json_get_str(t, (key+"_B").c_str(), B)) bl.dt_proj.B = join_path(base_dir, B);
            std::string WS; if (json_get_str(t, (key+"_WS").c_str(), WS)) bl.dt_proj.WS = join_path(base_dir, WS);
            int as_i=0, az_i=0; json_get_int(t, (key+"_act_scale").c_str(), as_i); json_get_int(t, (key+"_act_zp").c_str(), az_i);
            bl.dt_proj.a_scale = as_i? (double)as_i : 1.0; bl.dt_proj.a_zp = az_i;
        }
        // norm
        std::string nw; if (json_get_str(t, ("block"+std::to_string(i)+"_norm_weight").c_str(), nw)) load_npy_float32(join_path(base_dir, nw), shp, bl.norm_weight);
    }
    // final norm
    std::string fnw; if (json_get_str(t, "final_norm_weight", fnw)) load_npy_float32(join_path(base_dir, fnw), shp, bb.final_norm_weight);
    // outputs
    std::string ow; if (json_get_str(t, "out_flat_W", ow)) bb.out_flat.W = join_path(base_dir, ow);
    std::string ob; if (json_get_str(t, "out_flat_B", ob)) bb.out_flat.B = join_path(base_dir, ob);
    std::string ows; if (json_get_str(t, "out_flat_WS", ows)) bb.out_flat.WS = join_path(base_dir, ows);
    ow.clear(); if (json_get_str(t, "out_pool_W", ow)) bb.out_pool.W = join_path(base_dir, ow);
    ob.clear(); if (json_get_str(t, "out_pool_B", ob)) bb.out_pool.B = join_path(base_dir, ob);
    ows.clear(); if (json_get_str(t, "out_pool_WS", ows)) bb.out_pool.WS = join_path(base_dir, ows);
    return true;
}

static void linear_q_forward(const LinearQDesc& L, const std::vector<float>& x, std::vector<float>& y){
    std::vector<int64_t> shpW, shpB, shpWS; std::vector<float> W, B, WS;
    load_npy_float32(L.W, shpW, W);
    if (!L.B.empty()) load_npy_float32(L.B, shpB, B);
    if (!L.WS.empty()) load_npy_float32(L.WS, shpWS, WS); else WS.assign(shpW[0], 1.0f);
    int out_f = (int)shpW[0], in_f=(int)shpW[1];
    // quantize input
    std::vector<int8_t> xq(in_f);
    for (int i=0;i<in_f;++i) xq[i]=quant_per_tensor_asym(x[i], L.a_scale, L.a_zp, 0, 255);
    // quantize weights
    std::vector<int8_t> Wq(W.size());
    for (int o=0;o<out_f;++o){ double invs = 1.0 / (double)WS[o]; for (int i=0;i<in_f;++i){ double v=(double)W[o*in_f+i]*invs; int64_t q=rnd_ties_to_even(v); q=std::min<int64_t>(127,std::max<int64_t>(-128,q)); Wq[o*in_f+i]=(int8_t)q; }}
    // gemv
    y.assign(out_f, 0.0f);
    for (int o=0;o<out_f;++o){ int32_t acc=0; for (int i=0;i<in_f;++i) acc += (int32_t)Wq[o*in_f+i]*(int32_t)xq[i]; double yf=(double)acc * (L.a_scale * (double)WS[o]); if (!B.empty()) yf += (double)B[o]; y[o]=(float)yf; }
}

static void dwconv_time_same(const std::vector<float>& xTK, int K, int C, int k, const std::vector<float>& W, const std::vector<float>& B, std::vector<float>& yTK){
    // xTK: (K,C) row-major; W: (C,1,k) contiguous per C
    int pad = k/2; yTK.assign(K*C, 0.0f);
    for (int t=0;t<K;++t){ for(int c=0;c<C;++c){ double acc = 0.0; for (int u=0; u<k; ++u){ int tt = t + u - pad; float xv = 0.0f; if (tt>=0 && tt<K) xv = xTK[tt*C + c]; float w = W[c*k + u]; acc += (double)xv * (double)w; } if (!B.empty()) acc += (double)B[c]; yTK[t*C + c] = (float)acc; }}
}

// Full forward given export.json path and input x (K,Din)
bool ForwardFull(const std::string& export_json, const std::vector<float>& xKD, int Din, std::vector<float>& y_out){
    ModelIR ir{}; if (!LoadExport(export_json, ir)) return false;
    // find backbone.json path
    std::string text = read_file_text(export_json);
    std::string bb_rel; size_t p = text.find("\"params\"\s*:\s*\"backbone.json\""); if (p==std::string::npos) return false; // fixed name
    std::string bb_path = join_path(ir.base_dir, "backbone.json");
    BackboneDesc bb{}; if (!LoadBackbone(bb_path, bb, ir.base_dir)) return false;
    ActLUT lut; lut.build();
    // shapes
    int K = ir.seq_len, C = ir.proj_dim; int P = bb.patch_len, S = bb.stride; int num_patches = ((K - P)/S) + 1;
    // 1) proj over each time step
    // load proj layer
    LayerDesc projL{}; if (!GetLayer(ir, std::string("proj"), projL)) return false;
    std::vector<int64_t> shpW, shpB, shpWS; std::vector<float> Wp, Bp, WSp;
    load_npy_float32(projL.W_path, shpW, Wp);
    if (!projL.B_path.empty()) load_npy_float32(projL.B_path, shpB, Bp);
    if (!projL.w_scale_path.empty()) load_npy_float32(projL.w_scale_path, shpWS, WSp); else WSp.assign(shpW[0], 1.0f);
    int out_f = (int)shpW[0], in_f=(int)shpW[1];
    // pre-quantize weights
    std::vector<int8_t> Wq(out_f*in_f);
    for (int o=0;o<out_f;++o){ double invs=1.0/(double)WSp[o]; for (int i=0;i<in_f;++i){ double v=(double)Wp[o*in_f+i]*invs; int64_t q=rnd_ties_to_even(v); q=std::min<int64_t>(127,std::max<int64_t>(-128,q)); Wq[o*in_f+i]=(int8_t)q; }}
    // apply per time
    std::vector<float> xCK(K*C, 0.0f);
    for (int t=0;t<K;++t){ // xKD is row-major by time: index t*Din + d
        // quantize input vec length Din
        std::vector<int8_t> xq(in_f);
        for (int i=0;i<in_f;++i){ float xv = xKD[t*Din + i]; xq[i]=quant_per_tensor_asym(xv, projL.act_scale, projL.act_zp, 0, 255); }
        for (int o=0;o<out_f;++o){ int32_t acc=0; for (int i=0;i<in_f;++i) acc += (int32_t)Wq[o*in_f+i]*(int32_t)xq[i]; double y=(double)acc*(projL.act_scale*(double)WSp[o]); if (!Bp.empty()) y += (double)Bp[o]; xCK[t*C + o] = (float)y; }
    }
    // transpose to (C,K)
    // unfold to patches -> shape (num_patches, C*P)
    std::vector<float> patches(num_patches*C*P);
    for (int pi=0; pi<num_patches; ++pi){ int t0 = pi*S; for (int c=0;c<C;++c){ for (int u=0; u<P; ++u){ patches[pi*(C*P) + c*P + u] = xCK[(t0+u)*C + c]; } } }
    // 2) patch embedding
    std::vector<float> y_dmodel; y_dmodel.reserve(num_patches*bb.d_model);
    // load patch_emb weights and qparams
    LinearQDesc peL; peL.W = join_path(ir.base_dir, "patch_embed_W.npy"); peL.B = join_path(ir.base_dir, "patch_embed_B.npy");
    std::string peWS; if (json_get_str(text, "patch_embed_WS", peWS)) peL.WS = join_path(ir.base_dir, peWS);
    int as_i=0, az_i=0; if (json_get_int(text, "patch_embed_act_scale", as_i)) peL.a_scale = (double)as_i; else peL.a_scale = 1.0; if (json_get_int(text, "patch_embed_act_zp", az_i)) peL.a_zp = az_i; else peL.a_zp = 0;
    // load PE once if available
    std::vector<int64_t> shpPE; std::vector<float> pebuf; if (bb.pe_on && !bb.pe_path.empty()) load_npy_float32(bb.pe_path, shpPE, pebuf);
    for (int pi=0; pi<num_patches; ++pi){
        std::vector<float> xin(C*P); for (int i=0;i<C*P;++i) xin[i]=patches[pi*(C*P)+i]; std::vector<float> y; linear_q_forward(peL, xin, y);
        // add PE
        if (bb.pe_on && !pebuf.empty()){
            for (int j=0;j<bb.d_model;++j) y[j] += bb.pe_scale * pebuf[pi*bb.d_model + j];
        }
        // per-block sequence container
        y_dmodel.insert(y_dmodel.end(), y.begin(), y.end());
    }
    // y_dmodel now (num_patches, d_model)
    // 3) N blocks
    int T = num_patches; // time steps per block
    for (int bi=0; bi<bb.n_layer; ++bi){
        BlockDesc& bl = bb.blocks[bi];
        // RMSNorm
        for (int t=0;t<T;++t){ std::vector<float> vt(bb.d_model); for (int j=0;j<bb.d_model;++j) vt[j]=y_dmodel[t*bb.d_model + j]; rmsnorm_inplace(vt, bl.norm_weight); for (int j=0;j<bb.d_model;++j) y_dmodel[t*bb.d_model + j]=vt[j]; }
        // in_proj -> split u,z (size d_inner each)
        std::vector<float> uv(T*2*bb.d_inner);
        for (int t=0;t<T;++t){ std::vector<float> xvec(bb.d_model); for (int j=0;j<bb.d_model;++j) xvec[j]=y_dmodel[t*bb.d_model + j]; std::vector<float> y; linear_q_forward(bl.in_proj, xvec, y); for (int j=0;j<2*bb.d_inner;++j) uv[t*2*bb.d_inner + j] = y[j]; }
        // separate u and z
        std::vector<float> u(T*bb.d_inner), z(T*bb.d_inner);
        for (int t=0;t<T;++t){ for (int j=0;j<bb.d_inner;++j){ u[t*bb.d_inner+j]=uv[t*2*bb.d_inner + j]; z[t*bb.d_inner+j]=uv[t*2*bb.d_inner + bb.d_inner + j]; } }
        // optional dwconv on u (depthwise conv across time)
        if (bl.has_dw){ std::vector<float> u2(T*bb.d_inner); dwconv_time_same(u, T, bb.d_inner, bb.d_conv, bl.dw_W, bl.dw_B, u2); u.swap(u2); }
        // SiLU(u)
        for (float& v: u){ v = lut.silu_fn(v); }
        // SSM selective scan with dt_proj
        // load dt_proj weights once
        std::vector<int64_t> shpW, shpB, shpWS; std::vector<float> W, B, WS;
        load_npy_float32(bl.dt_proj.W, shpW, W);
        if (!bl.dt_proj.B.empty()) load_npy_float32(bl.dt_proj.B, shpB, B);
        if (!bl.dt_proj.WS.empty()) load_npy_float32(bl.dt_proj.WS, shpWS, WS); else WS.assign(shpW[0], 1.0f);
        int DF = (int)shpW[1]; // equals d_inner
        // state s and output ssm
        std::vector<float> s(bb.d_inner, 0.0f); std::vector<float> ssm(T*bb.d_inner);
        // pre-quantize W
        std::vector<int8_t> Wq(W.size()); for (int o=0;o<bb.d_inner;++o){ double invs=1.0/(double)WS[o]; for (int i=0;i<DF;++i){ double v=(double)W[o*DF+i]*invs; int64_t q=rnd_ties_to_even(v); q=std::min<int64_t>(127,std::max<int64_t>(-128,q)); Wq[o*DF+i]=(int8_t)q; }}
        for (int t=0;t<T;++t){
            // dt_proj(u_t)
            std::vector<int8_t> uq(DF);
            for (int i=0;i<DF;++i) uq[i]=quant_per_tensor_asym(u[t*DF + i], bl.dt_proj.a_scale, bl.dt_proj.a_zp, 0, 255);
            std::vector<float> dt(bb.d_inner, 0.0f);
            for (int o=0;o<bb.d_inner;++o){ int32_t acc=0; for (int i=0;i<DF;++i) acc += (int32_t)Wq[o*DF+i]*(int32_t)uq[i]; double vf=(double)acc * (bl.dt_proj.a_scale * (double)WS[o]); if (!B.empty()) vf += (double)B[o]; dt[o]=(float)vf; }
            // lam = sigmoid(dt)
            for (int j=0;j<bb.d_inner;++j){ float lam = lut.sigmoid(dt[j]); s[j] = lam*s[j] + (1.0f - lam)*u[t*DF + j]; ssm[t*DF + j] = s[j]; }
        }
        // gating
        if (true){ // use gate unless gate_off in meta; pack currently sets gate_off at meta
            for (int i=0;i<(int)z.size();++i){ z[i] = lut.silu_fn(z[i]); ssm[i] = ssm[i] * z[i]; }
        }
        // out_proj
        std::vector<float> y(T*bb.d_model);
        for (int t=0;t<T;++t){ std::vector<float> svec(bb.d_inner); for (int j=0;j<bb.d_inner;++j) svec[j]=ssm[t*bb.d_inner + j]; std::vector<float> yy; linear_q_forward(bl.out_proj, svec, yy); for (int j=0;j<bb.d_model;++j) y[t*bb.d_model + j]=yy[j]; }
        // residual: maintain legacy behavior 2x + y
        for (int t=0;t<T;++t){ for (int j=0;j<bb.d_model;++j){ y_dmodel[t*bb.d_model + j] = y_dmodel[t*bb.d_model + j]*2.0f + y[t*bb.d_model + j]; } }
    }
    // final norm
    for (int t=0;t<T;++t){ std::vector<float> vt(bb.d_model); for (int j=0;j<bb.d_model;++j) vt[j]=y_dmodel[t*bb.d_model + j]; rmsnorm_inplace(vt, bb.final_norm_weight); for (int j=0;j<bb.d_model;++j) y_dmodel[t*bb.d_model + j]=vt[j]; }
    // output heads inside backbone
    std::vector<float> feat; // (C*forecast_len) flattened
    if (bb.agg_pool == "avg"){ // pool then out_pool
        std::vector<float> agg(bb.d_model, 0.0f); for (int t=0;t<T;++t){ for (int j=0;j<bb.d_model;++j) agg[j]+=y_dmodel[t*bb.d_model+j]; } for (int j=0;j<bb.d_model;++j) agg[j]/=T; linear_q_forward(bb.out_pool, agg, feat);
    } else if (bb.agg_pool == "max"){
        std::vector<float> agg(bb.d_model, -1e30f); for (int t=0;t<T;++t){ for (int j=0;j<bb.d_model;++j) agg[j]=std::max(agg[j], y_dmodel[t*bb.d_model+j]); } linear_q_forward(bb.out_pool, agg, feat);
    } else {
        // flatten then out_flat
        std::vector<float> flat(T*bb.d_model); for (int t=0;t<T;++t){ for (int j=0;j<bb.d_model;++j) flat[t*bb.d_model + j] = y_dmodel[t*bb.d_model + j]; } linear_q_forward(bb.out_flat, flat, feat);
    }
    // reshape to (C, forecast_len==1)
    // final head
    LayerDesc headL{}; if (!GetLayer(ir, std::string("head"), headL)) return false;
    // prepare head in vector (C)
    std::vector<float> xin = feat; // expect len == C
    std::vector<int64_t> shpW, shpB, shpWS; std::vector<float> Wh, Bh, WSh; load_npy_float32(headL.W_path, shpW, Wh); if (!headL.B_path.empty()) load_npy_float32(headL.B_path, shpB, Bh); if (!headL.w_scale_path.empty()) load_npy_float32(headL.w_scale_path, shpWS, WSh); else WSh.assign(shpW[0], 1.0f);
    int out_f2=(int)shpW[0], in_f2=(int)shpW[1]; std::vector<int8_t> xq(in_f2);
    for (int i=0;i<in_f2;++i) xq[i]=quant_per_tensor_asym(xin[i], headL.act_scale, headL.act_zp, 0, 255);
    std::vector<int8_t> Wq2(Wh.size()); for (int o=0;o<out_f2;++o){ double invs=1.0/(double)WSh[o]; for(int i=0;i<in_f2;++i){ double v=(double)Wh[o*in_f2+i]*invs; int64_t q=rnd_ties_to_even(v); q=std::min<int64_t>(127,std::max<int64_t>(-128,q)); Wq2[o*in_f2+i]=(int8_t)q; }}
    y_out.assign(out_f2, 0.0f); for (int o=0;o<out_f2;++o){ int32_t acc=0; for (int i=0;i<in_f2;++i) acc += (int32_t)Wq2[o*in_f2+i]*(int32_t)xq[i]; double yf=(double)acc*(headL.act_scale*(double)WSh[o]); if (!Bh.empty()) yf += (double)Bh[o]; y_out[o]=(float)yf; }
    return true;
}
