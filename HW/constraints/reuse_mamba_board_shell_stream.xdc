## Clock constraint for top: reuse_mamba_board_shell_stream
## Target board flow: ZCU102 PL clock around 100 MHz

#create_clock -name sys_clk -period 12.000 [get_ports sys_clk]

## Keep reset asynchronous to timing closure targets.
#set_false_path -from [get_ports ext_reset_n]

## Conservative global uncertainty (can be tightened with board-level closure data).
#set_clock_uncertainty 0.200 [get_clocks sys_clk]

