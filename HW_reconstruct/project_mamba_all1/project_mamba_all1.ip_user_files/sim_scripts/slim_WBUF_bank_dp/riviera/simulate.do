transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+slim_WBUF_bank_dp  -L xpm -L blk_mem_gen_v8_4_8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.slim_WBUF_bank_dp xil_defaultlib.glbl

do {slim_WBUF_bank_dp.udo}

run 1000ns

endsim

quit -force
