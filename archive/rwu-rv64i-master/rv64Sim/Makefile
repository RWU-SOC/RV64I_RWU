# ======================================================================
#  rv64Sim / Makefile
#  • assemble  .asm  →  .o
#  • link      .o    →  <exe>      (ELF, no extension)
#  • objcopy   <exe> →  .v         (Verilog hex)
#    also copies a .mem file into ../sim/ for the RTL test-bench
# ======================================================================

# ----------- basic settings ------------------------------------------
TARGET      ?= rv64i          # what you get when you simply type “make”

# GNU RISC-V bare-metal tool-chain (Ubuntu pkg: gcc-riscv64-unknown-elf)
AS          = riscv64-unknown-elf-as
LD          = riscv64-unknown-elf-ld
CP          = riscv64-unknown-elf-objcopy

ASFLAGS     = -march=rv64i -mlittle-endian -g
LDFLAGS     = -b elf64-littleriscv
CPFLAGS     = -O verilog --verilog-data-width 4

# ----------- file lists (auto-generated) -----------------------------
ASM_SRC  := $(wildcard *.asm)          # e.g. foo.asm bar.asm
OBJS     := $(ASM_SRC:.asm=.o)         #          foo.o   bar.o
ELFS     := $(ASM_SRC:.asm=)           #          foo     bar
VERILOGS := $(ASM_SRC:.asm=.v)         #          foo.v   bar.v

# ----------- default goal --------------------------------------------
.DEFAULT_GOAL := $(TARGET)

# ======================================================================
#  Pattern rules
# ======================================================================

# ---------- 1.  .asm → .o  (assemble) ----------
%.o : %.asm
	@echo "[AS] $<"
	$(AS) $(ASFLAGS) -o $@ $< -al=$*.lst

# ---------- 2.  .o → .elf  (link) ----------
%.elf : %.o
	@echo "[LD] $< -> $@"
	$(LD) $(LDFLAGS) -o $@ $<

# ---------- 3.  .elf → .v  (+ copy .mem) ----------
%.v : %.elf
	@echo "[CP] $< -> $@"
	$(CP) $< $(CPFLAGS) $@
	sed -i 's/ /\n/g' $@
	sed -i 's/\r//g'  $@
	sed -i '1d'       $@
	cp -f $@ ../sim/riscvtest_tb_$*.mem
	cp -f $@ ../sim/riscvtest.mem

# ---------- 4.  convenience: “make foo” does the whole chain ----------
% : %.v ;


.PHONY: all
all: $(VERILOGS)
	@echo "Built: $(VERILOGS)"

.PHONY: clean
clean:
	@echo "Cleaning generated files"
	rm -f *.o *.lst
	rm -f *.v *.o *.elf
	
.PRECIOUS: %.elf %.o

