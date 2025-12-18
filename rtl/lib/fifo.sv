`timescale 1ns/1ps

// ============================================================================
// Simple Synchronous FIFO
// ============================================================================
// A basic, efficient FIFO for use in peripherals (UART, SPI, I2C, etc.)
//
// Features:
//   - Circular buffer (pointer-based, no data shifting)
//   - Parameterizable width and depth
//   - Full/empty status flags
//   - Registered read output for timing closure
//
// Notes:
//   - DEPTH must be a power of 2
//   - Simultaneous read/write supported
// ============================================================================

module fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 16        // Must be power of 2
) (
    input  logic                  clk_i,
    input  logic                  rst_i,

    // Write interface
    input  logic                  wr_en_i,
    input  logic [DATA_WIDTH-1:0] wdata_i,

    // Read interface
    input  logic                  rd_en_i,
    output logic [DATA_WIDTH-1:0] rdata_o,

    // Status outputs
    output logic                  full_o,
    output logic                  empty_o
);

    // --------------------------------------------------------
    // Local parameters
    // --------------------------------------------------------
    localparam int ADDR_WIDTH = $clog2(DEPTH);

    // --------------------------------------------------------
    // Build-time checks
    // --------------------------------------------------------
    initial begin
        if ((DEPTH & (DEPTH - 1)) != 0)
            $fatal("DEPTH must be power of 2");
    end

    // --------------------------------------------------------
    // Memory and pointers
    // --------------------------------------------------------
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [ADDR_WIDTH-1:0] wr_ptr;
    logic [ADDR_WIDTH-1:0] rd_ptr;
    logic [ADDR_WIDTH:0]   count;   // Can represent 0..DEPTH

    // --------------------------------------------------------
    // Status flags
    // --------------------------------------------------------
    assign full_o  = (count == DEPTH);
    assign empty_o = (count == 0);

    // --------------------------------------------------------
    // Write logic
    // --------------------------------------------------------
    always_ff @(posedge clk_i) begin
        if (!rst_i) begin
            wr_ptr <= '0;
        end else if (wr_en_i && !full_o) begin
            mem[wr_ptr] <= wdata_i;
            wr_ptr      <= wr_ptr + 1'b1;
        end
    end

    // --------------------------------------------------------
    // Read logic - registered output
    // --------------------------------------------------------
    always_ff @(posedge clk_i) begin
        if (!rst_i) begin
            rd_ptr  <= '0;
            rdata_o <= '0;
        end else if (rd_en_i && !empty_o) begin
            rdata_o <= mem[rd_ptr];
            rd_ptr  <= rd_ptr + 1'b1;
        end
    end

    // --------------------------------------------------------
    // Count logic
    // --------------------------------------------------------
    always_ff @(posedge clk_i) begin
        if (!rst_i) begin
            count <= '0;
        end else begin
            case ({wr_en_i && !full_o, rd_en_i && !empty_o})
                2'b10:   count <= count + 1'b1;  // Write only
                2'b01:   count <= count - 1'b1;  // Read only
                default: count <= count;          // Both or neither
            endcase
        end
    end

endmodule : fifo
