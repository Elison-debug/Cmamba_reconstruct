open_project {E:\course\smamba\HW_reconstruct\project_mamba_all1\project_mamba_all1.xpr}
update_compile_order -fileset sources_1
update_compile_order -fileset sim_3
reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1
launch_simulation -simset sim_3 -mode post-synthesis -type functional
quit
