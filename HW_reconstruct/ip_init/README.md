当前目录放给 Vivado blk_mem_gen IP 使用的初始化文件。

推荐边界：
- bias_ROM：必须加载真实内容
- u_xt_rom：仅旧版 mac_mem_controller/slim_mac_mem_controller 调试链需要
- inproj_ht_sram_ip / inproj_vec_out_sram_ip / s_buffer：可选零初始化，仅用于减少前仿 X
- slim_WBUF_bank_dp / outproj_WBUF_bank_dp：当前主链不靠 Vivado IP 初始化，改的是 reuse_weight_bank_rom + .mem，不要在 IP GUI 里重复配置

生成命令：

conda activate python-transformers
python HW_reconstruct\tools\make_vivado_ip_init.py

应用到 Vivado 工程：

E:\Xilinx\Vivado\2024.1\bin\vivado.bat -mode batch -source HW_reconstruct\tools\apply_vivado_ip_init.tcl
