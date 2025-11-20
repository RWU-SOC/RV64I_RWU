`timescale 1ns/1ps

import as_pack::*;

module tb_tap_fsm ();
  // constants, types and parameter
  parameter clk_2_t = 5; // 5 ns; given by timescale
  int	    j=0;
  //string    check_str;
  // internal signals
  logic	tck_s;
  logic trst_s;
  logic tms_s;
  logic ir_shift_s;
  logic ir_clock_s;
  logic ir_upd_s;
  logic dr_shift_s;
  logic dr_clock_s;
  logic dr_upd_s;
  logic jtag_rst_s;
  logic irdr_select_s;
  logic tdo_ena_s;

  // DUT
  tap_fsm DUT (tck_s,trst_s,tms_s,ir_shift_s,ir_clock_s,ir_upd_s,dr_shift_s,dr_clock_s,dr_upd_s,jtag_rst_s,irdr_select_s,tdo_ena_s);

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

  // Vectors
  initial
  begin
    // wait until reset is done
    tms_s = 1; #(2*clk_2_t); j=check01("RST",0,0,0,0,0,0,1,1,0);

    // test SW-reset: go to exit1-IR then 5 times TMS = 1 => reset state
    tms_s = 0; #(2*clk_2_t); j=check01("RTI",0,0,0,0,0,0,0,1,0); // run-test-idle
    tms_s = 1; #(2*clk_2_t); j=check01("SDS",0,0,0,0,0,0,0,0,0); // select-dr-scan
    tms_s = 1; #(2*clk_2_t); j=check01("SIS",0,0,0,0,0,0,0,0,0); // select-ir-scan
    tms_s = 0; #(2*clk_2_t); j=check01("CIR",0,1,0,0,0,0,0,1,0); // capture-ir
    tms_s = 0; #(2*clk_2_t); j=check01("SIR",1,1,0,0,0,0,0,1,1); // shift-ir
    tms_s = 1; #(2*clk_2_t); j=check01("E1I",0,0,0,0,0,0,0,1,0); // exit1-ir
    for(int i = 0; i < 5; i++ )
    begin
      tms_s = 1; #(2*clk_2_t);
    end
    j=check01("RST",0,0,0,0,0,0,1,1,0);

    // load 8 bit IR
    tms_s = 0; #(2*clk_2_t); j=check01("RTI",0,0,0,0,0,0,0,1,0); // run-test-idle
    tms_s = 1; #(2*clk_2_t); j=check01("SDS",0,0,0,0,0,0,0,0,0); // select-dr-scan
    tms_s = 1; #(2*clk_2_t); j=check01("SIS",0,0,0,0,0,0,0,0,0); // select-ir-scan
    tms_s = 0; #(2*clk_2_t); j=check01("CIR",0,1,0,0,0,0,0,1,0); // capture-ir
    for(int i = 0; i < 7; i++ )
    begin
      tms_s = 0; #(2*clk_2_t); j=check01("SIR",1,1,0,0,0,0,0,1,1); // shift-ir
    end
    tms_s = 1; #(2*clk_2_t); j=check01("E1I",0,0,0,0,0,0,0,1,0); // exit1-ir
    tms_s = 1; #(2*clk_2_t); j=check01("UIR",0,0,1,0,0,0,0,1,0); // update-ir
    for(int i = 0; i < 5; i++ )
    begin
      tms_s = 1; #(2*clk_2_t);
    end
    j=check01("RST",0,0,0,0,0,0,1,1,0);

    // load 8 bit DR
    tms_s = 0; #(2*clk_2_t); j=check01("RTI",0,0,0,0,0,0,0,1,0); // run-test-idle
    tms_s = 1; #(2*clk_2_t); j=check01("SDS",0,0,0,0,0,0,0,0,0); // select-dr-scan
    //tms_s = 1; #(2*clk_2_t); j=check01("SIS",0,0,0,0,0,0,0,0,0); // select-ir-scan
    tms_s = 0; #(2*clk_2_t); j=check01("CDR",0,0,0,0,1,0,0,0,0); // capture-dr
    for(int i = 0; i < 7; i++ )
    begin
      tms_s = 0; #(2*clk_2_t); j=check01("SDR",0,0,0,1,1,0,0,0,1); // shift-dr
    end
    tms_s = 1; #(2*clk_2_t); j=check01("E1D",0,0,0,0,0,0,0,0,0); // exit1-dr
    tms_s = 1; #(2*clk_2_t); j=check01("UDR",0,0,0,0,0,1,0,0,0); // update-dr
    for(int i = 0; i < 5; i++ )
    begin
      tms_s = 1; #(2*clk_2_t);
    end
    j=check01("RST",0,0,0,0,0,0,1,1,0);




    $display("TEST: %0d fails!", j);
    $stop;
  end

  function int check01(string str, logic sir, cir, uir, sdr, cdr, udr, jrst, irdr,tdoe);
    int j=0;
    assert (ir_shift_s === sir)     $display("@ %0t - OK-%s: IR_SHIFT = 0x%0h", $time, str, ir_shift_s);    
           else begin j++; $error("@ %0t - FAIL-%s: IR_SHIFT = 0x%0h", $time, str, ir_shift_s); end
    assert (ir_clock_s === cir)     $display("@ %0t - OK-%s: IR_CLOCK = 0x%0h", $time, str, ir_clock_s);    
           else begin j++; $error("@ %0t - FAIL-%s: IR_CLOCK = 0x%0h", $time, str, ir_clock_s); end
    assert (ir_upd_s === uir)       $display("@ %0t - OK-%s: IR_UPD = 0x%0h",   $time, str, ir_upd_s);      
           else begin j++; $error("@ %0t - FAIL-%s: IR_UPD = 0x%0h",   $time, str, ir_upd_s); end
    assert (dr_shift_s === sdr)     $display("@ %0t - OK-%s: DR_SHIFT = 0x%0h", $time, str, dr_shift_s);    
           else begin j++; $error("@ %0t - FAIL-%s: DR_SHIFT = 0x%0h", $time, str, dr_shift_s); end
    assert (dr_clock_s === cdr)     $display("@ %0t - OK-%s: DR_CLOCK = 0x%0h", $time, str, dr_clock_s);    
           else begin j++; $error("@ %0t - FAIL-%s: DR_CLOCK = 0x%0h", $time, str, dr_clock_s); end
    assert (dr_upd_s === udr)       $display("@ %0t - OK-%s: DR_UPD = 0x%0h",   $time, str, dr_upd_s);      
           else begin j++; $error("@ %0t - FAIL-%s: DR_UPD = 0x%0h",   $time, str, dr_upd_s); end
    assert (jtag_rst_s === jrst)    $display("@ %0t - OK-%s: J_RST = 0x%0h",    $time, str, jtag_rst_s);    
           else begin j++; $error("@ %0t - FAIL-%s: J_RST = 0x%0h",    $time, str, jtag_rst_s); end
    assert (irdr_select_s === irdr) $display("@ %0t - OK-%s: IRDR = 0x%0h",     $time, str, irdr_select_s); 
           else begin j++; $error("@ %0t - FAIL-%s: IRDR = 0x%0h",     $time, str, irdr_select_s); end
    assert (tdo_ena_s === tdoe)     $display("@ %0t - OK-%s: TDOE = 0x%0h",     $time, str, tdo_ena_s);     
           else begin j++; $error("@ %0t - FAIL-%s: TDOE = 0x%0h",     $time, str, tdo_ena_s); end
    return j;
  endfunction

endmodule : tb_tap_fsm
