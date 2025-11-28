# SPDX-License-Identifier: Apache-2.0
# Python support for build scripts

include_guard(GLOBAL)

# Find Python3
find_package(Python3 COMPONENTS Interpreter)

if(Python3_FOUND)
  set(PYTHON_EXECUTABLE ${Python3_EXECUTABLE} CACHE FILEPATH "Python interpreter" FORCE)
  
  # Get Python version
  execute_process(
    COMMAND ${Python3_EXECUTABLE} --version
    OUTPUT_VARIABLE PYTHON_VERSION_OUTPUT
    ERROR_VARIABLE PYTHON_VERSION_OUTPUT
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE
  )
  
  message(STATUS "Python found: ${PYTHON_EXECUTABLE}")
  message(STATUS "Python version: ${Python3_VERSION}")
else()
  message(STATUS "Python not found (optional for build scripts)")
endif()

# Function to execute Python script
function(rv64i_python_script script_path)
  if(NOT Python3_FOUND)
    message(FATAL_ERROR "Python is required to run ${script_path}")
  endif()
  
  cmake_parse_arguments(PY "" "RESULT_VAR;WORKING_DIR" "ARGS" ${ARGN})
  
  if(NOT PY_WORKING_DIR)
    set(PY_WORKING_DIR ${CMAKE_CURRENT_BINARY_DIR})
  endif()
  
  execute_process(
    COMMAND ${Python3_EXECUTABLE} ${script_path} ${PY_ARGS}
    WORKING_DIRECTORY ${PY_WORKING_DIR}
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE
  )
  
  if(PY_RESULT_VAR)
    set(${PY_RESULT_VAR} ${result} PARENT_SCOPE)
  endif()
  
  if(NOT result EQUAL 0)
    message(FATAL_ERROR
      "Python script failed: ${script_path}\n"
      "Error: ${error}\n"
      "Output: ${output}"
    )
  endif()
endfunction()
