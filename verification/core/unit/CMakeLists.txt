# ==============================================================================
# Unit Tests Build Configuration
# ==============================================================================
# Auto-discovers and configures unit-level testbenches (component tests)
# ==============================================================================

# Auto-discover core unit testbenches
file(GLOB CORE_UNIT_TB_FILES "${CMAKE_CURRENT_SOURCE_DIR}/tb_*.sv")

if(CORE_UNIT_TB_FILES)
    # Create tests for each core unit testbench
    foreach(tb_file ${CORE_UNIT_TB_FILES})
        get_filename_component(tb_name ${tb_file} NAME_WE)
        
        # Create CTest entry if XSIM is available
        if(XSIM_FOUND)
            add_test(
                NAME core_unit_${tb_name}
                COMMAND ${XSIM_EXECUTABLE} -gui ${tb_file}
                WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/sim/core/unit
            )
            set_tests_properties(core_unit_${tb_name} PROPERTIES
                LABELS "core;unit;hardware"
                TIMEOUT 300
            )
            message(STATUS "      Core unit test: ${tb_name}")
        endif()
    endforeach()
    
    # Export for parent scope
    set(RV64I_CORE_UNIT_TB_SOURCES ${CORE_UNIT_TB_FILES} PARENT_SCOPE)
endif()

message(STATUS "    Core unit tests configured: ${CMAKE_CURRENT_SOURCE_DIR}")
