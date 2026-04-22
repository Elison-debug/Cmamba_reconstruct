set xpr "E:/course/smamba/final_hw/project_mamba_final_hw/project_mamba_final_hw.xpr"
open_project $xpr
update_compile_order -fileset sources_1
set files [glob -nocomplain E:/course/smamba/final_hw/ip/*/*.xci]
foreach f $files {
  set fh [open $f r]
  set txt [read $fh]
  close $fh
  regexp {"gen_directory"\s*:\s*"([^"]+)"} $txt _ g
  regexp {"OUTPUTDIR"\s*:\s*\[\s*\{\s*"value"\s*:\s*"([^"]+)"} $txt _ o
  puts "$f"
  puts "  GEN=$g"
  puts "  OUT=$o"
}
close_project
exit