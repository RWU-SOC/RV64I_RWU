**All Makefiles Analysis**

Date: 20.11.25

This document summarizes the purpose, important variables and targets, usage notes, and recommended fixes for each `Makefile` found in the folder `rwu-rv64i-master`.

**Repository Makefiles**
- **`rv64Sim/Makefile`**
- **`spec/Makefile`**
- **`Report/Makefile`**
- **`c_complile/Makefile`**
- **`ip_uart/sim/Makefile`**
- **`ip_jtag/sim/Makefile`**

**Overview**
- **Purpose:** Build RISC‑V firmware, prepare simulation artifacts, and run Vivado simulations for RTL IP/testbenches.
- **Tooling:** RISC‑V GNU toolchain (`riscv64-unknown-elf-*`), Vivado tools (`xvlog`, `xelab`, `xsim`), LaTeX tools (`pdflatex`, `biber`).

**`rv64Sim/Makefile`**
- **Purpose:** Assemble `*.asm` files into ELF, convert to Verilog hex (`*.v`), and copy `.mem` files into `../sim/` for the RTL testbench.
- **Key variables:** `TARGET`, `AS`, `LD`, `CP`, `ASFLAGS`, `LDFLAGS`, `CPFLAGS`.
- **Important targets and rules:**
  - `%.o : %.asm` — assemble (uses `riscv64-unknown-elf-as`).
  - `%.elf : %.o` — link (uses `riscv64-unknown-elf-ld`).
  - `%.v : %.elf` — objcopy to verilog hex and postprocess with `sed`, then copy to `../sim/riscvtest_tb_<name>.mem` and `../sim/riscvtest.mem`.
  - Default goal uses `TARGET` and there is an `all` target that builds all `VERILOGS`.
- **Usage:**
  - `make` or `make <name>` if `<name>.asm` exists — runs assemble → link → objcopy → copy.
- **Notes:** Uses `sed` to reformat the objcopy output and remove the first line; behavior is intentional for RTL testbench consumption.

**`spec/Makefile`**
- **Purpose:** Build the main LaTeX document `00_rwurv64i_top.tex` and run `biber` for bibliography.
- **Key targets:** `latex`, `bib`, `all` (runs multiple pdflatex + biber passes), `clean`.
- **Usage:** `make` or `make all` to generate PDF; `make clean` to remove auxiliary files.
- **Notes / Fixes:**
  - `.phony : clean` is likely a typo; replace with `.PHONY: clean` for correct phony declaration.
  - Clean pattern contains a small oddity (`*. *.`) — harmless but unusual; consider simplifying to common extensions.

**`Report/Makefile`**
- **Purpose:** Combined firmware and simulation Makefile: compile a single C app (placed in the designated C folder), produce `.elf`, `.v`, `.map`, `.bin`, `.lst`, copy sim `.mem`, and call the simulation `Makefile` in `../sim/`.
- **Key variables:** `CC`, `AS`, `OBJCOPY`, `SIZE`, `OBJDUMP`, flags (`ARCH`, `COMMON`, `CFLAGS`, `LDFLAGS`, `CPFLAGS`), outputs (`ELF`, `VHEX`, `BIN`, `LST`, etc.), `SIMDIR` (`../sim`).
- **Important targets:** `all` (default), compile C, assemble `crt0.s`, link to ELF + map, convert ELF → verilog hex + copy to `../sim`, `size`, `clean`, and simulation helper targets: `sim`, `waves`, `simcompile`, `simclean` which invoke `make -C ../sim` with `TEST=$(APP)`.
- **Usage:** Place exactly one `.c` file in the configured C directory, then run `make`. Use `make sim` to invoke the RTL simulation.
- **Notes / Fixes:**
  - The source selection block is broken/garbled. The Makefile checks `ifeq ($(wildcard c_compile),)` but your folder is named `c_complile`. The `else` branch contains corrupted text: `SEL_DIR := ./c_compileram obmization leve;lns in c` — invalid Make syntax.
  - Because of this corruption, the Makefile effectively falls back to `SEL_DIR := .`, which may work if you run it from the intended folder, but the logic and errors are misleading. Fix the selection block to explicitly point at the correct directory or simply set `SEL_DIR := .`.
  - `SHELL := /bin/bash` is set only when `VIVADO_SETTINGS` is provided; on Windows, `/bin/bash` may not exist — adapt if you use PowerShell or WSL.

