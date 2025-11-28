# ==============================================================================
# Build Options (Feature Toggles)
# ==============================================================================
# These option() variables control what gets built. Set them with -D flags:
#   cmake -DBUILD_HARDWARE_TESTS=OFF ..
#
# Users can enable/disable components based on available tools.
# ==============================================================================

include_guard(GLOBAL)

# ------------------------------------------------------------------------------
# Primary Build Options
# ------------------------------------------------------------------------------
option(BUILD_HARDWARE_TESTS
  "Build hardware testbenches (requires Vivado XSIM)"
  ON
)

option(BUILD_SOFTWARE_TESTS
  "Build software tests / firmware (requires RISC-V toolchain)"
  ON
)

option(BUILD_INTEGRATION_TESTS
  "Build integration tests (requires both XSIM and RISC-V toolchain)"
  ON
)

option(ENABLE_TESTING 
  "Enable CTest framework" 
  ON
)

# ------------------------------------------------------------------------------
# Legacy Build Options (backward compatibility)
# ------------------------------------------------------------------------------
option(BUILD_FIRMWARE 
  "Build RISC-V firmware (legacy - use BUILD_SOFTWARE_TESTS)" 
  OFF
)

option(BUILD_SIMULATION 
  "Build RTL simulation targets (legacy - use BUILD_HARDWARE_TESTS)" 
  OFF
)

option(BUILD_IP_BLOCKS 
  "Build IP block simulations (legacy)" 
  OFF
)

# ------------------------------------------------------------------------------
# Advanced Options (rarely changed)
# ------------------------------------------------------------------------------
option(USE_CCACHE 
  "Use ccache if available (speeds up rebuilds)" 
  ON
)

option(VERBOSE_BUILD 
  "Enable verbose build output (useful for debugging)" 
  OFF
)

# ------------------------------------------------------------------------------
# ccache setup (compilation cache to speed up rebuilds)
# ------------------------------------------------------------------------------
if(USE_CCACHE)
  find_program(CCACHE_PROGRAM ccache)
  if(CCACHE_PROGRAM)
    message(STATUS \"Using ccache: ${CCACHE_PROGRAM}\")
    set(CMAKE_C_COMPILER_LAUNCHER \"${CCACHE_PROGRAM}\")
    set(CMAKE_CXX_COMPILER_LAUNCHER \"${CCACHE_PROGRAM}\")
  endif()
endif()

# ------------------------------------------------------------------------------
# Verbose build
# ------------------------------------------------------------------------------
if(VERBOSE_BUILD)
  set(CMAKE_VERBOSE_MAKEFILE ON)
endif()

# ------------------------------------------------------------------------------
# Print configuration summary
# ------------------------------------------------------------------------------
message(STATUS \"Build options:\")
message(STATUS \"  Firmware:     ${BUILD_FIRMWARE}\")
message(STATUS \"  Simulation:   ${BUILD_SIMULATION}\")
message(STATUS \"  IP Blocks:    ${BUILD_IP_BLOCKS}\")
message(STATUS \"  Testing:      ${ENABLE_TESTING}\")
