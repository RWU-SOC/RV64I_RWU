# ==============================================================================
# Firmware Build Configuration
# ==============================================================================
# Manages firmware tests and common libraries for the RV64I processor
# ==============================================================================

message(STATUS "Configuring Firmware Components...")

# ============================================================================
# Check for RISC-V toolchain
# ============================================================================
if(NOT RISCV_TOOLCHAIN_FOUND)
    message(WARNING "RISC-V toolchain not found - firmware builds disabled")
    message(STATUS "  Install riscv64-unknown-elf-gcc to enable firmware compilation")
    return()
endif()

# ============================================================================
# Firmware Build Options
# ============================================================================
option(BUILD_FIRMWARE_TESTS "Build firmware test programs" ON)
option(BUILD_FIRMWARE_ASM "Build assembly tests" ON)
option(BUILD_FIRMWARE_C "Build C tests" ON)

# ============================================================================
# Common firmware infrastructure
# ============================================================================

# Check for common runtime files (crt0.s, linker scripts, headers)
set(FIRMWARE_CRT0 "${RV64I_FIRMWARE_COMMON_DIR}/crt0.s")
set(FIRMWARE_LINKER "${RV64I_FIRMWARE_COMMON_DIR}/linker.ld")

if(EXISTS "${FIRMWARE_CRT0}")
    message(STATUS "  Runtime startup: ${FIRMWARE_CRT0}")
else()
    message(STATUS "  Runtime startup: not found (using defaults)")
endif()

if(EXISTS "${FIRMWARE_LINKER}")
    message(STATUS "  Linker script: ${FIRMWARE_LINKER}")
else()
    message(STATUS "  Linker script: not found (using defaults)")
endif()

# ============================================================================
# Firmware Tests
# ============================================================================

if(BUILD_FIRMWARE_TESTS)
    # Auto-discover assembly test files
    file(GLOB ASM_TEST_FILES "${RV64I_FIRMWARE_TESTS_DIR}/*.asm")
    
    if(BUILD_FIRMWARE_ASM AND ASM_TEST_FILES)
        message(STATUS "  Assembly tests found: ${CMAKE_CURRENT_SOURCE_DIR}/tests")
        foreach(asm_file ${ASM_TEST_FILES})
            get_filename_component(test_name ${asm_file} NAME_WE)
            
            # Build assembly test using helper function (generates .mem files)
            rv64i_add_firmware_asm(
                NAME fw_asm_${test_name}
                ASM_FILE ${asm_file}
                OUTPUT_DIR ${RV64I_BUILD_FIRMWARE_DIR}
            )
            
            # Add CTest entry
            add_test(
                NAME firmware_asm_${test_name}
                COMMAND ${CMAKE_COMMAND} -E echo "Assembly test built: ${test_name} (.mem files generated)"
                WORKING_DIRECTORY ${RV64I_BUILD_FIRMWARE_DIR}
            )
            set_tests_properties(firmware_asm_${test_name} PROPERTIES
                LABELS "firmware;assembly"
            )
            
            message(STATUS "    - ${test_name}.asm -> .mem")
        endforeach()
    endif()
    
    # Auto-discover C test files
    file(GLOB C_TEST_FILES "${RV64I_FIRMWARE_TESTS_DIR}/*.c")
    
    if(BUILD_FIRMWARE_C AND C_TEST_FILES)
        message(STATUS "  C tests found:")
        
        # Check if we have startup and linker files
        if(EXISTS "${FIRMWARE_CRT0}" AND EXISTS "${FIRMWARE_LINKER}")
            foreach(c_file ${C_TEST_FILES})
                get_filename_component(test_name ${c_file} NAME_WE)
                
                # Build C test using helper function (generates .mem files)
                rv64i_add_firmware_c(
                    NAME fw_c_${test_name}
                    C_FILE ${c_file}
                    CRT0_FILE ${FIRMWARE_CRT0}
                    LINKER_SCRIPT ${FIRMWARE_LINKER}
                    OUTPUT_DIR ${RV64I_BUILD_FIRMWARE_DIR}
                )
                
                add_test(
                    NAME firmware_c_${test_name}
                    COMMAND ${CMAKE_COMMAND} -E echo "C test built: ${test_name} (.mem files generated)"
                    WORKING_DIRECTORY ${RV64I_BUILD_FIRMWARE_DIR}
                )
                set_tests_properties(firmware_c_${test_name} PROPERTIES
                    LABELS "firmware;c_code"
                )
                
                message(STATUS "    - ${test_name}.c -> .mem")
            endforeach()
        else()
            message(STATUS "  C tests require crt0.s and linker.ld - skipping")
            message(STATUS "    Please add firmware/common/crt0.s and linker.ld")
        endif()
    endif()
endif()

message(STATUS "Firmware Components configuration complete")
message(STATUS "")
