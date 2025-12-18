# ==============================================================================
# UART IP Verification Build Configuration
# ==============================================================================
# UART peripheral testbenches
# ==============================================================================

file(GLOB UART_TB_FILES "${CMAKE_CURRENT_SOURCE_DIR}/tb_*.sv")

if(NOT UART_TB_FILES)
    message(STATUS "    No UART testbenches found")
    return()
endif()

foreach(tb_file ${UART_TB_FILES})
    get_filename_component(tb_name ${tb_file} NAME_WE)
    
    if(XSIM_FOUND)
        add_test(
            NAME ${tb_name}_uart
            COMMAND ${XSIM_EXECUTABLE} -gui ${tb_file}
            WORKING_DIRECTORY ${RV64I_BUILD_IP_DIR}
        )
        set_tests_properties(${tb_name}_uart PROPERTIES
            LABELS "ip;uart;hardware"
            TIMEOUT 300
        )
        message(STATUS "      UART test: ${tb_name}")
    endif()
endforeach()

set(RV64I_UART_TB_SOURCES ${UART_TB_FILES} PARENT_SCOPE)
