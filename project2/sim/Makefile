################################################################################
# Project: UART UVM Verification Environment
# Author: vietthanh
# Date: 2026-02-22
# Description: Optimized Makefile for VCS/Verdi flow. 
#              Uses local /tmp for builds to bypass Network Drive (NFS/Samba) 
#              latency and locking issues.
################################################################################

#===============================================================================
# 1. User Configurations
#===============================================================================
TESTNAME      ?= uart_base_test
UVM_VERBOSITY ?= UVM_LOW
TIMESCALE      = 1ns/1ns
# SEED          ?= 1
LOG_DIR        = log

# Random Seed Logic
# Nếu SEED trống hoặc bằng random, thì lấy thời gian hệ thống
ifeq ($(strip $(SEED)),)
    REAL_SEED = $(shell date +%s)
else ifeq ($(strip $(SEED)),random)
    REAL_SEED = $(shell date +%s)
else
    REAL_SEED = $(SEED)
endif

#===============================================================================
# 2. Path & Tool Definitions
#===============================================================================
# Tool Definitions
VCS      = vcs -sverilog -full64 -LDFLAGS -Wl,--no-as-needed

# Dynamic Path Management: Extract project name from parent directory
CURRENT_DIR     := $(shell pwd)
PROJ_NAME       := $(notdir $(patsubst %/sim,%,$(CURRENT_DIR)))
LOCAL_BUILD_DIR  = /tmp/$(USER)_build_$(PROJ_NAME)_tmp
SIMV_EXE         = $(LOCAL_BUILD_DIR)/simv

# Compilation Flags
# -kdb: Enable Knowledge Database for Verdi
# +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR: Enforce explicit new() in UVM objects
COMMON_FLAGS = -timescale=$(TIMESCALE) \
               -ntb_opts uvm-1.2 -j4 \
               +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
               -kdb -debug_access+class+all -quiet \
               +define+UVM_NO_DEPRECATED

VCS_DEBUG = $(VCS) $(COMMON_FLAGS)
VCS_COV   = $(VCS) $(COMMON_FLAGS) -cm line+cond+tgl

# Runtime Simulation Arguments
SIM_ARGS = -no_save \
           +UVM_VERBOSITY=$(UVM_VERBOSITY) \
           +UVM_TR_RECORD +UVM_LOG_RECORD \
           +ntb_random_seed=$(REAL_SEED) -quiet
#            +UVM_PHASE_TRACE \
           -quiet

#===============================================================================
# 3. Build & Run Targets
#===============================================================================
.PHONY: build run gui all clean deep_clean prepare debug_path help

.DEFAULT_GOAL := help

help:
	@echo "Usage: make [target] [TESTNAME=...] [SEED=...]"
	@echo "Targets: build, run, all, gui, clean, deep_clean, debug_path"

# Setup necessary directories
prepare:
	@mkdir -p $(LOG_DIR)
	@mkdir -p $(LOCAL_BUILD_DIR)

# Debug Path Variables
debug_path:
	@echo "--- Makefile Path Debug ---"
	@echo "Current Dir    : $(CURRENT_DIR)"
	@echo "Project Name   : $(PROJ_NAME)"
	@echo "Local Build Dir: $(LOCAL_BUILD_DIR)"
	@echo "---------------------------"

# Compilation: Offload build artifacts to Local SSD (/tmp)
build: prepare
	@echo ">>> [VCS] Compiling Standard Debug Mode..."
	$(VCS_DEBUG) -f compile.f \
	             -l $(LOG_DIR)/build.log \
	             -Mdir=$(LOCAL_BUILD_DIR)/csrc \
	             -o $(SIMV_EXE)

# Execution: Run simulation from Local SSD
run: prepare
	@echo ">>> [SIM] Running Test: $(TESTNAME) (Seed: $(REAL_SEED))..."
	$(SIMV_EXE) $(SIM_ARGS) +UVM_TESTNAME=$(TESTNAME) -l $(LOG_DIR)/$(TESTNAME).log
	@echo ">>> [SIM] Finished. Log: $(LOG_DIR)/$(TESTNAME).log"

# Debugging: Open Verdi with UVM awareness
gui: prepare
	$(SIMV_EXE) $(SIM_ARGS) +UVM_TESTNAME=$(TESTNAME) -l $(LOG_DIR)/gui.log \
	-gui=verdi +UVM_VERDI_TRACE="UVM_AWARE+RAL+HIER+COMPWAVE" &

all: build run

#===============================================================================
# 4. Cleanup Management
#===============================================================================

JUNK_FILES = csrc simv.daidir simv.vdb ucli.key *.h mc.err \
             novas.conf novas.rc verdiLog vdCovLog xrun.history \
             xcelium.d work vsim.wlf sysBusyP.* run_simv *.ini sysBusyPLog

# Standard Clean: Remove local junk but keep logs and simv
clean:
	@echo ">>> Cleaning up compilation junk files..."
	rm -rf $(JUNK_FILES)
	@echo ">>> Cleanup finished."

# Deep Clean: Remove all generated files including the local /tmp directory
deep_clean:
	@echo ">>> Deep cleaning... Removing ALL generated artifacts."
	-rm -rf $(JUNK_FILES) simv* $(LOG_DIR) *.fsdb *.vdb *.log
	-rm -rf $(LOCAL_BUILD_DIR)
	@echo ">>> Project reset to clean state."