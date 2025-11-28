`timescale 1ns/1ps

import as_pack::*;

module dr_reg #(parameter dr_width = 8)
              ( input logic                  tck_i,      // Base clock
                input logic                  trst_i,     // TAPC reset
                input logic                  mode_i,     // Functional mode or test mode
                input logic                  dr_shift_i, // For Mux: either shift tdi/tdo or capture data; Monitor only
                input logic                  dr_clock_i, // Clock the IR shift register (Latch?); Monitor only
                input logic                  dr_upd_i,   // Clock (activate) the IR hold register; Monitor only
                input logic [dr_width-1:0]   data_i,     // Parallel data in
                input logic                  ser_i,      // Serial data in
                output logic [dr_width-1:0]  data_o,     // Parallel data out
                output logic                 ser_o       // Serial data out
              );

  logic	[dr_width:0] ser_s;

  assign ser_s[0] = ser_i;
   
  genvar i;
  generate
    for (i=0;i<dr_width;i++)
    begin
      dr_cell ircell (.tck_i(tck_i),
                      .trst_i(trst_i),
                      .dr_shift_i(dr_shift_i),
                      .dr_clock_i(dr_clock_i),
                      .dr_upd_i(dr_upd_i),
                      .mode_i(mode_i),
                      .data_i(data_i[i]),
                      .ser_i(ser_s[i]),
                      .data_o(data_o[i]),
                      .ser_o(ser_s[i+1])
                     );
    end
  endgenerate

  assign ser_o = ser_s[dr_width];

endmodule : dr_reg
