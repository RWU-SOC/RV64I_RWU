# QSPI Peripheral CMakeLists.txt

set(QSPI_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/as_pack.sv
    ${CMAKE_CURRENT_SOURCE_DIR}/clk_div.sv
    ${CMAKE_CURRENT_SOURCE_DIR}/qspi_ctrl.sv
    ${CMAKE_CURRENT_SOURCE_DIR}/qspi.sv
)

set(QSPI_SOURCES ${QSPI_SOURCES} PARENT_SCOPE)
