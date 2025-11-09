// int16_conv.cpp -- Integer-only Q8.8 1x1 Conv (CPU)
#include <torch/extension.h>
#include <cstdint>
#include <vector>

// Round-to-nearest-even after right shift by `shift` bits on signed 64-bit accumulator.
static inline int64_t rshift_rne_q88(int64_t acc, int shift) {
    if (shift <= 0) return acc; // no shift
    int64_t sgn = (acc < 0) ? -1 : 1;
    uint64_t mag = (acc < 0) ? static_cast<uint64_t>(-acc) : static_cast<uint64_t>(acc);
    uint64_t q = mag >> shift;
    uint64_t r = mag & ((UINT64_C(1) << shift) - 1);
    uint64_t half = UINT64_C(1) << (shift - 1);
    // nearest-even
    if (r > half) {
        q += 1;
    } else if (r == half) {
        // tie: make result even
        if (q & 0x1ULL) q += 1;
    }
    int64_t res = static_cast<int64_t>(q);
    return sgn < 0 ? -res : res;
}

static inline int16_t sat_int16(int64_t x) {
    if (x > 32767) return 32767;
    if (x < -32768) return -32768;
    return static_cast<int16_t>(x);
}

// x: (B, Cin, L) int16, w: (Cout, Cin, 1) int16, b: (Cout) int16 (Q8.8)
// Returns y: (B, Cout, L) int16 (Q8.8)
torch::Tensor conv1x1_q88(torch::Tensor x, torch::Tensor w, torch::Tensor b) {
    TORCH_CHECK(x.is_contiguous() && w.is_contiguous() && b.is_contiguous(), "inputs must be contiguous");
    TORCH_CHECK(x.scalar_type() == torch::kInt16 && w.scalar_type() == torch::kInt16 && b.scalar_type() == torch::kInt16,
                "x,w,b must be int16 tensors");
    TORCH_CHECK(x.dim() == 3 && w.dim() == 3 && b.dim() == 1, "dimensions: x[B,Cin,L], w[Cout,Cin,1], b[Cout]");
    int64_t B = x.size(0);
    int64_t Cin = x.size(1);
    int64_t L = x.size(2);
    int64_t Cout = w.size(0);
    TORCH_CHECK(w.size(1) == Cin && w.size(2) == 1, "w shape mismatch");
    TORCH_CHECK(b.size(0) == Cout, "bias shape mismatch");

    auto y = torch::empty({B, Cout, L}, torch::dtype(torch::kInt16).device(x.device()));
    const int16_t* xp = x.data_ptr<int16_t>();
    const int16_t* wp = w.data_ptr<int16_t>();
    const int16_t* bp = b.data_ptr<int16_t>();
    int16_t* yp = y.data_ptr<int16_t>();

    // strides
    int64_t xsB = Cin * L;
    int64_t xsC = L;
    int64_t wsCout = Cin; // w stride by Cout over Cin

    for (int64_t bidx = 0; bidx < B; ++bidx) {
        for (int64_t oc = 0; oc < Cout; ++oc) {
            for (int64_t t = 0; t < L; ++t) {
                int64_t acc = 0;
                const int16_t* xrow = xp + bidx * xsB + t; // channel stride = L
                const int16_t* wrow = wp + oc * wsCout;
                for (int64_t ic = 0; ic < Cin; ++ic) {
                    int16_t xv = xrow[ic * xsC];
                    int16_t wv = wrow[ic];
                    acc += static_cast<int32_t>(xv) * static_cast<int32_t>(wv);
                }
                // Convert acc(Q16.16) -> Q8.8 by right shift 8 with RNE
                int64_t y_q88 = rshift_rne_q88(acc, 8) + static_cast<int64_t>(bp[oc]);
                yp[bidx * (Cout * L) + oc * L + t] = sat_int16(y_q88);
            }
        }
    }
    return y;
}

PYBIND11_MODULE(TORCH_EXTENSION_NAME, m) {
    m.def("conv1x1_q88", &conv1x1_q88, "INT16 Q8.8 1x1 conv (CPU)");
    // General Conv1d Kx with stride, no padding: x[B,Cin,L], w[Cout,Cin,K], b[Cout]
    m.def("conv1d_k_q88", [](torch::Tensor x, torch::Tensor w, torch::Tensor b, int64_t stride){
        TORCH_CHECK(x.is_contiguous() && w.is_contiguous() && b.is_contiguous(), "inputs must be contiguous");
        TORCH_CHECK(x.scalar_type() == torch::kInt16 && w.scalar_type() == torch::kInt16 && b.scalar_type() == torch::kInt16,
                    "x,w,b must be int16 tensors");
        TORCH_CHECK(x.dim() == 3 && w.dim() == 3 && b.dim() == 1, "dimensions: x[B,Cin,L], w[Cout,Cin,K], b[Cout]");
        int64_t B = x.size(0);
        int64_t Cin = x.size(1);
        int64_t L = x.size(2);
        int64_t Cout = w.size(0);
        int64_t K = w.size(2);
        TORCH_CHECK(w.size(1) == Cin, "w shape mismatch");
        TORCH_CHECK(b.size(0) == Cout, "bias shape mismatch");
        TORCH_CHECK(stride > 0, "stride must be > 0");
        int64_t Lout = (L - K) / stride + 1;
        TORCH_CHECK(L >= K && (L - K) % stride == 0, "unsupported L/K/stride combination for now");

        auto y = torch::empty({B, Cout, Lout}, torch::dtype(torch::kInt16).device(x.device()));
        const int16_t* xp = x.data_ptr<int16_t>();
        const int16_t* wp = w.data_ptr<int16_t>();
        const int16_t* bp = b.data_ptr<int16_t>();
        int16_t* yp = y.data_ptr<int16_t>();

        int64_t xsB = Cin * L;
        int64_t xsC = L;
        int64_t wsCout = Cin * K;
        int64_t wsCin = K;

        for (int64_t bidx = 0; bidx < B; ++bidx) {
            for (int64_t oc = 0; oc < Cout; ++oc) {
                for (int64_t to = 0; to < Lout; ++to) {
                    int64_t t_in = to * stride;
                    int64_t acc = 0;
                    const int16_t* xbase = xp + bidx * xsB + t_in; // channel stride = L
                    const int16_t* wbase = wp + oc * wsCout;
                    for (int64_t ic = 0; ic < Cin; ++ic) {
                        const int16_t* xrow = xbase + ic * xsC;
                        const int16_t* wrow = wbase + ic * wsCin;
                        for (int64_t k = 0; k < K; ++k) {
                            acc += static_cast<int32_t>(xrow[k]) * static_cast<int32_t>(wrow[k]);
                        }
                    }
                    int64_t y_q88 = rshift_rne_q88(acc, 8) + static_cast<int64_t>(bp[oc]);
                    yp[bidx * (Cout * Lout) + oc * Lout + to] = sat_int16(y_q88);
                }
            }
        }
        return y;
    }, "INT16 Q8.8 Conv1d Kx (CPU)");
}
