#include "ref_infer.hpp"
#include "io_utils.hpp"

#include <algorithm>
#include <cmath>
#include <cctype>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

std::string join_path(const std::string& a, const std::string& b) {
    if (b.empty()) return "";
    if (a.empty()) return b;
    if (a.back() == '/' || a.back() == '\\') return a + b;
    return a + "/" + b;
}

std::string trim(const std::string& s) {
    size_t b = 0;
    while (b < s.size() && std::isspace(static_cast<unsigned char>(s[b]))) ++b;
    size_t e = s.size();
    while (e > b && std::isspace(static_cast<unsigned char>(s[e - 1]))) --e;
    return s.substr(b, e - b);
}

bool extract_object_after_key(const std::string& text, const std::string& key, std::string& out) {
    const std::string needle = "\"" + key + "\"";
    size_t key_pos = text.find(needle);
    if (key_pos == std::string::npos) return false;
    size_t brace_pos = text.find('{', key_pos);
    if (brace_pos == std::string::npos) return false;
    int depth = 0;
    for (size_t i = brace_pos; i < text.size(); ++i) {
        if (text[i] == '{') ++depth;
        else if (text[i] == '}') {
            --depth;
            if (depth == 0) {
                out = text.substr(brace_pos, i - brace_pos + 1);
                return true;
            }
        }
    }
    return false;
}

bool extract_array_after_key(const std::string& text, const std::string& key, std::string& out) {
    const std::string needle = "\"" + key + "\"";
    size_t key_pos = text.find(needle);
    if (key_pos == std::string::npos) return false;
    size_t arr_pos = text.find('[', key_pos);
    if (arr_pos == std::string::npos) return false;
    int depth = 0;
    for (size_t i = arr_pos; i < text.size(); ++i) {
        if (text[i] == '[') ++depth;
        else if (text[i] == ']') {
            --depth;
            if (depth == 0) {
                out = text.substr(arr_pos, i - arr_pos + 1);
                return true;
            }
        }
    }
    return false;
}

std::vector<std::string> split_top_level_objects(const std::string& array_text) {
    std::vector<std::string> objs;
    int depth = 0;
    size_t start = std::string::npos;
    for (size_t i = 0; i < array_text.size(); ++i) {
        if (array_text[i] == '{') {
            if (depth == 0) start = i;
            ++depth;
        } else if (array_text[i] == '}') {
            --depth;
            if (depth == 0 && start != std::string::npos) {
                objs.push_back(array_text.substr(start, i - start + 1));
                start = std::string::npos;
            }
        }
    }
    return objs;
}

bool json_get_string(const std::string& text, const std::string& key, std::string& out) {
    const std::string needle = "\"" + key + "\"";
    size_t p = text.find(needle);
    if (p == std::string::npos) return false;
    size_t colon = text.find(':', p);
    if (colon == std::string::npos) return false;
    size_t q1 = text.find('"', colon + 1);
    if (q1 == std::string::npos) return false;
    size_t q2 = text.find('"', q1 + 1);
    if (q2 == std::string::npos) return false;
    out = text.substr(q1 + 1, q2 - q1 - 1);
    return true;
}

bool json_get_number_token(const std::string& text, const std::string& key, std::string& token) {
    const std::string needle = "\"" + key + "\"";
    size_t p = text.find(needle);
    if (p == std::string::npos) return false;
    size_t colon = text.find(':', p);
    if (colon == std::string::npos) return false;
    size_t start = colon + 1;
    while (start < text.size() && std::isspace(static_cast<unsigned char>(text[start]))) ++start;
    size_t end = start;
    while (end < text.size() && std::string(",}\n]").find(text[end]) == std::string::npos) ++end;
    token = trim(text.substr(start, end - start));
    return !token.empty();
}

bool json_get_int(const std::string& text, const std::string& key, int& out) {
    std::string tok;
    if (!json_get_number_token(text, key, tok)) return false;
    try {
        out = std::stoi(tok);
        return true;
    } catch (...) {
        return false;
    }
}

bool json_get_double(const std::string& text, const std::string& key, double& out) {
    std::string tok;
    if (!json_get_number_token(text, key, tok)) return false;
    try {
        out = std::stod(tok);
        return true;
    } catch (...) {
        return false;
    }
}

