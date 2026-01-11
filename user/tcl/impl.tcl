# Implementation script
# Usage: vivado -mode batch -source tcl/impl.tcl

# Project setup (adjust part/board as needed)
if {![info exists ::env(PROJECT_NAME)]} { set ::env(PROJECT_NAME) hw_impl }
set proj_name $::env(PROJECT_NAME)
set proj_dir  [file normalize "./.vivado_${proj_name}"]
set top_name  slim_mac_mem_controller_combined_dp

# Part (set your device here)
if {![info exists ::env(FPGA_PART)]} { set ::env(FPGA_PART) xc7a200tsbg484-1 } ;# TODO: adjust
set part_name $::env(FPGA_PART)

# Create or open project
if {[file exists $proj_dir] && [file exists "$proj_dir/$proj_name.xpr"]} {
    open_project "$proj_dir/$proj_name.xpr"
} else {
    create_project $proj_name $proj_dir -part $part_name -force
    # Add sources (guard empty glob)
    set sv_files [glob -nocomplain *.sv]
    if {[llength $sv_files] > 0} {
        add_files $sv_files
    }
    set_property top $top_name [current_fileset]
}

# Read constraints
if {[file exists minimal_timing.xdc]} {
    add_files -fileset constrs_1 minimal_timing.xdc
}

# Synthesis
synth_design -top $top_name -part $part_name

# Opt design with retiming
opt_design -retiming

# Place
place_design

# Physical optimization (aggressive for setup/hold)
phys_opt_design -directive AggressiveExplore
phys_opt_design -directive AggressiveHoldFix

# Route
route_design

# Post-route hold fix (if needed)
phys_opt_design -directive AggressiveHoldFix

# Reports
report_timing_summary -file $proj_dir/timing_summary.rpt -max_paths 20
report_timing -delay_type min_max -max_paths 20 -nworst 10 -file $proj_dir/timing_paths.rpt
report_utilization -file $proj_dir/utilization.rpt

# Write bitstream (optional)
# write_bitstream -force $proj_dir/${top_name}.bit
