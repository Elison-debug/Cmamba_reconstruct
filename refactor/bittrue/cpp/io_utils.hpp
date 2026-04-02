// io_utils.hpp - minimal JSON and NPY readers (restricted, schema-specific)
#pragma once
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <cstdint>
#include <stdexcept>
#include <algorithm>

inline std::string read_file_text(const std::string& path) {
    std::ifstream ifs(path, std::ios::binary);
    if (!ifs) throw std::runtime_error("Failed to open: " + path);
    std::ostringstream ss; ss << ifs.rdbuf();
    return ss.str();
}

// Minimal NPY loader for little-endian C-order float32 arrays (1D/2D)
inline void load_npy_float32(const std::string& path, std::vector<int64_t>& shape, std::vector<float>& data) {
    std::ifstream f(path, std::ios::binary);
    if (!f) throw std::runtime_error("Cannot open npy: " + path);
    // Magic
    char magic[6]; f.read(magic, 6);
    if (std::string(magic, 6) != "\x93NUMPY") throw std::runtime_error("Invalid NPY magic");
    char ver[2]; f.read(ver, 2);
    uint16_t header_len = 0; f.read(reinterpret_cast<char*>(&header_len), 2);
    std::string header(header_len, '\0'); f.read(&header[0], header_len);
    // parse dtype
    auto descr_pos = header.find("'descr': '");
    auto descr_end = header.find("'", descr_pos + 10);
    auto descr = header.substr(descr_pos + 10, descr_end - (descr_pos + 10));
    if (descr != "<f4" && descr != "|f4" && descr != "<f4 ") throw std::runtime_error("Only float32 supported: " + descr);
    auto fortran_pos = header.find("'fortran_order': ");
    bool fortran = header.substr(fortran_pos + 17, 5) == "True";
    if (fortran) throw std::runtime_error("Fortran-order npy not supported");
    auto shape_pos = header.find("'shape': (");
    auto shape_end = header.find(")", shape_pos);
    auto shape_str = header.substr(shape_pos + 10, shape_end - (shape_pos + 10));
    shape.clear();
    std::stringstream ss(shape_str);
    while (ss.good()) { long long d; char c; if (!(ss >> d)) break; shape.push_back(d); ss >> c; }
    // size
    int64_t count = 1; for (auto d: shape) count *= d; if (shape.empty()) count = 0;
    data.resize(static_cast<size_t>(count));
    f.read(reinterpret_cast<char*>(data.data()), static_cast<std::streamsize>(count * sizeof(float)));
}
