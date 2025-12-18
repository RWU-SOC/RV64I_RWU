// =============================================================================
// Module: as_pack (QSPI Package)
// Description: Package file containing QSPI constants, types, and parameters
// =============================================================================

package qspi_pkg;

    // QSPI Register Map (byte addresses)
    typedef enum logic [7:0] {
        QSPI_CTRL_REG      = 8'h00,  // Control register
        QSPI_STATUS_REG    = 8'h04,  // Status register
        QSPI_DATA_REG      = 8'h08,  // Data register (TX/RX)
        QSPI_CLKDIV_REG    = 8'h0C,  // Clock divider register
        QSPI_CS_REG        = 8'h10,  // Chip select register
        QSPI_INT_EN_REG    = 8'h14,  // Interrupt enable register
        QSPI_INT_STATUS_REG= 8'h18,  // Interrupt status register
        QSPI_FIFO_CTRL_REG = 8'h1C   // FIFO control register
    } qspi_reg_addr_t;

    // Control Register Bit Definitions
    typedef struct packed {
        logic [23:0] reserved;
        logic [1:0]  mode;           // 00=SPI, 01=Dual, 10=Quad, 11=Reserved
        logic        cpol;           // Clock polarity
        logic        cpha;           // Clock phase
        logic        lsb_first;      // 0=MSB first, 1=LSB first
        logic        cs_mode;        // 0=Auto CS, 1=Manual CS
        logic        tx_enable;      // TX enable
        logic        rx_enable;      // RX enable
    } qspi_ctrl_t;

    // Status Register Bit Definitions
    typedef struct packed {
        logic [23:0] reserved;
        logic        tx_full;        // TX FIFO full
        logic        tx_empty;       // TX FIFO empty
        logic        rx_full;        // RX FIFO full
        logic        rx_empty;       // RX FIFO empty
        logic        busy;           // Transfer in progress
        logic        error;          // Error flag
        logic [1:0]  reserved2;
    } qspi_status_t;

    // Interrupt Enable/Status Register Bit Definitions
    typedef struct packed {
        logic [27:0] reserved;
        logic        tx_done;        // TX complete interrupt
        logic        rx_ready;       // RX data available interrupt
        logic        error;          // Error interrupt
        logic        cs_change;      // CS change interrupt
    } qspi_int_t;

    // FIFO Control Register
    typedef struct packed {
        logic [23:0] reserved;
        logic [3:0]  tx_threshold;   // TX FIFO threshold
        logic [3:0]  rx_threshold;   // RX FIFO threshold
    } qspi_fifo_ctrl_t;

    // QSPI Operating Modes
    typedef enum logic [1:0] {
        SPI_MODE  = 2'b00,           // Standard SPI (1-bit)
        DUAL_MODE = 2'b01,           // Dual SPI (2-bit)
        QUAD_MODE = 2'b10,           // Quad SPI (4-bit)
        RESERVED  = 2'b11
    } qspi_mode_t;

    // QSPI State Machine States
    typedef enum logic [2:0] {
        IDLE        = 3'b000,
        LOAD        = 3'b001,
        TRANSFER    = 3'b010,
        WAIT_DONE   = 3'b011,
        CS_HOLD     = 3'b100,
        ERROR_STATE = 3'b101
    } qspi_state_t;

    // Constants
    parameter int FIFO_DEPTH = 16;
    parameter int DATA_WIDTH = 32;
    parameter int ADDR_WIDTH = 8;

endpackage : qspi_pkg
