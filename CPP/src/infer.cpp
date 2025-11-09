// infer.cpp — Q8.8 fixed-point inference (integer core ops)
#include "infer.hpp"
#include "io.hpp"
#include "quant_fixed88.hpp"
#include <cstring>
#include <cmath>
#include <iostream>

static bool json_get_bool(const std::string& text, const char* key, bool& out){
    auto p = text.find(std::string("\"") + key + "\""); if (p==std::string::npos) return false;
    auto v = text.find(':', p); if (v==std::string::npos) return false;
    auto e = text.find_first_of(",}\n", v+1);
    auto s = text.substr(v+1, e-(v+1));
    for (auto& c: s) c = (char)tolower(c);
    if (s.find("true")!=std::string::npos) { out=true; return true; }
    if (s.find("false")!=std::string::npos) { out=false; return true; }
    return false;
}

bool LoadExport(const std::string& export_json, ModelIR& ir){
    std::string t = read_file_text(export_json);
    auto pos = export_json.find_last_of("/\\");
    ir.base_dir = (pos==std::string::npos) ? std::string(".") : export_json.substr(0, pos);
    json_get_int(t, "seq_len", ir.seq_len);
    json_get_int(t, "proj_dim", ir.proj_dim);
    json_get_int(t, "d_model", ir.d_model);
    json_get_int(t, "n_layer", ir.n_layer);
    json_get_int(t, "patch_len", ir.patch_len);
    json_get_int(t, "stride", ir.stride);
    json_get_int(t, "forecast_len", ir.forecast_len);
    std::string W,B;
    if (json_find_layer_entry(t, "proj", W, B)) { ir.proj.W = join_path(ir.base_dir, W); ir.proj.B = B.empty()?std::string(""):join_path(ir.base_dir, B); }
    if (json_find_layer_entry(t, "head", W, B)) { ir.head.W = join_path(ir.base_dir, W); ir.head.B = B.empty()?std::string(""):join_path(ir.base_dir, B); }
    return !(ir.proj.W.empty() || ir.head.W.empty());
}

bool LoadBackbone(const std::string& backbone_json, BackboneDesc& bb, const std::string& base_dir){
    std::string t = read_file_text(backbone_json);
    // meta
    json_get_int(t, "d_model", bb.meta.d_model);
    json_get_int(t, "d_inner", bb.meta.d_inner);
    json_get_int(t, "n_layer", bb.meta.n_layer);
    json_get_int(t, "d_conv", bb.meta.d_conv);
    json_get_int(t, "num_patches", bb.meta.num_patches);
    json_get_int(t, "patch_len", bb.meta.patch_len);
    json_get_int(t, "stride", bb.meta.stride);
    json_get_bool(t, "pe_on", bb.meta.pe_on);
    {
        int tmp = 0; if (json_get_int(t, "pe_scale", tmp)) bb.meta.pe_scale = static_cast<float>(tmp);
    }
    json_get_bool(t, "gate_off", bb.meta.gate_off);
    std::string pef; if (json_get_str(t, "pe", pef)) bb.meta.pe = join_path(base_dir, pef);
    // patch embedding
    std::string peW, peB; json_get_str(t, "patch_embed_W", peW); json_get_str(t, "patch_embed_B", peB);
    if (!peW.empty()) bb.patch_embed.W = join_path(base_dir, peW);
    if (!peB.empty()) bb.patch_embed.B = join_path(base_dir, peB);
    // blocks
    bb.blocks.resize(std::max(0, bb.meta.n_layer));
    for (int i=0;i<bb.meta.n_layer;++i){
        auto& bl = bb.blocks[i];
        std::string W,B;
        // in_proj
        if (json_get_str(t, ("block"+std::to_string(i)+"_in_proj_W").c_str(), W)) bl.in_proj.W = join_path(base_dir, W);
        if (json_get_str(t, ("block"+std::to_string(i)+"_in_proj_B").c_str(), B)) bl.in_proj.B = join_path(base_dir, B);
        // out_proj
        if (json_get_str(t, ("block"+std::to_string(i)+"_out_proj_W").c_str(), W)) bl.out_proj.W = join_path(base_dir, W);
        if (json_get_str(t, ("block"+std::to_string(i)+"_out_proj_B").c_str(), B)) bl.out_proj.B = join_path(base_dir, B);
        // dw
        std::string dwW; if (json_get_str(t, ("block"+std::to_string(i)+"_dw_W").c_str(), dwW)){
            bl.has_dw = true; std::vector<int64_t> shp; load_npy_float32(join_path(base_dir, dwW), shp, bl.dw_W);
            std::string dwB; if (json_get_str(t, ("block"+std::to_string(i)+"_dw_B").c_str(), dwB)) load_npy_float32(join_path(base_dir, dwB), shp, bl.dw_B);
        }
        // dt_proj
        if (json_get_str(t, ("block"+std::to_string(i)+"_dt_proj_W").c_str(), W)) bl.dt_proj.W = join_path(base_dir, W);
        if (json_get_str(t, ("block"+std::to_string(i)+"_dt_proj_B").c_str(), B)) bl.dt_proj.B = join_path(base_dir, B);
        // norm
        std::string nw; std::vector<int64_t> shp; if (json_get_str(t, ("block"+std::to_string(i)+"_norm_weight").c_str(), nw)) load_npy_float32(join_path(base_dir, nw), shp, bl.norm_weight);
    }
    // final norm
    std::string fnw; std::vector<int64_t> shp; if (json_get_str(t, "final_norm_weight", fnw)) load_npy_float32(join_path(base_dir, fnw), shp, bb.final_norm_weight);
    // outputs
    std::string ow, ob;
    if (json_get_str(t, "out_flat_W", ow)) bb.out_flat.W = join_path(base_dir, ow);
    if (json_get_str(t, "out_flat_B", ob)) bb.out_flat.B = join_path(base_dir, ob);
    ow.clear(); ob.clear();
    if (json_get_str(t, "out_pool_W", ow)) bb.out_pool.W = join_path(base_dir, ow);
    if (json_get_str(t, "out_pool_B", ob)) bb.out_pool.B = join_path(base_dir, ob);
    return true;
}

