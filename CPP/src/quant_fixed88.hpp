// quant_fixed88.hpp — Fixed-point Q8.8 helpers for FPGA‑friendly inference
#pragma once
#include <cstdint>
#include <cmath>
#include <algorithm>

// Round to nearest, ties to even (IEEE-754 default for nearbyint)
inline int64_t rnd_ties_to_even(double v) {
    return static_cast<int64_t>(std::nearbyint(v));
}

template<typename T>
inline T sat(T x, T lo, T hi) {
    return std::min(std::max(x, lo), hi);
}

// Float <-> Q8.8 int16
inline int16_t q88_from_float(float x) {
    const double s = 256.0; // 2^8
    int64_t q = rnd_ties_to_even(static_cast<double>(x) * s);
    q = sat<int64_t>(q, -32768, 32767);
    return static_cast<int16_t>(q);
}

inline float float_from_q88(int16_t q) {
    return static_cast<float>(static_cast<int32_t>(q)) / 256.0f;
}

// Multiply-accumulate in Q8.8: (a*b) accumulates in int32 with 16 fractional bits,
// then convert back to Q8.8 by >> 8 with rounding-to-nearest-even and saturation.
inline int16_t q88_from_acc32_round8(int32_t acc) {
    // Round-to-nearest-even at bit 8
    // Build unbiased rounding: add 0.5 ulp with tie-even logic
    // For right shift by 8, the guard bit is bit7; we emulate ties-to-even by checking remainder.
    int32_t base = acc >> 8; // truncation
    int32_t rem  = acc & 0xFF; // remainder [0..255] for non-negative acc; for negatives we handle symmetrically
    // Normalize remainder for negative values
    if (acc < 0) {
        // Make remainder the distance to the next lower multiple of 256 in magnitude
        rem = ((-acc) & 0xFF);
        // If exact tie (rem==128), even rule applies to base which is already floor toward -inf.
        // Compute candidate rounding increment with tie-to-even.
        bool tie = (rem == 128);
        int32_t incr = (rem > 128) ? -1 : (tie && (base & 1)) ? -1 : 0;
        int32_t y = base + incr;
        return static_cast<int16_t>(sat<int32_t>(y, -32768, 32767));
    } else {
        bool tie = (rem == 128);
        int32_t incr = (rem > 128) ? 1 : (tie && (base & 1)) ? 1 : 0;
        int32_t y = base + incr;
        return static_cast<int16_t>(sat<int32_t>(y, -32768, 32767));
    }
}

// Saturating add in Q8.8 domain
inline int16_t q88_add(int16_t a, int16_t b) {
    int32_t s = static_cast<int32_t>(a) + static_cast<int32_t>(b);
    return static_cast<int16_t>(sat<int32_t>(s, -32768, 32767));
}

// Saturating multiply in Q8.8 domain with rounding shift by 8
inline int16_t q88_mul(int16_t a, int16_t b) {
    int32_t p = static_cast<int32_t>(a) * static_cast<int32_t>(b); // Q16.16
    return q88_from_acc32_round8(p);
}

