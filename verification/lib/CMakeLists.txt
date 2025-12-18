# ==============================================================================
# Library Component Tests Build Configuration
# ==============================================================================
# Auto-discovers and configures testbenches for RTL library components
# ==============================================================================

# Auto-discover library testbenches (both tb_*.sv and *_tb.sv patterns)
file(GLOB LIB_TB_FILES 
    "${CMAKE_CURRENT_SOURCE_DIR}/tb_*.sv"
    "${CMAKE_CURRENT_SOURCE_DIR}/*_tb.sv"
)

# Check if Vivado tools are available
if(NOT VIVADO_FOUND)
    message(STATUS "  Vivado not found - skipping library simulation tests")
    if(LIB_TB_FILES)
        message(STATUS "  Library testbenches found but XSIM not available")
    endif()
    return()
endif()

# Simulation build directory
set(SIM_LIB_DIR "${CMAKE_BINARY_DIR}/sim/lib")

if(LIB_TB_FILES)
    message(STATUS "  Configuring library testbenches...")
    
    # Create simulation directory
    file(MAKE_DIRECTORY ${SIM_LIB_DIR})
    
    # Get library RTL files
    file(GLOB LIB_RTL_FILES "${RV64I_RTL_DIR}/lib/*.sv")
    
    # Create tests for each library testbench
    foreach(tb_file ${LIB_TB_FILES})
        get_filename_component(tb_name ${tb_file} NAME_WE)
        
        # Simulation directory for this test
        set(test_sim_dir "${SIM_LIB_DIR}/${tb_name}")
        set(snapshot_name "${tb_name}_snapshot")
        
        # RTL file list
        set(rtl_filelist "${test_sim_dir}/rtl_sources.f")
        
        # Create RTL file list at configure time
        file(MAKE_DIRECTORY ${test_sim_dir})
        file(WRITE ${rtl_filelist} "")
        foreach(rtl_file ${LIB_RTL_FILES})
            file(APPEND ${rtl_filelist} "${rtl_file}\n")
        endforeach()
        
        # Step 1: Compile RTL
        add_custom_command(
            OUTPUT ${test_sim_dir}/.rtl_compiled
            COMMAND ${XVLOG} --sv --incr --relax -f ${rtl_filelist}
            COMMAND ${CMAKE_COMMAND} -E touch .rtl_compiled
            WORKING_DIRECTORY ${test_sim_dir}
            DEPENDS ${LIB_RTL_FILES} ${rtl_filelist}
            COMMENT "Compiling RTL for ${tb_name}"
            VERBATIM
        )
        
        # Step 2: Compile testbench
        add_custom_command(
            OUTPUT ${test_sim_dir}/.tb_compiled
            COMMAND ${XVLOG} --sv --incr --relax ${tb_file}
            COMMAND ${CMAKE_COMMAND} -E touch .tb_compiled
            WORKING_DIRECTORY ${test_sim_dir}
            DEPENDS ${test_sim_dir}/.rtl_compiled ${tb_file}
            COMMENT "Compiling testbench ${tb_name}"
            VERBATIM
        )
        
        # Step 3: Elaborate
        add_custom_command(
            OUTPUT ${test_sim_dir}/.elaborated
            COMMAND ${XELAB} -debug typical -top ${tb_name} -snapshot ${snapshot_name}
            COMMAND ${CMAKE_COMMAND} -E touch .elaborated
            WORKING_DIRECTORY ${test_sim_dir}
            DEPENDS ${test_sim_dir}/.tb_compiled
            COMMENT "Elaborating ${tb_name}"
            VERBATIM
        )
        
        # Build target (compile and elaborate only)
        add_custom_target(sim_${tb_name}
            DEPENDS ${test_sim_dir}/.elaborated
        )
        
        # Run target - Console mode (default)
        add_custom_target(run_${tb_name}
            COMMAND ${XSIM} ${snapshot_name} --runall --log xsim.log
            WORKING_DIRECTORY ${test_sim_dir}
            DEPENDS ${test_sim_dir}/.elaborated
            COMMENT "Running ${tb_name} in console mode"
            USES_TERMINAL
        )
        
        # Run target - GUI mode with waveform
        add_custom_target(run_${tb_name}_gui
            COMMAND ${XSIM} ${snapshot_name} --gui
            WORKING_DIRECTORY ${test_sim_dir}
            DEPENDS ${test_sim_dir}/.elaborated
            COMMENT "Running ${tb_name} in GUI mode"
        )
        
        # CTest entry to run simulation (for regression testing)
        add_test(
            NAME lib_${tb_name}
            COMMAND ${XSIM} ${snapshot_name} --runall --log xsim.log
            WORKING_DIRECTORY ${test_sim_dir}
        )
        set_tests_properties(lib_${tb_name} PROPERTIES
            LABELS "lib;simulation"
            TIMEOUT 300
        )
        
        message(STATUS "    Library test: ${tb_name}")
    endforeach()
    
    # Export for parent scope
    set(RV64I_LIB_TB_SOURCES ${LIB_TB_FILES} PARENT_SCOPE)
else()
    message(STATUS "  No library testbenches found in ${CMAKE_CURRENT_SOURCE_DIR}")
endif()

message(STATUS "  Library tests configured: ${CMAKE_CURRENT_SOURCE_DIR}")
