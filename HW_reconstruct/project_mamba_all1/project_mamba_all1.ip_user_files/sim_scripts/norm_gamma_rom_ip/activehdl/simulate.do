transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+norm_gamma_rom_ip  -L xilinx_vip -L xpm -L blk_mem_gen_v8_4_8 -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.norm_gamma_rom_ip xil_defaultlib.glbl

do {norm_gamma_rom_ip.udo}

run 1000ns

endsim

quit -force
