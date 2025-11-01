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

// Very naive JSON fetcher for: layers array entries with name==... and fields W, B, act_scale, act_zp, w_scale
inline bool json_find_layer_entry(const std::string& json, const std::string& layer_name,
                                 std::string& W, std::string& B, double& act_scale, int& act_zp, std::string& w_scale) {
    auto pos = json.find("\"name\"\s*:\s*\"" + layer_name + "\"");
    if (pos == std::string::npos) return false;
    auto sect_end = json.find("}\n", pos);
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
    auto get_num = [&](const char* key, double& out)->bool{
        auto kpos = sect.find(std::string("\"") + key + "\"");
        if (kpos == std::string::npos) return false;
        auto vpos = sect.find(':', kpos);
        if (vpos == std::string::npos) return false;
        auto vend = sect.find_first_of(",}\n", vpos+1);
        auto s = sect.substr(vpos+1, vend - (vpos+1));
        try { out = std::stod(s); } catch(...) { return false; }
        return true;
    };
    std::string Ws, Bs, Wscale;
    double As = 1.0, Az = 0.0;
    if (!get_str("W", Ws)) return false;
    get_str("B", Bs);
    get_str("w_scale", Wscale);
    get_num("act_scale", As);
    double tmp = 0.0; get_num("act_zp", tmp); Az = tmp;
    W = Ws; B = Bs; w_scale = Wscale; act_scale = As; act_zp = static_cast<int>(Az);
    return true;
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
    auto shape_str = header.substr(shape_pos + 9, shape_end - (shape_pos + 9));
    shape.clear();
    std::stringstream ss(shape_str);
    while (ss.good()) { long long d; char c; if (!(ss >> d)) break; shape.push_back(d); ss >> c; }
    // size
    int64_t count = 1; for (auto d: shape) count *= d; if (shape.empty()) count = 0;
    data.resize(static_cast<size_t>(count));
    f.read(reinterpret_cast<char*>(data.data()), static_cast<std::streamsize>(count * sizeof(float)));
}

