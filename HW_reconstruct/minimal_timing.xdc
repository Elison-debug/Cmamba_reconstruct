# --------------------------------------------------------------------
# minimal_timing.xdc
# Top-level timing constraints for reuse_mamba_board_shell
# --------------------------------------------------------------------

# Main board clock
create_clock -name sys_clk -period 10.000 [get_ports sys_clk]

## Optional clock uncertainty (reasonable starting point)
set_clock_uncertainty 0.200 [get_clocks sys_clk]

## Treat external reset as asynchronous reset.
## Cut reset path into synchronous logic timing analysis.
set_false_path -from [get_ports ext_reset_n]

## Optional: also cut reset to all sequential async reset pins if present
set_false_path -from [get_ports ext_reset_n] -to [all_registers]

## If you want slightly narrower reset exception instead of all registers,
## use one of the following styles depending on synthesis names:
# set_false_path -from [get_ports ext_reset_n] -to [get_pins -hier * /R]
# set_false_path -from [get_ports ext_reset_n] -to [get_pins -hier * /CLR]
# set_false_path -from [get_ports ext_reset_n] -to [get_pins -hier * /PRE]
