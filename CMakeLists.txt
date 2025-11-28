# ==============================================================================
# RV64I_RWU - RISC-V 64-bit Processor Core - CMake Build System
# ==============================================================================
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2025 RWU-SOC
#
# This is the top-level CMake configuration file. It orchestrates the build
# process using a modular, phased approach inspired by Zephyr RTOS.
#
# HOW THIS WORKS:
# ---------------
# 1. Configure Phase: Sets up build options, finds tools, configures paths
# 2. Generation Phase: Creates build files (Makefiles/Ninja/MSVC projects)
# 3. Build Phase: Compiles firmware, runs simulations, builds docs
#
# USAGE:
# ------
#   mkdir build && cd build
#   cmake ..                    # Configure
#   cmake --build .             # Build everything
#   ctest                       # Run tests
#
# BUILD OPTIONS (set with -D flag):
# ----------------------------------
#   BUILD_HARDWARE_TESTS=ON/OFF    - Build Verilog testbenches (needs Vivado)
#   BUILD_SOFTWARE_TESTS=ON/OFF    - Build firmware tests (needs RISC-V GCC)
#   ENABLE_TESTING=ON/OFF          - Enable CTest framework
#
# MAINTENANCE NOTES:
# ------------------
# - Edit cmake/modules/*.cmake for reusable logic (toolchain checks, paths)
# - firmware_extensions.cmake: Functions to build .asm/.c firmware
# - test_framework.cmake: CTest configuration and test helpers
# - Keep this file minimal - delegate to modules in cmake/modules/
#
# ==============================================================================

cmake_minimum_required(VERSION 3.20)

# ------------------------------------------------------------------------------
# Prevent in-source builds (keeps source tree clean)
# ------------------------------------------------------------------------------
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR 
    "In-source builds not allowed. Create a build directory:\n"
    "  mkdir build && cd build && cmake .."
  )
endif()

# ------------------------------------------------------------------------------
# Define project root path early (used by all modules)
# ------------------------------------------------------------------------------
set(RV64I_BASE ${CMAKE_CURRENT_SOURCE_DIR})
set(ENV{RV64I_BASE} ${RV64I_BASE})

# ==============================================================================
# PHASE 1: Load Core Modules
# ==============================================================================
# Add cmake/modules/ to the search path so we can include() them
list(APPEND CMAKE_MODULE_PATH ${RV64I_BASE}/cmake/modules)

# ------------------------------------------------------------------------------
# Set toolchain file BEFORE project() call
# ------------------------------------------------------------------------------
if(NOT CMAKE_TOOLCHAIN_FILE)
  set(CMAKE_TOOLCHAIN_FILE "${RV64I_BASE}/cmake/toolchain/riscv64-toolchain.cmake")
  message(STATUS "Using RISC-V toolchain (default)")
endif()

# ------------------------------------------------------------------------------
# Warn if using Visual Studio generator (conflicts with RISC-V toolchain)
# ------------------------------------------------------------------------------
if(CMAKE_GENERATOR MATCHES "Visual Studio")
  message(WARNING 
    "Visual Studio generator detected. This will use MSVC for C/CXX instead of RISC-V GCC!\n"
    "Recommended: Use Ninja generator for proper RISC-V toolchain support:\n"
    "  cmake -S . -B build -G Ninja\n"
    "Install Ninja: choco install ninja"
  )
endif()

# Basic settings: build type, policies, output directories
include(basic_settings)

# Extensions: reusable CMake functions (rv64i_add_firmware_asm, etc.)
include(extensions)

# Build options: ON/OFF toggles for features (loaded early so verify_* can use them)
include(build_options)

# ==============================================================================
# PHASE 2: Project Declaration
# ==============================================================================
# This triggers compiler detection using the RISC-V toolchain set above.
project(RV64I_RWU
    VERSION 1.0.0
    DESCRIPTION "RISC-V 64-bit Processor Core Implementation"
    LANGUAGES C CXX ASM
)

# ==============================================================================
# PHASE 3: Configure Paths and Metadata
# ==============================================================================
# Set standard paths: source dirs, build dirs, output locations
include(paths)

# Extract version info from VERSION file and git
include(version)

# Find Python interpreter (for build scripts, if needed)
include(python)

