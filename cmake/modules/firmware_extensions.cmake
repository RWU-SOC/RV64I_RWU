# ============================================================================
# RV64I_RWU Utility Functions
# Helper functions for firmware builds, Verilog conversion, and simulation
# ============================================================================

# ----------------------------------------------------------------------------
# Function: rv64i_add_firmware_asm
# Build assembly firmware and convert to Verilog hex format
# 
# Arguments:
#   TARGET_NAME - Name of the target
#   ASM_SOURCE  - Path to .asm source file
#   OUTPUT_DIR  - Output directory for generated files
# ----------------------------------------------------------------------------
function(rv64i_add_firmware_asm)
    cmake_parse_arguments(
        FW                      # prefix
        ""                      # options
        "NAME;ASM_FILE;OUTPUT_DIR"  # one-value keywords
        ""                      # multi-value keywords
        ${ARGN}                 # arguments to parse
    )
    
    if(NOT FW_NAME)
        message(FATAL_ERROR "rv64i_add_firmware_asm: NAME is required")
    endif()
    if(NOT FW_ASM_FILE)
        message(FATAL_ERROR "rv64i_add_firmware_asm: ASM_FILE is required")
    endif()
    if(NOT FW_OUTPUT_DIR)
        message(FATAL_ERROR "rv64i_add_firmware_asm: OUTPUT_DIR is required")
    endif()
    
    set(OBJ_FILE "${FW_OUTPUT_DIR}/${FW_NAME}.o")
    set(ELF_FILE "${FW_OUTPUT_DIR}/${FW_NAME}.elf")
    set(LST_FILE "${FW_OUTPUT_DIR}/${FW_NAME}.lst")
    set(VERILOG_FILE "${FW_OUTPUT_DIR}/${FW_NAME}.v")
    set(MEM_FILE "${FW_OUTPUT_DIR}/riscvtest_tb_${FW_NAME}.mem")
    
    # Step 1: Assemble .asm -> .o (use assembler directly, not gcc)
    add_custom_command(
        OUTPUT ${OBJ_FILE}
        COMMAND ${RISCV_AS}
            -march=rv64i
            -o ${OBJ_FILE}
            ${FW_ASM_FILE}
        DEPENDS ${FW_ASM_FILE}
        COMMENT "[AS] ${FW_NAME}.asm -> ${FW_NAME}.o"
        VERBATIM
    )
    
    # Generate listing separately
    add_custom_command(
        OUTPUT ${LST_FILE}
        COMMAND ${RISCV_OBJDUMP}
            -d -S ${OBJ_FILE}
            > ${LST_FILE}
        DEPENDS ${OBJ_FILE}
        COMMENT "[OBJDUMP] ${FW_NAME}.o -> ${FW_NAME}.lst"
        VERBATIM
    )
    
    # Step 2: Link .o -> .elf
    add_custom_command(
        OUTPUT ${ELF_FILE}
        COMMAND ${RISCV_LD}
            -b elf64-littleriscv
            -o ${ELF_FILE}
            ${OBJ_FILE}
        DEPENDS ${OBJ_FILE} ${LST_FILE}
        COMMENT "[LD] ${FW_NAME}.o -> ${FW_NAME}.elf"
        VERBATIM
    )
    
    # Step 3: Convert .elf -> .v (Verilog hex) with post-processing
    add_custom_command(
        OUTPUT ${VERILOG_FILE} ${MEM_FILE}
        COMMAND ${RISCV_OBJCOPY}
            -O verilog
            --verilog-data-width 4
            ${ELF_FILE}
            ${VERILOG_FILE}
        # Post-process: replace spaces with newlines, remove CR, delete first line
        COMMAND ${CMAKE_COMMAND} -E env
            powershell -NoProfile -Command
            "(Get-Content '${VERILOG_FILE}') -replace ' ', [Environment]::NewLine | Set-Content '${VERILOG_FILE}'"
        COMMAND ${CMAKE_COMMAND} -E env
            powershell -NoProfile -Command
            "(Get-Content '${VERILOG_FILE}') -replace '\\r', '' | Select-Object -Skip 1 | Set-Content '${VERILOG_FILE}'"
        # Copy to standard simulation memory files
        COMMAND ${CMAKE_COMMAND} -E copy ${VERILOG_FILE} ${MEM_FILE}
        COMMAND ${CMAKE_COMMAND} -E copy ${VERILOG_FILE} ${FW_OUTPUT_DIR}/riscvtest.mem
        DEPENDS ${ELF_FILE}
        COMMENT "[CP] ${FW_NAME}.elf -> ${FW_NAME}.v (Verilog hex)"
        VERBATIM
    )
    
    # Create target
    add_custom_target(${FW_NAME} ALL
        DEPENDS ${VERILOG_FILE} ${MEM_FILE}
    )
    
    # Set properties for access by other targets
    set_target_properties(${FW_NAME} PROPERTIES
        VERILOG_HEX_FILE ${VERILOG_FILE}
        MEM_FILE ${MEM_FILE}
        ELF_FILE ${ELF_FILE}
    )
