# ==============================================================================
# IP-Specific Tests Build Configuration
# ==============================================================================
# Orchestrates IP block verification (UART, JTAG testbenches)
# ==============================================================================

# UART IP tests
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/uart/CMakeLists.txt")
    add_subdirectory(uart)
else()
    message(STATUS "  UART IP tests: missing CMakeLists.txt")
endif()

# JTAG IP tests
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/jtag/CMakeLists.txt")
    add_subdirectory(jtag)
else()
    message(STATUS "  JTAG IP tests: missing CMakeLists.txt")
endif()

message(STATUS "  IP-specific tests configured")
