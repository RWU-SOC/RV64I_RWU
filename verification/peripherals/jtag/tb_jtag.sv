`timescale 1ns/1ps

import as_pack::*;

module tb_jtag ();
  // constants, types and parameter
  parameter clk_2_t = 4; // 5 ns; given by timescale
  parameter clk_func_2_t = 2; // 2 ns
  parameter sc01_length_in = 2;
  parameter sc01_length_out = 2;
  parameter im_length_in = 97;
  parameter im_length_out = 97;  
  //int	    j=0;
  //string    check_str;
  // internal signals
  logic	clk_func_s, clk_mux_s;
  logic	tck_s, trst_s, tms_s, tdi_s, tdo_s;
  logic tap_rst_s;
  logic	sc01_tdo_s, sc01_tdi_s, sc01_shift_s, sc01_clock_s;
  logic	im_tdo_s, im_tdi_s, im_shift_s, im_clock_s, im_upd_s, im_mode_s;
  logic	bs_tdo_s, bs_tdi_s, bs_shift_s, bs_clock_s, bs_upd_s, bs_mode_s;

  logic	and_in01_s, and_in02_s, and_out_s;
  logic	sc01_01_s, sc01_02_s, sc01_03_s;
  logic	to_some_pin1_s, to_some_pin2_s;

  logic [96:0] im_datai_s, im_datao_s;

  int test_rst;

  // DUT
  jtag DUT (tck_s, trst_s, tms_s, tdi_s, tdo_s, tap_rst_s, 
            sc01_tdo_s, sc01_tdi_s, sc01_shift_s, sc01_clock_s,
            im_tdo_s, im_tdi_s, im_shift_s, im_clock_s, im_upd_s, im_mode_s,
            bs_tdo_s, bs_tdi_s, bs_shift_s, bs_clock_s, bs_upd_s, bs_mode_s
           );

  // Scan Chain
  /*   ---
     1-|F|--
       |F|  |  _
       ---  |_| |   ---
             _|&|---|F|---
       ---  | |_|   |F|
     0-|F|--|       ---
       |F|
       ---
  */
  assign clk_mux_s = (sc01_clock_s == 1) ? tck_s : clk_func_s;
  scan_cell sc01 (clk_mux_s, tap_rst_s, sc01_shift_s, 1'b0, sc01_tdi_s, and_in01_s, sc01_01_s);
  scan_cell sc02 (clk_mux_s, tap_rst_s, sc01_shift_s, 1'b0, sc01_01_s, and_in02_s, sc01_02_s);
  assign and_out_s = and_in01_s & and_in02_s;
  scan_cell sc03 (clk_mux_s, tap_rst_s, sc01_shift_s, and_out_s, sc01_02_s, to_some_pin1_s, sc01_03_s);
  scan_cell sc04 (clk_mux_s, tap_rst_s, sc01_shift_s, 1'b0, sc01_03_s, to_some_pin2_s, sc01_tdo_s);

/*  logic	astck, asclk, asshift, ff1in, ff2in, ff4in, astdi, asser01, asser02, astdo, asand01, asand02, asandout, ff3out, ff4out;

  //assign clk_mux_s = (sc01_clock_s == 1) ? tck_s : clk_func_s;
  scan_cell sc01 (asclk, tap_rst_s, asshift, ff1in, astdi, asand01, asser01);
  scan_cell sc02 (asclk, tap_rst_s, asshift, ff2in, asser01, asand02, asser02);
  assign asandout = asand01 & asand02;
  scan_cell sc03 (asclk, tap_rst_s, asshift, asandout, asser02, ff3out, asser03);
  scan_cell sc04 (asclk, tap_rst_s, asshift, ff4in, asser03, ff4out, astdo);*/

  // I-Mem Chain
  assign im_datai_s  = 97'b0;
  dr_reg #(.dr_width(97)) idcode (.tck_i(tck_s),
                  .trst_i(tap_rst_s),
                  .mode_i(im_mode_s),
                  .dr_shift_i(im_shift_s),
                  .dr_clock_i(im_clock_s),
                  .dr_upd_i(im_upd_s),
                  .data_i(im_datai_s),
                  .ser_i(im_tdi_s),
                  .data_o(im_datao_s),
                  .ser_o(im_tdo_s)
		 );

  // Reset
  initial
  begin
    trst_s <= 1; #(2*clk_2_t); trst_s <= 0;
  end

  // Clock
  always
  begin
    tck_s <= 0; #clk_2_t; tck_s <= 1; #clk_2_t; 
  end

/*  always
  begin
    clk_func_s <= 0; #clk_func_2_t; clk_func_s <= 1; #clk_func_2_t; 
  end*/

  // Vectors
  initial
  begin
    // wait until reset is done
    clk_func_s = 0;
    tms_s   = 1;
    tdi_s = 0; #(2*clk_2_t);
    assert (tdo_s === 1'bz)  $display("@ %0t - OK: TDO_O (RST) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (RST) = 0x%0h", $time, tdo_s);

    // BYPASS - IR=255
    // ... IR
    tms_s = 0; #(2*clk_2_t); // Run-Test-Idle
    tms_s = 1; #(2*clk_2_t); // Select-DR-Scan
    tms_s = 1; #(2*clk_2_t); // Select-IR-Scan
    tdi_s = 0;
    tms_s = 0; #(2*clk_2_t); // Capture-IR
    tdi_s = 1;
    tms_s = 0; #(1*clk_2_t); // Shift-IR
    assert  (tdo_s === 1'bz)  $display("@ %0t - OK: TDO_O (ID) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (ID) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);
    tms_s = 0; #(1*clk_2_t); // Shift-IR
    assert  (tdo_s === 1'b1)  $display("@ %0t - OK: TDO_O (ID) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (ID) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);
    tms_s = 0; #(1*clk_2_t); // Shift-IR
    assert  (tdo_s === 1'b1)  $display("@ %0t - OK: TDO_O (ID) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (ID) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);
    tms_s = 0; #(1*clk_2_t); // Shift-IR
    assert  (tdo_s === 1'b1)  $display("@ %0t - OK: TDO_O (ID) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (ID) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);
    tms_s = 0; #(1*clk_2_t); // Shift-IR
    assert  (tdo_s === 1'b1)  $display("@ %0t - OK: TDO_O (ID) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (ID) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);
    tms_s = 0; #(1*clk_2_t); // Shift-IR
    assert  (tdo_s === 1'b0)  $display("@ %0t - OK: TDO_O (ID) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (ID) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);
    tms_s = 0; #(1*clk_2_t); // Shift-IR
    assert  (tdo_s === 1'b0)  $display("@ %0t - OK: TDO_O (ID) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (ID) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);
    tms_s = 1; #(1*clk_2_t); // Exit1-IR
    assert  (tdo_s === 1'b0)  $display("@ %0t - OK: TDO_O (ID) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (ID) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);
    tdi_s = 0;
    tms_s = 1; #(1*clk_2_t); // Update-IR
    assert  (tdo_s === 1'b1)  $display("@ %0t - OK: TDO_O (ID) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (ID) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);
    // ... DR -> 010100
    tdi_s = 0;
    tms_s = 1; #(2*clk_2_t); // Select-DR-Scan
    tms_s = 0; #(2*clk_2_t); // Capture-DR

    tdi_s = 0;
    tms_s = 0; #(1*clk_2_t); // Shift-DR
    assert  (tdo_s === 1'bz)  $display("@ %0t - OK: TDO_O (BY) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (BY) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);

    tdi_s = 1;
    tms_s = 0; #(1*clk_2_t); // Shift-DR
    assert  (tdo_s === 1'b0)  $display("@ %0t - OK: TDO_O (BY) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (BY) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);

    tdi_s = 0;
    tms_s = 0; #(1*clk_2_t); // Shift-DR
    assert  (tdo_s === 1'b1)  $display("@ %0t - OK: TDO_O (BY) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (BY) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);
    
    tdi_s = 1;
    tms_s = 0; #(1*clk_2_t); // Shift-DR
    assert  (tdo_s === 1'b0)  $display("@ %0t - OK: TDO_O (BY) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (BY) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);
    
    tdi_s = 0;
    tms_s = 0; #(1*clk_2_t); // Shift-DR
    assert  (tdo_s === 1'b1)  $display("@ %0t - OK: TDO_O (BY) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (BY) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);

    tms_s = 1; #(1*clk_2_t); // Exit1-DR
    assert  (tdo_s === 1'b0)  $display("@ %0t - OK: TDO_O (BY) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (BY) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);

    tms_s = 1; #(1*clk_2_t); // Update-DR
    assert  (tdo_s === 1'b0)  $display("@ %0t - OK: TDO_O (BY) = 0x%0h", $time, tdo_s);  else $error("@ %0t - FAIL: TDO_O (BY) = 0x%0h", $time, tdo_s); 
    #(1*clk_2_t);

    tms_s = 0; #(2*clk_2_t); // Run-Test-Idle
    #(5*2*clk_2_t);

    // Scan Chain -> IR=129=1000_0001
    // ... IR
    jtag_sw_rst(clk_2_t);
    jtag_load_ir(clk_2_t, 8'h81);
    // ... DR
    jtag_shift_in_dr_to_pause(clk_2_t, 2'b00);
    clk_func_s = 1; #clk_func_2_t; clk_func_s = 0; #clk_func_2_t; #(1*clk_2_t);
    jtag_shift_out_dr(clk_2_t);
    // next
    jtag_shift_in_dr_to_pause(clk_2_t, 2'b01);
    clk_func_s = 1; #clk_func_2_t; clk_func_s = 0; #clk_func_2_t; #(1*clk_2_t);
    jtag_shift_out_dr(clk_2_t);
    // next
    jtag_shift_in_dr_to_pause(clk_2_t, 2'b10);
    clk_func_s = 1; #clk_func_2_t; clk_func_s = 0; #clk_func_2_t; #(1*clk_2_t);
    jtag_shift_out_dr(clk_2_t);
    // next
    jtag_shift_in_dr_to_pause(clk_2_t, 2'b11);
    clk_func_s = 1; #clk_func_2_t; clk_func_s = 0; #clk_func_2_t; #(1*clk_2_t);
    jtag_shift_out_dr(clk_2_t);
    // next
    jtag_shift_in_dr_to_pause(clk_2_t, 2'b00);
    clk_func_s = 1; #clk_func_2_t; clk_func_s = 0; #clk_func_2_t; #(1*clk_2_t);
    jtag_shift_out_dr(clk_2_t);
    #(5*2*clk_2_t);

    // I-Mem -> IR=128=1000_0000
    // ... IR
    jtag_sw_rst(clk_2_t);
    jtag_load_ir(clk_2_t, 8'h80);
    // ... DR
    jtag_shift_in_imdr_to_rti(clk_2_t, 97'ha5a5a5a5a5a5a);
    jtag_shift_in_imdr_to_rti(clk_2_t, 97'ha5a5a5a5a5a5b);
    jtag_shift_in_imdr_to_rti(clk_2_t, 97'ha5a5a5a5a5a5a);
    #(5*2*clk_2_t);


    jtag_sw_rst(clk_2_t);
    $stop;
  end

  task jtag_sw_rst(int clk_2_t);
  begin
    tms_s = 1; #(5*2*clk_2_t);
  end
  endtask // jtag_sw_rst

  task jtag_load_ir(int clk_2_t, logic [7:0] ir);
  begin
    // from reset
    tms_s = 0; #(2*clk_2_t); // Run-Test-Idle
    tms_s = 1; #(2*clk_2_t); // Select-DR-Scan
    tms_s = 1; #(2*clk_2_t); // Select-IR-Scan
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Capture-IR
    tdi_s = ir[7]; tms_s = 0; #(2*clk_2_t); // Shift-IR
    tdi_s = ir[6]; tms_s = 0; #(2*clk_2_t); // Shift-IR
    tdi_s = ir[5]; tms_s = 0; #(2*clk_2_t); // Shift-IR
    tdi_s = ir[4]; tms_s = 0; #(2*clk_2_t); // Shift-IR
    tdi_s = ir[3]; tms_s = 0; #(2*clk_2_t); // Shift-IR
    tdi_s = ir[2]; tms_s = 0; #(2*clk_2_t); // Shift-IR
    tdi_s = ir[1]; tms_s = 0; #(2*clk_2_t); // Shift-IR
    tdi_s = ir[0]; tms_s = 1; #(2*clk_2_t); // Exit1-IR
    tdi_s = 0; tms_s = 1; #(2*clk_2_t); // Update-IR
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Run-Test_idle
  end
  endtask // jtag_load_ir

  task jtag_shift_in_dr_to_pause(int clk_2_t, logic [sc01_length_in-1:0] dr);
  begin
    // from run-test-idle
    tdi_s = 0; tms_s = 1; #(2*clk_2_t); // Select-DR-Scan
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Capture-DR
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Shift-DR ??
    for(int i=sc01_length_in-1;i>0;i--)
    begin
      tdi_s = dr[i]; tms_s = 0; #(2*clk_2_t); // Shift-DR
    end
    tdi_s = dr[0]; tms_s = 1; #(2*clk_2_t); // Exit1-DR
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Pause-DR
  end
  endtask // jtag_shift_in_dr_to_pause

  task jtag_shift_out_dr(int clk_2_t);
  begin
    // from pause
    tdi_s = 0; tms_s = 1; #(2*clk_2_t); // Exit2-DR;
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Shift-DR; // shift out ??
    for(int i=sc01_length_out-1;i>0;i--)
    begin
      tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Shift-DR; // shift out
    end
    tdi_s = 0; tms_s = 1; #(2*clk_2_t); // Exit1-DR  // shift out
    tdi_s = 0; tms_s = 1; #(2*clk_2_t); // Update-DR;
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Run-Test_idle
  end
  endtask // jtag_shift_in_dr_to_pause

  task jtag_shift_in_imdr_to_rti(int clk_2_t, logic [im_length_in-1:0] dr);
  begin
    // from run-test-idle
    tdi_s = 0; tms_s = 1; #(2*clk_2_t); // Select-DR-Scan
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Capture-DR
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Shift-DR ??
    for(int i=im_length_in-1;i>0;i--)
    begin
      tdi_s = dr[i]; tms_s = 0; #(2*clk_2_t); // Shift-DR
    end
    tdi_s = dr[0]; tms_s = 1; #(2*clk_2_t); // Exit1-DR
    tdi_s = 0; tms_s = 1; #(2*clk_2_t); // Update-DR
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Run-Test_idle
  end
  endtask // jtag_shift_in_imdr_to_pause

endmodule : tb_jtag
