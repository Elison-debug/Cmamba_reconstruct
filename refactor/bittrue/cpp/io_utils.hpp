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

// Minimal NPY loader for little-endian C-order float32 arrays
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

inline void save_npy_float32(const std::string& path, const std::vector<int64_t>& shape, const std::vector<float>& data) {
    int64_t count = 1;
    for (auto d : shape) count *= d;
    if (count != static_cast<int64_t>(data.size())) {
        throw std::runtime_error("save_npy_float32: shape/data size mismatch");
    }

    std::ostringstream ss;
    ss << "{'descr': '<f4', 'fortran_order': False, 'shape': (";
    for (size_t i = 0; i < shape.size(); ++i) {
        ss << shape[i];
        if (shape.size() == 1) ss << ",";
        else if (i + 1 < shape.size()) ss << ", ";
    }
    ss << "), }";
    std::string header = ss.str();
    const size_t preamble = 10;  // magic(6) + version(2) + header_len(2)
    while ((preamble + header.size() + 1) % 16 != 0) header.push_back(' ');
    header.push_back('\n');
    const uint16_t header_len = static_cast<uint16_t>(header.size());

    std::ofstream f(path, std::ios::binary);
    if (!f) throw std::runtime_error("Cannot write npy: " + path);
    const char magic[] = "\x93NUMPY";
    f.write(magic, 6);
    const char ver[2] = {1, 0};
    f.write(ver, 2);
    f.write(reinterpret_cast<const char*>(&header_len), 2);
    f.write(header.data(), static_cast<std::streamsize>(header.size()));
    f.write(reinterpret_cast<const char*>(data.data()), static_cast<std::streamsize>(data.size() * sizeof(float)));
}
