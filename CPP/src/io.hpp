// io.hpp — minimal JSON/NPY utilities matching refactor/export layout
#pragma once
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <cstdint>
#include <stdexcept>
#include <algorithm>
#include <limits>

inline std::string read_file_text(const std::string& path) {
    std::ifstream ifs(path, std::ios::binary);
    if (!ifs) throw std::runtime_error("Failed to open: " + path);
    std::ostringstream ss; ss << ifs.rdbuf();
    return ss.str();
}

inline std::string join_path(const std::string& a, const std::string& b) {
    if (a.empty()) return b; if (b.empty()) return a;
    if (a.back()=='/' || a.back()=='\\') return a + b;
    return a + "/" + b;
}

// Very limited JSON parsing helpers (schema-specific)
inline bool json_get_str(const std::string& text, const char* key, std::string& out){
    auto p = text.find(std::string("\"") + key + "\""); if (p==std::string::npos) return false;
    auto v = text.find('"', text.find(':', p)+1); if (v==std::string::npos) return false;
    auto e = text.find('"', v+1); if (e==std::string::npos) return false;
    out = text.substr(v+1, e-(v+1)); return true;
}

inline bool json_get_int(const std::string& text, const char* key, int& out){
    auto p = text.find(std::string("\"") + key + "\""); if (p==std::string::npos) return false;
    auto v = text.find(':', p); auto e = text.find_first_of(",}\n", v+1);
    try { out = std::stoi(text.substr(v+1, e-(v+1))); } catch(...) { return false; }
    return true;
}

// Find layer entry in export.json
inline bool json_find_layer_entry(const std::string& json, const std::string& layer_name,
                                 std::string& W, std::string& B) {
    // Scan for entries with key "name": "..." and match layer_name
    size_t pos = json.find("\"name\"");
    while (pos != std::string::npos) {
        size_t colon = json.find(':', pos);
        if (colon == std::string::npos) return false;
        size_t q1 = json.find('"', colon + 1); if (q1 == std::string::npos) return false;
        size_t q2 = json.find('"', q1 + 1);    if (q2 == std::string::npos) return false;
        auto lname = json.substr(q1 + 1, q2 - (q1 + 1));
        if (lname == layer_name) {
            // Take object slice until next closing brace
            size_t sect_end = json.find('}', q2);
            if (sect_end == std::string::npos) sect_end = json.size();
            auto sect = json.substr(pos, sect_end - pos);
            auto get_str = [&](const char* key, std::string& out)->bool{
                auto kpos = sect.find(std::string("\"") + key + "\"");
                if (kpos == std::string::npos) return false;
                auto vpos = sect.find('"', sect.find(':', kpos)+1);
                if (vpos == std::string::npos) return false;
                auto vend = sect.find('"', vpos+1);
                if (vend == std::string::npos) return false;
                out = sect.substr(vpos+1, vend - (vpos+1));
                return true;
            };
            std::string Ws, Bs;
            if (!get_str("W", Ws)) return false;
            get_str("B", Bs);
            W = Ws; B = Bs;
            return true;
        }
        pos = json.find("\"name\"", q2 + 1);
    }
    return false;
}

