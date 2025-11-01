// main_compare.cpp - Quantized Linear layer compare tool
#include "ref_infer.hpp"
#include "io_utils.hpp"
#include "reference_quant_int8.hpp"
#include <iostream>
#include <vector>
#include <string>
#include <cmath>

static void usage() {
    std::cerr << "Usage: main_compare <export.json> <layer_name> <x_in.npy> [y_ref.npy]\n";
    std::cerr << "  layer_name: 'proj' or 'head' (or any linear layer listed)\n";
}

int main(int argc, char** argv) {
    if (argc < 4) { usage(); return 1; }
    std::string json_path = argv[1];
    std::string layer_name = argv[2];
    std::string x_path = argv[3];
    std::string yref_path = (argc >= 5 ? argv[4] : "");

    ModelIR ir{};
    if (!LoadExport(json_path, ir)) {
        std::cerr << "Failed to load export: " << json_path << "\n";
        return 2;
    }
    LayerDesc L{};
    if (!GetLayer(ir, layer_name, L)) {
        std::cerr << "Layer not found: " << layer_name << "\n";
        return 3;
    }
    if (L.type != "linear") {
        std::cerr << "Only linear layers are supported in this tool." << "\n";
        return 4;
    }
    // Load weights/scales
    std::vector<int64_t> shpW, shpB, shpWS; std::vector<float> W, B, WS;
    load_npy_float32(L.W_path, shpW, W);
    if (!L.B_path.empty()) load_npy_float32(L.B_path, shpB, B);
    if (!L.w_scale_path.empty()) load_npy_float32(L.w_scale_path, shpWS, WS); else { WS.assign(shpW[0], 1.0f); }
    int out_f = static_cast<int>(shpW[0]); int in_f = static_cast<int>(shpW[1]);

    // Load input vector (flatten any shape)
    std::vector<int64_t> shx; std::vector<float> x;
    load_npy_float32(x_path, shx, x);
    int64_t n_in = static_cast<int64_t>(x.size());
    if (n_in != in_f) {
        std::cerr << "Input length mismatch. Expected " << in_f << ", got " << n_in << "\n";
        return 5;
    }

    // Quantize activation per-tensor asym
    std::vector<int8_t> x_q(in_f);
    for (int i = 0; i < in_f; ++i) x_q[i] = quant_per_tensor_asym(x[i], L.act_scale, L.act_zp, 0, 255);
    // Quantize weights per-channel symmetric using WS
    std::vector<int8_t> Wq(W.size());
    for (int o = 0; o < out_f; ++o) {
        double invs = 1.0 / (double)WS[o];
        for (int i = 0; i < in_f; ++i) {
            double v = (double)W[o*in_f + i] * invs;
            int64_t q = rnd_ties_to_even(v);
            q = std::min<int64_t>(127, std::max<int64_t>(-128, q));
            Wq[o*in_f + i] = static_cast<int8_t>(q);
        }
    }

    // GEMV and dequant
    std::vector<float> y(out_f, 0.0f);
    for (int o = 0; o < out_f; ++o) {
        int32_t acc = 0;
        for (int i = 0; i < in_f; ++i) acc += (int32_t)Wq[o*in_f + i] * (int32_t)x_q[i];
        double yy = (double)acc * (L.act_scale * (double)WS[o]);
        if (!B.empty()) yy += (double)B[o];
        y[o] = static_cast<float>(yy);
    }

    // Optionally compare with reference
    if (!yref_path.empty()) {
        std::vector<int64_t> shy; std::vector<float> yref;
        load_npy_float32(yref_path, shy, yref);
        if ((int)yref.size() != out_f) {
            std::cerr << "Ref length mismatch. Expected " << out_f << ", got " << yref.size() << "\n";
        } else {
            double mae=0.0, mse=0.0, mxa=0.0;
            for (int o=0;o<out_f;++o){
                double d = (double)y[o] - (double)yref[o];
                mae += std::fabs(d);
                mse += d*d;
                mxa = std::max(mxa, std::fabs(d));
            }
            mae /= out_f; mse /= out_f;
            std::cout << "compare: mae=" << mae << ", mse=" << mse << ", max_abs=" << mxa << "\n";
        }
    }

    // Print first few outputs as sample
    std::cout << "y[0:8]=";
    for (int i=0;i<std::min(8,out_f);++i) std::cout << (i?", ":"") << y[i];
    std::cout << "\n";
    return 0;
}

