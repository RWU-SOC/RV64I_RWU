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
            
            # Build assembly test
            set(output_file "${RV64I_BUILD_FIRMWARE_DIR}/${test_name}_asm.elf")
            add_custom_command(
                OUTPUT ${output_file}
                COMMAND ${RISCV_AS} -o ${output_file} ${asm_file}
                DEPENDS ${asm_file}
                COMMENT "Building assembly test: ${test_name}"
            )
            
            # Create target
            add_custom_target(fw_asm_${test_name} ALL DEPENDS ${output_file})
            
            # Add CTest entry
            add_test(
                NAME firmware_asm_${test_name}
                COMMAND ${CMAKE_COMMAND} -E echo "Assembly test built: ${test_name}"
                WORKING_DIRECTORY ${RV64I_BUILD_FIRMWARE_DIR}
            )
            set_tests_properties(firmware_asm_${test_name} PROPERTIES
                LABELS "firmware;assembly"
            )
            
            message(STATUS "    - ${test_name}.asm")
        endforeach()
    endif()
    
    # Auto-discover C test files
    file(GLOB C_TEST_FILES "${RV64I_FIRMWARE_TESTS_DIR}/*.c")
    
    if(BUILD_FIRMWARE_C AND C_TEST_FILES)
        message(STATUS "  C tests found:")
        foreach(c_file ${C_TEST_FILES})
            get_filename_component(test_name ${c_file} NAME_WE)
            
            # Build C test
            set(output_file "${RV64I_BUILD_FIRMWARE_DIR}/${test_name}_c.elf")
            
            # Only add if linker script exists
            if(EXISTS "${FIRMWARE_LINKER}")
                add_custom_command(
                    OUTPUT ${output_file}
                    COMMAND ${RISCV_CC} -march=rv64i -mabi=lp64 -nostdlib
                            -T ${FIRMWARE_LINKER} -o ${output_file} ${c_file}
                    DEPENDS ${c_file} ${FIRMWARE_LINKER}
                    COMMENT "Building C test: ${test_name}"
                )
            else()
                # Use default linker script if not provided
                add_custom_command(
                    OUTPUT ${output_file}
                    COMMAND ${RISCV_CC} -march=rv64i -mabi=lp64 -nostdlib
                            -o ${output_file} ${c_file}
                    DEPENDS ${c_file}
                    COMMENT "Building C test (no linker script): ${test_name}"
                )
            endif()
            
            add_custom_target(fw_c_${test_name} ALL DEPENDS ${output_file})
            
            add_test(
                NAME firmware_c_${test_name}
                COMMAND ${CMAKE_COMMAND} -E echo "C test built: ${test_name}"
                WORKING_DIRECTORY ${RV64I_BUILD_FIRMWARE_DIR}
            )
            set_tests_properties(firmware_c_${test_name} PROPERTIES
                LABELS "firmware;c_code"
            )
            
            message(STATUS "    - ${test_name}.c")
        endforeach()
    endif()
endif()

message(STATUS "Firmware Components configuration complete")
message(STATUS "")