endfunction()

# ----------------------------------------------------------------------------
# Function: rv64i_add_firmware_c
# Build C firmware with startup code and convert to Verilog hex format
# 
# Arguments:
#   TARGET_NAME - Name of the target
#   C_SOURCE    - Path to .c source file
#   CRT0_SOURCE - Path to crt0.s startup file
#   LINKER_SCRIPT - Path to linker script
#   INCLUDE_DIRS - List of include directories
#   OUTPUT_DIR  - Output directory for generated files
# ----------------------------------------------------------------------------
function(rv64i_add_firmware_c)
    cmake_parse_arguments(
        FW                      # prefix
        ""                      # options
        "NAME;C_FILE;CRT0_FILE;LINKER_SCRIPT;OUTPUT_DIR"  # one-value keywords
        "INCLUDE_DIRS"          # multi-value keywords
        ${ARGN}                 # arguments to parse
    )
    
    if(NOT FW_NAME)
        message(FATAL_ERROR "rv64i_add_firmware_c: NAME is required")
    endif()
    if(NOT FW_C_FILE)
        message(FATAL_ERROR "rv64i_add_firmware_c: C_FILE is required")
    endif()
    if(NOT FW_CRT0_FILE)
        message(FATAL_ERROR "rv64i_add_firmware_c: CRT0_FILE is required")
    endif()
    if(NOT FW_LINKER_SCRIPT)
        message(FATAL_ERROR "rv64i_add_firmware_c: LINKER_SCRIPT is required")
    endif()
    if(NOT FW_OUTPUT_DIR)
        message(FATAL_ERROR "rv64i_add_firmware_c: OUTPUT_DIR is required")
    endif()
    
    set(C_OBJ "${FW_OUTPUT_DIR}/${FW_NAME}.o")
    set(CRT0_OBJ "${FW_OUTPUT_DIR}/crt0.o")
    set(ELF_FILE "${FW_OUTPUT_DIR}/${FW_NAME}.elf")
    set(MAP_FILE "${FW_OUTPUT_DIR}/${FW_NAME}.map")
    set(BIN_FILE "${FW_OUTPUT_DIR}/${FW_NAME}.bin")
    set(LST_FILE "${FW_OUTPUT_DIR}/${FW_NAME}.lst")
    set(VERILOG_FILE "${FW_OUTPUT_DIR}/${FW_NAME}.v")
    set(MEM_FILE "${FW_OUTPUT_DIR}/riscvtest_tb_${FW_NAME}.mem")
    
    # Common flags
    set(ARCH_FLAGS -march=rv64i -mabi=lp64)
    set(COMMON_FLAGS -ffreestanding -nostdlib)
    set(CFLAGS ${ARCH_FLAGS} ${COMMON_FLAGS} -O2 -g -msmall-data-limit=0)
    
    # Build include directory arguments
    set(INCLUDE_ARGS "")
    foreach(INC_DIR ${FW_INCLUDE_DIRS})
        list(APPEND INCLUDE_ARGS -I${INC_DIR})
    endforeach()
    
    # Step 1: Compile C source
    add_custom_command(
        OUTPUT ${C_OBJ}
        COMMAND ${RISCV_CC}
            ${CFLAGS}
            ${INCLUDE_ARGS}
            -c ${FW_C_FILE}
            -o ${C_OBJ}
        DEPENDS ${FW_C_FILE}
        COMMENT "[CC] ${FW_NAME}.c -> ${FW_NAME}.o"
        VERBATIM
    )
    
    # Step 2: Assemble startup code
    add_custom_command(
        OUTPUT ${CRT0_OBJ}
        COMMAND ${RISCV_CC}
            ${CFLAGS}
            -c ${FW_CRT0_FILE}
            -o ${CRT0_OBJ}
        DEPENDS ${FW_CRT0_FILE}
        COMMENT "[AS] crt0.s -> crt0.o"
        VERBATIM
    )
    
    # Step 3: Link to ELF with map file
    add_custom_command(
        OUTPUT ${ELF_FILE} ${MAP_FILE}
        COMMAND ${RISCV_CC}
            ${ARCH_FLAGS} ${COMMON_FLAGS}
            -T ${FW_LINKER_SCRIPT}
            -Wl,-Map=${MAP_FILE}
            -o ${ELF_FILE}
            ${C_OBJ} ${CRT0_OBJ}
        DEPENDS ${C_OBJ} ${CRT0_OBJ} ${FW_LINKER_SCRIPT}
        COMMENT "[LD] ${FW_NAME}.o + crt0.o -> ${FW_NAME}.elf"
        VERBATIM
    )
    
    # Step 4: Generate binary
    add_custom_command(
        OUTPUT ${BIN_FILE}
        COMMAND ${RISCV_OBJCOPY}
            -O binary
            ${ELF_FILE}
            ${BIN_FILE}
        DEPENDS ${ELF_FILE}
        COMMENT "[OBJCOPY] ${FW_NAME}.elf -> ${FW_NAME}.bin"
        VERBATIM
    )
    
    # Step 5: Generate listing
    add_custom_command(
        OUTPUT ${LST_FILE}
        COMMAND ${RISCV_OBJDUMP}
            -d -S ${ELF_FILE}
            > ${LST_FILE}
        DEPENDS ${ELF_FILE}
        COMMENT "[OBJDUMP] ${FW_NAME}.elf -> ${FW_NAME}.lst"
        VERBATIM
    )
    
    # Step 6: Convert to Verilog hex
    add_custom_command(
        OUTPUT ${VERILOG_FILE} ${MEM_FILE}
        COMMAND ${RISCV_OBJCOPY}
            -O verilog
            --verilog-data-width 4
            ${ELF_FILE}
            ${VERILOG_FILE}
        # Post-process: replace spaces with newlines, remove CR, delete first line
        COMMAND ${CMAKE_COMMAND} -E env
            powershell -NoProfile -Command
            "(Get-Content '${VERILOG_FILE}') -replace ' ', [Environment]::NewLine | Set-Content '${VERILOG_FILE}'"
        COMMAND ${CMAKE_COMMAND} -E env
            powershell -NoProfile -Command
            "(Get-Content '${VERILOG_FILE}') -replace '\\r', '' | Select-Object -Skip 1 | Set-Content '${VERILOG_FILE}'"
        # Copy to standard simulation memory files
        COMMAND ${CMAKE_COMMAND} -E copy ${VERILOG_FILE} ${MEM_FILE}
        COMMAND ${CMAKE_COMMAND} -E copy ${VERILOG_FILE} ${FW_OUTPUT_DIR}/riscvtest.mem
        DEPENDS ${ELF_FILE}
        COMMENT "[CP] ${FW_NAME}.elf -> ${FW_NAME}.v (Verilog hex)"
        VERBATIM
    )
    
    # Create target
    add_custom_target(${FW_NAME} ALL
        DEPENDS ${VERILOG_FILE} ${MEM_FILE} ${BIN_FILE} ${LST_FILE}
    )
    
    # Size report (optional, runs after build)
    add_custom_command(TARGET ${FW_NAME} POST_BUILD
        COMMAND ${RISCV_SIZE} ${ELF_FILE}
        COMMENT "Size report for ${FW_NAME}:"
        VERBATIM
    )
    
    # Set properties for access by other targets
    set_target_properties(${FW_NAME} PROPERTIES
        VERILOG_HEX_FILE ${VERILOG_FILE}
        MEM_FILE ${MEM_FILE}
        ELF_FILE ${ELF_FILE}
        BIN_FILE ${BIN_FILE}
        LST_FILE ${LST_FILE}
        MAP_FILE ${MAP_FILE}
    )