bool json_get_bool(const std::string& text, const std::string& key, bool& out) {
    std::string tok;
    if (!json_get_number_token(text, key, tok)) return false;
    std::string low = tok;
    std::transform(low.begin(), low.end(), low.begin(), [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
    if (low == "true") {
        out = true;
        return true;
    }
    if (low == "false") {
        out = false;
        return true;
    }
    return false;
}

void load_quant_desc(const std::string& text, const std::string& key, const std::string& base_dir, QuantDesc& q) {
    std::string obj;
    if (!extract_object_after_key(text, key, obj)) return;
    json_get_bool(obj, "enabled", q.enabled);
    json_get_string(obj, "scheme", q.scheme);
    json_get_int(obj, "bits", q.bits);
    json_get_int(obj, "axis", q.axis);
    json_get_int(obj, "channels", q.channels);
    json_get_double(obj, "scale", q.scale_scalar);
    std::string scale_file;
    if (json_get_string(obj, "scale", scale_file)) q.scale_path = join_path(base_dir, scale_file);
    json_get_int(obj, "zero_point", q.zero_point);
    json_get_int(obj, "qmin", q.qmin);
    json_get_int(obj, "qmax", q.qmax);
}

void load_conv_desc_from_object(const std::string& obj, const std::string& base_dir, Conv1dDesc& desc) {
    json_get_string(obj, "name", desc.name);
    json_get_string(obj, "type", desc.type);
    json_get_string(obj, "impl", desc.impl);
    json_get_int(obj, "in_channels", desc.in_channels);
    json_get_int(obj, "out_channels", desc.out_channels);
    json_get_int(obj, "kernel_size", desc.kernel_size);
    json_get_int(obj, "stride", desc.stride);
    json_get_int(obj, "padding", desc.padding);
    json_get_int(obj, "groups", desc.groups);
    json_get_bool(obj, "bias", desc.bias);
    std::string weight_file, bias_file;
    json_get_string(obj, "weight", weight_file);
    json_get_string(obj, "bias_file", bias_file);
    desc.weight_path = join_path(base_dir, weight_file);
    if (!bias_file.empty()) desc.bias_path = join_path(base_dir, bias_file);
    std::string qobj;
    if (extract_object_after_key(obj, "quant", qobj)) {
        load_quant_desc(qobj, "activation", base_dir, desc.act_quant);
        load_quant_desc(qobj, "weight", base_dir, desc.weight_quant);
    }
}

void load_conv_desc(const std::string& text, const std::string& key, const std::string& base_dir, Conv1dDesc& desc) {
    std::string obj;
    if (!extract_object_after_key(text, key, obj)) {
        throw std::runtime_error("Missing conv object: " + key);
    }
    load_conv_desc_from_object(obj, base_dir, desc);
}

void load_rmsnorm_desc(const std::string& text, const std::string& key, const std::string& base_dir, RMSNormDesc& desc) {
    std::string obj;
    if (!extract_object_after_key(text, key, obj)) {
        throw std::runtime_error("Missing RMSNorm object: " + key);
    }
    json_get_string(obj, "name", desc.name);
    json_get_int(obj, "dim", desc.dim);
    json_get_double(obj, "eps", desc.eps);
    std::string weight_file;
    json_get_string(obj, "weight", weight_file);
    desc.weight_path = join_path(base_dir, weight_file);
}

void load_positional_encoding(const std::string& text, const std::string& key, const std::string& base_dir, PositionalEncodingDesc& desc) {
    std::string obj;
    if (!extract_object_after_key(text, key, obj)) return;
    json_get_bool(obj, "enabled", desc.enabled);
    json_get_double(obj, "scale", desc.scale);
    json_get_int(obj, "num_patches", desc.num_patches);
    json_get_int(obj, "d_model", desc.d_model);
    std::string file;
    if (json_get_string(obj, "file", file) && !file.empty()) desc.value_path = join_path(base_dir, file);
}

void load_block_desc_from_object(const std::string& obj, const std::string& base_dir, BlockDesc& desc) {
    json_get_int(obj, "index", desc.index);
    json_get_string(obj, "type", desc.type);
    json_get_int(obj, "d_model", desc.d_model);
    json_get_int(obj, "d_inner", desc.d_inner);
    json_get_int(obj, "d_conv", desc.d_conv);
    json_get_bool(obj, "use_gate", desc.use_gate);
    json_get_bool(obj, "use_dwconv", desc.use_dwconv);
    load_rmsnorm_desc(obj, "norm", base_dir, desc.norm);
    load_conv_desc(obj, "in_proj", base_dir, desc.in_proj);
    if (desc.use_dwconv) load_conv_desc(obj, "dw_conv", base_dir, desc.dw_conv);
    std::string ssm_obj;
    if (!extract_object_after_key(obj, "ssm", ssm_obj)) {
        throw std::runtime_error("Missing ssm object in block");
    }
    json_get_string(ssm_obj, "type", desc.ssm.type);
    json_get_int(ssm_obj, "dim", desc.ssm.dim);
    load_conv_desc(ssm_obj, "dt_proj", base_dir, desc.ssm.dt_proj);
    load_conv_desc(obj, "out_proj", base_dir, desc.out_proj);
}

void load_output_head(const std::string& text, const std::string& key, const std::string& base_dir, OutputHeadDesc& desc) {
    std::string obj;
    if (!extract_object_after_key(text, key, obj)) {
        throw std::runtime_error("Missing output_head object");
    }
    json_get_string(obj, "kind", desc.kind);
    json_get_string(obj, "agg_pool", desc.agg_pool);
    load_conv_desc(obj, "flat", base_dir, desc.flat);
    load_conv_desc(obj, "pool", base_dir, desc.pool);
}

void load_backbone(const std::string& json_path, const std::string& base_dir, BackboneDesc& bb) {
    std::string text = read_file_text(json_path);
    json_get_string(text, "type", bb.type);
    std::string meta;
    if (!extract_object_after_key(text, "meta", meta)) {
        throw std::runtime_error("Missing backbone meta");
    }
    json_get_int(meta, "d_model", bb.d_model);
    json_get_int(meta, "d_inner", bb.d_inner);
    json_get_int(meta, "n_layer", bb.n_layer);
    json_get_int(meta, "d_conv", bb.d_conv);
    json_get_int(meta, "num_patches", bb.num_patches);
    json_get_int(meta, "patch_len", bb.patch_len);
    json_get_int(meta, "stride", bb.stride);
    json_get_int(meta, "seq_len", bb.seq_len);
    json_get_int(meta, "num_channels", bb.num_channels);
    json_get_int(meta, "forecast_len", bb.forecast_len);
    json_get_bool(meta, "pe_on", bb.pe_on);
    json_get_double(meta, "pe_scale", bb.pe_scale);
    json_get_bool(meta, "gate_off", bb.gate_off);
    json_get_string(meta, "agg_pool", bb.agg_pool);
    json_get_bool(meta, "use_dwconv", bb.use_dwconv);

    load_conv_desc(text, "patch_embedding", base_dir, bb.patch_embedding);
    load_positional_encoding(text, "positional_encoding", base_dir, bb.positional_encoding);

    std::string blocks_arr;
    if (!extract_array_after_key(text, "blocks", blocks_arr)) {
        throw std::runtime_error("Missing backbone blocks array");
    }
    auto block_objs = split_top_level_objects(blocks_arr);
    bb.blocks.clear();
    bb.blocks.reserve(block_objs.size());
    for (const auto& obj : block_objs) {
        BlockDesc blk;
        load_block_desc_from_object(obj, base_dir, blk);
        bb.blocks.push_back(blk);
    }

    load_rmsnorm_desc(text, "final_norm", base_dir, bb.final_norm);
    load_output_head(text, "output_head", base_dir, bb.output_head);
}

struct ActLUT {
    std::vector<float> sig;
    std::vector<float> silu;
    float xmin{-8.0f};
    float xmax{8.0f};
    int n{4096};

    void build(float a = -8.0f, float b = 8.0f, int N = 4096) {
        xmin = a;
        xmax = b;
        n = N;
        sig.resize(n);
        silu.resize(n);
        for (int i = 0; i < n; ++i) {
            float x = a + (b - a) * static_cast<float>(i) / static_cast<float>(n - 1);
            float s = 1.0f / (1.0f + std::exp(-x));
            sig[i] = s;
            silu[i] = x * s;
        }
    }

    float interp(const std::vector<float>& table, float x) const {
        if (x <= xmin) return table.front();
        if (x >= xmax) return table.back();
        float t = (x - xmin) / (xmax - xmin);
        float idx = t * static_cast<float>(n - 1);
        int i = static_cast<int>(idx);
        float u = idx - static_cast<float>(i);
        return table[i] * (1.0f - u) + table[i + 1] * u;
    }

    float sigmoid(float x) const { return interp(sig, x); }
    float silu_fn(float x) const { return interp(silu, x); }
};

float quant_dequant_scalar_asym(float x, double scale, int zp, int bits, int qmin, int qmax) {
    if (scale == 0.0) return x;
    if (qmin == 0 && qmax == 0 && bits > 0) {
        qmin = 0;
        qmax = (1 << bits) - 1;
    }
    int q = static_cast<int>(std::nearbyint(static_cast<double>(x) / scale + static_cast<double>(zp)));
    q = std::max(qmin, std::min(qmax, q));
    return static_cast<float>((static_cast<double>(q) - static_cast<double>(zp)) * scale);
}

float quant_dequant_scalar_sym(float x, double scale, int bits) {
    if (scale == 0.0) return x;
    const int qmin = -(1 << (bits - 1));
    const int qmax = (1 << (bits - 1)) - 1;
    int q = static_cast<int>(std::nearbyint(static_cast<double>(x) / scale));
    q = std::max(qmin, std::min(qmax, q));
    return static_cast<float>(static_cast<double>(q) * scale);
}

void load_scale_vector(const QuantDesc& q, std::vector<float>& scales) {
    scales.clear();
    if (!q.scale_path.empty()) {
        std::vector<int64_t> shape;
        load_npy_float32(q.scale_path, shape, scales);
    }
}

void apply_input_quant(const std::vector<float>& x, int channels, const QuantDesc& q, std::vector<float>& x_hat) {
    x_hat = x;
    if (!q.enabled || q.scheme == "none") return;
    if (q.scheme == "per_tensor_asym") {
        for (size_t i = 0; i < x_hat.size(); ++i) {
            x_hat[i] = quant_dequant_scalar_asym(x_hat[i], q.scale_scalar, q.zero_point, q.bits, q.qmin, q.qmax);
        }
        return;
    }
    if (q.scheme == "per_channel_sym") {
        std::vector<float> scales;
        load_scale_vector(q, scales);
        if (static_cast<int>(scales.size()) != channels) {
            throw std::runtime_error("Activation per-channel scale size mismatch");
        }
        const int T = static_cast<int>(x_hat.size()) / channels;
        for (int t = 0; t < T; ++t) {
            for (int c = 0; c < channels; ++c) {
                x_hat[t * channels + c] = quant_dequant_scalar_sym(x_hat[t * channels + c], static_cast<double>(scales[c]), q.bits);
            }
        }
        return;
    }
    throw std::runtime_error("Unsupported activation quant scheme: " + q.scheme);
}

void apply_weight_quant(const std::vector<float>& w, int out_channels, int elems_per_out, const QuantDesc& q, std::vector<float>& w_hat) {
    w_hat = w;
    if (!q.enabled || q.scheme == "none") return;
    if (q.scheme != "per_channel_sym") {
        throw std::runtime_error("Unsupported weight quant scheme: " + q.scheme);
    }
    std::vector<float> scales;
    load_scale_vector(q, scales);
    if (static_cast<int>(scales.size()) != out_channels) {
        throw std::runtime_error("Weight per-channel scale size mismatch");
    }
    for (int oc = 0; oc < out_channels; ++oc) {
        for (int i = 0; i < elems_per_out; ++i) {
            const int idx = oc * elems_per_out + i;
            w_hat[idx] = quant_dequant_scalar_sym(w_hat[idx], static_cast<double>(scales[oc]), q.bits);
        }
    }
}

int conv1d_out_len(int in_len, int kernel_size, int stride, int padding) {
    return (in_len + 2 * padding - kernel_size) / stride + 1;
}

void conv1d_run(const Conv1dDesc& desc, const std::vector<float>& x_tc, int T_in, std::vector<float>& y_tc) {
    std::vector<int64_t> w_shape, b_shape;
    std::vector<float> w_raw, b_raw;
    load_npy_float32(desc.weight_path, w_shape, w_raw);
    if (desc.bias && !desc.bias_path.empty()) load_npy_float32(desc.bias_path, b_shape, b_raw);
    std::cerr << "[bittrue] conv " << desc.name
              << " x_size=" << x_tc.size()
              << " T_in=" << T_in
              << " Cin=" << desc.in_channels
              << " Cout=" << desc.out_channels
              << " K=" << desc.kernel_size
              << " weight_shape=";
    for (size_t i = 0; i < w_shape.size(); ++i) std::cerr << (i ? "x" : "") << w_shape[i];
    std::cerr << " weight_size=" << w_raw.size() << "\n";

    std::vector<float> x_hat;
    apply_input_quant(x_tc, desc.in_channels, desc.act_quant, x_hat);

    std::vector<float> w_hat;
    const int elems_per_out = (desc.in_channels / desc.groups) * desc.kernel_size;
    apply_weight_quant(w_raw, desc.out_channels, elems_per_out, desc.weight_quant, w_hat);

    const int T_out = conv1d_out_len(T_in, desc.kernel_size, desc.stride, desc.padding);
    const int cin_per_group = desc.in_channels / desc.groups;
    const int cout_per_group = desc.out_channels / desc.groups;
    y_tc.assign(T_out * desc.out_channels, 0.0f);

    for (int t = 0; t < T_out; ++t) {
        for (int oc = 0; oc < desc.out_channels; ++oc) {
            const int g = oc / cout_per_group;
            double acc = b_raw.empty() ? 0.0 : static_cast<double>(b_raw[oc]);
            for (int icg = 0; icg < cin_per_group; ++icg) {
                const int ic = g * cin_per_group + icg;
                for (int k = 0; k < desc.kernel_size; ++k) {
                    const int ti = t * desc.stride - desc.padding + k;
                    if (ti < 0 || ti >= T_in) continue;
                    const float xv = x_hat[ti * desc.in_channels + ic];
                    const int w_idx = ((oc * cin_per_group) + icg) * desc.kernel_size + k;
                    const float wv = w_hat[w_idx];
                    acc += static_cast<double>(xv) * static_cast<double>(wv);
                }
            }
            y_tc[t * desc.out_channels + oc] = static_cast<float>(acc);
        }
    }
}

void rmsnorm_inplace(std::vector<float>& x_tc, int T, int C, const RMSNormDesc& norm) {
    std::vector<int64_t> shape;
    std::vector<float> weight;
    load_npy_float32(norm.weight_path, shape, weight);
    for (int t = 0; t < T; ++t) {
        double mean_sq = 0.0;
        for (int c = 0; c < C; ++c) {
            const float v = x_tc[t * C + c];
            mean_sq += static_cast<double>(v) * static_cast<double>(v);
        }
        mean_sq /= static_cast<double>(std::max(1, C));
        const float inv = 1.0f / std::sqrt(static_cast<float>(mean_sq) + static_cast<float>(norm.eps));
        for (int c = 0; c < C; ++c) {
            x_tc[t * C + c] = x_tc[t * C + c] * inv * weight[c];
        }
    }
}

std::vector<float> reshape_cf_to_tc(const std::vector<float>& x_cf, int C, int F) {
    std::vector<float> y_tc(F * C, 0.0f);
    for (int c = 0; c < C; ++c) {
        for (int f = 0; f < F; ++f) {
            y_tc[f * C + c] = x_cf[c * F + f];
        }
    }
    return y_tc;
}

}  // namespace

bool LoadExport(const std::string& json_path, ModelIR& ir) {
    std::string text = read_file_text(json_path);
    const size_t pos = json_path.find_last_of("/\\");
    ir.base_dir = (pos == std::string::npos) ? "." : json_path.substr(0, pos);

    std::string model_obj;
    if (!extract_object_after_key(text, "model", model_obj)) return false;
    json_get_int(model_obj, "input_dim", ir.input_dim);
    json_get_int(model_obj, "seq_len", ir.seq_len);
    json_get_int(model_obj, "proj_dim", ir.proj_dim);
    json_get_int(model_obj, "d_model", ir.d_model);
    json_get_int(model_obj, "n_layer", ir.n_layer);
    json_get_int(model_obj, "patch_len", ir.patch_len);
    json_get_int(model_obj, "stride", ir.stride);
    json_get_int(model_obj, "forecast_len", ir.forecast_len);
    json_get_int(model_obj, "output_dim", ir.output_dim);

    load_conv_desc(text, "proj", ir.base_dir, ir.proj);
    load_conv_desc(text, "head", ir.base_dir, ir.head);

    std::string backbone_obj;
    if (!extract_object_after_key(text, "backbone", backbone_obj)) return false;
    std::string backbone_file;
    if (!json_get_string(backbone_obj, "file", backbone_file)) return false;
    load_backbone(join_path(ir.base_dir, backbone_file), ir.base_dir, ir.backbone);
    return true;
}

bool GetLayer(const ModelIR& ir, const std::string& name, Conv1dDesc& out) {
    if (name == ir.proj.name || name == "proj") {
        out = ir.proj;
        return true;
    }
    if (name == ir.head.name || name == "head") {
        out = ir.head;
        return true;
    }
    for (const auto& blk : ir.backbone.blocks) {
        if (name == blk.in_proj.name) {
            out = blk.in_proj;
            return true;
        }
        if (name == blk.out_proj.name) {
            out = blk.out_proj;
            return true;
        }
        if (name == blk.ssm.dt_proj.name) {
            out = blk.ssm.dt_proj;
            return true;
        }
        if (blk.use_dwconv && name == blk.dw_conv.name) {
            out = blk.dw_conv;
            return true;
        }
    }
    return false;
}

void Forward(const ModelIR& ir, const float* x_ck, float* y_out) {
    std::vector<float> x(ir.seq_len * ir.input_dim, 0.0f);
    for (size_t i = 0; i < x.size(); ++i) x[i] = x_ck[i];
    std::vector<float> y;
    if (!ForwardFull(join_path(ir.base_dir, "export.json"), x, ir.input_dim, y)) {
        throw std::runtime_error("ForwardFull failed");
    }
    for (size_t i = 0; i < y.size(); ++i) y_out[i] = y[i];
}

bool ForwardFull(const std::string& export_json, const std::vector<float>& xKD, int Din, std::vector<float>& y_out) {
    ModelIR ir;
    if (!LoadExport(export_json, ir)) return false;
    if (Din != 0 && ir.input_dim != 0 && Din != ir.input_dim) {
        throw std::runtime_error("Input dim mismatch between CLI and export");
    }

    const BackboneDesc& bb = ir.backbone;
    ActLUT lut;
    lut.build();
    std::cerr << "[bittrue] loaded export: K=" << ir.seq_len << " Din=" << ir.input_dim
              << " proj=" << ir.proj_dim << " d_model=" << bb.d_model
              << " layers=" << bb.n_layer << "\n";

    // 1) top-level proj: (K, Din) -> (K, proj_dim)
    std::vector<float> proj_out;
    std::cerr << "[bittrue] stage proj\n";
    conv1d_run(ir.proj, xKD, ir.seq_len, proj_out);

    // 2) patch embedding: input is already (K, C)
    std::vector<float> x_seq = proj_out;
    std::vector<float> x_patches;
    std::cerr << "[bittrue] stage patch_embedding\n";
    conv1d_run(bb.patch_embedding, x_seq, ir.seq_len, x_patches);
    const int T_patch = conv1d_out_len(ir.seq_len, bb.patch_embedding.kernel_size, bb.patch_embedding.stride, bb.patch_embedding.padding);
    if (bb.positional_encoding.enabled && !bb.positional_encoding.value_path.empty()) {
        std::vector<int64_t> pe_shape;
        std::vector<float> pe;
        load_npy_float32(bb.positional_encoding.value_path, pe_shape, pe);
        for (int t = 0; t < T_patch; ++t) {
            for (int c = 0; c < bb.d_model; ++c) {
                x_patches[t * bb.d_model + c] += static_cast<float>(bb.positional_encoding.scale) * pe[t * bb.d_model + c];
            }
        }
    }
    x_seq = x_patches;  // (num_patches, d_model)

    // 3) stacked SlimMambaBlock
    for (const auto& blk : bb.blocks) {
        std::cerr << "[bittrue] block " << blk.index << "\n";
        const int T = static_cast<int>(x_seq.size()) / blk.d_model;
        std::vector<float> residual = x_seq;

        rmsnorm_inplace(x_seq, T, blk.d_model, blk.norm);

        std::vector<float> uv;
        std::cerr << "[bittrue] block " << blk.index << " in_proj\n";
        conv1d_run(blk.in_proj, x_seq, T, uv);  // (T, 2*d_inner)
        std::vector<float> u(T * blk.d_inner, 0.0f);
        std::vector<float> z(T * blk.d_inner, 0.0f);
        for (int t = 0; t < T; ++t) {
            for (int c = 0; c < blk.d_inner; ++c) {
                u[t * blk.d_inner + c] = uv[t * (2 * blk.d_inner) + c];
                z[t * blk.d_inner + c] = uv[t * (2 * blk.d_inner) + blk.d_inner + c];
            }
        }

        if (blk.use_dwconv) {
            std::cerr << "[bittrue] block " << blk.index << " dw_conv\n";
            std::vector<float> u_dw;
            conv1d_run(blk.dw_conv, u, T, u_dw);
            u.swap(u_dw);
        }

        for (float& v : u) v = lut.silu_fn(v);

        std::vector<float> dt;
        std::cerr << "[bittrue] block " << blk.index << " dt_proj\n";
        conv1d_run(blk.ssm.dt_proj, u, T, dt);  // (T, d_inner)
        std::vector<float> s(blk.d_inner, 0.0f);
        std::vector<float> ssm_out(T * blk.d_inner, 0.0f);
        for (int t = 0; t < T; ++t) {
            for (int c = 0; c < blk.d_inner; ++c) {
                const float lam = lut.sigmoid(dt[t * blk.d_inner + c]);
                const float in_u = u[t * blk.d_inner + c];
                s[c] = lam * s[c] + (1.0f - lam) * in_u;
                ssm_out[t * blk.d_inner + c] = s[c];
            }
        }

        if (blk.use_gate) {
            for (int i = 0; i < static_cast<int>(ssm_out.size()); ++i) {
                ssm_out[i] *= lut.silu_fn(z[i]);
            }
        }

        std::vector<float> y_blk;
        std::cerr << "[bittrue] block " << blk.index << " out_proj\n";
        conv1d_run(blk.out_proj, ssm_out, T, y_blk);  // (T, d_model)
        x_seq.assign(T * blk.d_model, 0.0f);
        for (int i = 0; i < T * blk.d_model; ++i) {
            x_seq[i] = residual[i] + y_blk[i];
        }
    }

    // 4) final norm
    const int T_final = static_cast<int>(x_seq.size()) / bb.d_model;
    std::cerr << "[bittrue] stage final_norm\n";
    rmsnorm_inplace(x_seq, T_final, bb.d_model, bb.final_norm);

    // 5) backbone output head
    std::vector<float> backbone_out;
    if (bb.output_head.kind == "pool") {
        std::cerr << "[bittrue] stage output_pool\n";
        std::vector<float> pooled(bb.d_model, 0.0f);
        if (bb.output_head.agg_pool == "max") {
            std::fill(pooled.begin(), pooled.end(), -1e30f);
            for (int t = 0; t < T_final; ++t) {
                for (int c = 0; c < bb.d_model; ++c) {
                    pooled[c] = std::max(pooled[c], x_seq[t * bb.d_model + c]);
                }
            }
        } else {
            for (int t = 0; t < T_final; ++t) {
                for (int c = 0; c < bb.d_model; ++c) {
                    pooled[c] += x_seq[t * bb.d_model + c];
                }
            }
            for (int c = 0; c < bb.d_model; ++c) pooled[c] /= static_cast<float>(std::max(1, T_final));
        }
        conv1d_run(bb.output_head.pool, pooled, 1, backbone_out);  // (1, C*F)
    } else {
        std::cerr << "[bittrue] stage output_flat\n";
        conv1d_run(bb.output_head.flat, x_seq, T_final, backbone_out);  // (1, C*F)
    }

    if (static_cast<int>(backbone_out.size()) != bb.num_channels * bb.forecast_len) {
        throw std::runtime_error("Unexpected backbone head output size");
    }

    // reshape (C*F) -> (F, C) for final top-level head conv1d
    std::vector<float> head_in = reshape_cf_to_tc(backbone_out, bb.num_channels, bb.forecast_len);

    // 6) top-level head
    std::vector<float> head_out;
    std::cerr << "[bittrue] stage head\n";
    conv1d_run(ir.head, head_in, bb.forecast_len, head_out);  // (F, 2)
    std::cerr << "[bittrue] done\n";
    y_out = head_out;
    return true;
}
