// main_full.cpp - Full forward of exported CMambaSlim backbone + head
#include "ref_infer.hpp"
#include "io_utils.hpp"
#include <iostream>
#include <vector>
#include <string>

// ForwardFull is implemented in ref_infer.cpp
bool ForwardFull(const std::string& export_json, const std::vector<float>& xKD, int Din, std::vector<float>& y_out);
bool ForwardFull(const std::string& export_json, const std::vector<float>& xKD, int Din, const RuntimeOptions& opts, std::vector<float>& y_out);

static void usage(){
    std::cerr << "Usage: main_full <export.json> <x_kdin.npy> <Din> [--mode fake|int8|int16] [--overrides role=mode,...] [--verbose]\n";
    std::cerr << "Roles: proj, patch_embedding, in_proj, dw_conv, dt_proj, out_proj, output_flat, output_pool, head\n";
    std::cerr << "Use name:<layer_name>=mode for exact-layer overrides.\n";
}

int main(int argc, char** argv){
    if (argc < 4) { usage(); return 1; }
    std::string exp = argv[1]; std::string xpath = argv[2]; int Din = std::stoi(argv[3]);
    RuntimeOptions opts;
    for (int i = 4; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg == "--mode") {
            if (i + 1 >= argc) { usage(); return 1; }
            opts.default_mode = ParseExecMode(argv[++i]);
            continue;
        }
        if (arg == "--overrides") {
            if (i + 1 >= argc) { usage(); return 1; }
            std::string err;
            if (!ParseRuntimeOverrides(argv[++i], opts, err)) {
                std::cerr << err << "\n";
                return 1;
            }
            continue;
        }
        if (arg == "--verbose") {
            opts.verbose = true;
            continue;
        }
        std::cerr << "Unknown argument: " << arg << "\n";
        usage();
        return 1;
    }
    std::vector<int64_t> shp; std::vector<float> x; load_npy_float32(xpath, shp, x);
    std::vector<float> y;
    if (!ForwardFull(exp, x, Din, opts, y)) { std::cerr << "ForwardFull failed\n"; return 2; }
    std::cout << "y (len=" << y.size() << ") first 8: ";
    for (size_t i=0;i<y.size() && i<8;i++){ std::cout << (i?", ":"") << y[i]; }
    std::cout << "\n";
    return 0;
}
