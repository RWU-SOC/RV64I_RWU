# ==============================================================================
# Simulation Configuration Files
# ==============================================================================
# This directory contains only configuration files (TCL, waveforms, etc.)
# All simulation builds are generated under build/sim/
# ==============================================================================

message(STATUS "Configuring Simulation Infrastructure...")

# Simulation configuration directory
set(RV64I_SIM_CONFIG_DIR "${CMAKE_CURRENT_SOURCE_DIR}/config" CACHE PATH "Simulation config directory")

# Find TCL scripts
file(GLOB SIM_TCL_SCRIPTS "${RV64I_SIM_CONFIG_DIR}/*.tcl")
if(SIM_TCL_SCRIPTS)
    message(STATUS "  Simulation TCL scripts:")
    foreach(tcl_file ${SIM_TCL_SCRIPTS})
        get_filename_component(script_name ${tcl_file} NAME)
        message(STATUS "    - ${script_name}")
    endforeach()
endif()

# Find waveform configurations
file(GLOB SIM_WAVEFORM_CONFIGS "${RV64I_SIM_CONFIG_DIR}/*.wcfg")
if(SIM_WAVEFORM_CONFIGS)
    message(STATUS "  Waveform configurations:")
    foreach(wcfg_file ${SIM_WAVEFORM_CONFIGS})
        get_filename_component(wcfg_name ${wcfg_file} NAME)
        message(STATUS "    - ${wcfg_name}")
    endforeach()
endif()

message(STATUS "Simulation Infrastructure configuration complete")
message(STATUS "")
