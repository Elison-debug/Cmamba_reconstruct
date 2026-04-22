set projects [list \
  "E:/course/smamba/final_hw/project_mamba_final_hw/project_mamba_final_hw.xpr" \
  "E:/course/smamba/HW_reconstruct/project_mamba_all1/project_mamba_all1.xpr" \
]

foreach p $projects {
  puts "=== OPEN $p ==="
  if {![file exists $p]} {
    puts "MISSING: $p"
    continue
  }
  open_project $p
  update_compile_order -fileset sources_1
  close_project
}

puts "DONE"
exit
