# SPDX-License-Identifier: Apache-2.0
# RTL Library Components

# Collect all library RTL source files
file(GLOB LIB_RTL_FILES "${CMAKE_CURRENT_SOURCE_DIR}/*.sv" "${CMAKE_CURRENT_SOURCE_DIR}/*.v")

# Create INTERFACE library to track RTL dependencies
add_library(rtl_lib INTERFACE)
target_sources(rtl_lib INTERFACE ${LIB_RTL_FILES})

# Library RTL files are used by hardware testbenches
# Store file list for other components to use
set(RV64I_LIB_RTL_SOURCES ${LIB_RTL_FILES} PARENT_SCOPE)

# List files for visibility
foreach(rtl_file ${LIB_RTL_FILES})
    get_filename_component(filename ${rtl_file} NAME)
    message(STATUS "    - ${filename}")
endforeach()

message(STATUS "    Library RTL configured (${CMAKE_CURRENT_SOURCE_DIR})")
