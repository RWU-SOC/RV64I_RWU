`timescale 1ns/1ps

import as_pack::*;

module by_cell ( input logic  tck_i,      // Base clock
                 input logic  trst_i,     // TAPC reset
                 input logic  by_shift_i, // For Mux: either shift tdi/tdo or capture data; Monitor only
                 input logic  by_clock_i,
                 input logic  ser_i,      // Serial data in
                 output logic ser_o       // Serial data out
               );

  logic	inter_s;
  //logic	data_out_s;
  
  // make reset invertible if needed (active high <-> active low)
  //assign trst_s = trst_i;

  // FF
  always_ff @(posedge tck_i, posedge trst_i)
  begin
    if(trst_i == 1)
      inter_s <= 0;
    else 
      if(by_clock_i == 1)
        inter_s <= ser_i & by_shift_i;
  end // always_ff @ (posedge tck_i, posedge trst_s)
  
  // Assign outputs
  assign ser_o  = inter_s;

endmodule : by_cell
