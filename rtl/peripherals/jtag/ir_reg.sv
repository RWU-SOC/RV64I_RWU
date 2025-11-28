`timescale 1ns/1ps

import as_pack::*;

module ir_reg ( input logic                 tck_i,      // Base clock
                input logic                 trst_i,     // TAPC reset
                input logic [ir_width-1:0]  ir_rst_i,   // Reset value of the IR
                input logic                 ir_shift_i, // For Mux: either shift tdi/tdo or capture data; Monitor only
                input logic                 ir_clock_i, // Clock the IR shift register (Latch?); Monitor only
                input logic                 ir_upd_i,   // Clock (activate) the IR hold register; Monitor only
                input logic [ir_width-1:0]  data_i,     // Parallel data in
                input logic                 ser_i,      // Serial data in
                output logic [ir_width-1:0] data_o,     // Parallel data out
                output logic                ser_o       // Serial data out
              );

  logic	[ir_width:0] ser_s;

  assign ser_s[0] = ser_i;
   
  genvar i;
  generate
    for (i=0;i<ir_width;i++)
    begin
      ir_cell ircell (.tck_i(tck_i),
                      .trst_i(trst_i),
                      .ir_rst_i(ir_rst_i[i]),
                      .ir_shift_i(ir_shift_i),
                      .ir_clock_i(ir_clock_i),
                      .ir_upd_i(ir_upd_i),
                      .data_i(data_i[i]),
                      .ser_i(ser_s[i]),
                      .data_o(data_o[i]),
                      .ser_o(ser_s[i+1])
                     );
    end
  endgenerate

  assign ser_o = ser_s[ir_width];

endmodule : ir_reg