// Act LUTs (float domain; quantize around LUT for fixed-point friendliness)
struct ActLUT {
    std::vector<float> xs, sig, silu; float xmin=-8.0f, xmax=8.0f; int n=4096;
    void build(float a=-8.0f, float b=8.0f, int N=4096){ xmin=a; xmax=b; n=N; xs.resize(n); sig.resize(n); silu.resize(n);
        for(int i=0;i<n;++i){ float x=a + (b-a)*i/(n-1); xs[i]=x; float s=1.0f/(1.0f+std::exp(-x)); sig[i]=s; silu[i]=x*s; } }
    inline float _lerp(const std::vector<float>& v, float x) const {
        if (x<=xmin) return v.front(); if (x>=xmax) return v.back();
        float u = (x - xmin) / (xmax - xmin); float idx = u * (n - 1);
        int i = (int)idx; float t = idx - i; if (i>=n-1) return v.back();
        return v[i] * (1.0f - t) + v[i+1] * t;
    }
    float sigmoid(float x) const { return _lerp(sig, x); }
    float silu_fn(float x) const { return _lerp(silu, x); }
};

// Linear GEMV in pure fixed Q8.8: y_q88[o] = round_even( (sum_i Wi_q88 * xi_q88) >> 8 ) + b_q88
static void linear_q88_forward(const LinearDesc& L, const std::vector<int16_t>& x_q, std::vector<int16_t>& y_q){
    std::vector<int64_t> shpW, shpB; std::vector<float> Wf, Bf;
    load_npy_float32(L.W, shpW, Wf);
    if (!L.B.empty()) load_npy_float32(L.B, shpB, Bf);
    int O = (int)shpW[0], I = (int)shpW[1];
    std::vector<int16_t> Wq(Wf.size());
    for (int o=0;o<O;++o){ for (int i=0;i<I;++i){ Wq[o*I+i] = q88_from_float(Wf[o*I+i]); }}
    std::vector<int16_t> Bq(O, 0);
    if (!Bf.empty()){
        for (int o=0;o<O;++o) Bq[o] = q88_from_float(Bf[o]);
    }
    y_q.assign(O, 0);
    for (int o=0;o<O;++o){
        int32_t acc = 0;
        for (int i=0;i<I;++i){ acc += static_cast<int32_t>(Wq[o*I+i]) * static_cast<int32_t>(x_q[i]); }
        int16_t y = q88_from_acc32_round8(acc);
        if (!Bf.empty()) y = q88_add(y, Bq[o]);
        y_q[o] = y;
    }
}

