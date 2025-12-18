# ==============================================================================
# Peripheral IP Tests Build Configuration
# ==============================================================================
# Orchestrates peripheral IP block verification (UART, JTAG testbenches)
# ==============================================================================

# UART peripheral tests
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/uart/CMakeLists.txt")
    message(STATUS "  UART peripheral tests: ${CMAKE_CURRENT_SOURCE_DIR}/uart")
    add_subdirectory(uart)
else()
    message(STATUS "  UART peripheral tests: missing CMakeLists.txt")
endif()

# JTAG peripheral tests
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/jtag/CMakeLists.txt")
    message(STATUS "  JTAG peripheral tests: ${CMAKE_CURRENT_SOURCE_DIR}/jtag")
    add_subdirectory(jtag)
else()
    message(STATUS "  JTAG peripheral tests: missing CMakeLists.txt")
endif()

message(STATUS "  Peripheral tests configured: ${CMAKE_CURRENT_SOURCE_DIR}")
