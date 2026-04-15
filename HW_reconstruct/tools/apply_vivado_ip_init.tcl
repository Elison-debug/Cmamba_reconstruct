set repo_root [file normalize [file join [file dirname [info script]] .. ..]]
set proj_path [file join $repo_root HW_reconstruct project_mamba_all1 project_mamba_all1.xpr]
set init_dir  [file join $repo_root HW_reconstruct ip_init test_case3_smoke block0]

open_project $proj_path

proc apply_blk_mem_init {ip_name coe_file} {
    set ip_obj [get_ips $ip_name]
    if {[llength $ip_obj] == 0} {
        puts "WARN: IP '$ip_name' not found, skip."
        return
    }
    set_property -dict [list \
        CONFIG.Load_Init_File {true} \
        CONFIG.Coe_File $coe_file \
        CONFIG.Fill_Remaining_Memory_Locations {true}] $ip_obj
    generate_target all $ip_obj
}

apply_blk_mem_init bias_ROM               [file join $init_dir bias_ROM_block.coe]
apply_blk_mem_init u_xt_rom               [file join $init_dir u_xt_rom_block.coe]
apply_blk_mem_init inproj_ht_sram_ip      [file join $init_dir inproj_ht_sram_zero.coe]
apply_blk_mem_init inproj_vec_out_sram_ip [file join $init_dir inproj_vec_out_sram_zero.coe]
apply_blk_mem_init s_buffer               [file join $init_dir s_buffer_zero.coe]

update_compile_order -fileset sources_1

close_project