// Minimal NPY loader for little-endian C-order float32 arrays (1D/2D/3D)
inline void load_npy_float32(const std::string& path, std::vector<int64_t>& shape, std::vector<float>& data) {
    std::ifstream f(path, std::ios::binary);
    if (!f) throw std::runtime_error("Cannot open npy: " + path);
    char magic[6]; f.read(magic, 6);
    if (std::string(magic, 6) != "\x93NUMPY") throw std::runtime_error("Invalid NPY magic");
    unsigned char ver[2]; f.read(reinterpret_cast<char*>(ver), 2);
    uint32_t header_len32 = 0; uint16_t header_len16 = 0; size_t header_len = 0;
    if (ver[0] == 1) {
        f.read(reinterpret_cast<char*>(&header_len16), 2);
        header_len = header_len16;
    } else if (ver[0] >= 2) {
        // v2.0+ uses 4‑byte little‑endian header length
        f.read(reinterpret_cast<char*>(&header_len32), 4);
        header_len = header_len32;
    } else {
        throw std::runtime_error("Unsupported NPY version");
    }
    std::string header(header_len, '\0'); f.read(&header[0], (std::streamsize)header_len);
    auto get_key_string = [&](const std::string& key)->std::string{
        size_t kpos = header.find("'" + key + "'");
        if (kpos == std::string::npos) kpos = header.find("\"" + key + "\"");
        if (kpos == std::string::npos) return std::string();
        size_t colon = header.find(':', kpos);
        if (colon == std::string::npos) return std::string();
        // find opening quote for value
        size_t vq = header.find_first_of("'\"", colon + 1);
        if (vq == std::string::npos) return std::string();
        char q = header[vq];
        size_t vend = header.find(q, vq + 1);
        if (vend == std::string::npos) return std::string();
        return header.substr(vq + 1, vend - (vq + 1));
    };
    auto descr = get_key_string("descr");
    // fortran_order
    bool fortran = false;
    {
        size_t kpos = header.find("'fortran_order'");
        if (kpos == std::string::npos) kpos = header.find("\"fortran_order\"");
        if (kpos != std::string::npos) {
            size_t colon = header.find(':', kpos);
            if (colon != std::string::npos) {
                std::string rest = header.substr(colon + 1, 8);
                if (rest.find("True") != std::string::npos) fortran = true;
            }
        }
    }
    if (fortran) throw std::runtime_error("Fortran-order npy not supported");
    // Parse shape robustly: locate key, then scan between '(' and ')' for integers
    shape.clear();
    size_t sp = header.find("'shape'"); if (sp == std::string::npos) sp = header.find("\"shape\"");
    if (sp != std::string::npos) {
        size_t lp = header.find('(', sp);
        size_t rp = (lp == std::string::npos) ? std::string::npos : header.find(')', lp + 1);
        if (lp != std::string::npos && rp != std::string::npos && rp > lp + 1) {
            std::string s = header.substr(lp + 1, rp - lp - 1);
            long long acc = 0; bool in = false; bool neg = false; bool any = false;
            for (char c : s) {
                if (c == '-' && !in) { neg = true; in = true; acc = 0; }
                else if (c >= '0' && c <= '9') { acc = acc * 10 + (c - '0'); in = true; }
                else {
                    if (in) { shape.push_back(neg ? -acc : acc); any = true; }
                    acc = 0; in = false; neg = false;
                }
            }
            if (in) { shape.push_back(neg ? -acc : acc); any = true; }
            (void)any;
        }
    }
    int64_t count = 1; for (auto d: shape) count *= d; if (shape.empty()) count = 0;
    data.resize(static_cast<size_t>(count));
    // dtype handling: accept float32 and float16, convert half->float for output
    bool is_f4 = (descr.find("f4") != std::string::npos);
    bool is_f2 = (descr.find("f2") != std::string::npos);
    if (!(is_f4 || is_f2)) {
        throw std::runtime_error(std::string("Only float32/float16 supported: ") + descr);
    }
    // endianness
    char endian = descr.empty()? '<' : descr[0];
    auto need_swap = [&](void){ return endian == '>'; };
    if (is_f4) {
        // Read raw float32
        f.read(reinterpret_cast<char*>(data.data()), static_cast<std::streamsize>(count * sizeof(float)));
        if (need_swap()) {
            // swap bytes in-place (unlikely for our data)
            for (int64_t i=0;i<count;++i){
                uint8_t* p = reinterpret_cast<uint8_t*>(&data[(size_t)i]);
                std::swap(p[0], p[3]); std::swap(p[1], p[2]);
            }
        }
    } else { // f2
        std::vector<uint16_t> buf((size_t)count);
        f.read(reinterpret_cast<char*>(buf.data()), static_cast<std::streamsize>(count * sizeof(uint16_t)));
        auto half_to_float = [](uint16_t h)->float{
            uint32_t s = (h & 0x8000u) ? 0x80000000u : 0u;
            uint32_t e = (h >> 10) & 0x1Fu;
            uint32_t m = h & 0x03FFu;
            if (e == 0) {
                if (m == 0) {
                    uint32_t u = s; float out; std::memcpy(&out, &u, sizeof(out)); return out;
                } else {
                    // subnormal: (mant/1024) * 2^-14
                    float v = (float)m / 1024.0f;
                    v = std::ldexp(v, -14);
                    return s ? -v : v;
                }
            } else if (e == 31) {
                if (m == 0) {
                    return s ? -std::numeric_limits<float>::infinity() : std::numeric_limits<float>::infinity();
                } else {
                    return std::numeric_limits<float>::quiet_NaN();
                }
            } else {
                float v = 1.0f + ((float)m / 1024.0f);
                v = std::ldexp(v, (int)e - 15);
                return s ? -v : v;
            }
        };
        for (int64_t i=0;i<count;++i){
            uint16_t h = buf[(size_t)i];
            if (need_swap()) h = (uint16_t)((h >> 8) | (h << 8));
            data[(size_t)i] = half_to_float(h);
        }
    }
}
