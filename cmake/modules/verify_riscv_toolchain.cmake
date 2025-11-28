# SPDX-License-Identifier: Apache-2.0
# RISC-V toolchain verification and setup

include_guard(GLOBAL)

message(STATUS "Verifying RISC-V toolchain...")

# Find RISC-V tools
find_program(RISCV_CC riscv64-unknown-elf-gcc)
find_program(RISCV_AS riscv64-unknown-elf-as)
find_program(RISCV_LD riscv64-unknown-elf-ld)
find_program(RISCV_OBJCOPY riscv64-unknown-elf-objcopy)
find_program(RISCV_OBJDUMP riscv64-unknown-elf-objdump)
find_program(RISCV_SIZE riscv64-unknown-elf-size)
find_program(RISCV_GDB riscv64-unknown-elf-gdb)

# Check if minimal toolchain is available
if(NOT RISCV_CC OR NOT RISCV_AS OR NOT RISCV_LD OR NOT RISCV_OBJCOPY)
  message(WARNING "RISC-V toolchain not found. Firmware builds disabled.")
  message(STATUS "Required tools: riscv64-unknown-elf-{gcc,as,ld,objcopy}")
  set(BUILD_FIRMWARE OFF CACHE BOOL "Build firmware" FORCE)
  return()
endif()

# Get toolchain version
execute_process(
  COMMAND ${RISCV_CC} --version
  OUTPUT_VARIABLE RISCV_VERSION_OUTPUT
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

string(REGEX MATCH "([0-9]+\\.[0-9]+\\.[0-9]+)" RISCV_VERSION "${RISCV_VERSION_OUTPUT}")

# Set toolchain variables in parent scope
set(RISCV_CC ${RISCV_CC} CACHE FILEPATH "RISC-V GCC compiler" FORCE)
set(RISCV_AS ${RISCV_AS} CACHE FILEPATH "RISC-V assembler" FORCE)
set(RISCV_LD ${RISCV_LD} CACHE FILEPATH "RISC-V linker" FORCE)
set(RISCV_OBJCOPY ${RISCV_OBJCOPY} CACHE FILEPATH "RISC-V objcopy" FORCE)
set(RISCV_OBJDUMP ${RISCV_OBJDUMP} CACHE FILEPATH "RISC-V objdump" FORCE)
set(RISCV_SIZE ${RISCV_SIZE} CACHE FILEPATH "RISC-V size utility" FORCE)

if(RISCV_GDB)
  set(RISCV_GDB ${RISCV_GDB} CACHE FILEPATH "RISC-V GDB debugger" FORCE)
endif()

# Set architecture flags
set(RV64I_ARCH_FLAGS "-march=rv64i -mabi=lp64" CACHE STRING "RISC-V architecture flags")
set(RV64I_COMMON_FLAGS "-ffreestanding -nostdlib" CACHE STRING "Common firmware flags")

# Mark toolchain as found
set(RISCV_TOOLCHAIN_FOUND TRUE CACHE BOOL "RISC-V toolchain is available" FORCE)

message(STATUS "RISC-V toolchain found:")
message(STATUS "  Compiler:  ${RISCV_CC}")
message(STATUS "  Version:   ${RISCV_VERSION}")
message(STATUS "  Assembler: ${RISCV_AS}")
message(STATUS "  Linker:    ${RISCV_LD}")
message(STATUS "  Objcopy:   ${RISCV_OBJCOPY}")
if(RISCV_GDB)
  message(STATUS "  Debugger:  ${RISCV_GDB}")
endif()
