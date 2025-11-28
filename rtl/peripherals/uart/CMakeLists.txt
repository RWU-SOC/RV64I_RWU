# ==============================================================================
# UART Peripheral RTL Build Configuration
# ==============================================================================
# Auto-discovers UART RTL sources
# ==============================================================================

file(GLOB UART_RTL_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/*.sv"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.v"
)

add_custom_target(rtl_uart
    COMMENT "UART peripheral RTL"
    SOURCES ${UART_RTL_SOURCES}
)

set(RV64I_UART_RTL_SOURCES ${UART_RTL_SOURCES} PARENT_SCOPE)

message(STATUS "UART RTL files: ${CMAKE_CURRENT_SOURCE_DIR}")
foreach(rtl_file ${UART_RTL_SOURCES})
    get_filename_component(filename ${rtl_file} NAME)
    message(STATUS "  - ${filename}")
endforeach()
