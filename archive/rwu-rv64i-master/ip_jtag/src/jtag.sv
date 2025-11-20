`timescale 1ns/1ps

import as_pack::*;

module jtag ( input logic  tck_i,        // Test Clock
              input logic  trst_i,       // TAPC reset
              input logic  tms_i,        // Test Mode Select
              input logic  tdi_i,        // Test Data In
              output logic tdo_o,        // Test Data Out
              output logic tap_rst_o,    // Reset from TAPC
              input logic  sc01_tdo_i,   // Scan Chain: serial end
              output logic sc01_tdi_o,   // Scan Chain: serial begin
              output logic sc01_shift_o, // Scan Chain: shift enable
              output logic sc01_clock_o, // Scan Chain: clock enable
              input logic  im_tdo_i,     // I-Mem: serial end
              output logic im_tdi_o,     // I-Mem: serial begin
              output logic im_shift_o,   // I-Mem: shift enable
              output logic im_clock_o,   // I-Mem: clock enable
              output logic im_upd_o,     // I-Mem: update slave
              output logic im_mode_o,    // I-Mem: function or serial
              input  logic bs_tdo_i,     // BS: serial end
              output logic bs_tdi_o,     // BS: serial begin
              output logic bs_shift_o,   // BS: shift enable
              output logic bs_clock_o,   // BS: clock enable
              output logic bs_upd_o,     // BS: update slave
              output logic bs_mode_o     // BS: function or serial
              
              );

  logic	tapc_rst_s, jtag_rst_s;
  logic	ir_shift_s, ir_clock_s, ir_upd_s;
  logic	id_shift_s, id_clock_s, id_upd_s, id_mode_s;
  logic	dr_shift_s, dr_clock_s, dr_upd_s;
  logic	irdr_select_s;
  logic	tdo_ena_s, tdo_ena_n_s;

  logic	[ir_width:0]   ser_ir_s;
  logic	[ir_width-1:0] ir_rst_s, ir_data_s;
  logic [ir_width-1:0] ir_s; //IR
  logic		       tdo_ir_s;

  logic [nr_drs-1:0]   sel_tdo_s;

  logic		       by_shift_s, by_clock_s;

  logic		       tdo_by_s;

  logic		       tdo_id_s;
  logic [id_width-1:0] id_data_s;

  logic		       tdo_1st_s;
  logic		       tdo_2nd_s;
  logic		       tdo_3rd_s;


  //----------------------------------------
  // TAPC
  //----------------------------------------
  tap_fsm tapc (.tck_i(tck_i),                 // from IO
                .trst_i(trst_i),               // from IO
                .tms_i(tms_i),                 // from IO
                .ir_shift_o(ir_shift_s),       // to IR
                .ir_clock_o(ir_clock_s),       // to IR
                .ir_upd_o(ir_upd_s),           // to IR
                .dr_shift_o(dr_shift_s),       // to IR Dec
                .dr_clock_o(dr_clock_s),       // to IR Dec
                .dr_upd_o(dr_upd_s),           // to IR Dec
                .jtag_rst_o(tapc_rst_s),       // to rst OR
                .irdr_select_o(irdr_select_s), // to mux2: IR or DRs TDO
                .tdo_ena_o(tdo_ena_s)          // to TDO TriState buffer
               );
  assign jtag_rst_s = tapc_rst_s | trst_i;
  assign tap_rst_o  = jtag_rst_s;

  //----------------------------------------
  // IR
  //----------------------------------------
  assign ir_rst_s  = 'h96;
  assign ir_data_s = 'hf1;
  assign ser_ir_s[0] = tdi_i;
  genvar i;
  generate
    for (i=0;i<ir_width;i++)
    begin
      ir_cell ircell (.tck_i(tck_i),           // from IO
                      .trst_i(jtag_rst_s),     // from rst OR
                      .ir_rst_i(ir_rst_s[i]),  // from constant
                      .ir_shift_i(ir_shift_s), // from FSM
                      .ir_clock_i(ir_clock_s), // from FSM
                      .ir_upd_i(ir_upd_s),     // from FSM
                      .data_i(ir_data_s[i]),   // from constant
                      .ser_i(ser_ir_s[i]),     // from tdi_i and internal
                      .data_o(ir_s[i]),        // to ir_decode; IR
                      .ser_o(ser_ir_s[i+1])    // to 2nd tdo mux
                     );
    end
  endgenerate
  assign tdo_ir_s = ser_ir_s[ir_width];        // to to 2nd tdo mux

  //----------------------------------------
  // IR Decode
  //----------------------------------------
  ir_decode irdecode (dr_shift_s,dr_clock_s,dr_upd_s,ir_s,sel_tdo_s,bs_mode_o,by_shift_s,by_clock_s,bs_shift_o,bs_clock_o,bs_upd_o,id_shift_s,id_clock_s,id_upd_s,id_mode_s,im_shift_o,im_clock_o,im_upd_o,im_mode_o,sc01_clock_o,sc01_shift_o);
  /*ir_decode irdecode (.dr_shift_i(dr_shift_s),    // from FSM
                      .dr_clock_i(dr_clock_s),    // from FSM
                      .dr_upd_i(dr_upd_s),        // from FSM
                      .ir_i(ir_s),                // from IR
                      .sel_tdo_o(sel_tdo_s),      // to 1st tdo mux
                      .test_mode_o(bs_mode_o),    // to BS register; IO
                      .by_shift_o(by_shift_s),    // to bypass register
                      .by_clock_o(by_clock_s),    // to bypass register
                      .bs_shift_o(bs_shift_o),    // to BS register; IO
                      .bs_clock_o(bs_clock_o),    // to BS register; IO
                      .bs_upd_o(bs_upd_o),        // to BS register; IO
                      .id_shift_o(id_shift_s),    // to IDCODE register
                      .id_clock_o(id_clock_s),    // to IDCODE register
                      .id_upd_o(id_upd_s),        // to IDCODE register
                      .id_mode_o(id_mode_s),      // to IDCODE register
                      .im_shift_o(im_shift_o),    // to I-Mem; IO
                      .im_clock_o(im_clock_o),    // to I-Mem; IO
                      .im_upd_o(im_upd_o),        // to I-Mem; IO
                      .im_mode_o(im_mode_o),       // to I-Mem; IO
		      -sc01_clock_o(sc01_clock_o), // to Scan Chain 01; IO
                      .sc01_shift_o(sc01_shift_o)  // to Scan Chain 01; IO
                     );*/

  //----------------------------------------
  // IDCODE Data Register
  //----------------------------------------
  assign id_data_s  = 'hdeadbeef;
  dr_reg #(.dr_width(32)) idcode (.tck_i(tck_i), // from IO
                  .trst_i(jtag_rst_s),           // from rst OR
                  .mode_i(id_mode_s),            // from IR-Decode
                  .dr_shift_i(id_shift_s),       // from IR-Decode
                  .dr_clock_i(id_clock_s),       // from IR-Decode
                  .dr_upd_i(id_upd_s),           // from IR-Decode
                  .data_i(id_data_s),            // from constant
                  .ser_i(tdi_i),                 // from IO
                  .data_o(),                     // open
                  .ser_o(tdo_id_s)               // to to 1st tdo mux
		 );

  //----------------------------------------
  // Bypass Register
  //----------------------------------------
  by_cell bypass (.tck_i(tck_i),            // from IO
                  .trst_i(jtag_rst_s),      // from rst OR
                  .by_shift_i(by_shift_s),  // from IR-Decode
                  .by_clock_i(by_clock_s),  // from IR-Decode
                  .ser_i(tdi_i),            // from IO
                  .ser_o(tdo_by_s)          // to to 1st tdo mux
		 );

  //----------------------------------------
  // Scan Chain 01
  //----------------------------------------
  //assign sc01_tdi_o = tdi_i;

  //----------------------------------------
  // I-Mem Chain
  //----------------------------------------
  //assign im_tdi_o = tdi_i;

  //----------------------------------------
  // BS Chain
  //----------------------------------------
  //assign bs_tdi_o = tdi_i;

  always_comb
  begin
    case(sel_tdo_s)
      0       : begin              // BYPASS
                  sc01_tdi_o = 0; 
                  im_tdi_o   = 0; 
                  bs_tdi_o   = 0;  
                end
      1       : begin              // IDCODE
                  sc01_tdi_o = 0; 
                  im_tdi_o   = 0; 
                  bs_tdi_o   = 0;  
                end
      2       : begin              // BS-Chain
                  sc01_tdi_o = 0; 
                  im_tdi_o   = 0; 
                  bs_tdi_o   = tdi_i;  
                end
      3       : begin              // I-Mem Chain
                  sc01_tdi_o = 0; 
                  im_tdi_o   = tdi_i; 
                  bs_tdi_o   = 0;  
                end
      4       : begin              // Scan Chain 01
                  sc01_tdi_o = tdi_i; 
                  im_tdi_o   = 0; 
                  bs_tdi_o   = 0;  
                end
      default : begin              // BYPASS
                  sc01_tdi_o = 0; 
                  im_tdi_o   = 0; 
                  bs_tdi_o   = 0;  
                end
    endcase
  end

  //----------------------------------------
  // 1st TDO Mux
  //----------------------------------------
  always_comb
  begin
    case(sel_tdo_s)
      0       : tdo_1st_s = tdo_by_s;   // BYPASS
      1       : tdo_1st_s = tdo_by_s;   // IDCODE
      2       : tdo_1st_s = bs_tdo_i;   // BS-Chain
      3       : tdo_1st_s = im_tdo_i;   // I-Mem Chain
      4       : tdo_1st_s = sc01_tdo_i; // Scan Chain 01
      default : tdo_1st_s = tdo_by_s;   // BYPASS
    endcase
  end // always_comb

  //----------------------------------------
  // 2nd TDO Mux
  //----------------------------------------
  assign tdo_2nd_s = (irdr_select_s == 0) ? tdo_1st_s : tdo_ir_s;

  //----------------------------------------
  // TDO neg-edge FF
  //----------------------------------------
  always_ff @(negedge tck_i, posedge jtag_rst_s)
  begin
    if(jtag_rst_s == 1)
    begin
      tdo_3rd_s <= 0;
      tdo_ena_n_s <= 0;
    end
    else
    begin
      tdo_3rd_s <= tdo_2nd_s;
      tdo_ena_n_s <= tdo_ena_s;
    end
  end

  //----------------------------------------
  // TDO Tri-State
  //----------------------------------------
  assign tdo_o = (tdo_ena_n_s == 1) ? tdo_3rd_s : 1'bz;


endmodule : jtag
