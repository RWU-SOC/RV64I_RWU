# SPDX-License-Identifier: Apache-2.0
# CTest framework integration for comprehensive regression testing

include_guard(GLOBAL)

# ============================================================================
# Test Framework Configuration
# ============================================================================
set(CTEST_OUTPUT_ON_FAILURE ON CACHE BOOL "Show test output on failure")

# Configure test timeouts
set(TEST_TIMEOUT_SHORT 300 CACHE STRING "Timeout for short tests (seconds)")
set(TEST_TIMEOUT_MEDIUM 600 CACHE STRING "Timeout for medium tests (seconds)")
set(TEST_TIMEOUT_LONG 1200 CACHE STRING "Timeout for long tests (seconds)")

# Test labels for categorization
set(TEST_LABELS_AVAILABLE
  "unit"           # Unit tests (individual modules)
  "instruction"    # Instruction-level tests
  "system"         # System-level tests
  "hardware"       # Hardware testbenches (RTL simulation)
  "software"       # Software tests (firmware)
  "integration"    # Integration tests (HW+SW)
  "quick"          # Fast tests (<1 min)
  "slow"           # Slow tests (>5 min)
  "regression"     # Full regression suite
  CACHE INTERNAL "Available test labels"
)

# ============================================================================
# Regression Test Suites
# ============================================================================
# Define test suite groups for different regression levels

set(REGRESSION_QUICK_LABELS "unit;quick" CACHE STRING "Labels for quick regression")
set(REGRESSION_FULL_LABELS "unit;instruction;system" CACHE STRING "Labels for full regression")
set(REGRESSION_NIGHTLY_LABELS "unit;instruction;system;integration;slow" CACHE STRING "Labels for nightly regression")

# ============================================================================
# Parallel Execution Configuration
# ============================================================================
option(ENABLE_PARALLEL_TESTS "Enable parallel CTest execution" ON)

if(ENABLE_PARALLEL_TESTS)
  include(ProcessorCount)
  ProcessorCount(N)
  if(NOT N EQUAL 0)
    # Reserve one core for OS/other tasks
    math(EXPR PARALLEL_JOBS "${N} - 1")
    if(PARALLEL_JOBS LESS 1)
      set(PARALLEL_JOBS 1)
    endif()
    set(CTEST_PARALLEL_LEVEL ${PARALLEL_JOBS} CACHE STRING "Number of parallel test jobs")
    message(STATUS "Parallel testing enabled: ${PARALLEL_JOBS} jobs (${N} cores detected)")
  endif()
endif()

# ============================================================================
# Test Result Aggregation
# ============================================================================
set(TEST_RESULTS_DIR "${CMAKE_BINARY_DIR}/test_results" CACHE PATH "Test results directory")
file(MAKE_DIRECTORY "${TEST_RESULTS_DIR}")

# ============================================================================
# Helper Function: Add Categorized Test
# ============================================================================
function(rv64i_add_test)
  cmake_parse_arguments(
    TEST                          # prefix
    ""                           # options
    "NAME;TIMEOUT;WORKING_DIRECTORY"  # one-value keywords
    "COMMAND;LABELS;DEPENDS"     # multi-value keywords
    ${ARGN}                      # arguments to parse
  )
  
  if(NOT TEST_NAME)
    message(FATAL_ERROR "rv64i_add_test: NAME is required")
  endif()
  
  if(NOT TEST_COMMAND)
    message(FATAL_ERROR "rv64i_add_test: COMMAND is required")
  endif()
  
  # Add the test
  add_test(
    NAME ${TEST_NAME}
    COMMAND ${TEST_COMMAND}
  )
  
  # Set working directory
  if(TEST_WORKING_DIRECTORY)
    set_tests_properties(${TEST_NAME} PROPERTIES 
      WORKING_DIRECTORY ${TEST_WORKING_DIRECTORY}
    )
  endif()
  
  # Set timeout
  if(TEST_TIMEOUT)
    set_tests_properties(${TEST_NAME} PROPERTIES TIMEOUT ${TEST_TIMEOUT})
  else()
    set_tests_properties(${TEST_NAME} PROPERTIES TIMEOUT ${TEST_TIMEOUT_MEDIUM})
  endif()
  
  # Set labels
  if(TEST_LABELS)
    set_tests_properties(${TEST_NAME} PROPERTIES LABELS "${TEST_LABELS}")
  endif()
  
  # Set dependencies
  if(TEST_DEPENDS)
    set_tests_properties(${TEST_NAME} PROPERTIES DEPENDS "${TEST_DEPENDS}")
  endif()
endfunction()

# ============================================================================
# Helper Function: Add Simulation Test with Result Parsing
# ============================================================================
function(rv64i_add_simulation_test)
  cmake_parse_arguments(
    SIM
    ""
    "NAME;TARGET;WORKING_DIRECTORY;TIMEOUT"
    "LABELS"
    ${ARGN}
  )
  
  if(NOT SIM_NAME)
    message(FATAL_ERROR "rv64i_add_simulation_test: NAME is required")
  endif()
  
  # Result parser script (to be created if needed)
  set(result_parser "${CMAKE_SOURCE_DIR}/cmake/scripts/parse_sim_results.cmake")
  
  # Build simulation-specific labels
  set(sim_labels ${SIM_LABELS})
  list(APPEND sim_labels "simulation" "hardware")
  
  rv64i_add_test(
    NAME ${SIM_NAME}
    COMMAND ${CMAKE_COMMAND}
      -DTEST_NAME=${SIM_NAME}
      -DWORK_DIR=${SIM_WORKING_DIRECTORY}
      -P ${result_parser}
    WORKING_DIRECTORY ${SIM_WORKING_DIRECTORY}
    TIMEOUT ${SIM_TIMEOUT}
    LABELS "${sim_labels}"
    DEPENDS ${SIM_TARGET}
  )
endfunction()

# ============================================================================
# Helper Function: Add Test Suite
# ============================================================================
function(rv64i_add_test_suite suite_name)
  cmake_parse_arguments(
    SUITE
    ""
    "DESCRIPTION"
    "LABELS;TESTS"
    ${ARGN}
  )
  
  # Create convenience target to run this test suite
  add_custom_target(test_suite_${suite_name}
    COMMAND ${CMAKE_CTEST_COMMAND}
      -L "${SUITE_LABELS}"
      --output-on-failure
      -j ${CTEST_PARALLEL_LEVEL}
    COMMENT "Running ${suite_name} test suite: ${SUITE_DESCRIPTION}"
    USES_TERMINAL
  )
  
endfunction()

# ============================================================================
# Status Output
# ============================================================================
message(STATUS "Test Framework Configuration:")
message(STATUS "  Short timeout:    ${TEST_TIMEOUT_SHORT}s")
message(STATUS "  Medium timeout:   ${TEST_TIMEOUT_MEDIUM}s")
message(STATUS "  Long timeout:     ${TEST_TIMEOUT_LONG}s")
message(STATUS "  Results dir:      ${TEST_RESULTS_DIR}")
message(STATUS "")
