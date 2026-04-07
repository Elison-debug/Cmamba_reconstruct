TOPLEVEL_LANG ?= verilog
SIM ?= icarus
MODULE ?= test_sigmoid4_vec
TOPLEVEL ?= sigmoid4_vec
RTL_TOP ?= ../../sigmoid4_vec.sv
EXTRA_SOURCES ?=
STUB_DIR ?= ./stubs
IP_SIM_DIR ?= ../../project_mamba_all1/project_mamba_all1.gen/sources_1/ip

export PYTHONPATH := $(shell pwd)

VERILOG_SOURCES = $(RTL_TOP) $(EXTRA_SOURCES)

include $(shell cocotb-config --makefiles)/Makefile.sim
