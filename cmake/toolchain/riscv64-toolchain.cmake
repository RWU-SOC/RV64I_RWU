# ==============================================================================
# RISC-V 64-bit Toolchain File
# ==============================================================================
# This file configures CMake to use RISC-V GCC as the primary compiler.
# Usage: cmake -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/riscv64-toolchain.cmake ..
# ==============================================================================

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv64)

# Find RISC-V toolchain (Windows paths with .exe)
find_program(CMAKE_C_COMPILER 
  NAMES riscv64-unknown-elf-gcc.exe riscv64-unknown-elf-gcc
  PATHS C:/SysGCC/risc-v/bin
  NO_DEFAULT_PATH
)
find_program(CMAKE_CXX_COMPILER 
  NAMES riscv64-unknown-elf-g++.exe riscv64-unknown-elf-g++
  PATHS C:/SysGCC/risc-v/bin
  NO_DEFAULT_PATH
)
find_program(CMAKE_ASM_COMPILER 
  NAMES riscv64-unknown-elf-gcc.exe riscv64-unknown-elf-gcc
  PATHS C:/SysGCC/risc-v/bin
  NO_DEFAULT_PATH
)

if(NOT CMAKE_C_COMPILER)
  message(FATAL_ERROR "RISC-V GCC not found. Check C:/SysGCC/risc-v/bin/")
endif()

# Toolchain utilities
find_program(CMAKE_AR 
  NAMES riscv64-unknown-elf-ar.exe riscv64-unknown-elf-ar
  PATHS C:/SysGCC/risc-v/bin
  NO_DEFAULT_PATH
)
find_program(CMAKE_RANLIB 
  NAMES riscv64-unknown-elf-ranlib.exe riscv64-unknown-elf-ranlib
  PATHS C:/SysGCC/risc-v/bin
  NO_DEFAULT_PATH
)
find_program(CMAKE_OBJCOPY 
  NAMES riscv64-unknown-elf-objcopy.exe riscv64-unknown-elf-objcopy
  PATHS C:/SysGCC/risc-v/bin
  NO_DEFAULT_PATH
)
find_program(CMAKE_OBJDUMP 
  NAMES riscv64-unknown-elf-objdump.exe riscv64-unknown-elf-objdump
  PATHS C:/SysGCC/risc-v/bin
  NO_DEFAULT_PATH
)
find_program(CMAKE_SIZE 
  NAMES riscv64-unknown-elf-size.exe riscv64-unknown-elf-size
  PATHS C:/SysGCC/risc-v/bin
  NO_DEFAULT_PATH
)

# Architecture flags
set(CMAKE_C_FLAGS_INIT "-march=rv64i -mabi=lp64 -ffreestanding -nostdlib")
set(CMAKE_CXX_FLAGS_INIT "-march=rv64i -mabi=lp64 -ffreestanding -nostdlib")
set(CMAKE_ASM_FLAGS_INIT "-march=rv64i -mabi=lp64")

# Don't try to link executables during configuration
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Search only in RISC-V toolchain paths
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

message(STATUS "RISC-V toolchain configured:")
message(STATUS "  Compiler: ${CMAKE_C_COMPILER}")