**`c_complile/Makefile`**
- **Purpose:** Functionally the same as `Report/Makefile` — intended place to drop exactly one `.c` file. Produces firmware artifacts and supports simulation invocation.
- **Notes / Fixes:**
  - Contains the same corrupted source-selection logic as `Report/Makefile` (see above). Also the folder name is likely misspelled (`c_complile` vs `c_compile`) — either rename the folder or update the Makefile.

**`ip_uart/sim/Makefile`**
- **Purpose:** Vivado-based simulation Makefile for the UART IP. Compiles SystemVerilog sources (`xvlog`), elaborates (`xelab`), and runs `xsim`. Produces `.wdb` snapshot files and can open wave GUI.
- **Key variables:** `TB_TOP := tb_uart`, `SOURCES_SV` list, `COMP_OPTS_SV`, `DEFINES_SV`.
- **Important targets:** `compile`, `elaborate`, `simulate`, `waves`, `clean`, `activate`.
- **Usage:**
  - `make compile` → `make elaborate` → `make simulate` or simply `make simulate` (Make will run prerequisites).
  - `make waves` opens the GUI.
- **Notes / Fixes:**
  - `activate` uses `source /tools/Xilinx/Vivado/2024.2/settings64.sh` which is a Unix-style shell command. On Windows, use Vivado's `settings64.bat` or run inside WSL/MSYS if you prefer the `.sh`.

**`ip_jtag/sim/Makefile`**
- **Purpose:** Same Vivado flow as `ip_uart/sim/Makefile` but for the JTAG IP (`TB_TOP := tb_jtag`).
- **Notes:** `activate` points to `settings64.sh` for Vivado 2022.2 — verify the Vivado version you intend to use (2022.2 vs 2024.2 in other Makefile).

**General Recommendations & Quick Fixes**
- Fix the `.PHONY` usage in `spec/Makefile` (change `.phony : clean` → `.PHONY: clean`).
- Fix the corrupted `SEL_DIR` / source-selection logic in `Report/Makefile` and `c_complile/Makefile`. Replace the entire selection block with a simple explicit selection or a clear directory variable. Example replacement:

```
# Simple source selection (use current dir by default)
SEL_DIR := .
ALL_CS := $(wildcard $(SEL_DIR)/*.c)
NUM_SELECTED := $(words $(ALL_CS))
ifeq ($(NUM_SELECTED),0)
  $(error No .c file found in $(SEL_DIR)/. Keep exactly one C file.)
endif
ifneq ($(NUM_SELECTED),1)
  $(error More than one .c file found in $(SEL_DIR)/. Keep exactly one C file.)
endif

SRC_C := $(firstword $(ALL_CS))
APP   := $(strip $(basename $(notdir $(SRC_C))))
```

- Ensure the intended C folder name matches the Makefile (`c_complile` vs `c_compile`). Rename or update Makefile accordingly.
- For Windows, adapt Vivado `activate` and any `SHELL := /bin/bash` uses: either run Make in WSL/MSYS with bash or change `activate` to call the appropriate `.bat` script.
- Consider adding a `help` target to each Makefile that prints common commands (build, clean, sim, waves).

**How to run common tasks (PowerShell)**

Build all Verilog outputs in `rv64Sim`:

```powershell
cd 'd:\SoC\ref-materials\Archiv\rwu-rv64i-master\rv64Sim'
make
# or build a specific program (if foo.asm exists):
make foo
```

Build a C firmware app (assuming selection logic points at the folder with exactly one `.c` file):

```powershell
cd 'd:\SoC\ref-materials\Archiv\rwu-rv64i-master\c_complile'
make
# then run simulation (invokes ../sim Makefile)
make sim
```

Run Vivado sim for UART (ensure Vivado is available or use `activate` first):

```powershell
cd 'd:\SoC\ref-materials\Archiv\rwu-rv64i-master\ip_uart\sim'
make compile
make elaborate
make simulate
# or open waves
make waves
```


