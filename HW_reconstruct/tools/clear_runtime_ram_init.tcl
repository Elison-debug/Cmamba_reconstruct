set repo_root [file normalize [pwd]]
set proj_path [file join $repo_root HW_reconstruct project_mamba_all1 project_mamba_all1.xpr]
open_project $proj_path
proc clear_blk_mem_init {ip_name} {
    set ip_obj [get_ips $ip_name]
    if {[llength $ip_obj] == 0} {return}
    set_property -dict [list \
        CONFIG.Load_Init_File {false} \
        CONFIG.Coe_File {no_coe_file_loaded} \
        CONFIG.Fill_Remaining_Memory_Locations {false}] $ip_obj
    generate_target all $ip_obj
}
clear_blk_mem_init inproj_ht_sram_ip
clear_blk_mem_init inproj_vec_out_sram_ip
clear_blk_mem_init s_buffer
update_compile_order -fileset sources_1
close_project
