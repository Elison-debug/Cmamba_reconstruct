// reference_quant_int8.hpp
#pragma once
#include <cstdint>
#include <cmath>
#include <algorithm>

inline int64_t rnd_ties_to_even(double v) {
    // C99 nearbyint honors current rounding mode; default is ties-to-even under IEEE-754
    return static_cast<int64_t>(std::nearbyint(v));
}

template<typename T>
inline T sat(T x, T lo, T hi) { return std::min(std::max(x, lo), hi); }

inline int8_t quant_per_tensor_asym(float x, double scale, int zp, int qmin, int qmax) {
    double xi = x / scale + static_cast<double>(zp);
    int64_t q = rnd_ties_to_even(xi);
    q = sat<int64_t>(q, qmin, qmax);
    return static_cast<int8_t>(q);
}

inline float dequant_per_tensor_asym(int8_t q, double scale, int zp) {
    return static_cast<float>((static_cast<int>(q) - zp) * scale);
}

