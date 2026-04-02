transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+inproj_vec_out_sram_ip  -L xpm -L blk_mem_gen_v8_4_8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.inproj_vec_out_sram_ip xil_defaultlib.glbl

do {inproj_vec_out_sram_ip.udo}

run 1000ns

endsim

quit -force
