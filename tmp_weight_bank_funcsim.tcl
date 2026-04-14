read_verilog -sv E:/course/smamba/HW_reconstruct/rtl_reuse_shared/reuse_weight_bank_rom.sv
read_verilog -sv E:/course/smamba/HW_reconstruct/rtl_reuse_shared/slim_multi_bank_wbuf_dp.sv
read_verilog -sv E:/course/smamba/HW_reconstruct/rtl_reuse_shared/reuse_weight_bank_storage_consistency_dut.sv
synth_design -top reuse_weight_bank_storage_consistency_dut -part xczu9eg-ffvb1156-2-e
write_verilog -mode funcsim -force E:/course/smamba/HW_reconstruct/tb/reuse_weight_bank_storage_consistency_dut_func_synth.v
quit
