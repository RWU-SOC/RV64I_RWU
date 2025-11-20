`timescale 1ns/1ps

import as_pack::*;

module ir_decode (input logic                dr_shift_i,   // distribute it to the selected chains
                  input logic                dr_clock_i,
                  input logic                dr_upd_i,
                  input logic [ir_width-1:0] ir_i,         // IR
                  output logic [nr_drs-1:0]  sel_tdo_o,
                  output logic               test_mode_o,  // EXTEST
                  output logic               by_shift_o,   // BYPASS
                  output logic               by_clock_o,   // BYPASS
                  output logic               bs_shift_o,   // BS
                  output logic               bs_clock_o,   // BS
                  output logic               bs_upd_o,     // BS
                  output logic               id_shift_o,   // IDCODE
                  output logic               id_clock_o,   // IDCODE
                  output logic               id_upd_o,     // IDCODE
                  output logic               id_mode_o,    // IDCODE
                  output logic               im_shift_o,   // I-Mem
                  output logic               im_clock_o,   // I-Mem
                  output logic               im_upd_o,     // I-Mem
                  output logic               im_mode_o,    // I-Mem
                  output logic               sc01_clock_o, // Scan chain
                  output logic               sc01_shift_o  // Scan chain
               );

  logic       ext_o_s;
  logic [1:0] by_o_s;
  logic [2:0] bs_o_s; 
  logic [3:0] id_o_s;
  logic [3:0] im_o_s;
  logic	      sc01_o_s;

  assign test_mode_o = ext_o_s;
  assign {by_shift_o, by_clock_o} = by_o_s;
  assign {bs_shift_o, bs_clock_o, bs_upd_o} = bs_o_s;
  assign {id_shift_o, id_clock_o, id_upd_o, id_mode_o} = id_o_s;
  assign {im_shift_o, im_clock_o, im_upd_o, im_mode_o} = im_o_s;
  assign sc01_shift_o = sc01_o_s;

  // chains: 0 - BY
  //         1 - ID
  //         2 - BS
  //         3 - IMem
  //         4 - SC01

  always_comb
  begin
    case(ir_i)
        0 :     begin // EXTEST           - BSCAN
                  sel_tdo_o    = 'h2;
                  ext_o_s      = 1'b1;
                  by_o_s       = {dr_shift_i, 1'b0};
                  bs_o_s       = {dr_shift_i, dr_clock_i, dr_upd_i};
                  id_o_s       = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  im_o_s       = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  sc01_clock_o = 1'b0;
                  sc01_o_s     = 1'b0;
                end
        1 :     begin // INTEST           - BSCAN
                  sel_tdo_o    = 'h2;
                  ext_o_s      = 1'b0;
                  by_o_s       = {dr_shift_i, 1'b0};
                  bs_o_s       = {dr_shift_i, dr_clock_i, dr_upd_i};
                  id_o_s       = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  im_o_s       = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  sc01_clock_o = 1'b0;
                  sc01_o_s     = 1'b0;
                end
        2 :     begin // SAMPLE & PRELOAD - BSCAN
                  sel_tdo_o = 'h2;
                  ext_o_s   = 1'b0;
                  by_o_s    = {dr_shift_i, 1'b0};
                  bs_o_s    = {dr_shift_i, dr_clock_i, dr_upd_i};
                  id_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  im_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  sc01_clock_o = 1'b0;
                  sc01_o_s  = 0;
                end
        3 :     begin // RUNBIST          - BYPASS
                  sel_tdo_o = 'h0;
                  ext_o_s   = 1'b0;
                  by_o_s    = {dr_shift_i, 1'b0};
                  bs_o_s    = {dr_shift_i, 1'b0, 1'b0};
                  id_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  im_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  sc01_clock_o = 1'b0;
                  sc01_o_s  = 1'b0;
                end
        4 :     begin // IDCODE           - IR
                  sel_tdo_o = 'h1;
                  ext_o_s   = 1'b0;
                  by_o_s    = {dr_shift_i, dr_clock_i};
                  bs_o_s    = {dr_shift_i, 1'b0, 1'b0};
                  id_o_s    = {dr_shift_i, dr_clock_i, dr_upd_i, 1'b1};
                  im_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  sc01_clock_o = 1'b0;
                  sc01_o_s  = 1'b0;
                end
        5 :     begin // USERCODE         - USERCODE ?? not implemented  ??
                  sel_tdo_o = 'h0;
                  ext_o_s   = 1'b0;
                  by_o_s    = {dr_shift_i, 1'b0};
                  bs_o_s    = {dr_shift_i, 1'b0, 1'b0};
                  id_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  im_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  sc01_clock_o = 1'b0;
                  sc01_o_s  = 1'b0;
                end
        6 :     begin // CLAMP            - BYPASS
                  sel_tdo_o = 'h0;
                  ext_o_s   = 1'b0;
                  by_o_s    = {dr_shift_i, 1'b0};
                  bs_o_s    = {dr_shift_i, 1'b0, 1'b0};
                  id_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  im_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  sc01_clock_o = 1'b0;
                  sc01_o_s  = 1'b0;
                end
        7 :     begin // HIGHZ            - BYPASS
                  sel_tdo_o = 'h0;
                  ext_o_s   = 1'b0;
                  by_o_s    = {dr_shift_i, 1'b0};
                  bs_o_s    = {dr_shift_i, 1'b0, 1'b0};
                  id_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  im_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  sc01_clock_o = 1'b0;
                  sc01_o_s  = 1'b0;
                end
      128 :     begin // I_MEM            - I_MEM
                  sel_tdo_o = 'h3;
                  ext_o_s   = 1'b0;
                  by_o_s    = {dr_shift_i, 1'b0};
                  bs_o_s    = {dr_shift_i, 1'b0, 1'b0};
                  id_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  im_o_s    = {dr_shift_i, dr_clock_i, dr_upd_i, 1'b1};
                  sc01_clock_o = 1'b0;
                  sc01_o_s  = 1'b0;
                end
      129 :     begin // SCANTEST         - Scan chain
                  sel_tdo_o    = 'h4;
                  ext_o_s      = 1'b0;
                  by_o_s       = {dr_shift_i, 1'b0};
                  bs_o_s       = {dr_shift_i, 1'b0, 1'b0};
                  id_o_s       = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  im_o_s       = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  sc01_clock_o = dr_clock_i;
                  sc01_o_s     = dr_shift_i;
                end
      255 :     begin // BYPASS           - BYPASS
                  sel_tdo_o = 'h0;
                  ext_o_s   = 1'b0;
                  by_o_s    = {dr_shift_i, dr_clock_i};
                  bs_o_s    = {dr_shift_i, 1'b0, 1'b0};
                  id_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  im_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  sc01_clock_o = 1'b0;
                  sc01_o_s  = 1'b0;
                end
      default : begin
                  sel_tdo_o = 'h0;
                  ext_o_s   = 1'b0;
                  by_o_s    = {dr_shift_i, 1'b0};
                  bs_o_s    = {dr_shift_i, 1'b0, 1'b0};
                  id_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  im_o_s    = {dr_shift_i, 1'b0, 1'b0, 1'b0};
                  sc01_clock_o = 1'b0;
                  sc01_o_s  = 1'b0;
               end
    endcase
  end

endmodule : ir_decode
