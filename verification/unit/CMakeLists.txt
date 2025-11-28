# ==============================================================================
# Unit Tests Build Configuration
# ==============================================================================
# Auto-discovers and configures unit-level testbenches (component tests)
# ==============================================================================

# Auto-discover unit testbenches
file(GLOB UNIT_TB_FILES "${CMAKE_CURRENT_SOURCE_DIR}/tb_*.sv")

if(NOT UNIT_TB_FILES)
    message(WARNING "No unit testbenches found in ${CMAKE_CURRENT_SOURCE_DIR}")
    return()
endif()

# Create tests for each unit testbench
foreach(tb_file ${UNIT_TB_FILES})
    get_filename_component(tb_name ${tb_file} NAME_WE)
    
    # Create CTest entry if XSIM is available
    if(XSIM_FOUND)
        add_test(
            NAME ${tb_name}
            COMMAND ${XSIM_EXECUTABLE} -gui ${tb_file}
            WORKING_DIRECTORY ${RV64I_BUILD_UNIT_DIR}
        )
        set_tests_properties(${tb_name} PROPERTIES
            LABELS "unit;hardware"
            TIMEOUT 300
        )
        message(STATUS "    Unit test: ${tb_name}")
    endif()
endforeach()

# Export for parent scope
set(RV64I_UNIT_TB_SOURCES ${UNIT_TB_FILES} PARENT_SCOPE)

message(STATUS "  Unit tests configured: ${CMAKE_CURRENT_SOURCE_DIR}")
