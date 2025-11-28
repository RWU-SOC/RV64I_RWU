# SPDX-License-Identifier: Apache-2.0
# RV64I CMake Extensions
# Reusable functions and macros for the build system

include_guard(GLOBAL)

# ============================================================================
# 1. CMake-generic extensions
# ============================================================================

# ----------------------------------------------------------------------------
# Function: rv64i_set_ifndef
# Set a variable only if it's not already defined
# ----------------------------------------------------------------------------
macro(rv64i_set_ifndef variable value)
  if(NOT DEFINED ${variable})
    set(${variable} ${value} ${ARGN})
  endif()
endmacro()

# ----------------------------------------------------------------------------
# Function: rv64i_append_ifndef
# Append to a variable only if the value is not already present
# ----------------------------------------------------------------------------
macro(rv64i_append_ifndef variable value)
  if(NOT ${value} IN_LIST ${variable})
    list(APPEND ${variable} ${value})
  endif()
endmacro()

# ----------------------------------------------------------------------------
# Function: rv64i_check_cache
# Verify that a cached variable hasn't changed unexpectedly
# ----------------------------------------------------------------------------
function(rv64i_check_cache variable)
  cmake_parse_arguments(CHECK "REQUIRED" "" "" ${ARGN})
  
  set(cache_var "${variable}_CACHED")
  
  if(DEFINED ${cache_var})
    if(NOT "${${variable}}" STREQUAL "${${cache_var}}")
      message(WARNING 
        "${variable} changed from '${${cache_var}}' to '${${variable}}'. "
        "This may cause build issues. Consider a clean rebuild."
      )
    endif()
  elseif(CHECK_REQUIRED AND NOT DEFINED ${variable})
    message(FATAL_ERROR "${variable} is required but not defined")
  endif()
  
  set(${cache_var} "${${variable}}" CACHE INTERNAL "${variable} cached value")
endfunction()

# ----------------------------------------------------------------------------
# Function: rv64i_add_custom_target_ifnot_exists
# Create custom target only if it doesn't exist
# ----------------------------------------------------------------------------
function(rv64i_add_custom_target_ifnot_exists target_name)
  if(NOT TARGET ${target_name})
    add_custom_target(${target_name} ${ARGN})
  endif()
endfunction()

# ============================================================================
# 2. Build helper functions
# ============================================================================

# ----------------------------------------------------------------------------
# Function: rv64i_create_build_stamp
# Create a timestamp file to track build dependencies
# ----------------------------------------------------------------------------
function(rv64i_create_build_stamp output_var stamp_name)
  set(stamp_file "${CMAKE_CURRENT_BINARY_DIR}/.${stamp_name}.timestamp")
  set(${output_var} ${stamp_file} PARENT_SCOPE)
endfunction()

# ----------------------------------------------------------------------------
# Function: rv64i_get_target_sources
# Get list of sources for a target (helper for dependency tracking)
# ----------------------------------------------------------------------------
function(rv64i_get_target_sources target output_var)
  get_target_property(sources ${target} SOURCES)
  if(sources)
    set(${output_var} ${sources} PARENT_SCOPE)
  else()
    set(${output_var} "" PARENT_SCOPE)
  endif()
endfunction()

# ============================================================================
# 3. Logging and debugging
# ============================================================================

# ----------------------------------------------------------------------------
# Function: rv64i_print_var
# Print a variable's value (for debugging)
# ----------------------------------------------------------------------------
function(rv64i_print_var variable)
  message(STATUS "${variable} = ${${variable}}")
endfunction()

# ----------------------------------------------------------------------------
# Function: rv64i_print_target_properties
# Print all properties of a target (for debugging)
# ----------------------------------------------------------------------------
function(rv64i_print_target_properties target)
  if(NOT TARGET ${target})
    message(WARNING "Target '${target}' does not exist")
    return()
  endif()
  
  message(STATUS "Properties of target '${target}':")
  
  foreach(prop
    TYPE
    SOURCES
    COMPILE_DEFINITIONS
    COMPILE_OPTIONS
    INCLUDE_DIRECTORIES
    LINK_LIBRARIES
    DEPENDS
  )
    get_target_property(val ${target} ${prop})
    if(val)
      message(STATUS "  ${prop}: ${val}")
    endif()
  endforeach()
