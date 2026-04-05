# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ACC_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ADDR_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXIL_ADDR_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "D" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FRAC_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "G_FRAC_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "LUT_FILE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "N_BANK" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PIPE_LAT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S_ADDR_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TILE_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WADDR_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WDEPTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "XT_ADDR_W" -parent ${Page_0}


}

proc update_PARAM_VALUE.ACC_WIDTH { PARAM_VALUE.ACC_WIDTH } {
	# Procedure called to update ACC_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ACC_WIDTH { PARAM_VALUE.ACC_WIDTH } {
	# Procedure called to validate ACC_WIDTH
	return true
}

proc update_PARAM_VALUE.ADDR_BITS { PARAM_VALUE.ADDR_BITS } {
	# Procedure called to update ADDR_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_BITS { PARAM_VALUE.ADDR_BITS } {
	# Procedure called to validate ADDR_BITS
	return true
}

proc update_PARAM_VALUE.AXIL_ADDR_W { PARAM_VALUE.AXIL_ADDR_W } {
	# Procedure called to update AXIL_ADDR_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIL_ADDR_W { PARAM_VALUE.AXIL_ADDR_W } {
	# Procedure called to validate AXIL_ADDR_W
	return true
}

proc update_PARAM_VALUE.D { PARAM_VALUE.D } {
	# Procedure called to update D when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.D { PARAM_VALUE.D } {
	# Procedure called to validate D
	return true
}

proc update_PARAM_VALUE.DATA_W { PARAM_VALUE.DATA_W } {
	# Procedure called to update DATA_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_W { PARAM_VALUE.DATA_W } {
	# Procedure called to validate DATA_W
	return true
}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.FRAC_BITS { PARAM_VALUE.FRAC_BITS } {
	# Procedure called to update FRAC_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FRAC_BITS { PARAM_VALUE.FRAC_BITS } {
	# Procedure called to validate FRAC_BITS
	return true
}

proc update_PARAM_VALUE.G_FRAC_BITS { PARAM_VALUE.G_FRAC_BITS } {
	# Procedure called to update G_FRAC_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.G_FRAC_BITS { PARAM_VALUE.G_FRAC_BITS } {
	# Procedure called to validate G_FRAC_BITS
	return true
}

proc update_PARAM_VALUE.LUT_FILE { PARAM_VALUE.LUT_FILE } {
	# Procedure called to update LUT_FILE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LUT_FILE { PARAM_VALUE.LUT_FILE } {
	# Procedure called to validate LUT_FILE
	return true
}

proc update_PARAM_VALUE.N_BANK { PARAM_VALUE.N_BANK } {
	# Procedure called to update N_BANK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_BANK { PARAM_VALUE.N_BANK } {
	# Procedure called to validate N_BANK
	return true
}

proc update_PARAM_VALUE.PIPE_LAT { PARAM_VALUE.PIPE_LAT } {
	# Procedure called to update PIPE_LAT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PIPE_LAT { PARAM_VALUE.PIPE_LAT } {
	# Procedure called to validate PIPE_LAT
	return true
}

proc update_PARAM_VALUE.S_ADDR_W { PARAM_VALUE.S_ADDR_W } {
	# Procedure called to update S_ADDR_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_ADDR_W { PARAM_VALUE.S_ADDR_W } {
	# Procedure called to validate S_ADDR_W
	return true
}

proc update_PARAM_VALUE.TILE_SIZE { PARAM_VALUE.TILE_SIZE } {
	# Procedure called to update TILE_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TILE_SIZE { PARAM_VALUE.TILE_SIZE } {
	# Procedure called to validate TILE_SIZE
	return true
}

proc update_PARAM_VALUE.WADDR_W { PARAM_VALUE.WADDR_W } {
	# Procedure called to update WADDR_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WADDR_W { PARAM_VALUE.WADDR_W } {
	# Procedure called to validate WADDR_W
	return true
}

proc update_PARAM_VALUE.WDEPTH { PARAM_VALUE.WDEPTH } {
	# Procedure called to update WDEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WDEPTH { PARAM_VALUE.WDEPTH } {
	# Procedure called to validate WDEPTH
	return true
}

