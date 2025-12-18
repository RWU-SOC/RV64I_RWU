// =============================================================================
// Module: qspi (QSPI Top-Level Module)
// Description: QSPI peripheral with register interface and bus integration
// =============================================================================

import qspi_pkg::*;

module qspi #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
) (
    // Clock and reset
    input  logic                    clk_i,          // System clock
    input  logic                    rst_ni,         // Active-low reset
    
    // Bus interface (APB-like)
    input  logic [ADDR_WIDTH-1:0]   addr_i,         // Address
    input  logic                    write_i,        // Write enable
    input  logic                    read_i,         // Read enable
    input  logic [DATA_WIDTH-1:0]   wdata_i,        // Write data
    output logic [DATA_WIDTH-1:0]   rdata_o,        // Read data
    output logic                    ready_o,        // Transfer ready
    output logic                    error_o,        // Error response
    
    // Interrupt
    output logic                    irq_o,          // Interrupt request
    
    // QSPI interface
    output logic                    qspi_cs_no,     // Chip select (active low)
    output logic                    qspi_sclk_o,    // SPI clock
    inout  logic [3:0]              qspi_data_io    // Bidirectional data pins
);

    // =========================================================================
    // Internal signals
    // =========================================================================
    
    // Register file
    logic [31:0] ctrl_reg;
    logic [31:0] status_reg;
    logic [31:0] data_reg;
    logic [31:0] clkdiv_reg;
    logic [31:0] cs_reg;
    logic [31:0] int_en_reg;
    logic [31:0] int_status_reg;
    logic [31:0] fifo_ctrl_reg;
    
    // Decoded control signals
    qspi_ctrl_t   ctrl;
    qspi_status_t status;
    qspi_int_t    int_en;
    qspi_int_t    int_status;
    
    // Clock divider signals
    logic        sclk;
    logic        sclk_posedge;
    logic        sclk_negedge;
    logic        clk_enable;
    
    // Controller signals
    logic [31:0] tx_data;
    logic [31:0] rx_data;
    logic        start_transfer;
    logic        ctrl_busy;
    logic        ctrl_done;
    logic        ctrl_error;
    logic [3:0]  sdo;
    logic [3:0]  sdo_en;
    logic [3:0]  sdi;
    
    // FIFO signals (simplified - direct register access)
    logic        tx_empty;
    logic        tx_full;
    logic        rx_empty;
    logic        rx_full;
    
    // Bus control
    logic        bus_write;
    logic        bus_read;
    logic [7:0]  reg_addr;
    
    // =========================================================================
    // Assignments
    // =========================================================================
    
    assign ctrl       = qspi_ctrl_t'(ctrl_reg);
    assign int_en     = qspi_int_t'(int_en_reg);
    assign int_status = qspi_int_t'(int_status_reg);
    
    assign bus_write  = write_i;
    assign bus_read   = read_i;
    assign reg_addr   = addr_i[7:0];
    
    // Status register construction
    always_comb begin
        status.reserved  = 24'h000000;
        status.tx_full   = tx_full;
        status.tx_empty  = tx_empty;
        status.rx_full   = rx_full;
        status.rx_empty  = rx_empty;
        status.busy      = ctrl_busy;
        status.error     = ctrl_error;
        status.reserved2 = 2'b00;
        status_reg       = status;
    end
    
    // Simple FIFO status (single entry for simplicity)
    assign tx_empty = (data_reg == 32'h00000000) && !ctrl_busy;
    assign tx_full  = 1'b0;
    assign rx_empty = (rx_data == 32'h00000000) && !ctrl_done;
    assign rx_full  = ctrl_done;
    
    // Clock enable
    assign clk_enable = ctrl.tx_enable || ctrl.rx_enable;
    
    // =========================================================================
    // Register write logic
    // =========================================================================
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            ctrl_reg       <= 32'h00000000;
            data_reg       <= 32'h00000000;
            clkdiv_reg     <= 32'h00000010;  // Default divider = 16
            cs_reg         <= 32'h00000001;  // CS = 1 (deasserted)
            int_en_reg     <= 32'h00000000;
            int_status_reg <= 32'h00000000;
            fifo_ctrl_reg  <= 32'h00000044;  // Default thresholds = 4
            start_transfer <= 1'b0;
        end else begin
            // Auto-clear start transfer
            start_transfer <= 1'b0;
            
            // Update interrupt status
            if (ctrl_done && int_en.tx_done) begin
                int_status_reg[3] <= 1'b1;
            end
            if (ctrl_done && int_en.rx_ready) begin
                int_status_reg[2] <= 1'b1;
            end
            if (ctrl_error && int_en.error) begin
                int_status_reg[1] <= 1'b1;
            end
            
            // Latch RX data when transfer completes
            if (ctrl_done && ctrl.rx_enable) begin
                data_reg <= rx_data;
            end
            
            // Register writes
            if (bus_write) begin
                case (reg_addr)
                    QSPI_CTRL_REG: begin
                        ctrl_reg <= wdata_i;
                    end
                    
                    QSPI_DATA_REG: begin
                        data_reg       <= wdata_i;
                        start_transfer <= 1'b1;  // Writing data starts transfer
                    end
                    
                    QSPI_CLKDIV_REG: begin
                        clkdiv_reg <= wdata_i;
                    end
                    
                    QSPI_CS_REG: begin
                        cs_reg <= wdata_i;
                    end
                    
                    QSPI_INT_EN_REG: begin
                        int_en_reg <= wdata_i;
                    end
                    
                    QSPI_INT_STATUS_REG: begin
                        // Write 1 to clear
                        int_status_reg <= int_status_reg & ~wdata_i;
                    end
                    
                    QSPI_FIFO_CTRL_REG: begin
                        fifo_ctrl_reg <= wdata_i;
                    end
                    
                    default: begin
                        // Do nothing for invalid addresses
                    end
                endcase
            end
        end
    end
    
    // =========================================================================
    // Register read logic
    // =========================================================================
    
    always_comb begin
        rdata_o = 32'h00000000;
        ready_o = 1'b1;
        error_o = 1'b0;
        
        if (bus_read) begin
            case (reg_addr)
                QSPI_CTRL_REG:       rdata_o = ctrl_reg;
                QSPI_STATUS_REG:     rdata_o = status_reg;
                QSPI_DATA_REG:       rdata_o = data_reg;
                QSPI_CLKDIV_REG:     rdata_o = clkdiv_reg;
                QSPI_CS_REG:         rdata_o = cs_reg;
                QSPI_INT_EN_REG:     rdata_o = int_en_reg;
                QSPI_INT_STATUS_REG: rdata_o = int_status_reg;
                QSPI_FIFO_CTRL_REG:  rdata_o = fifo_ctrl_reg;
                default: begin
                    rdata_o = 32'hDEADBEEF;
                    error_o = 1'b1;
                end
            endcase
        end
    end
    
    // =========================================================================
    // Interrupt generation
    // =========================================================================
    
    assign irq_o = |(int_status_reg & int_en_reg);
    
    // =========================================================================
    // Clock divider instantiation
    // =========================================================================
    
    clk_div u_clk_div (
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),
        .enable_i       (clk_enable && !ctrl_busy),
        .divisor_i      (clkdiv_reg[15:0]),
        .sclk_o         (sclk),
        .sclk_posedge_o (sclk_posedge),
        .sclk_negedge_o (sclk_negedge)
    );
    
    // =========================================================================
    // QSPI controller instantiation
    // =========================================================================
    
    qspi_ctrl u_qspi_ctrl (
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),
        .mode_i         (ctrl.mode),
        .cpol_i         (ctrl.cpol),
        .cpha_i         (ctrl.cpha),
        .lsb_first_i    (ctrl.lsb_first),
        .tx_enable_i    (ctrl.tx_enable),
        .rx_enable_i    (ctrl.rx_enable),
        .cs_manual_i    (ctrl.cs_mode),
        .cs_value_i     (cs_reg[0]),
        .tx_data_i      (data_reg),
        .bit_count_i    (6'd32),  // Transfer 32 bits
        .start_i        (start_transfer),
        .rx_data_o      (rx_data),
        .busy_o         (ctrl_busy),
        .done_o         (ctrl_done),
        .error_o        (ctrl_error),
        .sclk_posedge_i (sclk_posedge),
        .sclk_negedge_i (sclk_negedge),
        .sclk_i         (sclk),
        .cs_no          (qspi_cs_no),
        .sclk_o         (qspi_sclk_o),
        .sdo_o          (sdo),
        .sdo_en_o       (sdo_en),
        .sdi_i          (sdi)
    );
    
    // =========================================================================
    // Bidirectional pin control
    // =========================================================================
    
    // Data pin 0
    assign qspi_data_io[0] = sdo_en[0] ? sdo[0] : 1'bz;
    assign sdi[0] = qspi_data_io[0];
    
    // Data pin 1
    assign qspi_data_io[1] = sdo_en[1] ? sdo[1] : 1'bz;
    assign sdi[1] = qspi_data_io[1];
    
    // Data pin 2
    assign qspi_data_io[2] = sdo_en[2] ? sdo[2] : 1'bz;
    assign sdi[2] = qspi_data_io[2];
    
    // Data pin 3
    assign qspi_data_io[3] = sdo_en[3] ? sdo[3] : 1'bz;
    assign sdi[3] = qspi_data_io[3];

endmodule : qspi
