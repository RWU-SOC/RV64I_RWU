# ==============================================================================
# Integration Tests - Vivado XSIM Simulation Build
# ==============================================================================
# Auto-discovers integration testbenches (tb_rv64i*.sv) and creates simulation
# targets that compile RTL, compile testbench, elaborate, and run simulation.
#
# Build artifacts go to: build/sim/integration/<test_name>/
# Firmware .mem files from: build/firmware/<test_name>_asm.elf
# ==============================================================================

message(STATUS "  Integration tests: ${CMAKE_CURRENT_SOURCE_DIR}")

# Check if Vivado tools are available
if(NOT VIVADO_FOUND)
    message(STATUS "  Vivado not found - skipping integration tests")
    return()
endif()

# Auto-discover integration testbenches
file(GLOB INTEGRATION_TB_FILES "${CMAKE_CURRENT_SOURCE_DIR}/tb_rv64i*.sv")
if(NOT INTEGRATION_TB_FILES)
    message(WARNING "No integration testbenches found in ${CMAKE_CURRENT_SOURCE_DIR}")
    return()
endif()

# Get RTL source files list (matching original Makefile)
file(GLOB RTL_CORE_FILES "${RV64I_RTL_CORE_DIR}/*.sv")
file(GLOB RTL_JTAG_FILES "${RV64I_RTL_PERIPHERALS_DIR}/jtag/*.sv")

# Remove duplicate as_pack.sv files (keep only core version)
list(FILTER RTL_CORE_FILES EXCLUDE REGEX "as_pack\\.sv$")
list(FILTER RTL_JTAG_FILES EXCLUDE REGEX "as_pack\\.sv$")

# Simulation build directory
set(SIM_BUILD_DIR "${CMAKE_BINARY_DIR}/sim/integration")

# Create simulation targets for each testbench
foreach(tb_file ${INTEGRATION_TB_FILES})
    get_filename_component(tb_name ${tb_file} NAME_WE)
    
    # Extract test name (tb_rv64i_instr06addi -> instr06addi)
    string(REGEX REPLACE "^tb_rv64i_(.+)$" "\\1" test_name ${tb_name})
    string(REGEX REPLACE "^tb_rv64i$" "tb_rv64i" test_name ${test_name})
    
    # Simulation directory for this test
    set(test_sim_dir "${SIM_BUILD_DIR}/${test_name}")
    set(snapshot_name "${test_name}_snapshot")
    
    # RTL file list
    set(rtl_filelist "${test_sim_dir}/rtl_sources.f")
    
    # Create RTL file list at configure time
    file(MAKE_DIRECTORY ${test_sim_dir})
    file(WRITE ${rtl_filelist} "${RV64I_RTL_CORE_DIR}/as_pack.sv\n")
    foreach(rtl_file ${RTL_CORE_FILES})
        file(APPEND ${rtl_filelist} "${rtl_file}\n")
    endforeach()
    foreach(rtl_file ${RTL_JTAG_FILES})
        file(APPEND ${rtl_filelist} "${rtl_file}\n")
    endforeach()
    
    # Firmware files
    set(fw_elf "${CMAKE_BINARY_DIR}/firmware/${test_name}_asm.elf")
    set(fw_mem "${test_sim_dir}/riscvtest.mem")
    
    # Step 1: Generate .mem file from firmware
    add_custom_command(
        OUTPUT ${fw_mem}
        COMMAND ${RISCV_OBJCOPY} -O verilog --verilog-data-width=4 ${fw_elf} ${test_name}.v
        COMMAND ${Python3_EXECUTABLE} -c "import re; data=open('${test_name}.v').read(); data=re.sub(r' +','\\n',data); data=data.replace('\\r',''); lines=data.split('\\n'); open('riscvtest.mem','w').write('\\n'.join(lines[1:]))"
        WORKING_DIRECTORY ${test_sim_dir}
        DEPENDS ${fw_elf}
        COMMENT "Generating memory file for ${test_name}"
        VERBATIM
    )
    
    # Step 2: Compile RTL
    add_custom_command(
        OUTPUT ${test_sim_dir}/.rtl_compiled
        COMMAND ${XVLOG} --sv --incr --relax -d LOGIC_SV -f ${rtl_filelist}
        COMMAND ${CMAKE_COMMAND} -E touch .rtl_compiled
        WORKING_DIRECTORY ${test_sim_dir}
        DEPENDS ${RTL_CORE_FILES} ${RTL_JTAG_FILES} ${rtl_filelist}
        COMMENT "Compiling RTL for ${test_name}"
        VERBATIM
    )
    
    # Step 3: Compile testbench
    add_custom_command(
        OUTPUT ${test_sim_dir}/.tb_compiled
        COMMAND ${XVLOG} --sv --incr --relax -d LOGIC_SV ${tb_file}
        COMMAND ${CMAKE_COMMAND} -E touch .tb_compiled
        WORKING_DIRECTORY ${test_sim_dir}
        DEPENDS ${test_sim_dir}/.rtl_compiled ${tb_file}
        COMMENT "Compiling testbench ${tb_name}"
        VERBATIM
    )
    
    # Step 4: Elaborate
    add_custom_command(
        OUTPUT ${test_sim_dir}/.elaborated
        COMMAND ${XELAB} -debug typical -top tb_rv64i -snapshot ${snapshot_name}
        COMMAND ${CMAKE_COMMAND} -E touch .elaborated
        WORKING_DIRECTORY ${test_sim_dir}
        DEPENDS ${test_sim_dir}/.tb_compiled ${fw_mem}
        COMMENT "Elaborating ${test_name}"
        VERBATIM
    )
    
    # Build target
    add_custom_target(sim_${test_name}
        DEPENDS ${test_sim_dir}/.elaborated
    )
    
    # CTest entry to run simulation
    add_test(
        NAME integration_${test_name}
        COMMAND ${XSIM} ${snapshot_name} -runall
        WORKING_DIRECTORY ${test_sim_dir}
    )
    set_tests_properties(integration_${test_name} PROPERTIES
        LABELS "integration;simulation"
        TIMEOUT 300
    )
    
    message(STATUS "    Integration test: ${test_name}")
endforeach()

message(STATUS "  Integration tests configured: ${CMAKE_CURRENT_SOURCE_DIR}")
