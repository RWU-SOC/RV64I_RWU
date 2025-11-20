#======================================================================
#  sim / Makefile   –   Vivado-XSIM compile & run
#======================================================================

# ---------------------------------------------------------------------
# Select which memory image (produced by rv64Sim) to load
# ---------------------------------------------------------------------
TEST ?= rv64i                              # override:  make TEST=<name>

TB_TOP := tb_rv64i
# single universal test-bench
SNAP   := $(TB_TOP)_snapshot
# elaboration snapshot name
MEM_SRC := riscvtest_tb_$(TEST).mem        # comes from rv64Sim
MEM_DST := riscvtest.mem                   # name expected by tb_rv64i

# ---------------------------------------------------------------------
# Vivado compile options
# ---------------------------------------------------------------------
COMP_OPTS_SV = --incr --relax
DEFINES_SV   = -d LOGIC_SV

# ---------------------------------------------------------------------
# SystemVerilog sources  (add new RTL files here if needed)
# ---------------------------------------------------------------------
SOURCES_SV := \
	../src/as_pack.sv \
	../src/asRegFile.sv \
	../src/asAdd.sv \
	../src/asDMemBack.sv \
	../src/asDMemFront.sv \
	../src/asDMemCore.sv \
	../src/asDMem.sv \
	../src/asIMem.sv \
	../src/asImmGen.sv \
	../src/asMux2.sv \
	../src/asMux3.sv \
	../src/asPC.sv \
	../src/asAluRV.sv \
	../src/asControlAll.sv \
	../src/asDelReg.sv \
	../ip_jtag/src/tap_fsm.sv \
	../ip_jtag/src/ir_cell.sv \
	../ip_jtag/src/dr_cell.sv \
	../ip_jtag/src/scan_cell.sv \
	../ip_jtag/src/by_cell.sv \
	../ip_jtag/src/ir_reg.sv \
	../ip_jtag/src/dr_reg.sv \
	../ip_jtag/src/ir_decode.sv \
	../ip_jtag/src/jtag.sv \
	../src/asMBpi.sv \
	../src/asSBpi.sv \
	../src/asGpio.sv \
	../src/asGpioTop.sv \
	../src/asCPU.sv \
	../src/asTopMem.sv \
	../src/asDecode.sv \
	../src/asSBpiMem.sv \
	../src/asCguCore.sv \
	../src/asCgu.sv \
	../tb/tb_regfile.sv \
	../tb/tb_alu.sv \
	../tb/tb_alurv.sv \
	../tb/tb_control.sv \
	../tb/tb_rv64i_readgpioid.sv \


# ---------------------------------------------------------------------
# Default goal
# ---------------------------------------------------------------------
.DEFAULT_GOAL := simulate

#======================================================================
#  Targets
#======================================================================

# ---- run head-less simulation ---------------------------------------
simulate : $(SNAP).wdb
	@echo "\n### RUNNING SIMULATION ###"
	xsim "$(SNAP)" --runall --onfinish quit \
		--wdb "$(SNAP).wdb"

# ---- open waveform GUI ---------------------------------------------
waves : simulate
	@echo "\n### OPENING WAVES ###"
	xsim "$(SNAP)" -gui -tclbatch ./xsim_cfg2.tcl



# ---- elaboration snapshot ------------------------------------------
$(SNAP).wdb : .elab.timestamp ;

.elab.timestamp : .comp_sv.timestamp
	@echo "\n### ELABORATING ###"
	xelab -debug all -top $(TB_TOP) -snapshot "$(SNAP)"
	touch $@

# ---- compile SystemVerilog + copy .mem -----------------------------
.comp_sv.timestamp : $(SOURCES_SV) $(MEM_SRC)
	@echo "\n### COMPILING SYSTEMVERILOG ###"
	xvlog --sv $(COMP_OPTS_SV) $(DEFINES_SV) $(SOURCES_SV)
	@echo "[MEM]  $(MEM_SRC) -> $(MEM_DST)"
	cp -f $(MEM_SRC) $(MEM_DST)
	touch $@

.PHONY: compile
compile : .comp_sv.timestamp

# ---- clean ----------------------------------------------------------
.PHONY: clean
clean :
	@echo "Cleaning simulator outputs"
	rm -rf *.jou *.log *.pb *.wdb xsim.dir *.txt
	rm -rf .*.timestamp vivado_pid* *.mem

# ---- vivado environment helper -------------------------------------
.PHONY: activate
activate :
	@source /tools/Xilinx/Vivado/2024.2/settings64.sh
	@echo "Vivado environment sourced"
