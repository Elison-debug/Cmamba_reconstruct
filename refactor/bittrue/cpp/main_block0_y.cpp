#include "ref_infer.hpp"
#include "io_utils.hpp"

#include <iostream>
#include <string>
#include <vector>

int main(int argc, char** argv) {
    if (argc < 5) {
        std::cerr << "Usage: main_block0_y.exe <export.json> <samples.npy> <Din> <out.npy> [--mode fake|int8|int16] [--overrides spec]\n";
        return 1;
    }

    const std::string exp = argv[1];
    const std::string samples_npy = argv[2];
    const int Din = std::stoi(argv[3]);
    const std::string out_npy = argv[4];

    RuntimeOptions opts;
    for (int i = 5; i < argc; ++i) {
        std::string a = argv[i];
        if (a == "--mode" && i + 1 < argc) {
            opts.default_mode = ParseExecMode(argv[++i]);
        } else if (a == "--overrides" && i + 1 < argc) {
            std::string err;
            if (!ParseRuntimeOverrides(argv[++i], opts, err)) {
                std::cerr << "override parse error: " << err << "\n";
                return 2;
            }
        } else if (a == "--verbose") {
            opts.verbose = true;
        }
    }

    std::vector<int64_t> shape;
    std::vector<float> data;
    load_npy_float32(samples_npy, shape, data);
    if (shape.size() != 3) {
        std::cerr << "Expected samples.npy shape (N,K,D), got rank=" << shape.size() << "\n";
        return 2;
    }
    const int64_t N = shape[0];
    const int64_t K = shape[1];
    const int64_t D = shape[2];
    if (D != Din) {
        std::cerr << "Din mismatch: npy D=" << D << " cli Din=" << Din << "\n";
        return 2;
    }

    std::vector<float> out;
    out.reserve(static_cast<size_t>(N * 32 * 4));
    std::vector<float> x;
    x.resize(static_cast<size_t>(K * D));
    for (int64_t n = 0; n < N; ++n) {
        const float* src = data.data() + n * K * D;
        std::copy(src, src + K * D, x.begin());
        std::vector<float> y_block;
        if (!ForwardBlock0LocalY(exp, x, Din, opts, y_block)) {
            std::cerr << "ForwardBlock0LocalY failed at sample " << n << "\n";
            return 3;
        }
        out.insert(out.end(), y_block.begin(), y_block.end());
    }

    save_npy_float32(out_npy, {N, 32, 4}, out);
    std::cerr << "[block0_y] wrote " << out_npy << " shape=(" << N << ",32,4)\n";
    return 0;
}
