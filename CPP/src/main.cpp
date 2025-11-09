#include "infer.hpp"
#include <iostream>
#include <vector>
#include <string>
#include <cstdlib>
#include <filesystem>
#include "io.hpp"

static bool ends_with(const std::string& s, const std::string& suf){
    if (s.size() < suf.size()) return false; return std::equal(suf.rbegin(), suf.rend(), s.rbegin());
}

int main(int argc, char** argv){
    if (argc < 3){
        std::cerr << "Usage: cmamba_demo <export.json> <x_kdin.npy | features_root> [Din]\n";
        return 2;
    }
    std::string exp = argv[1];
    std::string arg2 = argv[2];
    int Din_cli = argc >= 4 ? std::atoi(argv[3]) : 0;

    std::vector<float> xKD;
    int Din = 0;
    try {
    if (ends_with(arg2, ".npy")){
        std::vector<int64_t> shp; load_npy_float32(arg2, shp, xKD);
        Din = Din_cli; if (Din == 0){ if (shp.size() >= 2) Din = (int)shp.back(); else { std::cerr << "Din not provided and cannot infer from shape\n"; return 3; } }
    } else {
        // Treat arg2 as features root; find first json under <root>/json/*.json and load corresponding npy/<base>.feats.npy
        std::filesystem::path root(arg2);
        std::filesystem::path json_dir = root / "json";
        std::filesystem::path npy_dir = root / "npy";
        std::filesystem::path first_json;
        for (auto& p : std::filesystem::directory_iterator(json_dir)){
            if (p.is_regular_file()) {
                auto path = p.path().string();
                if (ends_with(path, ".json")) { first_json = p.path(); break; }
            }
        }
        if (first_json.empty()) { std::cerr << "No json found under " << json_dir.string() << "\n"; return 3; }
        std::string stem = first_json.stem().string();
        std::filesystem::path feats = npy_dir / (stem + ".feats.npy");
        std::vector<int64_t> shp; std::vector<float> data; load_npy_float32(feats.string(), shp, data);
        // Strict format from preprocess_logo.py: feats is (T, Din)
        if (shp.size() != 2) {
            std::cerr << "Invalid feats shape in " << feats.string() << ", expected 2D (T,Din), got rank=" << (int)shp.size() << "\n";
            return 3;
        }
        int T = (int)shp[0]; Din = (int)shp[1];
        // Read export meta for K
        ModelIR ir{}; if (!LoadExport(exp, ir)) { std::cerr << "Failed to parse export.json\n"; return 3; }
        int K = ir.seq_len;
        if (T < K) { std::cerr << "feats too short: T=" << T << " < K=" << K << "\n"; return 3; }
        // Read window end index list from json: prefer indices_eval > indices > indices_train
        std::string jtxt = read_file_text(first_json.string());
        auto find_list = [&](const char* key)->std::vector<int>{
            std::vector<int> vals; size_t p = jtxt.find(std::string("\"") + key + "\""); if (p==std::string::npos) return vals; size_t lb = jtxt.find('[', p); size_t rb = jtxt.find(']', lb); if (lb==std::string::npos || rb==std::string::npos) return vals; auto s = jtxt.substr(lb+1, rb-(lb+1)); int v=0; bool neg=false; bool in=false; for(char c: s){ if (c=='-'&&!in){ neg=true; in=true; v=0; } else if (c>='0'&&c<='9'){ v = v*10 + (c-'0'); in=true; } else { if (in){ vals.push_back(neg ? -v : v); } v=0; neg=false; in=false; } } if (in){ vals.push_back(neg ? -v : v); } return vals; };
        std::vector<int> idx = find_list("indices_eval"); if (idx.empty()) idx = find_list("indices"); if (idx.empty()) idx = find_list("indices_train");
        int e = (idx.empty() ? K : idx.front());
        if (e < K) e = K; if (e > T) e = T;
        // Build window [e-K, e)
        xKD.assign((size_t)K * Din, 0.0f);
        size_t off = (size_t)(e - K) * (size_t)Din;
        std::memcpy(xKD.data(), data.data() + off, sizeof(float) * (size_t)K * (size_t)Din);
    }
    }
    catch (const std::exception& e) {
        std::cerr << "Error loading features: " << e.what() << "\n"; return 5;
    }
    std::vector<float> y;
    bool ok = false;
    try {
        ok = ForwardFullQ88(exp, xKD, Din, y);
    } catch (const std::exception& e) {
        std::cerr << "Forward exception: " << e.what() << "\n"; return 6;
    }
    if (!ok){ std::cerr << "Forward failed\n"; return 4; }
    std::cout << "y:";
    for (auto v: y) std::cout << ' ' << v;
    std::cout << "\n";
    return 0;
}
