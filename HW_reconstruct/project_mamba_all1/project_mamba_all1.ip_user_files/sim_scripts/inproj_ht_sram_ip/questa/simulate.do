onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib inproj_ht_sram_ip_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {inproj_ht_sram_ip.udo}

run 1000ns

quit -force
