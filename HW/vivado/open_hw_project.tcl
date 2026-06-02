set script_dir [file normalize [file dirname [info script]]]
set hw_dir     [file normalize [file join $script_dir ".."]]
set proj_name  "project_mamba_hw_refactor"
set proj_dir   [file join $hw_dir $proj_name]
set xpr_path   [file join $proj_dir "${proj_name}.xpr"]

proc add_sv_files_from_dir {dir fileset} {
  if {![file exists $dir]} { return }
  set f [glob -nocomplain [file join $dir *.sv]]
  set v [glob -nocomplain [file join $dir *.v]]
  foreach src [concat $f $v] {
    if {[llength [get_files -quiet $src]] == 0} {
      add_files -fileset $fileset -norecurse $src
    }
  }
}

proc add_local_xci_ips {hw_dir} {
  set ip_xci_files [glob -nocomplain [file join $hw_dir "ip" "*" "*.xci"]]
  foreach xci $ip_xci_files {
    if {[llength [get_files -quiet $xci]] == 0} {
      add_files -norecurse $xci
    }
  }
}

if {[file exists $xpr_path]} {
  puts "Open existing project: $xpr_path"
  open_project $xpr_path
} else {
  puts "Create project: $xpr_path"
  create_project -force $proj_name $proj_dir -part xczu9eg-ffvb1156-2-e
  set_property board_part xilinx.com:zcu102:part0:3.4 [current_project]

  add_sv_files_from_dir [file join $hw_dir "rtl" "common"] sources_1
  add_sv_files_from_dir [file join $hw_dir "rtl" "linear"] sources_1
  add_sv_files_from_dir [file join $hw_dir "rtl" "state"] sources_1
  add_sv_files_from_dir [file join $hw_dir "rtl" "block"] sources_1
  add_sv_files_from_dir [file join $hw_dir "rtl" "legacy_reuse_shared"] sources_1
  add_sv_files_from_dir [file join $hw_dir "rtl" "shell"] sources_1
  add_sv_files_from_dir [file join $hw_dir "tb"] sim_1

  if {[file exists [file join $hw_dir "constraints" "reuse_mamba_board_shell_stream.xdc"]]} {
    add_files -fileset constrs_1 -norecurse [file join $hw_dir "constraints" "reuse_mamba_board_shell_stream.xdc"]
  }
  add_local_xci_ips $hw_dir

  set_property top slm_mamba_block_top [current_fileset]
  update_compile_order -fileset sources_1
  update_compile_order -fileset sim_1
  save_project_as $proj_name $proj_dir
}

puts "Project ready: $xpr_path"
start_gui


