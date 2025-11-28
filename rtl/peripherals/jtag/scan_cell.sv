`timescale 1ns/1ps

import as_pack::*;

module scan_cell ( input logic  tck_i,        // Base clock
                   input logic  trst_i,       // TAPC reset
                   input logic  scan_shift_i, // For Mux: either shift tdi/tdo or capture data; Monitor only
                   input logic  data_i,       // Parallel data in
                   input logic  ser_i,        // Serial data in
                   output logic data_o,       // Parallel data out
                   output logic ser_o         // Serial data out
                 );

  logic	inter_s;
  logic	mux_data_s;
  logic	trst_s;
  
  // make reset invertible if needed (active high <-> active low)
  assign trst_s = trst_i;

  // MUX
  assign mux_data_s = (scan_shift_i == 1) ? ser_i : data_i;

  // FF
  always_ff @(posedge tck_i, posedge trst_s)
  begin
    if(trst_s == 1)
      inter_s <= 0;
    else 
      inter_s <= mux_data_s; // serial load
  end // always_ff @ (posedge tck_i, posedge trst_s)
  
  // Assign outputs
  assign ser_o  = inter_s;
  assign data_o = inter_s;

endmodule : scan_cell