// Depthwise conv along time for Q8.8 (same padding, kernel k odd): xTK (K,C) -> yTK (K,C)
static void dwconv_q88_time_same(const std::vector<int16_t>& xTK, int K, int C, int k,
                                 const std::vector<int16_t>& Wq, const std::vector<int16_t>& Bq,
                                 std::vector<int16_t>& yTK){
    int pad = k/2; yTK.assign(K*C, 0);
    for (int t=0;t<K;++t){
        for (int c=0;c<C;++c){
            int32_t acc=0;
            for (int u=0; u<k; ++u){ int tt = t + u - pad; int16_t xv = 0; if (tt>=0 && tt<K) xv = xTK[tt*C + c]; int16_t w = Wq[c*k + u]; acc += static_cast<int32_t>(xv) * static_cast<int32_t>(w); }
            int16_t y = q88_from_acc32_round8(acc);
            if (!Bq.empty()) y = q88_add(y, Bq[c]);
            yTK[t*C + c] = y;
        }
    }
}

// RMSNorm (float path, quantize in/out)
static void rmsnorm_q88_inplace(std::vector<int16_t>& v_q, const std::vector<float>& weight){
    const int D = (int)v_q.size();
    if (D == 0) return;
    std::vector<float> v(D);
    for (int i=0;i<D;++i) v[i] = float_from_q88(v_q[i]);
    double ss = 0.0; for (int i=0;i<D;++i) ss += (double)v[i]*(double)v[i];
    float rms = std::sqrt((float)(ss / std::max(1, D)) + 1e-6f);
    float inv = 1.0f / rms;
    for (int i=0;i<D;++i){ float y = v[i] * inv * (weight.empty()?1.0f:weight[i]); v_q[i] = q88_from_float(y); }
}

