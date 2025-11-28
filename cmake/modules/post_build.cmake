# SPDX-License-Identifier: Apache-2.0
# Post-build integration - summary and final tasks

include_guard(GLOBAL)

# ============================================================================
# Build summary
# ============================================================================

message(STATUS "")
message(STATUS "========================================")
message(STATUS "RV64I_RWU Build Configuration Summary")
message(STATUS "========================================")
message(STATUS "Version:           ${RV64I_VERSION}")
message(STATUS "Git commit:        ${RV64I_GIT_COMMIT}")
message(STATUS "Build type:        ${CMAKE_BUILD_TYPE}")
message(STATUS "")
message(STATUS "Components:")
message(STATUS "  Firmware:        ${BUILD_FIRMWARE}")
message(STATUS "  Simulation:      ${BUILD_SIMULATION}")
message(STATUS "  IP Blocks:       ${BUILD_IP_BLOCKS}")
message(STATUS "  Documentation:   ${BUILD_DOCS}")
message(STATUS "  Testing:         ${ENABLE_TESTING}")
message(STATUS "")
message(STATUS "Directories:")
message(STATUS "  Source:          ${RV64I_BASE}")
message(STATUS "  Build:           ${CMAKE_BINARY_DIR}")
message(STATUS "  Firmware output: ${RV64I_FIRMWARE_DIR}")
message(STATUS "  Sim output:      ${RV64I_SIM_DIR}")
message(STATUS "")

if(BUILD_FIRMWARE)
  message(STATUS "RISC-V Toolchain:")
  message(STATUS "  Compiler:        ${RISCV_CC}")
  message(STATUS "")
endif()

if(BUILD_SIMULATION OR BUILD_IP_BLOCKS)
  message(STATUS "Vivado Tools:")
  message(STATUS "  XSIM:            ${XSIM}")
  message(STATUS "")
endif()

if(BUILD_DOCS)
  message(STATUS "Documentation:")
  message(STATUS "  Sphinx:          ${SPHINX_BUILD}")
  if(DOCS_PDF_AVAILABLE)
    message(STATUS "  PDF:             Enabled")
  else()
    message(STATUS "  PDF:             Disabled (pdflatex not found)")
  endif()
  message(STATUS "")
endif()

message(STATUS "========================================")
message(STATUS "")
message(STATUS "Build commands:")
message(STATUS "  cmake --build .              # Build everything")
message(STATUS "  cmake --build . --target help # List all targets")
message(STATUS "  ctest                        # Run all tests")
message(STATUS "")
message(STATUS "Quick start:")
message(STATUS "  cmake --build . --target firmware_all")
message(STATUS "  cmake --build . --target sim_instr06addi")
message(STATUS "  ctest -R test_instr06addi -V")
message(STATUS "")
message(STATUS "For more information, see:")
message(STATUS "  - GETTING_STARTED.md")
message(STATUS "  - CMAKE_QUICK_REFERENCE.md")
message(STATUS "  - CMAKE_BUILD_GUIDE.md")
message(STATUS "========================================")
message(STATUS "")

# ============================================================================
# Create convenience targets
# ============================================================================

# Help target
add_custom_target(usage
  COMMAND ${CMAKE_COMMAND} -E echo "RV64I_RWU Build System"
  COMMAND ${CMAKE_COMMAND} -E echo ""
  COMMAND ${CMAKE_COMMAND} -E echo "Common targets:"
  COMMAND ${CMAKE_COMMAND} -E echo "  all              - Build everything"
  COMMAND ${CMAKE_COMMAND} -E echo "  firmware_all     - Build all firmware"
  COMMAND ${CMAKE_COMMAND} -E echo "  sim_all          - Run all simulations"
  COMMAND ${CMAKE_COMMAND} -E echo "  docs             - Build documentation"
  COMMAND ${CMAKE_COMMAND} -E echo "  clean            - Clean build artifacts"
  COMMAND ${CMAKE_COMMAND} -E echo ""
  COMMAND ${CMAKE_COMMAND} -E echo "For full list: cmake --build . --target help"
  COMMENT "Showing usage information"
)

# Info target
add_custom_target(info
  COMMAND ${CMAKE_COMMAND} -E echo "RV64I_RWU ${RV64I_VERSION}"
  COMMAND ${CMAKE_COMMAND} -E echo "Git: ${RV64I_GIT_VERSION}"
  COMMAND ${CMAKE_COMMAND} -E echo "Build: ${CMAKE_BUILD_TYPE}"
  COMMAND ${CMAKE_COMMAND} -E echo "Binary dir: ${CMAKE_BINARY_DIR}"
  COMMENT "Showing project information"
)
