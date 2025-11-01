// ref_infer.hpp
#pragma once
#include <string>
#include <vector>

struct LayerDesc {
    std::string type;
    std::string name;
    int in_dim;
    int out_dim;
    std::string W_path;
    std::string B_path;
    // quant params
    double act_scale{1.0};
    int act_zp{0};
    std::string w_scale_path; // per-channel scales npy
};

struct ModelIR {
    std::string base_dir;
    int seq_len;
    int proj_dim;
    int d_model;
    int n_layer;
    int patch_len;
    int stride;
    int forecast_len;
    std::vector<LayerDesc> layers;
};

bool LoadExport(const std::string& json_path, ModelIR& ir);
void Forward(const ModelIR& ir, const float* x_ck, float* y_out);
bool GetLayer(const ModelIR& ir, const std::string& name, LayerDesc& out);
