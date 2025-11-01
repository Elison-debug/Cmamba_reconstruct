#include "ref_infer.hpp"
#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include "io_utils.hpp"

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "Usage: main_demo <export.json> <x_ck.npy>\n";
        return 1;
    }
    std::string json_path = argv[1];
    std::string x_path = argv[2];

    ModelIR ir{};
    if (!LoadExport(json_path, ir)) {
        std::cerr << "Failed to load export: " << json_path << "\n";
        return 2;
    }
    std::vector<int64_t> shp; std::vector<float> x;
    load_npy_float32(x_path, shp, x);
    if (shp.size()!=2) { std::cerr << "x_ck must be 2D (C,K)\n"; return 3; }
    std::vector<float> y(2, 0.0f);
    try {
        Forward(ir, x.data(), y.data());
    } catch (const std::exception& e) {
        std::cerr << "Forward error: " << e.what() << "\n";
        return 4;
    }
    std::cout << y[0] << "," << y[1] << "\n";
    return 0;
}

