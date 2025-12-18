// =============================================================================
// Module: qspi_ctrl (QSPI Controller)
// Description: State machine and control logic for SPI/Dual/Quad operations
// =============================================================================

import qspi_pkg::*;

module qspi_ctrl (
    input  logic        clk_i,          // System clock
    input  logic        rst_ni,         // Active-low reset
    
    // Configuration
    input  logic [1:0]  mode_i,         // Operating mode (SPI/Dual/Quad)
    input  logic        cpol_i,         // Clock polarity
    input  logic        cpha_i,         // Clock phase
    input  logic        lsb_first_i,    // Data order
    input  logic        tx_enable_i,    // TX enable
    input  logic        rx_enable_i,    // RX enable
    input  logic        cs_manual_i,    // Manual CS control
    input  logic        cs_value_i,     // CS value (manual mode)
    
    // Data interface
    input  logic [31:0] tx_data_i,      // TX data
    input  logic [5:0]  bit_count_i,    // Number of bits to transfer
    input  logic        start_i,        // Start transfer
    output logic [31:0] rx_data_o,      // RX data
    output logic        busy_o,         // Transfer in progress
    output logic        done_o,         // Transfer complete
    output logic        error_o,        // Error flag
    
    // SPI clock control
    input  logic        sclk_posedge_i, // SPI clock positive edge
    input  logic        sclk_negedge_i, // SPI clock negative edge
    input  logic        sclk_i,         // SPI clock
    
    // SPI interface
    output logic        cs_no,          // Chip select (active low)
    output logic        sclk_o,         // SPI clock output
    output logic [3:0]  sdo_o,          // Serial data out (4-bit for quad)
    output logic [3:0]  sdo_en_o,       // Data output enable
    input  logic [3:0]  sdi_i           // Serial data in (4-bit for quad)
);

    // State machine
    qspi_state_t state, next_state;
    
    // Internal registers
    logic [31:0] tx_shift_reg;
    logic [31:0] rx_shift_reg;
    logic [5:0]  bit_counter;
    logic        cs_reg;
    logic        sample_edge;
    logic        shift_edge;
    logic [3:0]  sdo_reg;
    logic [3:0]  sdo_en_reg;
    
    // Determine sampling and shifting edges based on CPHA and CPOL
    always_comb begin
        if (cpha_i == 1'b0) begin
            // CPHA=0: Sample on first edge, shift on second edge
            sample_edge = cpol_i ? sclk_negedge_i : sclk_posedge_i;
            shift_edge  = cpol_i ? sclk_posedge_i : sclk_negedge_i;
        end else begin
            // CPHA=1: Shift on first edge, sample on second edge
            sample_edge = cpol_i ? sclk_posedge_i : sclk_negedge_i;
            shift_edge  = cpol_i ? sclk_negedge_i : sclk_posedge_i;
        end
    end
    
    // State machine sequential logic
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // State machine combinational logic
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (start_i && (tx_enable_i || rx_enable_i)) begin
                    next_state = LOAD;
                end
            end
            
            LOAD: begin
                next_state = TRANSFER;
            end
            
            TRANSFER: begin
                if (bit_counter == 6'h00) begin
                    next_state = WAIT_DONE;
                end
            end
            
            WAIT_DONE: begin
                if (cs_manual_i) begin
                    next_state = IDLE;
                end else begin
                    next_state = CS_HOLD;
                end
            end
            
            CS_HOLD: begin
                next_state = IDLE;
            end
            
            ERROR_STATE: begin
                if (!start_i) begin
                    next_state = IDLE;
                end
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end
    
    // Data path and control logic
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            tx_shift_reg <= 32'h00000000;
            rx_shift_reg <= 32'h00000000;
            bit_counter  <= 6'h00;
            cs_reg       <= 1'b1;
            sdo_reg      <= 4'b0000;
            sdo_en_reg   <= 4'b0000;
        end else begin
            case (state)
                IDLE: begin
                    if (cs_manual_i) begin
                        cs_reg <= cs_value_i;
                    end else begin
                        cs_reg <= 1'b1;
                    end
                    sdo_en_reg <= 4'b0000;
                end
                
                LOAD: begin
                    tx_shift_reg <= tx_data_i;
                    rx_shift_reg <= 32'h00000000;
                    bit_counter  <= bit_count_i;
                    
                    if (!cs_manual_i) begin
                        cs_reg <= 1'b0;  // Assert CS
                    end
                    
                    // Set output enables based on mode
                    if (tx_enable_i) begin
                        case (mode_i)
                            SPI_MODE:  sdo_en_reg <= 4'b0001;  // Only SD0
                            DUAL_MODE: sdo_en_reg <= 4'b0011;  // SD0, SD1
                            QUAD_MODE: sdo_en_reg <= 4'b1111;  // All 4 bits
                            default:   sdo_en_reg <= 4'b0000;
                        endcase
                    end else begin
                        sdo_en_reg <= 4'b0000;
                    end
                end
                
                TRANSFER: begin
                    // Shift data out on shift edge
                    if (shift_edge && tx_enable_i) begin
                        case (mode_i)
                            SPI_MODE: begin
                                sdo_reg[0] <= lsb_first_i ? tx_shift_reg[0] : tx_shift_reg[31];
                                tx_shift_reg <= lsb_first_i ? {1'b0, tx_shift_reg[31:1]} : 
                                                               {tx_shift_reg[30:0], 1'b0};
                            end
                            DUAL_MODE: begin
                                sdo_reg[1:0] <= lsb_first_i ? tx_shift_reg[1:0] : tx_shift_reg[31:30];
                                tx_shift_reg <= lsb_first_i ? {2'b00, tx_shift_reg[31:2]} : 
                                                               {tx_shift_reg[29:0], 2'b00};
                            end
                            QUAD_MODE: begin
                                sdo_reg[3:0] <= lsb_first_i ? tx_shift_reg[3:0] : tx_shift_reg[31:28];
                                tx_shift_reg <= lsb_first_i ? {4'b0000, tx_shift_reg[31:4]} : 
                                                               {tx_shift_reg[27:0], 4'b0000};
                            end
                            default: begin
                                sdo_reg <= 4'b0000;
                            end
                        endcase
                    end
                    
                    // Sample data in on sample edge
                    if (sample_edge && rx_enable_i) begin
                        case (mode_i)
                            SPI_MODE: begin
                                rx_shift_reg <= lsb_first_i ? {sdi_i[0], rx_shift_reg[31:1]} : 
                                                               {rx_shift_reg[30:0], sdi_i[0]};
                            end
                            DUAL_MODE: begin
                                rx_shift_reg <= lsb_first_i ? {sdi_i[1:0], rx_shift_reg[31:2]} : 
                                                               {rx_shift_reg[29:0], sdi_i[1:0]};
                            end
                            QUAD_MODE: begin
                                rx_shift_reg <= lsb_first_i ? {sdi_i[3:0], rx_shift_reg[31:4]} : 
                                                               {rx_shift_reg[27:0], sdi_i[3:0]};
                            end
                            default: begin
                                rx_shift_reg <= rx_shift_reg;
                            end
                        endcase
                        
                        // Decrement bit counter
                        if (mode_i == QUAD_MODE) begin
                            bit_counter <= bit_counter - 6'd4;
                        end else if (mode_i == DUAL_MODE) begin
                            bit_counter <= bit_counter - 6'd2;
                        end else begin
                            bit_counter <= bit_counter - 6'd1;
                        end
                    end
                end
                
                WAIT_DONE: begin
                    // Hold data
                end
                
                CS_HOLD: begin
                    if (!cs_manual_i) begin
                        cs_reg <= 1'b1;  // Deassert CS
                    end
                    sdo_en_reg <= 4'b0000;
                end
                
                ERROR_STATE: begin
                    cs_reg <= 1'b1;
                    sdo_en_reg <= 4'b0000;
                end
                
                default: begin
                    cs_reg <= 1'b1;
                    sdo_en_reg <= 4'b0000;
                end
            endcase
        end
    end
    
    // Output assignments
    assign busy_o    = (state != IDLE);
    assign done_o    = (state == WAIT_DONE) || (state == CS_HOLD);
    assign error_o   = (state == ERROR_STATE);
    assign rx_data_o = rx_shift_reg;
    assign cs_no     = cs_reg;
    assign sclk_o    = (state == TRANSFER) ? (cpol_i ? ~sclk_i : sclk_i) : cpol_i;
    assign sdo_o     = sdo_reg;
    assign sdo_en_o  = sdo_en_reg;

endmodule : qspi_ctrl
