set script_dir [file normalize [file dirname [info script]]]
set root_dir   [file normalize [file join $script_dir ".."]]
set proj_name  "project_mamba_final_hw"
set proj_dir   [file join $root_dir $proj_name]
set xpr_path   [file join $proj_dir "${proj_name}.xpr"]
set import_legacy_bd 1

set old_bd_path [file join $root_dir ".." "HW_reconstruct" "project_mamba_all1" "project_mamba_all1.srcs" "sources_1" "bd" "design_1" "design_1.bd"]

proc add_local_xci_ips {root_dir} {
  set ip_xci_files [glob -nocomplain [file join $root_dir "ip" "*" "*.xci"]]
  if {[llength $ip_xci_files] == 0} {
    puts "[clock format [clock seconds] -format {%H:%M:%S}] no local xci found under [file join $root_dir ip]"
    return
  }
  foreach xci $ip_xci_files {
    set already [get_files -quiet $xci]
    if {[llength $already] == 0} {
      puts "[clock format [clock seconds] -format {%H:%M:%S}] add ip xci: $xci"
      add_files -norecurse $xci
    }
  }
}

proc normalize_local_xci_gen_dirs {root_dir proj_name} {
  set ip_xci_files [glob -nocomplain [file join $root_dir "ip" "*" "*.xci"]]
  foreach xci $ip_xci_files {
    set ip_name [file rootname [file tail $xci]]
    set want "../../${proj_name}/${proj_name}.gen/sources_1/ip/${ip_name}"
    set fh [open $xci r]
    set txt [read $fh]
    close $fh

    set txt [string map [list \
      "../../${proj_name}/${proj_name}.gen/sources_1/ip/${ip_name}" $want \
      "../../../${proj_name}/${proj_name}.gen/sources_1/ip/${ip_name}" $want \
      "../../../../${proj_name}/${proj_name}.gen/sources_1/ip/${ip_name}" $want \
      "../${proj_name}.gen/sources_1/ip/${ip_name}" $want \
      "../../${proj_name}.gen/sources_1/ip/${ip_name}" $want \
      "../../../${proj_name}.gen/sources_1/ip/${ip_name}" $want \
      "../../../../${proj_name}.gen/sources_1/ip/${ip_name}" $want \
      ] $txt]

    set fh [open $xci w]
    puts -nonewline $fh $txt
    close $fh
  }
}

proc add_legacy_bd_if_needed {old_bd_path} {
  if {![file exists $old_bd_path]} {
    puts "[clock format [clock seconds] -format {%H:%M:%S}] warning: legacy BD not found: $old_bd_path"
    return
  }
  set already [get_files -quiet */sources_1/bd/design_1/design_1.bd]
  if {[llength $already] == 0} {
    puts "[clock format [clock seconds] -format {%H:%M:%S}] import legacy BD: $old_bd_path"
    import_files -fileset sources_1 $old_bd_path
  } else {
    puts "[clock format [clock seconds] -format {%H:%M:%S}] legacy BD already present in sources_1"
  }
}

if {[file exists $xpr_path]} {
  puts "[clock format [clock seconds] -format {%H:%M:%S}] open existing project: $xpr_path"
  open_project $xpr_path

  # Clean stale module-reference wrapper IP that carries invalid string params.
  set stale_files [concat \
    [get_files -quiet */sources_1/bd/design_1/ip/design_1_reuse_mamba_board_sh_0_1/*] \
    [get_files -quiet *design_1_reuse_mamba_board_sh_0_1.xci] \
  ]
  if {[llength $stale_files] > 0} {
    puts "[clock format [clock seconds] -format {%H:%M:%S}] remove stale legacy BD/IP files from project sources"
    remove_files -quiet $stale_files
  }
  if {$import_legacy_bd} {
    add_legacy_bd_if_needed $old_bd_path
  }
  normalize_local_xci_gen_dirs $root_dir $proj_name
  add_local_xci_ips $root_dir
  update_compile_order -fileset sources_1
} else {
  puts "[clock format [clock seconds] -format {%H:%M:%S}] create project: $xpr_path"
  create_project -force $proj_name $proj_dir -part xczu9eg-ffvb1156-2-e
  set_property board_part xilinx.com:zcu102:part0:3.4 [current_project]

  set rtl_files [concat \
    [glob -nocomplain [file join $root_dir "rtl" "*.v"]] \
    [glob -nocomplain [file join $root_dir "rtl" "*.sv"]] \
    [glob -nocomplain [file join $root_dir "rtl_reuse_shared" "*.v"]] \
    [glob -nocomplain [file join $root_dir "rtl_reuse_shared" "*.sv"]] \
  ]
  if {[llength $rtl_files] > 0} {
    add_files -norecurse $rtl_files
  }

  set tb_files [concat \
    [glob -nocomplain [file join $root_dir "tb" "*.v"]] \
    [glob -nocomplain [file join $root_dir "tb" "*.sv"]] \
  ]
  if {[llength $tb_files] > 0} {
    add_files -fileset sim_1 -norecurse $tb_files
  }
  normalize_local_xci_gen_dirs $root_dir $proj_name
  add_local_xci_ips $root_dir

  if {$import_legacy_bd} {
    add_legacy_bd_if_needed $old_bd_path
  } else {
    puts "[clock format [clock seconds] -format {%H:%M:%S}] skip legacy BD import (import_legacy_bd=0)"
  }

  set_property top reuse_mamba_board_shell_stream [current_fileset]
  update_compile_order -fileset sources_1
  update_compile_order -fileset sim_1
  save_project_as $proj_name $proj_dir
}

if {[llength [get_filesets -quiet sim_3]] > 0} {
  set_property top tb_reuse_mamba_board_shell_ps [get_filesets sim_3]
}

puts "[clock format [clock seconds] -format {%H:%M:%S}] project ready"
start_gui
