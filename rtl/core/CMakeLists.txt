# SPDX-License-Identifier: Apache-2.0
# Core Processor RTL

# Collect all core RTL source files
file(GLOB CORE_RTL_FILES "${RV64I_RTL_CORE_DIR}/*.sv")

# Create INTERFACE library to track RTL dependencies
add_library(rtl_core INTERFACE)
target_sources(rtl_core INTERFACE ${CORE_RTL_FILES})

# Core RTL files are used by hardware testbenches
# Store file list for other components to use
set(RV64I_CORE_RTL_SOURCES ${CORE_RTL_FILES} PARENT_SCOPE)

# List files for visibility
foreach(rtl_file ${CORE_RTL_FILES})
    get_filename_component(filename ${rtl_file} NAME)
    message(STATUS "    - ${filename}")
endforeach()

message(STATUS "    Core RTL configured (${CMAKE_CURRENT_SOURCE_DIR})")
