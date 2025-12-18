# ==============================================================================
# Unit Tests Build Configuration
# ==============================================================================
# Auto-discovers and configures unit-level testbenches (component tests)
# ==============================================================================

# Auto-discover unit testbenches (in current directory only)
file(GLOB UNIT_TB_FILES "${CMAKE_CURRENT_SOURCE_DIR}/tb_*.sv")

if(UNIT_TB_FILES)
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
endif()

# Add library component unit tests subdirectory
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/lib/CMakeLists.txt")
    message(STATUS "  Library component unit tests: ${CMAKE_CURRENT_SOURCE_DIR}/lib")
    add_subdirectory(lib)
else()
    message(STATUS "  Library component unit tests: not found")
endif()

message(STATUS "  Unit tests configured: ${CMAKE_CURRENT_SOURCE_DIR}")
