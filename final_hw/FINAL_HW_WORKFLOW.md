# final_hw 工作流（2026-04-21）

## 1) RTL 仿真
- 4-block 链路（功能对照）：
```powershell
cd E:\course\smamba\final_hw\vivado
python .\run_xsim_stage.py --stage reuse_mamba_4block_chain_top --clean
```
- stream shell 多帧连续输入（严格 X/Z 检查 + 帧边界检查）：
```powershell
cd E:\course\smamba\final_hw\vivado
python .\run_xsim_stage.py --stage reuse_mamba_board_shell_stream --clean
```
- 说明：
  - `tb_reuse_mamba_board_shell_stream.sv` 默认 `CHECK_FRAME0_GOLDEN=0`，用于“连续流/无 X/Z/帧边界”验证。
  - 若需要做单帧 golden 对照，改 `CHECK_FRAME0_GOLDEN=1`。

## 2) 综合扫频（IP stub）
```powershell
cd E:\course\smamba\final_hw\vivado
python .\run_synth_sweep.py --tops reuse_mamba_4block_chain_top reuse_mamba_board_shell_stream --ip_mode stub --periods 12 11 10 8 6 5
```
- 输出：`E:\course\smamba\final_hw\synth_runs\summary.csv`

## 3) 当前频率结论（chain4 / stream shell）
- `period=12.0ns`: WNS `+0.260ns`（可过）
- `period=11.0ns`: WNS `-0.740ns`
- `period=10.0ns`: WNS `-1.740ns`
- `period=5.0ns`: WNS `-6.740ns`
- 当前可收敛频率约 `~83MHz`（12ns 档位）。
- 5ns 档位当前主瓶颈已从 RMSNorm 转移到 SSM/EW 路径：
  - `u_ssm_core/u_ew/u_to_state_requant -> s_new_vec_reg[*]`

## 4) 本轮关键改动
- `reuse_mamba_board_shell_stream.v`
  - `tlast` 改为按帧计数输出（不再每拍拉高）。
  - 修复 preload/core 启动竞争，加入 `core_launch_pending`，避免多帧卡死。
- `reuse_mamba_board_shell.v`
  - `tlast` 改为按 `y_rows_cfg` 计数输出。
- `reuse_rmsnorm_scheduler.sv`
  - `RMS_APPROX_RECIP` 下改为无除法的 `2^k` 倒数近似，减少超长组合路径。
- `reuse_mamba_block_top.sv`
  - RMSNorm 实例默认使用 `RMS_APPROX_RECIP=1`（final_hw timing 优先）。
- `run_xsim_stage.py`
  - 去除重复 source，消除重复编译告警。
- `run_synth_sweep.py`
  - 支持 `--periods` 多时钟扫频。

## 5) 下一步建议
- 如果目标 `100MHz`：
  - 优先在 RMSNorm 内把 `ST_NORM` 再切 1 级寄存（乘法与量化分拍）。
  - 对 chain4 的 block 间 residual preload 增加寄存切分。
- 如果目标是“稳定上板先跑通”：
  - 固定 `12ns` 约束先收敛，后续再增量压频。