endfunction()

# ----------------------------------------------------------------------------
# Function: rv64i_add_xsim_simulation
# Create Vivado XSIM simulation target
# 
# Arguments:
#   TARGET_NAME - Name of the simulation target
#   TB_TOP      - Top-level testbench module name
#   SV_SOURCES  - List of SystemVerilog source files
#   MEM_FILE    - Memory file to use for simulation
#   WORK_DIR    - Working directory for simulation
# ----------------------------------------------------------------------------
function(rv64i_add_xsim_simulation TARGET_NAME TB_TOP SV_SOURCES MEM_FILE WORK_DIR)
    set(COMPILE_STAMP "${WORK_DIR}/.comp_sv.timestamp")
    set(ELAB_STAMP "${WORK_DIR}/.elab.timestamp")
    set(SNAPSHOT "${TB_TOP}_snapshot")
    set(WDB_FILE "${WORK_DIR}/${SNAPSHOT}.wdb")
    
    # Step 1: Compile SystemVerilog sources
    add_custom_command(
        OUTPUT ${COMPILE_STAMP}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${WORK_DIR}
        COMMAND ${XVLOG}
            --incr
            --relax
            -d LOGIC_SV
            --work work=${WORK_DIR}/work
            ${SV_SOURCES}
        COMMAND ${CMAKE_COMMAND} -E touch ${COMPILE_STAMP}
        DEPENDS ${SV_SOURCES}
        WORKING_DIRECTORY ${WORK_DIR}
        COMMENT "[XVLOG] Compiling SystemVerilog sources for ${TARGET_NAME}"
        VERBATIM
    )
    
    # Step 2: Elaborate
    add_custom_command(
        OUTPUT ${ELAB_STAMP}
        COMMAND ${XELAB}
            -debug all
            -top ${TB_TOP}
            -snapshot ${SNAPSHOT}
            -work work=${WORK_DIR}/work
        COMMAND ${CMAKE_COMMAND} -E touch ${ELAB_STAMP}
        DEPENDS ${COMPILE_STAMP}
        WORKING_DIRECTORY ${WORK_DIR}
        COMMENT "[XELAB] Elaborating ${TB_TOP}"
        VERBATIM
    )
    
    # Step 3: Simulate (headless)
    add_custom_command(
        OUTPUT ${WDB_FILE}
        COMMAND ${CMAKE_COMMAND} -E copy ${MEM_FILE} ${WORK_DIR}/riscvtest.mem
        COMMAND ${XSIM}
            ${SNAPSHOT}
            --runall
            --onfinish quit
            --wdb ${SNAPSHOT}.wdb
        DEPENDS ${ELAB_STAMP} ${MEM_FILE}
        WORKING_DIRECTORY ${WORK_DIR}
        COMMENT "[XSIM] Running simulation ${TARGET_NAME}"
        VERBATIM
    )
    
    # Create simulation target
    add_custom_target(${TARGET_NAME}
        DEPENDS ${WDB_FILE}
    )
    
    # Create waveform viewer target
    add_custom_target(${TARGET_NAME}_waves
        COMMAND ${XSIM}
            ${SNAPSHOT}
            --gui
            --wdb ${SNAPSHOT}.wdb
        DEPENDS ${WDB_FILE}
        WORKING_DIRECTORY ${WORK_DIR}
        COMMENT "Opening waveform viewer for ${TARGET_NAME}"
        VERBATIM
    )
    
    # Set properties
    set_target_properties(${TARGET_NAME} PROPERTIES
        SNAPSHOT ${SNAPSHOT}
        WDB_FILE ${WDB_FILE}
        WORK_DIR ${WORK_DIR}
    )
endfunction()