proc update_PARAM_VALUE.XT_ADDR_W { PARAM_VALUE.XT_ADDR_W } {
	# Procedure called to update XT_ADDR_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.XT_ADDR_W { PARAM_VALUE.XT_ADDR_W } {
	# Procedure called to validate XT_ADDR_W
	return true
}


proc update_MODELPARAM_VALUE.TILE_SIZE { MODELPARAM_VALUE.TILE_SIZE PARAM_VALUE.TILE_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TILE_SIZE}] ${MODELPARAM_VALUE.TILE_SIZE}
}

proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.ACC_WIDTH { MODELPARAM_VALUE.ACC_WIDTH PARAM_VALUE.ACC_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ACC_WIDTH}] ${MODELPARAM_VALUE.ACC_WIDTH}
}

proc update_MODELPARAM_VALUE.FRAC_BITS { MODELPARAM_VALUE.FRAC_BITS PARAM_VALUE.FRAC_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FRAC_BITS}] ${MODELPARAM_VALUE.FRAC_BITS}
}

proc update_MODELPARAM_VALUE.N_BANK { MODELPARAM_VALUE.N_BANK PARAM_VALUE.N_BANK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_BANK}] ${MODELPARAM_VALUE.N_BANK}
}

proc update_MODELPARAM_VALUE.WDEPTH { MODELPARAM_VALUE.WDEPTH PARAM_VALUE.WDEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WDEPTH}] ${MODELPARAM_VALUE.WDEPTH}
}

proc update_MODELPARAM_VALUE.WADDR_W { MODELPARAM_VALUE.WADDR_W PARAM_VALUE.WADDR_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WADDR_W}] ${MODELPARAM_VALUE.WADDR_W}
}

proc update_MODELPARAM_VALUE.DATA_W { MODELPARAM_VALUE.DATA_W PARAM_VALUE.DATA_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_W}] ${MODELPARAM_VALUE.DATA_W}
}

proc update_MODELPARAM_VALUE.XT_ADDR_W { MODELPARAM_VALUE.XT_ADDR_W PARAM_VALUE.XT_ADDR_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.XT_ADDR_W}] ${MODELPARAM_VALUE.XT_ADDR_W}
}

proc update_MODELPARAM_VALUE.D { MODELPARAM_VALUE.D PARAM_VALUE.D } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.D}] ${MODELPARAM_VALUE.D}
}

proc update_MODELPARAM_VALUE.PIPE_LAT { MODELPARAM_VALUE.PIPE_LAT PARAM_VALUE.PIPE_LAT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PIPE_LAT}] ${MODELPARAM_VALUE.PIPE_LAT}
}

proc update_MODELPARAM_VALUE.ADDR_BITS { MODELPARAM_VALUE.ADDR_BITS PARAM_VALUE.ADDR_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_BITS}] ${MODELPARAM_VALUE.ADDR_BITS}
}

proc update_MODELPARAM_VALUE.LUT_FILE { MODELPARAM_VALUE.LUT_FILE PARAM_VALUE.LUT_FILE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LUT_FILE}] ${MODELPARAM_VALUE.LUT_FILE}
}

proc update_MODELPARAM_VALUE.S_ADDR_W { MODELPARAM_VALUE.S_ADDR_W PARAM_VALUE.S_ADDR_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_ADDR_W}] ${MODELPARAM_VALUE.S_ADDR_W}
}

proc update_MODELPARAM_VALUE.G_FRAC_BITS { MODELPARAM_VALUE.G_FRAC_BITS PARAM_VALUE.G_FRAC_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.G_FRAC_BITS}] ${MODELPARAM_VALUE.G_FRAC_BITS}
}

proc update_MODELPARAM_VALUE.AXIL_ADDR_W { MODELPARAM_VALUE.AXIL_ADDR_W PARAM_VALUE.AXIL_ADDR_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIL_ADDR_W}] ${MODELPARAM_VALUE.AXIL_ADDR_W}
}

