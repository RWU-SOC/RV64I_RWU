# ==============================================================================
# JTAG Peripheral RTL Build Configuration
# ==============================================================================
# Auto-discovers JTAG RTL sources
# ==============================================================================

file(GLOB JTAG_RTL_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/*.sv"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.v"
)

add_custom_target(rtl_jtag
    COMMENT "JTAG peripheral RTL"
    SOURCES ${JTAG_RTL_SOURCES}
)

set(RV64I_JTAG_RTL_SOURCES ${JTAG_RTL_SOURCES} PARENT_SCOPE)

message(STATUS "JTAG RTL files: ${CMAKE_CURRENT_SOURCE_DIR}")
foreach(rtl_file ${JTAG_RTL_SOURCES})
    get_filename_component(filename ${rtl_file} NAME)
    message(STATUS "  - ${filename}")
endforeach()
