`timescale 1ns/1ps

import as_pack::*;

module dr_cell ( input logic  tck_i,      // Base clock
                 input logic  trst_i,     // TAPC reset
                 input logic  dr_shift_i, // For Mux: either shift tdi/tdo or capture data; Monitor only
                 input logic  dr_clock_i, // Clock the DR shift register (Latch?); Monitor only
                 input logic  dr_upd_i,   // Clock (activate) the DR hold register; Monitor only
                 input logic  mode_i,     // Transparent or register
                 input logic  data_i,     // Parallel data in
                 input logic  ser_i,      // Serial data in
                 output logic data_o,     // Parallel data out
                 output logic ser_o       // Serial data out
              );

  logic	inter_s;
  logic	data_out_s;
  logic	trst_s;
  
  // make reset invertible if needed (active high <-> active low)
  assign trst_s = trst_i;

  // Master FF
  always_ff @(posedge tck_i, posedge trst_s)
  begin
    if(trst_s == 1)
      inter_s <= 0;
    else 
      if(dr_clock_i == 1)
        if(dr_shift_i == 0)
          inter_s <= data_i; // parallel load
        else
          inter_s <= ser_i; // serial load
  end // always_ff @ (posedge tck_i, posedge trst_s)

  // Slave FF
  always_ff @(posedge tck_i, posedge trst_s)
  begin
    if(trst_s == 1)
      data_out_s <= 0;
    else 
      if(dr_upd_i == 1)
        data_out_s <= inter_s;
  end // always_ff @ (posedge tck_i, posedge trst_s)

  // Assign outputs
  assign ser_o  = inter_s;
  assign data_o = (mode_i == 0) ? data_i : data_out_s;

endmodule : dr_cell
