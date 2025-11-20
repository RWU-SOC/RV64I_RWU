# ======================================================================
# RWU-RV64I | Combined Firmware + Simulation Makefile
# Place exactly ONE .c file in this folder (c_complile/).
# Produces <name>.elf/.v/.map/.bin/.lst and sim .mem files.
# Can also run Vivado xsim by calling the ../sim/Makefile.
# ======================================================================

.SUFFIXES:

# -------- Toolchain --------
CC      := riscv64-unknown-elf-gcc
AS      := riscv64-unknown-elf-gcc
OBJCOPY := riscv64-unknown-elf-objcopy
SIZE    := riscv64-unknown-elf-size
OBJDUMP := riscv64-unknown-elf-objdump

# -------- Flags --------
ARCH    := -march=rv64i -mabi=lp64
COMMON  := -ffreestanding -nostdlib
CFLAGS  := $(ARCH) $(COMMON) -O2 -g -msmall-data-limit=0 -I.
ASFLAGS := $(CFLAGS)
LDFLAGS := $(ARCH) $(COMMON) -T linker.ld
CPFLAGS := -O verilog --verilog-data-width 4

# -------- Source selection --------
ifeq ($(wildcard c_compile),)
  SEL_DIR := .
else
  SEL_DIR := ./c_compileram obmization leve;lns in c
endif

ALL_CS       := $(wildcard $(SEL_DIR)/*.c)
NUM_SELECTED := $(words $(ALL_CS))
ifeq ($(NUM_SELECTED),0)
  $(error No .c file found in $(SEL_DIR)/. Keep exactly one C file.)
endif
ifneq ($(NUM_SELECTED),1)
  $(error More than one .c file found in $(SEL_DIR)/. Keep exactly one C file.)
endif

SRC_C := $(firstword $(ALL_CS))
APP   := $(strip $(basename $(notdir $(SRC_C))))

# Guard: reject whitespace in name
empty :=
space := $(empty) $(empty)
ifneq ($(findstring $(space),$(APP)),)
  $(error Source filename contains spaces: '$(APP)'. Please rename.)
endif

# -------- Outputs --------
CRT_OBJ := crt0.o
C_OBJ   := $(APP).o
ELF     := $(APP).elf
MAP     := $(APP).map
VHEX    := $(APP).v
BIN     := $(APP).bin
LST     := $(APP).lst

# -------- Sim outputs --------
SIMDIR  := ../sim
SIMMEM1 := riscvtest.mem
SIMMEM2 := riscvtest_tb_$(APP).mem

# -------- Default goal --------
.PHONY: all clean size who
.DEFAULT_GOAL := all

# ================== Firmware build ==================

all: who $(VHEX) $(BIN) $(LST) size

who:
	@echo "Building APP='$(APP)' from SRC_C='$(SRC_C)'"

# C -> obj
$(C_OBJ): $(SRC_C)
	@echo "[CC] $<"
	$(CC) $(CFLAGS) -c "$<" -o "$@"

# asm -> obj
$(CRT_OBJ): crt0.s
	@echo "[AS] $<"
	$(AS) $(ASFLAGS) -c "$<" -o "$@"

# link -> ELF (+map)
$(ELF): $(C_OBJ) $(CRT_OBJ) linker.ld
	@echo "[LD] $@"
	$(CC) $(LDFLAGS) -Wl,-Map="$(MAP)" -o "$@" $(C_OBJ) $(CRT_OBJ)

# ELF -> VHEX + copy to sim mem
$(VHEX): $(ELF)
	@echo "[CP] $< -> $@"
	$(OBJCOPY) $(CPFLAGS) "$<" "$@"
	sed -i 's/ /\n/g' "$@"
	sed -i 's/\r//g'  "$@"
	sed -i '1d'       "$@"
	@mkdir -p "$(SIMDIR)"
	cp -f "$@" "$(SIMDIR)/$(SIMMEM1)"
	cp -f "$@" "$(SIMDIR)/$(SIMMEM2)"

# ELF -> raw binary
$(BIN): $(ELF)
	@echo "[BIN] $< -> $@"
	$(OBJCOPY) -O binary "$<" "$@"

# ELF -> disassembly
$(LST): $(ELF)
	@echo "[DMP] $< -> $@"
	$(OBJDUMP) -d -S "$<" > "$@"

# ELF size
size: $(ELF)
	@echo "[SZ] $<"
	$(SIZE) --format=berkeley "$<"

clean:
	@echo "[RM] cleaning firmware build"
	rm -f *.o *.elf *.v *.map *.bin *.lst

# ================== Simulation targets ==================

VIVADO_SETTINGS ?= 
SIM_TEST := $(APP)

define _SIM_MAKE
$(MAKE) -C $(SIMDIR) TEST=$(SIM_TEST) $(1)
endef

ifeq ($(strip $(VIVADO_SETTINGS)),)
  SIM_CALL = $(_SIM_MAKE)
else
  SHELL := /bin/bash
  SIM_CALL = source "$(VIVADO_SETTINGS)"; $(_SIM_MAKE)
endif

.PHONY: sim waves simcompile simclean

sim: $(VHEX)
	@echo "[SIM] Running xsim for TEST=$(SIM_TEST)"
	@$(SIM_CALL) simulate

waves: $(VHEX)
	@echo "[SIM] Launching xsim GUI for TEST=$(SIM_TEST)"
	@$(SIM_CALL) waves

simcompile: $(VHEX)
	@echo "[SIM] Compiling/elaborating for TEST=$(SIM_TEST)"
	@$(SIM_CALL) compile

simclean:
	@echo "[SIM] Cleaning simulation outputs"
	@$(SIM_CALL) clean
