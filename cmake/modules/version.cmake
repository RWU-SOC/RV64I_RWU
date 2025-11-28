# SPDX-License-Identifier: Apache-2.0
# Version information for RV64I project

include_guard(GLOBAL)

# Project version from CMakeLists.txt
set(RV64I_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(RV64I_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(RV64I_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(RV64I_VERSION "${RV64I_VERSION_MAJOR}.${RV64I_VERSION_MINOR}.${RV64I_VERSION_PATCH}")

# Build information
string(TIMESTAMP RV64I_BUILD_DATE "%Y-%m-%d")
string(TIMESTAMP RV64I_BUILD_TIME "%H:%M:%S")
set(RV64I_BUILD_TIMESTAMP "${RV64I_BUILD_DATE} ${RV64I_BUILD_TIME}")

# Get git information if available
find_package(Git QUIET)
if(GIT_FOUND)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
    WORKING_DIRECTORY ${RV64I_BASE}
    OUTPUT_VARIABLE RV64I_GIT_COMMIT
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  
  execute_process(
    COMMAND ${GIT_EXECUTABLE} describe --tags --always --dirty
    WORKING_DIRECTORY ${RV64I_BASE}
    OUTPUT_VARIABLE RV64I_GIT_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
else()
  set(RV64I_GIT_COMMIT "unknown")
  set(RV64I_GIT_VERSION "unknown")
endif()

# Cache version variables
set(RV64I_VERSION ${RV64I_VERSION} CACHE STRING "Project version" FORCE)
set(RV64I_GIT_COMMIT ${RV64I_GIT_COMMIT} CACHE STRING "Git commit hash" FORCE)
set(RV64I_GIT_VERSION ${RV64I_GIT_VERSION} CACHE STRING "Git version" FORCE)

message(STATUS "Version information:")
message(STATUS "  Version:    ${RV64I_VERSION}")
message(STATUS "  Git commit: ${RV64I_GIT_COMMIT}")
message(STATUS "  Build date: ${RV64I_BUILD_DATE}")
