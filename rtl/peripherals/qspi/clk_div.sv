// =============================================================================
// Module: clk_div (QSPI Clock Divider)
// Description: Configurable clock divider for generating SPI clock
// =============================================================================

module clk_div (
    input  logic        clk_i,          // System clock
    input  logic        rst_ni,         // Active-low reset
    input  logic        enable_i,       // Enable clock generation
    input  logic [15:0] divisor_i,      // Clock divisor (sys_clk / (2 * (divisor + 1)))
    output logic        sclk_o,         // SPI clock output
    output logic        sclk_posedge_o, // SPI clock positive edge pulse
    output logic        sclk_negedge_o  // SPI clock negative edge pulse
);

    logic [15:0] counter;
    logic        sclk_reg;
    logic        sclk_prev;

    // Generate divided clock
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            counter      <= 16'h0000;
            sclk_reg     <= 1'b0;
            sclk_prev    <= 1'b0;
        end else begin
            sclk_prev <= sclk_reg;
            
            if (!enable_i) begin
                counter  <= 16'h0000;
                sclk_reg <= 1'b0;
            end else begin
                if (counter >= divisor_i) begin
                    counter  <= 16'h0000;
                    sclk_reg <= ~sclk_reg;
                end else begin
                    counter <= counter + 16'h0001;
                end
            end
        end
    end

    // Output assignments
    assign sclk_o = sclk_reg;

    // Edge detection
    assign sclk_posedge_o = enable_i && sclk_reg && !sclk_prev;
    assign sclk_negedge_o = enable_i && !sclk_reg && sclk_prev;

endmodule : clk_div
