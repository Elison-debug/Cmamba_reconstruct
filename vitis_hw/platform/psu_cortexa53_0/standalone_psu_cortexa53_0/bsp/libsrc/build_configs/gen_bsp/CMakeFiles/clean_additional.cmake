# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "E:\\course\\smamba\\vitis_hw\\platform\\psu_cortexa53_0\\standalone_psu_cortexa53_0\\bsp\\include\\diskio.h"
  "E:\\course\\smamba\\vitis_hw\\platform\\psu_cortexa53_0\\standalone_psu_cortexa53_0\\bsp\\include\\ff.h"
  "E:\\course\\smamba\\vitis_hw\\platform\\psu_cortexa53_0\\standalone_psu_cortexa53_0\\bsp\\include\\ffconf.h"
  "E:\\course\\smamba\\vitis_hw\\platform\\psu_cortexa53_0\\standalone_psu_cortexa53_0\\bsp\\include\\sleep.h"
  "E:\\course\\smamba\\vitis_hw\\platform\\psu_cortexa53_0\\standalone_psu_cortexa53_0\\bsp\\include\\xilffs.h"
  "E:\\course\\smamba\\vitis_hw\\platform\\psu_cortexa53_0\\standalone_psu_cortexa53_0\\bsp\\include\\xilffs_config.h"
  "E:\\course\\smamba\\vitis_hw\\platform\\psu_cortexa53_0\\standalone_psu_cortexa53_0\\bsp\\include\\xiltimer.h"
  "E:\\course\\smamba\\vitis_hw\\platform\\psu_cortexa53_0\\standalone_psu_cortexa53_0\\bsp\\include\\xtimer_config.h"
  "E:\\course\\smamba\\vitis_hw\\platform\\psu_cortexa53_0\\standalone_psu_cortexa53_0\\bsp\\lib\\libxilffs.a"
  "E:\\course\\smamba\\vitis_hw\\platform\\psu_cortexa53_0\\standalone_psu_cortexa53_0\\bsp\\lib\\libxiltimer.a"
  )
endif()