// End-to-end fixed Q8.8 forward
bool ForwardFullQ88(const std::string& export_json, const std::vector<float>& xKD, int Din, std::vector<float>& y_out){
    ModelIR ir{}; if (!LoadExport(export_json, ir)) return false;
    // backbone path
    std::string bb_path = join_path(ir.base_dir, "backbone.json");
    BackboneDesc bb{}; if (!LoadBackbone(bb_path, bb, ir.base_dir)) return false;
    const int K = ir.seq_len; const int C = ir.proj_dim; const int P = bb.meta.patch_len; const int S = bb.meta.stride;
    ActLUT lut; lut.build();
    // 1) input projection per step: xKD(K,Din) -> XKC(K,C) in Q8.8
    std::vector<int64_t> shpW, shpB; std::vector<float> Wp, Bp; load_npy_float32(ir.proj.W, shpW, Wp); if (!ir.proj.B.empty()) load_npy_float32(ir.proj.B, shpB, Bp);
    const int out_f = (int)shpW[0], in_f = (int)shpW[1];
    if (out_f != C) { std::cerr << "proj out channels mismatch: expected C=" << C << ", got " << out_f << "\n"; return false; }
    if (in_f != Din) { std::cerr << "Din mismatch with proj weight: Din=" << Din << ", W.in=" << in_f << "\n"; return false; }
    // prepare quantized W,B for proj
    std::vector<int16_t> Wp_q(Wp.size()); for (size_t i=0;i<Wp.size();++i) Wp_q[i]=q88_from_float(Wp[i]);
    std::vector<int16_t> Bp_q(out_f, 0); if (!Bp.empty()) for (int o=0;o<out_f;++o) Bp_q[o]=q88_from_float(Bp[o]);
    // XKC Q8.8
    std::vector<int16_t> XKC(K*C, 0);
    for (int t=0;t<K;++t){
        // quantize input Din to Q8.8
        std::vector<int16_t> x_q(in_f);
        for (int i=0;i<in_f;++i){ float xf = xKD[t*Din + i]; x_q[i] = q88_from_float(xf); }
        // gemv
        for (int o=0;o<out_f;++o){ int32_t acc=0; for (int i=0;i<in_f;++i) acc += (int32_t)Wp_q[o*in_f+i]*(int32_t)x_q[i]; int16_t y = q88_from_acc32_round8(acc); if (!Bp.empty()) y = q88_add(y, Bp_q[o]); XKC[t*C + o] = y; }
    }
    // 2) patch embedding to T patches along time
    const int T = ((K - P) / S) + 1;
    // Simple stride window average projection using patch_embed as linear (flatten per patch: P*C -> d_model)
    std::vector<int64_t> shpPEw, shpPEb; std::vector<float> PEw, PEb;
    if (!bb.patch_embed.W.empty()) load_npy_float32(bb.patch_embed.W, shpPEw, PEw);
    if (!bb.patch_embed.B.empty()) load_npy_float32(bb.patch_embed.B, shpPEb, PEb);
    const int DM = bb.meta.d_model;
    if (PEw.empty() || shpPEw.size()!=2 || (int)shpPEw[0]!=DM || (int)shpPEw[1]!=(P*C)){
        std::cerr << "patch_embed W shape mismatch or missing. expected [" << DM << "," << (P*C) << "]\n";
        return false;
    }
    // Expect PEw shape [DM, P*C]
    std::vector<int16_t> PEw_q(PEw.size()); for (size_t i=0;i<PEw.size();++i) PEw_q[i]=q88_from_float(PEw[i]);
    std::vector<int16_t> PEb_q(DM, 0); if (!PEb.empty()) for (int o=0;o<DM;++o) PEb_q[o]=q88_from_float(PEb[o]);
    std::vector<int16_t> YTM(T*DM, 0);
    for (int t=0; t<T; ++t){
        // gather patch [P,C] -> flatten vec length P*C in Q8.8
        std::vector<int16_t> vec_q(P*C);
        for (int u=0; u<P; ++u){ for (int c=0;c<C;++c){ vec_q[u*C + c] = XKC[(t*S + u)*C + c]; }}
        // linear to d_model
        for (int o=0;o<DM;++o){ int32_t acc=0; for (int i=0;i<P*C;++i) acc += (int32_t)PEw_q[o*(P*C)+i] * (int32_t)vec_q[i]; int16_t y = q88_from_acc32_round8(acc); if (!PEb.empty()) y = q88_add(y, PEb_q[o]); YTM[t*DM + o] = y; }
    }
    // 3) backbone blocks
    for (int bi=0; bi<bb.meta.n_layer; ++bi){
        auto& bl = bb.blocks[bi];
        // in_proj: per timestep linear d_model->d_inner (if present) else identity d_model
        std::vector<int64_t> shpWl, shpBl; std::vector<float> Win, Bin;
        bool have_in = false;
        if (!bl.in_proj.W.empty()) { load_npy_float32(bl.in_proj.W, shpWl, Win); if (!bl.in_proj.B.empty()) load_npy_float32(bl.in_proj.B, shpBl, Bin); have_in = true; }
        const int DI = have_in ? (int)shpWl[0] : DM;
        if (have_in){
            if (shpWl.size()!=2 || (int)shpWl[1]!=DM){ std::cerr << "block "<<bi<<" in_proj W shape mismatch. expected [DI,"<<DM<<"]\n"; return false; }
            if (!Bin.empty() && (!shpBl.size() || (int)shpBl[0]!=DI)){ std::cerr << "block "<<bi<<" in_proj B len mismatch\n"; return false; }
        }
        // pre-quantize in_proj
        std::vector<int16_t> Win_q(Win.size()); for (size_t i=0;i<Win.size();++i) Win_q[i]=q88_from_float(Win[i]);
        std::vector<int16_t> Bin_q(DI, 0); if (!Bin.empty()) for (int o=0;o<DI;++o) Bin_q[o]=q88_from_float(Bin[o]);
        // u: (T, DI) q88
        std::vector<int16_t> U(T*DI, 0);
        for (int t=0;t<T;++t){
            if (have_in){
                for (int o=0;o<DI;++o){ int32_t acc=0; for (int i=0;i<DM;++i) acc += (int32_t)Win_q[o*DM + i] * (int32_t)YTM[t*DM + i]; int16_t y = q88_from_acc32_round8(acc); if (!Bin.empty()) y = q88_add(y, Bin_q[o]); U[t*DI + o] = y; }
            } else {
                for (int i=0;i<DM;++i) U[t*DI + i] = YTM[t*DM + i];
            }
        }
        // optional DW conv depthwise over time on U (channel=DI)
        if (bl.has_dw && !bl.dw_W.empty()){
            // quantize dw kernel to q88: Wf [DI,k], Bf [DI]
            int k = (int)(bl.dw_W.size() / std::max(1, DI));
            std::vector<int16_t> Wdw_q(bl.dw_W.size()); for (size_t i=0;i<bl.dw_W.size();++i) Wdw_q[i] = q88_from_float(bl.dw_W[i]);
            std::vector<int16_t> Bdw_q(DI, 0); if (!bl.dw_B.empty()) for (int c=0;c<DI;++c) Bdw_q[c] = q88_from_float(bl.dw_B[c]);
            std::vector<int16_t> U2(T*DI); dwconv_q88_time_same(U, T, DI, k, Wdw_q, Bdw_q, U2); U.swap(U2);
        }
        // dt_proj (per-timestep linear) -> dt
        std::vector<int16_t> dtq(DI, 0);
        if (!bl.dt_proj.W.empty()){
            for (int t=0;t<T;++t){
                std::vector<int16_t> x_q(DI); for (int i=0;i<DI;++i) x_q[i]=U[t*DI+i];
                std::vector<int16_t> y_q; LinearDesc L = bl.dt_proj; linear_q88_forward(L, x_q, y_q);
                for (int i=0;i<DI;++i) dtq[i] = y_q[i];
                // Update state with sigmoid(dt) (float LUT) and gate silu
                // Maintain a simple state s per channel
                static thread_local std::vector<int16_t> s;
                if ((int)s.size() != DI) s.assign(DI, 0);
                for (int j=0;j<DI;++j){
                    float lam = lut.sigmoid(float_from_q88(dtq[j]));
                    float sj = float_from_q88(s[j]);
                    float uj = float_from_q88(U[t*DI + j]);
                    float s_next = lam * sj + (1.0f - lam) * uj;
                    s[j] = q88_from_float(s_next);
                    U[t*DI + j] = s[j];
                }
            }
        }
        // gating: z = silu(U), then elementwise multiply
        for (int t=0;t<T;++t){
            for (int j=0;j<DI;++j){
                float zf = lut.silu_fn(float_from_q88(U[t*DI + j]));
                int16_t zq = q88_from_float(zf);
                U[t*DI + j] = q88_mul(U[t*DI + j], zq);
            }
        }
        // out_proj to DM and residual: YTM = 2*YTM + out_proj(U)
        std::vector<int64_t> shpWo, shpBo; std::vector<float> Wout, Bout;
        if (!bl.out_proj.W.empty()) load_npy_float32(bl.out_proj.W, shpWo, Wout);
        if (!bl.out_proj.B.empty()) load_npy_float32(bl.out_proj.B, shpBo, Bout);
        if (Wout.empty() || shpWo.size()!=2 || (int)shpWo[0]!=DM || (int)shpWo[1]!=DI){ std::cerr << "block "<<bi<<" out_proj W shape mismatch. expected ["<<DM<<","<<DI<<"]\n"; return false; }
        if (!Bout.empty() && (!shpBo.size() || (int)shpBo[0]!=DM)){ std::cerr << "block "<<bi<<" out_proj B len mismatch\n"; return false; }
        std::vector<int16_t> Wout_q(Wout.size()); for (size_t i=0;i<Wout.size();++i) Wout_q[i]=q88_from_float(Wout[i]);
        std::vector<int16_t> Bout_q(DM, 0); if (!Bout.empty()) for (int o=0;o<DM;++o) Bout_q[o]=q88_from_float(Bout[o]);
        for (int t=0;t<T;++t){
            // y = out_proj(U[t])
            std::vector<int16_t> yq(DM, 0);
            for (int o=0;o<DM;++o){ int32_t acc=0; for (int i=0;i<DI;++i) acc += (int32_t)Wout_q[o*DI + i] * (int32_t)U[t*DI + i]; int16_t y = q88_from_acc32_round8(acc); if (!Bout.empty()) y = q88_add(y, Bout_q[o]); yq[o]=y; }
            // residual: 2*YTM + y
            for (int j=0;j<DM;++j){
                int16_t two_x = q88_add(YTM[t*DM+j], YTM[t*DM+j]);
                YTM[t*DM + j] = q88_add(two_x, yq[j]);
            }
        }
        // RMSNorm
        if (!bl.norm_weight.empty()){
            for (int t=0;t<T;++t){ std::vector<int16_t> v(DM); for (int j=0;j<DM;++j) v[j]=YTM[t*DM + j]; rmsnorm_q88_inplace(v, bl.norm_weight); for (int j=0;j<DM;++j) YTM[t*DM + j]=v[j]; }
        }
    }
    // final norm
    if (!bb.final_norm_weight.empty()){
        for (int t=0;t<T;++t){ std::vector<int16_t> v(DM); for (int j=0;j<DM;++j) v[j]=YTM[t*DM + j]; rmsnorm_q88_inplace(v, bb.final_norm_weight); for (int j=0;j<DM;++j) YTM[t*DM + j]=v[j]; }
    }
    // output heads (flat/pool inside backbone)
    std::vector<int16_t> feat_q; // expect C entries in Q8.8
    if (!bb.out_pool.W.empty()){
        // avg pool then linear
        std::vector<int16_t> agg(DM, 0);
        for (int j=0;j<DM;++j){ int32_t sum=0; for (int t=0;t<T;++t) sum += (int32_t)YTM[t*DM + j]; // sum in Q8.8
            // divide by T -> multiply by (1/T) in float and re-quantize to Q8.8
            float avgf = (float)sum / (float)T / 256.0f; agg[j] = q88_from_float(avgf); }
        // ensure out_pool W has shape [C, DM]
        std::vector<int64_t> shpOw, shpOb; std::vector<float> Ow, Ob; load_npy_float32(bb.out_pool.W, shpOw, Ow); if (!bb.out_pool.B.empty()) load_npy_float32(bb.out_pool.B, shpOb, Ob);
        if (shpOw.size()!=2 || (int)shpOw[1]!=DM){ std::cerr << "out_pool W.in mismatch, expected DM="<<DM<<"\n"; return false; }
        linear_q88_forward(bb.out_pool, agg, feat_q);
    } else if (!bb.out_flat.W.empty()){
        std::vector<int64_t> shpFw, shpFb; std::vector<float> Fw, Fb; load_npy_float32(bb.out_flat.W, shpFw, Fw); if (!bb.out_flat.B.empty()) load_npy_float32(bb.out_flat.B, shpFb, Fb);
        if (shpFw.size()!=2 || (int)shpFw[1]!=(T*DM)){ std::cerr << "out_flat W.in mismatch, expected T*DM="<<(T*DM)<<"\n"; return false; }
        std::vector<int16_t> flat(T*DM); for (int t=0;t<T;++t){ for (int j=0;j<DM;++j) flat[t*DM + j] = YTM[t*DM + j]; }
        linear_q88_forward(bb.out_flat, flat, feat_q);
    } else {
        std::cerr << "backbone outputs missing: neither out_pool nor out_flat provided\n";
        return false;
    }
    // 4) final head linear from C->2
    // Ensure head W shape [2, C] and C == feat_q size
    {
        std::vector<int64_t> shpHw; std::vector<float> Hw; load_npy_float32(ir.head.W, shpHw, Hw);
        if (shpHw.size()!=2){ std::cerr << "head W rank != 2\n"; return false; }
        int Cexp = (int)shpHw[1]; if (Cexp != (int)feat_q.size()){ std::cerr << "head W.in mismatch: got "<<Cexp<<", feat_len="<<(int)feat_q.size()<<"\n"; return false; }
    }
    std::vector<int16_t> y2_q; linear_q88_forward(ir.head, feat_q, y2_q);
    // dequantize to float
    y_out.resize(y2_q.size()); for (size_t i=0;i<y2_q.size();++i) y_out[i] = float_from_q88(y2_q[i]);
    return true;
}