# Get git commit hash and branch (stamped into binaries/reports)
include(git)

# ==============================================================================
# PHASE 4: Detect and Verify Toolchains
# ==============================================================================
# Verify RISC-V toolchain is available (should be auto-configured by toolchain file)
set(RISCV_CC ${CMAKE_C_COMPILER} CACHE FILEPATH "RISC-V GCC compiler" FORCE)
set(RISCV_CXX ${CMAKE_CXX_COMPILER} CACHE FILEPATH "RISC-V G++ compiler" FORCE)

# Find the actual assembler (not gcc acting as assembler)
find_program(RISCV_AS 
  NAMES riscv64-unknown-elf-as.exe riscv64-unknown-elf-as
  PATHS C:/SysGCC/risc-v/bin
  NO_DEFAULT_PATH
  REQUIRED
)
find_program(RISCV_LD 
  NAMES riscv64-unknown-elf-ld.exe riscv64-unknown-elf-ld
  PATHS C:/SysGCC/risc-v/bin
  NO_DEFAULT_PATH
  REQUIRED
)

set(RISCV_AS ${RISCV_AS} CACHE FILEPATH "RISC-V assembler" FORCE)
set(RISCV_LD ${RISCV_LD} CACHE FILEPATH "RISC-V linker" FORCE)
set(RISCV_OBJCOPY ${CMAKE_OBJCOPY} CACHE FILEPATH "RISC-V objcopy" FORCE)
set(RISCV_OBJDUMP ${CMAKE_OBJDUMP} CACHE FILEPATH "RISC-V objdump" FORCE)
set(RISCV_SIZE ${CMAKE_SIZE} CACHE FILEPATH "RISC-V size" FORCE)
set(RISCV_TOOLCHAIN_FOUND TRUE CACHE BOOL "RISC-V toolchain is available" FORCE)

message(STATUS "RISC-V toolchain verified:")
message(STATUS "  Compiler:  ${RISCV_CC}")
message(STATUS "  Assembler: ${RISCV_AS}")
message(STATUS "  Linker:    ${RISCV_LD}")
message(STATUS "  Objcopy:   ${RISCV_OBJCOPY}")

# Vivado XSIM (xvlog/xelab/xsim) for RTL simulation
if(BUILD_HARDWARE_TESTS OR BUILD_SIMULATION OR BUILD_IP_BLOCKS)
  include(verify_vivado_toolchain)
endif()

# ==============================================================================
# PHASE 5: Configure Testing Framework (CTest)
# ==============================================================================
# Note: CTest may have limited functionality in cross-compilation mode
if(ENABLE_TESTING)
  enable_testing()            # Enable testing (CTest not fully compatible with cross-compile)
  include(test_framework)     # Our custom test helpers
  message(STATUS "Testing framework enabled")
endif()

# ==============================================================================
# PHASE 6: Add Subdirectories (Components)
# ==============================================================================
# Each subdirectory has its own CMakeLists.txt that registers targets/tests.

# RTL components: processor core and peripheral IP blocks
if(EXISTS "${RV64I_RTL_DIR}/CMakeLists.txt")
    add_subdirectory(rtl)
else()
    message(WARNING "RTL directory missing: ${RV64I_RTL_DIR}")
endif()

# Verification: unit tests, integration tests, IP testbenches
if(EXISTS "${RV64I_VERIFICATION_DIR}/CMakeLists.txt" AND ENABLE_TESTING)
    add_subdirectory(verification)
else()
    message(STATUS "Verification tests disabled or missing")
endif()

# Firmware: software tests and common runtime libraries
if(EXISTS "${RV64I_FIRMWARE_DIR}/CMakeLists.txt")
    add_subdirectory(firmware)
else()
    message(STATUS "Firmware directory missing: ${RV64I_FIRMWARE_DIR}")
endif()

# Simulation infrastructure: TCL scripts, waveform configs
if(EXISTS "${RV64I_SIM_DIR}/CMakeLists.txt")
    add_subdirectory(sim)
else()
    message(STATUS "Simulation directory missing: ${RV64I_SIM_DIR}")
endif()

# ==============================================================================
# PHASE 7: Post-Build Summary and Convenience Targets
# ==============================================================================
# Print configuration summary and create helper targets (info, usage, etc.)
include(post_build)
