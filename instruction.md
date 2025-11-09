标题：CMamba 量化与硬件推理落地指南

目标

实现实时推理可部署的整数域（INT8/INT16）版本：
Host 侧原型：PyTorch + C++ Extension（bit‑true 准确验证）。
纯 C++ Runtime（与导出的 JSON/NPY 配套），便于嵌入式/FPGA。
统一量化规范（建议）

激活：per‑tensor asymmetric INT8（scale: 标量，zp: 标量）。
权重：per‑out‑channel symmetric INT8（scale: 向量，长度=out_channels）。
INT16 Q8.8 路径：作为“bit‑true”原型（整数乘加 + RNE 舍入 + 饱和），激活/权重都用 Q8.8 定点，非线性用 LUT。
说明：若需与现有 LSQ（per‑channel act）完全一致，可以切换到“激活 per‑channel symmetric”的规范，但要统一两后端实现与导出格式。
实现路线

规范固化与对齐

统一 QConv1x1INT 的激活/权重量化策略（Python LSQ 与 C++ STE 一致），修正 refactor/quant/cpp_backend.py 中的 a_scale 形状与用法。
将状态字典迁移/填充逻辑集中到单文件（如 refactor/core/ckpt_compat.py），对外提供 normalize_state_dict(ckpt, model, backend)。
覆盖所有需要量化的算子

1x1 Conv：已具备（QConv1x1INT）。
Kx1 Conv（Patch Embedding/DWConv）：补齐 QConv1dINT 的 cpp 后端（现有 python 版 + INT16 Q88 版）。
dt_proj（SelectiveScanIC 内部 1x1）：换成 QConv1x1INT。
SiLU/Sigmoid：bit‑true 用 LUT（refactor/quant/int16/backend.py 已有），LSQ 路径用浮点激活后量化（可先简化）。
RMSNorm：阶段性策略
V1：float 执行 + 量化回整数（混合精度，保证正确性）。
V2：定点 RMSNorm（近似/查表/牛顿迭代），确保位真。
移除危险 fallback

refactor/core/cmamba_slim.py:_QuantConv1d 中去掉“无 QConv1dINT 时降级为 QConv1x1INT”的逻辑，改为回退浮点 Conv1d 或报错，以免语义变化。
为 block/proj/head/patch_embedding 明确：quantize=True 时若后端不可用则报错；quantize=False 时走浮点。
Bit‑true 路径（INT16 Q8.8）

利用 refactor/quant/int16/backend.py 的 Int16Conv1x1Q88/Int16Conv1dKxQ88/Int16SiLULUT/Int16SigmoidLUT，逐层替换：
proj/head/patch_embedding/dwconv/dt_proj 用 INT16 conv。
递推（SelectiveScan）在整数域实现：s_t = lam ⊙ s_{t-1} + (1−lam) ⊙ u_t。lam = sigmoid(dt_proj(u_t))，sigmoid 用 LUT；乘法为 Q8.8 定点；保持 RNE 舍入与饱和策略一致。
统一 scale 管理：定义模块级 scale 分配与校准顺序；支持统计尝试（maxabs/p99）并保存到 ckpt。
测试：构建小输入向量，对比 float 基线与 INT16 输出误差（MSE/MaxAE），计数饱和次数。
C++ Runtime 打通

导出：在 export/pack.py 输出所有层的 W/B 与量化参数（act_scale/zp、w_scale），以及非线性 LUT（如需要）。
runtime_cpp/*：按 JSON 加载，调用 C++ INT 卷积/LUT/递推，实现完整前向。与 PyTorch+C++ extension bit‑true 路径对比输出。
工具：提供 compare_ref.py，用同一输入/权重在两种路径跑，输出差值直方图+统计。
Eval/Test 集成

refactor/core/eval.py/test.py 加入 --mode=fp32|quant8|quant16|bittrue 选项，统一入口。
统计并输出：精度指标、饱和值、scale 分布、对比曲线等；CSV 与图保持一致布局。
代码修改建议（摘选）

refactor/core/cmamba_slim.py:53
将 53–55 的 QConv1dINT 缺失降级为 QConv1x1INT 的逻辑删除；
若 quant 后端不可用则使用浮点 Conv1d（self.conv）或直接报错。
refactor/quant/cpp_backend.py:99
8-bit 路径将 a_scale 改为标量参数（per‑tensor），或将 forward 改为 per‑channel symmetric（与 LSQ 对齐），避免出现“参数是向量但按标量使用”的不一致。
refactor/core/mamba_regressor.py:16 与 refactor/core/cmamba_slim.py:17
将重复的 _Pointwise1x1 提取到 refactor/core/layers.py，保持行为一致。
refactor/core/eval.py
将“ckpt 权重键迁移 + scale 补齐”的大段逻辑抽到独立工具函数，减少重复与错误面。
SelectiveScanIC（refactor/core/cmamba_slim.py:206 起）
dt_proj 换 QConv1x1INT；加入选择：在量化模式下用 INT16 LUT 近似 sigmoid，或者保留浮点激活+回量化。
落地顺序（务实版本）

先统一 QConv1x1INT/1dINT 的量化规范（8-bit 路径）。
修正危险 fallback；补齐 dt_proj 的量化实现（至少 LSQ/C++ STE）。
在 eval/test 中加上模式切换，确认 float vs 8-bit 的精度与可视化。
接着推进 INT16 Q8.8 bit‑true（先 proj/head/patch_embedding → 再 DWConv → 再 SSM 递推）。
完成导出与 C++ runtime 打通，对齐 bit‑true。
回到训练：按需要做 QAT 或蒸馏，提升量化精度。