endfunction()

# ============================================================================
# 4. File system helpers
# ============================================================================

# ----------------------------------------------------------------------------
# Function: rv64i_normalize_path
# Convert path to absolute and normalized form
# ----------------------------------------------------------------------------
function(rv64i_normalize_path path output_var)
  get_filename_component(abs_path "${path}" ABSOLUTE)
  file(TO_CMAKE_PATH "${abs_path}" normalized)
  set(${output_var} "${normalized}" PARENT_SCOPE)
endfunction()

# ----------------------------------------------------------------------------
# Function: rv64i_copy_if_different
# Copy file only if source and destination differ
# ----------------------------------------------------------------------------
function(rv64i_copy_if_different source dest)
  if(NOT EXISTS "${dest}" OR NOT "${source}" IS_NEWER_THAN "${dest}")
    configure_file("${source}" "${dest}" COPYONLY)
  endif()
endfunction()

# ============================================================================
# 5. List manipulation
# ============================================================================

# ----------------------------------------------------------------------------
# Function: rv64i_list_transform_prepend
# Prepend a prefix to each item in a list
# ----------------------------------------------------------------------------
function(rv64i_list_transform_prepend output_var prefix)
  set(result "")
  foreach(item ${ARGN})
    list(APPEND result "${prefix}${item}")
  endforeach()
  set(${output_var} ${result} PARENT_SCOPE)
endfunction()

# ----------------------------------------------------------------------------
# Function: rv64i_list_transform_append  
# Append a suffix to each item in a list
# ----------------------------------------------------------------------------
function(rv64i_list_transform_append output_var suffix)
  set(result "")
  foreach(item ${ARGN})
    list(APPEND result "${item}${suffix}")
  endforeach()
  set(${output_var} ${result} PARENT_SCOPE)
endfunction()

# ============================================================================
# 6. Platform compatibility
# ============================================================================

# ----------------------------------------------------------------------------
# Function: rv64i_get_shell_command
# Get platform-appropriate shell command
# ----------------------------------------------------------------------------
function(rv64i_get_shell_command output_var command)
  if(WIN32)
    set(${output_var} powershell -NoProfile -Command "${command}" PARENT_SCOPE)
  else()
    set(${output_var} bash -c "${command}" PARENT_SCOPE)
  endif()
endfunction()

# ----------------------------------------------------------------------------
# Function: rv64i_execute_process_checked
# Execute process and check return code
# ----------------------------------------------------------------------------
function(rv64i_execute_process_checked)
  cmake_parse_arguments(EXEC "" "RESULT_VAR;COMMAND_NAME" "COMMAND" ${ARGN})
  
  execute_process(
    COMMAND ${EXEC_COMMAND}
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE
  )
  
  if(NOT result EQUAL 0)
    message(FATAL_ERROR 
      "${EXEC_COMMAND_NAME} failed with code ${result}\n"
      "Command: ${EXEC_COMMAND}\n"
      "Output: ${output}\n"
      "Error: ${error}"
    )
  endif()
  
  if(EXEC_RESULT_VAR)
    set(${EXEC_RESULT_VAR} ${result} PARENT_SCOPE)
  endif()
endfunction()

# ============================================================================
# 7. Zephyr-style include_guard for modules
# ============================================================================

# Note: We use CMake's built-in include_guard(GLOBAL) in most modules,
# but this provides a custom implementation if needed for compatibility

macro(rv64i_include_guard)
  get_filename_component(_guard_file "${CMAKE_CURRENT_LIST_FILE}" NAME_WE)
  string(MAKE_C_IDENTIFIER "rv64i_${_guard_file}_included" _guard_var)
  string(TOUPPER "${_guard_var}" _guard_var)
  
  if(DEFINED ${_guard_var})
    return()
  endif()
  
  set(${_guard_var} TRUE)
endmacro()

# Load firmware-specific extensions
include(firmware_extensions OPTIONAL)

# Load simulation-specific extensions
include(simulation_extensions OPTIONAL)

message(STATUS "CMake extensions loaded")
