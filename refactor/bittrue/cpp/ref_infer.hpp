#pragma once

#include <cstdint>
#include <string>
#include <unordered_map>
#include <vector>

struct QuantDesc {
    bool enabled{false};
    std::string scheme{"none"};
    int bits{0};
    int axis{0};
    int channels{0};
    double scale_scalar{1.0};
    std::string scale_path;
    int zero_point{0};
    int qmin{0};
    int qmax{0};
};

struct Conv1dDesc {
    std::string name;
    std::string role;
    std::string type;
    std::string impl;
    int in_channels{0};
    int out_channels{0};
    int kernel_size{1};
    int stride{1};
    int padding{0};
    int groups{1};
    bool bias{false};
    std::string weight_path;
    std::string bias_path;
    QuantDesc act_quant;
    QuantDesc weight_quant;
};

struct RMSNormDesc {
    std::string name;
    double eps{1e-5};
    std::string weight_path;
    int dim{0};
};

struct PositionalEncodingDesc {
    bool enabled{false};
    double scale{1.0};
    int num_patches{0};
    int d_model{0};
    std::string value_path;
};

struct SSMDesc {
    std::string type;
    int dim{0};
    Conv1dDesc dt_proj;
};

struct BlockDesc {
    int index{0};
    std::string type;
    int d_model{0};
    int d_inner{0};
    int d_conv{0};
    bool use_gate{true};
    bool use_dwconv{false};
    RMSNormDesc norm;
    Conv1dDesc in_proj;
    Conv1dDesc dw_conv;
    SSMDesc ssm;
    Conv1dDesc out_proj;
};

struct OutputHeadDesc {
    std::string kind;
    std::string agg_pool;
    Conv1dDesc flat;
    Conv1dDesc pool;
};

struct BackboneDesc {
    std::string type;
    int d_model{0};
    int d_inner{0};
    int n_layer{0};
    int d_conv{0};
    int num_patches{0};
    int patch_len{0};
    int stride{0};
    int seq_len{0};
    int num_channels{0};
    int forecast_len{0};
    bool pe_on{false};
    double pe_scale{1.0};
    bool gate_off{false};
    std::string agg_pool;
    bool use_dwconv{false};
    Conv1dDesc patch_embedding;
    PositionalEncodingDesc positional_encoding;
    std::vector<BlockDesc> blocks;
    RMSNormDesc final_norm;
    OutputHeadDesc output_head;
};

struct ModelIR {
    std::string base_dir;
    int input_dim{0};
    int seq_len{0};
    int proj_dim{0};
    int d_model{0};
    int n_layer{0};
    int patch_len{0};
    int stride{0};
    int forecast_len{0};
    int output_dim{0};
    Conv1dDesc proj;
    Conv1dDesc head;
    BackboneDesc backbone;
};

enum class ExecMode {
    kFakeQdq = 0,
    kInt8 = 1,
    kInt16 = 2,
};

struct RuntimeOptions {
    ExecMode default_mode{ExecMode::kFakeQdq};
    std::unordered_map<std::string, ExecMode> role_overrides;
    std::unordered_map<std::string, ExecMode> name_overrides;
    bool verbose{false};
};

bool LoadExport(const std::string& json_path, ModelIR& ir);
bool GetLayer(const ModelIR& ir, const std::string& name, Conv1dDesc& out);
void Forward(const ModelIR& ir, const float* x_ck, float* y_out);
bool ForwardFull(const std::string& export_json, const std::vector<float>& xKD, int Din, std::vector<float>& y_out);
bool ForwardFull(const std::string& export_json, const std::vector<float>& xKD, int Din, const RuntimeOptions& opts, std::vector<float>& y_out);
bool ForwardBlock0LocalY(const std::string& export_json, const std::vector<float>& xKD, int Din, std::vector<float>& y_out);
bool ForwardBlock0LocalY(const std::string& export_json, const std::vector<float>& xKD, int Din, const RuntimeOptions& opts, std::vector<float>& y_out);

ExecMode ParseExecMode(const std::string& text);
std::string ExecModeName(ExecMode mode);
bool ParseRuntimeOverrides(const std::string& spec, RuntimeOptions& opts, std::string& err);
