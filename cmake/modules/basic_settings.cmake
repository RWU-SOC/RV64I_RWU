# ==============================================================================
# Basic CMake Settings
# ==============================================================================
# Loaded early to set policies, build type, and platform detection.
# Think of this as the "foundation" that everything else builds on.
# ==============================================================================

include_guard(GLOBAL)

# ------------------------------------------------------------------------------
# CMake Policies (behavior switches for compatibility)
# ------------------------------------------------------------------------------
if(POLICY CMP0076)
  cmake_policy(SET CMP0076 NEW) # target_sources() uses relative paths
endif()

if(POLICY CMP0077)
  cmake_policy(SET CMP0077 NEW) # option() honors normal variables
endif()

# ------------------------------------------------------------------------------
# Set default build type if user didn't specify
# ------------------------------------------------------------------------------
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type (Debug/Release)" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Release" "MinSizeRel" "RelWithDebInfo"
  )
endif()

# ------------------------------------------------------------------------------
# Enable colored diagnostics (CMake 3.24+)
# ------------------------------------------------------------------------------
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24")
  set(CMAKE_COLOR_DIAGNOSTICS ON)
endif()

# ------------------------------------------------------------------------------
# Platform detection (Windows vs Unix)
# ------------------------------------------------------------------------------
if(WIN32)
  set(RV64I_HOST_PLATFORM "windows")
  set(RV64I_SHELL "powershell")
else()
  set(RV64I_HOST_PLATFORM "unix")
  set(RV64I_SHELL "bash")
endif()

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Host platform: ${RV64I_HOST_PLATFORM}")
