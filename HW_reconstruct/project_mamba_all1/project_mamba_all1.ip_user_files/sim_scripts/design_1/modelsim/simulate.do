onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc"  -L xpm -L axi_infrastructure_v1_1_0 -L axi_vip_v1_1_17 -L zynq_ultra_ps_e_vip_v1_0_17 -L xil_defaultlib -L xlconstant_v1_1_9 -L lib_cdc_v1_0_3 -L proc_sys_reset_v5_0_15 -L smartconnect_v1_0 -L axi_register_slice_v2_1_31 -L lib_pkg_v1_0_4 -L fifo_generator_v13_2_10 -L lib_fifo_v1_0_19 -L lib_srl_fifo_v1_0_4 -L axi_datamover_v5_1_33 -L axi_sg_v4_1_18 -L axi_dma_v7_1_32 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.design_1 xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {design_1.udo}

run 1000ns

quit -force
