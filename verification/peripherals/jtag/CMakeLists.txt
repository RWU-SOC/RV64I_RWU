# ==============================================================================
# JTAG IP Verification Build Configuration
# ==============================================================================
# JTAG peripheral testbenches
# ==============================================================================

file(GLOB JTAG_TB_FILES "${CMAKE_CURRENT_SOURCE_DIR}/tb_*.sv")

if(NOT JTAG_TB_FILES)
    message(STATUS "    No JTAG testbenches found")
    return()
endif()

foreach(tb_file ${JTAG_TB_FILES})
    get_filename_component(tb_name ${tb_file} NAME_WE)
    
    if(XSIM_FOUND)
        add_test(
            NAME ${tb_name}_jtag
            COMMAND ${XSIM_EXECUTABLE} -gui ${tb_file}
            WORKING_DIRECTORY ${RV64I_BUILD_IP_DIR}
        )
        set_tests_properties(${tb_name}_jtag PROPERTIES
            LABELS "ip;jtag;hardware"
            TIMEOUT 300
        )
        message(STATUS "      JTAG test: ${tb_name}")
    endif()
endforeach()

set(RV64I_JTAG_TB_SOURCES ${JTAG_TB_FILES} PARENT_SCOPE)
