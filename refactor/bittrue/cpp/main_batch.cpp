// main_batch.cpp - batch forward for exported bittrue runtime
#include "ref_infer.hpp"
#include "io_utils.hpp"

#include <chrono>
#include <iostream>
#include <string>
#include <vector>

static void usage() {
    std::cerr << "Usage: main_batch <export.json> <x_nkdin.npy> <out.npy> <Din> "
                 "[--mode fake|int8|int16] [--overrides role=mode,...] [--verbose]\n";
}

int main(int argc, char** argv) {
    if (argc < 5) {
        usage();
        return 1;
    }

    std::string exp = argv[1];
    std::string x_path = argv[2];
    std::string out_path = argv[3];
    int Din = std::stoi(argv[4]);

    RuntimeOptions opts;
    for (int i = 5; i < argc; ++i) {
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

    std::vector<int64_t> shp;
    std::vector<float> x_all;
    load_npy_float32(x_path, shp, x_all);
    if (shp.size() != 3) {
        std::cerr << "Expected input shape (N,K,Din), got rank " << shp.size() << "\n";
        return 2;
    }
    const int64_t N = shp[0];
    const int64_t K = shp[1];
    const int64_t D = shp[2];
    if (D != Din) {
        std::cerr << "Din mismatch: arg=" << Din << " npy=" << D << "\n";
        return 2;
    }

    std::vector<float> y_all;
    y_all.resize(static_cast<size_t>(N) * 2u, 0.0f);

    const int64_t stride = K * D;
    auto t0 = std::chrono::steady_clock::now();
    int64_t next_report = 1;
    if (N >= 20) next_report = std::max<int64_t>(1, N / 20);

    for (int64_t n = 0; n < N; ++n) {
        std::vector<float> x_one(
            x_all.begin() + static_cast<std::ptrdiff_t>(n * stride),
            x_all.begin() + static_cast<std::ptrdiff_t>((n + 1) * stride));
        std::vector<float> y_one;
        if (!ForwardFull(exp, x_one, Din, opts, y_one)) {
            std::cerr << "ForwardFull failed at sample " << n << "\n";
            return 3;
        }
        if (y_one.size() < 2) {
            std::cerr << "Unexpected output size at sample " << n << ": " << y_one.size() << "\n";
            return 3;
        }
        y_all[static_cast<size_t>(n) * 2u + 0u] = y_one[0];
        y_all[static_cast<size_t>(n) * 2u + 1u] = y_one[1];

        const int64_t done = n + 1;
        if (done == N || done % next_report == 0) {
            auto now = std::chrono::steady_clock::now();
            const double elapsed = std::chrono::duration<double>(now - t0).count();
            const double per_sample = elapsed / static_cast<double>(done);
            const double eta = per_sample * static_cast<double>(N - done);
            std::cerr << "[batch] " << done << "/" << N
                      << " (" << static_cast<int>(100.0 * done / std::max<int64_t>(1, N)) << "%)"
                      << " elapsed=" << elapsed << "s"
                      << " eta=" << eta << "s\n";
        }
    }

    save_npy_float32(out_path, {N, 2}, y_all);
    std::cout << "saved " << out_path << " shape=(" << N << ",2)\n";
    return 0;
}
