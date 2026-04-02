onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib bias2sigmoid_fifo_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {bias2sigmoid_fifo.udo}

run 1000ns

quit -force
