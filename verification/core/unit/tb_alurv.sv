`timescale 1ns/1ps

import as_pack::*;

module tb_alurv ();
  logic	clk_s;
  logic	rst_n_s;

  logic [reg_width-1:0]	     data01_s;
  logic [reg_width-1:0]	     data02_s;
  logic [aluselrv_width-1:0] aluSel_s;
  logic			     aluZero_s;
  logic			     aluNega_s;
  logic			     aluCarr_s;
  logic			     aluOver_s;
  logic [reg_width-1:0]	     aluResult_s;


  // DUT
  as_alurv DUT(data01_s,data02_s,aluSel_s,aluZero_s,aluNega_s,aluCarr_s,aluOver_s,aluResult_s);

  // clock
  always
  begin
    clk_s = 0; #5; clk_s = 1; #5;
  end

  // reset
  initial
  begin
    rst_n_s = 0; #20; rst_n_s = 1;
  end

  initial
  begin // started at start of simulation
    // ADD
    data01_s = '0; // wie others
    data02_s = 64'h0000000000000000;
    aluSel_s = 3'b000; #40;
    assert (aluZero_s === 1'b1)    $display("OK: Test00: Z-Flag set");     else $error("FAIL: Test00: Z-Flag not set");
    assert (aluNega_s === 1'b0)    $display("OK: Test00: N-Flag not set"); else $error("FAIL: Test00: N-Flag set");
    assert (aluCarr_s === 1'b0)    $display("OK: Test00: C-Flag not set"); else $error("FAIL: Test00: C-Flag set");
    assert (aluOver_s === 1'b0)    $display("OK: Test00: O-Flag not set"); else $error("FAIL: Test00: O-Flag set");
    assert (aluResult_s === 64'b0) $display("OK: Test00: Result = 0");     else $error("FAIL: Test00: Result != 0");
    // normal ADD
    data01_s = 64'h000000000000000f;
    data02_s = 64'h000000000000000a;
    aluSel_s = 3'b000; #40;
    assert (aluZero_s === 1'b0)                   $display("OK: Test01: Z-Flag not set"); else $error("FAIL: Test01: Z-Flag set");
    assert (aluNega_s === 1'b0)                   $display("OK: Test01: N-Flag not set"); else $error("FAIL: Test01: N-Flag set");
    assert (aluCarr_s === 1'b0)                   $display("OK: Test01: C-Flag not set"); else $error("FAIL: Test01: C-Flag set");
    assert (aluOver_s === 1'b0)                   $display("OK: Test01: O-Flag not set"); else $error("FAIL: Test01: O-Flag set");
    assert (aluResult_s === 64'h0000000000000019) $display("OK: Test01: Result = h19");   else $error("FAIL: Test01: Result != h19");
    // ADD with carry
    data01_s = 64'hffffffffffffffff;
    data02_s = 64'h0000000000000002;
    aluSel_s = 3'b000; #40;
    assert (aluZero_s === 1'b0)                   $display("OK: Test02: Z-Flag not set"); else $error("FAIL: Test02: Z-Flag set");
    assert (aluNega_s === 1'b0)                   $display("OK: Test02: N-Flag not set"); else $error("FAIL: Test02: N-Flag set");
    assert (aluCarr_s === 1'b1)                   $display("OK: Test02: C-Flag set");     else $error("FAIL: Test02: C-Flag not set");
    assert (aluOver_s === 1'b0)                   $display("OK: Test02: O-Flag not set"); else $error("FAIL: Test02: O-Flag set");
    assert (aluResult_s === 64'h0000000000000001) $display("OK: Test02: Result = 1");     else $error("FAIL: Test02: Result != 1");
    // ADD with negative result (ony relevant for signed numbers)
    data01_s = 64'h7fffffffffffffff;
    data02_s = 64'h0000000000000001;
    aluSel_s = 3'b000; #40;
    assert (aluZero_s === 1'b0)                   $display("OK: Test03: Z-Flag not set"); else $error("FAIL: Test03: Z-Flag set");
    assert (aluNega_s === 1'b1)                   $display("OK: Test03: N-Flag set");     else $error("FAIL: Test03: N-Flag not set");
    assert (aluCarr_s === 1'b0)                   $display("OK: Test03: C-Flag not set"); else $error("FAIL: Test03: C-Flag set");
    assert (aluOver_s === 1'b1)                   $display("OK: Test03: O-Flag set");     else $error("FAIL: Test03: O-Flag not set");
    assert (aluResult_s === 64'h8000000000000000) $display("OK: Test03: Result = h800..");else $error("FAIL: Test03: Result != h800..");
    // ADD with overflow
    data01_s = 64'h7fffffffffffffff;
    data02_s = 64'h0000000000000002;
    aluSel_s = 3'b000; #40;
    assert (aluZero_s === 1'b0)                   $display("OK: Test03: Z-Flag not set"); else $error("FAIL: Test03: Z-Flag set");
    assert (aluNega_s === 1'b1)                   $display("OK: Test03: N-Flag set");     else $error("FAIL: Test03: N-Flag not set");
    assert (aluCarr_s === 1'b0)                   $display("OK: Test03: C-Flag not set"); else $error("FAIL: Test03: C-Flag set");
    assert (aluOver_s === 1'b1)                   $display("OK: Test03: O-Flag set");     else $error("FAIL: Test03: O-Flag not set");
    assert (aluResult_s === 64'h8000000000000001) $display("OK: Test03: Result = h800.1");else $error("FAIL: Test03: Result != h800.1");

    // SUB
    data01_s = '0; // wie others
    data02_s = 64'h0000000000000000;
    aluSel_s = 3'b001; #40;
    assert (aluZero_s === 1'b1)    $display("OK: Test04: Z-Flag set");     else $error("FAIL: Test04: Z-Flag not set");
    assert (aluNega_s === 1'b0)    $display("OK: Test04: N-Flag not set"); else $error("FAIL: Test04: N-Flag set");
    assert (aluCarr_s === 1'b1)    $display("OK: Test04: C-Flag set");     else $error("FAIL: Test04: C-Flag not set");
    assert (aluOver_s === 1'b0)    $display("OK: Test04: O-Flag not set"); else $error("FAIL: Test04: O-Flag set");
    assert (aluResult_s === 64'b0) $display("OK: Test04: Result = 0");     else $error("FAIL: Test04: Result != 0");
    // normal SUB with carry (15-10)
    data01_s = 64'h000000000000000f;
    data02_s = 64'h000000000000000a;
    aluSel_s = 3'b001; #40;
    assert (aluZero_s === 1'b0)                   $display("OK: Test05: Z-Flag not set"); else $error("FAIL: Test05: Z-Flag set");
    assert (aluNega_s === 1'b0)                   $display("OK: Test05: N-Flag not set"); else $error("FAIL: Test05: N-Flag set");
    assert (aluCarr_s === 1'b1)                   $display("OK: Test05: C-Flag set");     else $error("FAIL: Test05: C-Flag not set");
    assert (aluOver_s === 1'b0)                   $display("OK: Test05: O-Flag not set"); else $error("FAIL: Test05: O-Flag set");
    assert (aluResult_s === 64'h0000000000000005) $display("OK: Test05: Result = h5");    else $error("FAIL: Test05: Result != h5");
    // SUB without carry (10-(-5))
    data01_s = 64'h000000000000000a; // 10
    data02_s = 64'hfffffffffffffffb; // -5
    aluSel_s = 3'b001; #40;
    assert (aluZero_s === 1'b0)                   $display("OK: Test06: Z-Flag not set"); else $error("FAIL: Test06: Z-Flag set");
    assert (aluNega_s === 1'b0)                   $display("OK: Test06: N-Flag not set"); else $error("FAIL: Test06: N-Flag set");
    assert (aluCarr_s === 1'b0)                   $display("OK: Test06: C-Flag not set"); else $error("FAIL: Test06: C-Flag set");
    assert (aluOver_s === 1'b0)                   $display("OK: Test06: O-Flag not set"); else $error("FAIL: Test06: O-Flag set");
    assert (aluResult_s === 64'h000000000000000f) $display("OK: Test06: Result = 15");    else $error("FAIL: Test06: Result != 15");
    // SUB with negative result (2-4)
    data01_s = 64'h0000000000000002;
    data02_s = 64'h0000000000000004;
    aluSel_s = 3'b001; #40;
    assert (aluZero_s === 1'b0)                   $display("OK: Test07: Z-Flag not set"); else $error("FAIL: Test07: Z-Flag set");
    assert (aluNega_s === 1'b1)                   $display("OK: Test07: N-Flag set");     else $error("FAIL: Test07: N-Flag not set");
    assert (aluCarr_s === 1'b0)                   $display("OK: Test07: C-Flag not set"); else $error("FAIL: Test07: C-Flag set");
    assert (aluOver_s === 1'b0)                   $display("OK: Test07: O-Flag not set"); else $error("FAIL: Test07: O-Flag set");
    assert (aluResult_s === 64'hfffffffffffffffe) $display("OK: Test07: Result = -2");    else $error("FAIL: Test07: Result != -2");
    // SUB with overflow (max negative - 2)
    data01_s = 64'h8000000000000000; // max negative
    data02_s = 64'h0000000000000002; // 2
    aluSel_s = 3'b001; #40;
    assert (aluZero_s === 1'b0)                   $display("OK: Test08: Z-Flag not set");     else $error("FAIL: Test08: Z-Flag set");
    assert (aluNega_s === 1'b0)                   $display("OK: Test08: N-Flag not set");     else $error("FAIL: Test08: N-Flag set");
    assert (aluCarr_s === 1'b1)                   $display("OK: Test08: C-Flag set");         else $error("FAIL: Test08: C-Flag not set");
    assert (aluOver_s === 1'b1)                   $display("OK: Test08: O-Flag set");         else $error("FAIL: Test08: O-Flag notset");
    assert (aluResult_s === 64'h7ffffffffffffffe) $display("OK: Test08: Result = max pos-1"); else $error("FAIL: Test08: Result != max pos-1");



    

    

    
    #100;
    //$finish(1);
    $fatal(1,"End of simulation!");
    //$stop;
  end

endmodule : tb_alurv
