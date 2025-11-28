# ==============================================================================
# Project Paths Configuration
# ==============================================================================
# Defines all source and build directory paths used throughout the project.
# This follows industry-standard separation: RTL / Verification / Firmware / Sim
# ==============================================================================

include_guard(GLOBAL)

# ------------------------------------------------------------------------------
# RTL Source Directories (hardware design)
# ------------------------------------------------------------------------------
set(RV64I_RTL_DIR "${RV64I_BASE}/rtl")
set(RV64I_RTL_CORE_DIR "${RV64I_RTL_DIR}/core")
set(RV64I_RTL_PERIPHERALS_DIR "${RV64I_RTL_DIR}/peripherals")
set(RV64I_RTL_UART_DIR "${RV64I_RTL_PERIPHERALS_DIR}/uart")
set(RV64I_RTL_JTAG_DIR "${RV64I_RTL_PERIPHERALS_DIR}/jtag")
set(RV64I_RTL_GPIO_DIR "${RV64I_RTL_PERIPHERALS_DIR}/gpio")

# ------------------------------------------------------------------------------
# Verification Directories (all testbenches)
# ------------------------------------------------------------------------------
set(RV64I_VERIFICATION_DIR "${RV64I_BASE}/verification")
set(RV64I_VERIFICATION_UNIT_DIR "${RV64I_VERIFICATION_DIR}/unit")
set(RV64I_VERIFICATION_INTEGRATION_DIR "${RV64I_VERIFICATION_DIR}/integration")
set(RV64I_VERIFICATION_IP_DIR "${RV64I_VERIFICATION_DIR}/ip")
set(RV64I_VERIFICATION_IP_UART_DIR "${RV64I_VERIFICATION_IP_DIR}/uart")
set(RV64I_VERIFICATION_IP_JTAG_DIR "${RV64I_VERIFICATION_IP_DIR}/jtag")

# ------------------------------------------------------------------------------
# Firmware Directories (software tests)
# ------------------------------------------------------------------------------
set(RV64I_FIRMWARE_DIR "${RV64I_BASE}/firmware")
set(RV64I_FIRMWARE_TESTS_DIR "${RV64I_FIRMWARE_DIR}/tests")
set(RV64I_FIRMWARE_COMMON_DIR "${RV64I_FIRMWARE_DIR}/common")

# ------------------------------------------------------------------------------
# Simulation Infrastructure
# ------------------------------------------------------------------------------
set(RV64I_SIM_DIR "${RV64I_BASE}/sim")
set(RV64I_SIM_SCRIPTS_DIR "${RV64I_SIM_DIR}/scripts")
set(RV64I_SIM_CONFIG_DIR "${RV64I_SIM_DIR}/config")

# ------------------------------------------------------------------------------
# Build Output Directories
# ------------------------------------------------------------------------------
set(RV64I_BUILD_VERIFICATION_DIR "${CMAKE_BINARY_DIR}/verification")
set(RV64I_BUILD_UNIT_DIR "${RV64I_BUILD_VERIFICATION_DIR}/unit")
set(RV64I_BUILD_INTEGRATION_DIR "${RV64I_BUILD_VERIFICATION_DIR}/integration")
set(RV64I_BUILD_IP_DIR "${RV64I_BUILD_VERIFICATION_DIR}/ip")

set(RV64I_BUILD_FIRMWARE_DIR "${CMAKE_BINARY_DIR}/firmware")
set(RV64I_BUILD_RTL_DIR "${CMAKE_BINARY_DIR}/rtl")
set(RV64I_BUILD_DOCS_DIR "${CMAKE_BINARY_DIR}/docs")
set(RV64I_BUILD_REPORTS_DIR "${CMAKE_BINARY_DIR}/reports")

# Create output directories
file(MAKE_DIRECTORY "${RV64I_BUILD_VERIFICATION_DIR}")
file(MAKE_DIRECTORY "${RV64I_BUILD_UNIT_DIR}")
file(MAKE_DIRECTORY "${RV64I_BUILD_INTEGRATION_DIR}")
file(MAKE_DIRECTORY "${RV64I_BUILD_IP_DIR}")
file(MAKE_DIRECTORY "${RV64I_BUILD_FIRMWARE_DIR}")
file(MAKE_DIRECTORY "${RV64I_BUILD_RTL_DIR}")
file(MAKE_DIRECTORY "${RV64I_BUILD_DOCS_DIR}")
file(MAKE_DIRECTORY "${RV64I_BUILD_REPORTS_DIR}")

# ------------------------------------------------------------------------------
# Print configuration (for debugging)
# ------------------------------------------------------------------------------
message(STATUS "")
message(STATUS "Project Paths:")
message(STATUS "  Source:        ${RV64I_BASE}")
message(STATUS "  RTL:           ${RV64I_RTL_DIR}")
message(STATUS "  Verification:  ${RV64I_VERIFICATION_DIR}")
message(STATUS "  Firmware:      ${RV64I_FIRMWARE_DIR}")
message(STATUS "  Simulation:    ${RV64I_SIM_DIR}")
message(STATUS "  Build:         ${CMAKE_BINARY_DIR}")
message(STATUS "")
