// main_full.cpp - Full forward of exported CMambaSlim backbone + head
#include "ref_infer.hpp"
#include "io_utils.hpp"
#include <iostream>
#include <vector>
#include <string>

// ForwardFull is implemented in ref_infer.cpp
bool ForwardFull(const std::string& export_json, const std::vector<float>& xKD, int Din, std::vector<float>& y_out);

static void usage(){
    std::cerr << "Usage: main_full <export.json> <x_kdin.npy> <Din>\n";
}

int main(int argc, char** argv){
    if (argc < 4) { usage(); return 1; }
    std::string exp = argv[1]; std::string xpath = argv[2]; int Din = std::stoi(argv[3]);
    std::vector<int64_t> shp; std::vector<float> x; load_npy_float32(xpath, shp, x);
    std::vector<float> y;
    if (!ForwardFull(exp, x, Din, y)) { std::cerr << "ForwardFull failed\n"; return 2; }
    std::cout << "y (len=" << y.size() << ") first 8: ";
    for (size_t i=0;i<y.size() && i<8;i++){ std::cout << (i?", ":"") << y[i]; }
    std::cout << "\n";
    return 0;
}

