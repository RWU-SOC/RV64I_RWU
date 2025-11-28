# ==============================================================================
# Verification Top-Level Build Configuration
# ==============================================================================
# Orchestrates all verification components:
# - Unit tests (individual component testbenches)
# - Integration tests (full system testbenches)
# - IP-specific tests (UART, JTAG verification)
# ==============================================================================

message(STATUS "Configuring Verification Components...")

# ============================================================================
# Verification Build Options
# ============================================================================
option(BUILD_VERIFICATION_UNIT "Include unit tests" ON)
option(BUILD_VERIFICATION_INTEGRATION "Include integration tests" ON)
option(BUILD_VERIFICATION_IP "Include IP-specific tests" ON)

# ============================================================================
# Add Verification Subdirectories
# ============================================================================

# Unit tests
if(BUILD_VERIFICATION_UNIT AND EXISTS "${RV64I_VERIFICATION_UNIT_DIR}/CMakeLists.txt")
    message(STATUS "  Unit tests: ${RV64I_VERIFICATION_UNIT_DIR}")
    add_subdirectory(unit)
else()
    message(STATUS "  Unit tests: disabled or missing")
endif()

# Integration tests
if(BUILD_VERIFICATION_INTEGRATION AND EXISTS "${RV64I_VERIFICATION_INTEGRATION_DIR}/CMakeLists.txt")
    message(STATUS "  Integration tests: ${RV64I_VERIFICATION_INTEGRATION_DIR}")
    add_subdirectory(integration)
else()
    message(STATUS "  Integration tests: disabled or missing")
endif()

# IP-specific tests
if(BUILD_VERIFICATION_IP AND EXISTS "${RV64I_VERIFICATION_IP_DIR}/CMakeLists.txt")
    message(STATUS "  IP tests: ${RV64I_VERIFICATION_IP_DIR}")
    add_subdirectory(ip)
else()
    message(STATUS "  IP tests: disabled or missing")
endif()

# ============================================================================
# Verification Documentation
# ============================================================================

# Generate verification file listing
file(GLOB_RECURSE ALL_TB_FILES "${RV64I_VERIFICATION_DIR}/*.sv")

add_custom_target(verification_filelist
    COMMAND ${CMAKE_COMMAND} -E echo "# RV64I Verification Testbenches" > 
            "${RV64I_BUILD_VERIFICATION_DIR}/verification_sources.txt"
    COMMENT "Generating verification file listing"
)

message(STATUS "Verification Components configuration complete")
message(STATUS "")
