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
option(BUILD_VERIFICATION_CORE "Include core processor tests" ON)
option(BUILD_VERIFICATION_LIB "Include library component tests" ON)
option(BUILD_VERIFICATION_PERIPHERALS "Include peripheral IP tests" ON)

# ============================================================================
# Add Verification Subdirectories
# ============================================================================

# Core processor tests (unit + integration)
if(BUILD_VERIFICATION_CORE AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/core/CMakeLists.txt")
    message(STATUS "  Core processor tests: ${CMAKE_CURRENT_SOURCE_DIR}/core")
    add_subdirectory(core)
else()
    message(STATUS "  Core processor tests: disabled or missing")
endif()

# Library component tests
if(BUILD_VERIFICATION_LIB AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/lib/CMakeLists.txt")
    message(STATUS "  Library component tests: ${CMAKE_CURRENT_SOURCE_DIR}/lib")
    add_subdirectory(lib)
else()
    message(STATUS "  Library component tests: disabled or missing")
endif()

# Peripheral IP tests
if(BUILD_VERIFICATION_PERIPHERALS AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/peripherals/CMakeLists.txt")
    message(STATUS "  Peripheral IP tests: ${CMAKE_CURRENT_SOURCE_DIR}/peripherals")
    add_subdirectory(peripherals)
else()
    message(STATUS "  Peripheral IP tests: disabled or missing")
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
