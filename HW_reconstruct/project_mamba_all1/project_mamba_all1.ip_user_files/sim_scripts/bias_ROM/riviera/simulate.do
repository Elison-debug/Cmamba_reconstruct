transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+bias_ROM  -L xilinx_vip -L xpm -L blk_mem_gen_v8_4_8 -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.bias_ROM xil_defaultlib.glbl

do {bias_ROM.udo}

run 1000ns

endsim

quit -force
