// quant_cpu.cpp  --  PyTorch C++ extension (CPU)
// Refactored to share INT8/INT16 logic via small templated kernels.
#include <torch/extension.h>
#include <cmath>
#include <cstdint>
#include <limits>
#include <vector>

inline int64_t rnd_nearest_even(double v) {
    double r = std::nearbyint(v);
    return static_cast<int64_t>(r);
}

template<typename T>
inline T sat(T x, T lo, T hi) {
    return x < lo ? lo : (x > hi ? hi : x);
}

template<typename QI>
torch::Tensor quantize_per_tensor_asym_T(torch::Tensor x, double scale, int64_t zp, int64_t qmin, int64_t qmax) {
    TORCH_CHECK(x.is_contiguous(), "x must be contiguous");
    auto x_f = x.contiguous().to(torch::kFloat32);
    auto out = torch::empty(x_f.sizes(), torch::CppTypeToScalarType<QI>::value);
    auto N = x_f.numel();
    const float* xp = x_f.data_ptr<float>();
    QI* op = out.data_ptr<QI>();
    const double s_inv = 1.0 / scale;
    for (int64_t i = 0; i < N; ++i) {
        double v = static_cast<double>(xp[i]) * s_inv + static_cast<double>(zp);
        int64_t qi = rnd_nearest_even(v);
        qi = sat<int64_t>(qi, qmin, qmax);
        op[i] = static_cast<QI>(qi);
    }
    return out;
}

template<typename QI>
torch::Tensor dequantize_per_tensor_asym_T(torch::Tensor xq, double scale, int64_t zp) {
    TORCH_CHECK(xq.is_contiguous(), "xq must be contiguous");
    auto x_i = xq.contiguous().to(torch::CppTypeToScalarType<QI>::value);
    auto out = torch::empty(x_i.sizes(), torch::kFloat32);
    const QI* ip = x_i.data_ptr<QI>();
    float* op = out.data_ptr<float>();
    auto N = x_i.numel();
    for (int64_t i = 0; i < N; ++i) {
        int32_t qi = static_cast<int32_t>(ip[i]);
        op[i] = static_cast<float>((qi - zp) * scale);
    }
    return out;
}

template<typename QI>
torch::Tensor quantize_per_channel_sym_T(torch::Tensor w, torch::Tensor scale, int64_t ch_axis, int64_t qmin, int64_t qmax) {
    TORCH_CHECK(w.is_contiguous(), "w must be contiguous");
    TORCH_CHECK(scale.dim() == 1, "scale must be 1D (per-channel)");
    TORCH_CHECK(ch_axis >= 0 && ch_axis < w.dim(), "ch_axis out of range");
    TORCH_CHECK(scale.size(0) == w.size(ch_axis), "scale length mismatch with channel size");

    auto w_f = w.contiguous().to(torch::kFloat32);
    auto out = torch::empty(w_f.sizes(), torch::CppTypeToScalarType<QI>::value);

    const float* wp = w_f.data_ptr<float>();
    QI* op = out.data_ptr<QI>();

    auto sizes = w_f.sizes();
    std::vector<int64_t> shape(w_f.dim(), 0);
    for (int i = 0; i < w_f.dim(); ++i) {
        shape[i]  = sizes[i];
    }

    auto sp = scale.to(torch::kFloat64).contiguous().data_ptr<double>();
    int64_t total = w_f.numel();
    int64_t nd = w_f.dim();
    std::vector<int64_t> idx(nd, 0);

    for (int64_t linear = 0; linear < total; ++linear) {
        int64_t tmp = linear;
        for (int d = nd - 1; d >= 0; --d) {
            idx[d] = tmp % shape[d];
            tmp   /= shape[d];
        }
        int64_t c = idx[ch_axis];
        double s_inv = 1.0 / sp[c];
        double v = static_cast<double>(wp[linear]) * s_inv;
        int64_t qi = rnd_nearest_even(v);
        qi = sat<int64_t>(qi, qmin, qmax);
        op[linear] = static_cast<QI>(qi);
    }
    return out;
}

// Non-templated wrappers exposed to Python
torch::Tensor quantize_per_tensor_asym(torch::Tensor x, double scale, int64_t zp, int64_t qmin, int64_t qmax) {
    return quantize_per_tensor_asym_T<int8_t>(x, scale, zp, qmin, qmax);
}
torch::Tensor dequantize_per_tensor_asym(torch::Tensor xq, double scale, int64_t zp) {
    return dequantize_per_tensor_asym_T<int8_t>(xq, scale, zp);
}
torch::Tensor quantize_per_channel_sym(torch::Tensor w, torch::Tensor scale, int64_t ch_axis, int64_t qmin, int64_t qmax) {
    return quantize_per_channel_sym_T<int8_t>(w, scale, ch_axis, qmin, qmax);
}

torch::Tensor quantize_per_tensor_asym16(torch::Tensor x, double scale, int64_t zp, int64_t qmin, int64_t qmax) {
    return quantize_per_tensor_asym_T<int16_t>(x, scale, zp, qmin, qmax);
}
torch::Tensor dequantize_per_tensor_asym16(torch::Tensor xq, double scale, int64_t zp) {
    return dequantize_per_tensor_asym_T<int16_t>(xq, scale, zp);
}
torch::Tensor quantize_per_channel_sym16(torch::Tensor w, torch::Tensor scale, int64_t ch_axis, int64_t qmin, int64_t qmax) {
    return quantize_per_channel_sym_T<int16_t>(w, scale, ch_axis, qmin, qmax);
}

PYBIND11_MODULE(TORCH_EXTENSION_NAME, m) {
    // INT8
    m.def("quant_per_tensor_asym", &quantize_per_tensor_asym, "INT8 per-tensor asymmetric quant (CPU)");
    m.def("dequant_per_tensor_asym", &dequantize_per_tensor_asym, "dequant (CPU)");
    m.def("quant_per_channel_sym",  &quantize_per_channel_sym,  "INT8 per-channel symmetric quant (CPU)");
    // INT16
    m.def("quant_per_tensor_asym16", &quantize_per_tensor_asym16, "INT16 per-tensor asymmetric quant (CPU)");
    m.def("dequant_per_tensor_asym16", &dequantize_per_tensor_asym16, "INT16 dequant (CPU)");
    m.def("quant_per_channel_sym16",  &quantize_per_channel_sym16,  "INT16 per-channel symmetric quant (CPU)");
}
