# SPDX-License-Identifier: Apache-2.0
# RTL Components - Top Level
#
# This file orchestrates the RTL design hierarchy including the core processor
# and peripheral IP blocks (UART, JTAG, GPIO, etc.)

message(STATUS "Configuring RTL Components...")

# ============================================================================
# RTL Build Options
# ============================================================================
option(BUILD_RTL_CORE "Include core processor RTL" ON)
option(BUILD_RTL_UART "Include UART IP block RTL" ON)
option(BUILD_RTL_JTAG "Include JTAG IP block RTL" ON)
option(BUILD_RTL_GPIO "Include GPIO IP block RTL" ON)

# ============================================================================
# Add RTL Subdirectories
# ============================================================================

# Core processor RTL files
if(BUILD_RTL_CORE AND EXISTS "${RV64I_RTL_CORE_DIR}/CMakeLists.txt")
    file(GLOB_RECURSE RTL_CORE_FILES "${RV64I_RTL_CORE_DIR}/*.sv")
    if(RTL_CORE_FILES)
        message(STATUS "  Core processor RTL: ${RV64I_RTL_CORE_DIR}")
        add_subdirectory(core)
    else()
        message(WARNING "  No RTL files found in ${RV64I_RTL_CORE_DIR}")
    endif()
endif()

# Peripheral IP blocks
if(EXISTS "${RV64I_RTL_PERIPHERALS_DIR}/CMakeLists.txt")
    message(STATUS "  Peripheral IP blocks: ${RV64I_RTL_PERIPHERALS_DIR}")
    add_subdirectory(peripherals)
else()
    message(WARNING "  Peripherals directory missing CMakeLists.txt")
endif()

# ============================================================================
# RTL Documentation Targets
# ============================================================================

# Generate RTL file listing
set(RTL_FILELIST "${RV64I_BUILD_RTL_DIR}/rtl_sources.txt")
file(GLOB_RECURSE ALL_RTL_FILES "${RV64I_RTL_DIR}/*.sv" "${RV64I_RTL_DIR}/*.v")

add_custom_target(rtl_filelist
    COMMAND ${CMAKE_COMMAND} -E echo "# RV64I RTL Source Files" > ${RTL_FILELIST}
    COMMAND ${CMAKE_COMMAND} -E echo "# Generated: ${CMAKE_CURRENT_TIMESTAMP}" >> ${RTL_FILELIST}
    COMMAND ${CMAKE_COMMAND} -E echo "" >> ${RTL_FILELIST}
    COMMENT "Generating RTL file listing"
)

foreach(rtl_file ${ALL_RTL_FILES})
    file(RELATIVE_PATH rel_path "${RV64I_RTL_DIR}" "${rtl_file}")
    add_custom_command(
        TARGET rtl_filelist POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "${rel_path}" >> ${RTL_FILELIST}
        VERBATIM
    )
endforeach()

# ============================================================================
# Convenience Targets
# ============================================================================
add_custom_target(rtl_all
    COMMENT "RTL component placeholder target"
)

message(STATUS "RTL Components configuration complete")
message(STATUS "")
