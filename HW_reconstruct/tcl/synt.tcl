# ================================================================
# Vivado Synthesis Automation Script (Timing + Fanout Fix)
# Project: Mamba SSM
# Author: Shengjie Chen
# ================================================================

# -------------------- [0] 基本路径设置 --------------------
set proj_path     "D:/Mamba/project_mamba/project_mamba.xpr"
set report_dir    "D:/Mamba/CMamba/Verilog/reports"
set fanout_target 16
set net_pattern   "*xt_stage_cnt_reg*"
set top_module    "mac_mem_controller_combined"
set part_name     "xczu9eg-ffvb1156-2-e"

# 自动创建报告目录
if {![file exists $report_dir]} {
    file mkdir $report_dir
}

# -------------------- [1] 安全日志函数（级别 + 消息） --------------------
proc log {level msg} {
    set formatted [format "\n=== \[%s\] %s ===" $level $msg]
    puts $formatted
}

# -------------------- [2] 打开 Vivado 工程 --------------------
log INFO "Opening project: $proj_path"
if {[catch {open_project $proj_path} err]} {
    if {[string match "*already open*" $err]} {
        log WARN "Project already open, reusing existing session"
    } else {
        error $err
    }
}

# -------------------- [3] 清理旧的综合运行 --------------------
if {[get_runs synth_1 -quiet] ne ""} {
    log INFO "Resetting previous synthesis run (synth_1)"
    reset_run synth_1
}

# -------------------- [4] 配置综合属性 --------------------
log INFO "Configuring synthesis settings"
set_property top $top_module [current_fileset]
set_property part $part_name [current_project]
set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE AreaOptimized_high [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]

# -------------------- [5] 启动综合 --------------------
set synth_run [get_runs synth_1]
set synth_run_dir [get_property DIRECTORY $synth_run]

log INFO "Launching synthesis run synth_1"
if {[catch {launch_runs synth_1 -jobs 8 -to_step synth_design} launch_err]} {
    if {[string match "*is already running*" $launch_err]} {
        log WARN "synth_1 already running, waiting for completion"
    } else {
        error $launch_err
    }
}

if {[catch {wait_on_run synth_1} wait_err]} {
    log ERROR "wait_on_run failed, see $synth_run_dir/run.log"
    error $wait_err
}

set synth_status [string tolower [get_property STATUS $synth_run]]
if {![string match "*complete*" $synth_status]} {
    log ERROR "synth_1 finished with status '$synth_status'. Check $synth_run_dir/run.log"
    error "synth_1 did not complete successfully"
}

# -------------------- [6] 打开综合结果 --------------------
log INFO "Opening synthesized design"
open_run synth_1

# -------------------- [7] 应用扇出约束 --------------------
log INFO "Searching nets matching pattern: $net_pattern"
set found_nets [get_nets -hier -filter "NAME =~ $net_pattern"]

if {[llength $found_nets] == 0} {
    log WARN "No nets found matching '$net_pattern', skipping fanout constraint"
} else {
    log INFO "Found [llength $found_nets] nets, applying MAX_FANOUT = $fanout_target"
    foreach net $found_nets {
        set_property MAX_FANOUT $fanout_target $net
    }
}
# 限制 tile_cnt_reg 扇出
set net_pattern_tile "*tile_cnt_reg*"
set found_tile [get_nets -hier -filter "NAME =~ $net_pattern_tile"]

if {[llength $found_tile] != 0} {
    log INFO "Found [llength $found_tile] tile_cnt_reg nets, applying MAX_FANOUT = 16"
    foreach net $found_tile {
        set_property MAX_FANOUT 16 $net
    }
}

# -------------------- [8] 重新优化设计 --------------------
log INFO "Running opt_design for timing improvement"
opt_design -directive Explore
#opt_design

# -------------------- [9] 生成报告 --------------------
log INFO "Generating synthesis reports in $report_dir"
report_high_fanout_nets -max_nets 20 -file "$report_dir/high_fanout_post_opt.rpt"
report_timing_summary   -file "$report_dir/timing_summary_post_opt.rpt"
report_clock_utilization -file "$report_dir/clock_util_post_opt.rpt"

# -------------------- [10] 脚本完成 --------------------
log INFO "Vivado synthesis + fanout optimization completed successfully!"
