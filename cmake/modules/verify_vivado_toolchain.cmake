# SPDX-License-Identifier: Apache-2.0
# Vivado/XSIM toolchain verification

include_guard(GLOBAL)

message(STATUS "Verifying Vivado toolchain...")

# Find Vivado XSIM tools
find_program(XVLOG xvlog)
find_program(XELAB xelab)
find_program(XSIM xsim)
find_program(XVHDL xvhdl)

# Check if minimal toolchain is available
if(NOT XVLOG OR NOT XELAB OR NOT XSIM)
  message(WARNING "Vivado XSIM tools not found. Simulation builds disabled.")
  message(STATUS "Hint: Source Vivado settings64.sh/bat before running CMake")
  message(STATUS "  Windows: & \"C:\\Xilinx\\Vivado\\2024.2\\settings64.bat\"")
  message(STATUS "  Linux:   source /tools/Xilinx/Vivado/2024.2/settings64.sh")
  set(BUILD_SIMULATION OFF CACHE BOOL "Build simulations" FORCE)
  set(BUILD_IP_BLOCKS OFF CACHE BOOL "Build IP blocks" FORCE)
  return()
endif()

# Get Vivado version
execute_process(
  COMMAND ${XSIM} --version
  OUTPUT_VARIABLE XSIM_VERSION_OUTPUT
  ERROR_VARIABLE XSIM_VERSION_OUTPUT
  OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_STRIP_TRAILING_WHITESPACE
)

string(REGEX MATCH "Vivado Simulator ([0-9]+\\.[0-9]+)" VIVADO_VERSION_MATCH "${XSIM_VERSION_OUTPUT}")
if(VIVADO_VERSION_MATCH)
  set(VIVADO_VERSION "${CMAKE_MATCH_1}")
else()
  set(VIVADO_VERSION "Unknown")
endif()

# Set toolchain variables in cache
set(XVLOG ${XVLOG} CACHE FILEPATH "Vivado xvlog tool" FORCE)
set(XELAB ${XELAB} CACHE FILEPATH "Vivado xelab tool" FORCE)
set(XSIM ${XSIM} CACHE FILEPATH "Vivado xsim tool" FORCE)

if(XVHDL)
  set(XVHDL ${XVHDL} CACHE FILEPATH "Vivado xvhdl tool" FORCE)
endif()

# Set default compilation flags
set(XVLOG_FLAGS "--incr --relax" CACHE STRING "Default xvlog flags")
set(XELAB_FLAGS "-debug all" CACHE STRING "Default xelab flags")
set(XSIM_FLAGS "--runall --onfinish quit" CACHE STRING "Default xsim flags")

# Define Vivado-specific compile definitions
set(VIVADO_DEFINES "-d LOGIC_SV" CACHE STRING "Vivado simulator defines")

# Mark toolchain as found
set(VIVADO_FOUND TRUE CACHE BOOL "Vivado toolchain is available" FORCE)

message(STATUS "Vivado toolchain found:")
message(STATUS "  Version: ${VIVADO_VERSION}")
message(STATUS "  xvlog:   ${XVLOG}")
message(STATUS "  xelab:   ${XELAB}")
message(STATUS "  xsim:    ${XSIM}")
if(XVHDL)
  message(STATUS "  xvhdl:   ${XVHDL}")
endif()
