// infer.hpp — Q8.8 fixed-point inference API
#pragma once
#include <string>
#include <vector>

struct LinearDesc {
    std::string W; // npy float32 [O,I]
    std::string B; // optional npy float32 [O]
};

struct BackboneMeta {
    int d_model{0};
    int d_inner{0};
    int n_layer{0};
    int d_conv{0};
    int num_patches{0};
    int patch_len{0};
    int stride{0};
    bool pe_on{false};
    float pe_scale{1.0f};
    bool gate_off{false};
    std::string pe; // optional npy
};

struct BlockDesc {
    LinearDesc in_proj;     // [d_model, d_model]
    LinearDesc out_proj;    // [d_model, d_model]
    bool has_dw{false};
    std::vector<float> dw_W; // [C,1,k] flattened as (C*k)
    std::vector<float> dw_B; // [C]
    LinearDesc dt_proj;     // [d_inner, d_inner]
    std::vector<float> norm_weight; // RMSNorm weight [d_model]
};

struct BackboneDesc {
    BackboneMeta meta;
    LinearDesc patch_embed; // [d_model, d_model] when K->patches embedding, typically 1x1 conv-like
    std::vector<BlockDesc> blocks;
    std::vector<float> final_norm_weight; // [d_model]
    LinearDesc out_flat; // if flatten head exists
    LinearDesc out_pool; // if pooled head exists
};

struct ModelIR {
    std::string base_dir;
    int seq_len{0};
    int proj_dim{0};
    int d_model{0};
    int n_layer{0};
    int patch_len{0};
    int stride{0};
    int forecast_len{1};
    LinearDesc proj; // input projection [C,Din]
    LinearDesc head; // output head [2,C]
};

// Loaders
bool LoadExport(const std::string& export_json, ModelIR& ir);
bool LoadBackbone(const std::string& backbone_json, BackboneDesc& bb, const std::string& base_dir);

// End-to-end forward (xKD: (K,Din) row-major)
bool ForwardFullQ88(const std::string& export_json, const std::vector<float>& xKD, int Din, std::vector<float>& y_out);

