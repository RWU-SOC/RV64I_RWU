# SPDX-License-Identifier: Apache-2.0
# Git integration for version tracking

include_guard(GLOBAL)

find_package(Git QUIET)

if(GIT_FOUND)
  # Get current branch
  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
    WORKING_DIRECTORY ${RV64I_BASE}
    OUTPUT_VARIABLE GIT_BRANCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  
  # Check if working directory is clean
  execute_process(
    COMMAND ${GIT_EXECUTABLE} status --porcelain
    WORKING_DIRECTORY ${RV64I_BASE}
    OUTPUT_VARIABLE GIT_STATUS
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  
  if(GIT_STATUS)
    set(GIT_IS_DIRTY TRUE)
  else()
    set(GIT_IS_DIRTY FALSE)
  endif()
  
  # Cache git variables
  set(GIT_BRANCH ${GIT_BRANCH} CACHE STRING "Current git branch" FORCE)
  set(GIT_IS_DIRTY ${GIT_IS_DIRTY} CACHE BOOL "Git working directory is dirty" FORCE)
  
  if(GIT_IS_DIRTY)
    message(STATUS "Git: ${GIT_BRANCH} (dirty)")
  else()
    message(STATUS "Git: ${GIT_BRANCH}")
  endif()
else()
  message(STATUS "Git not found (version tracking disabled)")
endif()

# Function to get file list from git
function(rv64i_git_ls_files output_var)
  if(NOT GIT_FOUND)
    message(FATAL_ERROR "Git is required for git_ls_files")
  endif()
  
  cmake_parse_arguments(GIT "" "PATH" "" ${ARGN})
  
  if(NOT GIT_PATH)
    set(GIT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
  endif()
  
  execute_process(
    COMMAND ${GIT_EXECUTABLE} ls-files
    WORKING_DIRECTORY ${GIT_PATH}
    OUTPUT_VARIABLE files
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  
  string(REPLACE "\n" ";" file_list "${files}")
  set(${output_var} ${file_list} PARENT_SCOPE)
endfunction()
