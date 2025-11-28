# ==============================================================================
# RTL Peripherals Build Configuration
# ==============================================================================
# Orchestrates the build of all peripheral IP blocks
# ==============================================================================

# UART peripheral
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/uart/CMakeLists.txt")
    add_subdirectory(uart)
else()
    message(WARNING "UART peripheral missing CMakeLists.txt")
endif()

# JTAG peripheral
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/jtag/CMakeLists.txt")
    add_subdirectory(jtag)
else()
    message(WARNING "JTAG peripheral missing CMakeLists.txt")
endif()

# GPIO peripheral
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/gpio/CMakeLists.txt")
    add_subdirectory(gpio)
else()
    message(STATUS "GPIO peripheral not yet implemented (placeholder directory)")
endif()

message(STATUS "Peripherals configuration complete")
