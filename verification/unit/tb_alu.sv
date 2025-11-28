import as_pack::*;
`timescale 1ns/1ps
module tb_alu ();
  logic	clk_s;
  logic	rst_n_s;

  logic [reg_width-1:0]	   data01_s;
  logic [reg_width-1:0]	   data02_s;
  logic [alusel_width-1:0] aluSel_s;
  logic			   aluZero_s;
  logic			   aluNega_s;
  logic [reg_width-1:0]	   aluResult_s;


  // DUT
  as_alu DUT(data01_s,data02_s,aluSel_s,aluZero_s,aluNega_s,aluResult_s);

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
    // AND
    data01_s = '0; // wie others
    data02_s = 64'h0000000000000000;
    aluSel_s = 4'b0000; #40;
    assert (aluZero_s === 1'b1)    $display("OK: Test00: Zero set");   else $error("FAIL: Test00: Zero not set");
    assert (aluResult_s === 64'b0) $display("OK: Test00: Result = 0"); else $error("FAIL: Test00: Result != 0");

    data01_s = 64'h000000000000000f;
    data02_s = 64'h000000000000000a;
    aluSel_s = 4'b0000; #40;
    assert (aluZero_s === 1'b0)                   $display("OK: Test01: Zero not set"); else $error("FAIL: Test01: Zero set");
    assert (aluResult_s === 64'h000000000000000a) $display("OK: Test01: Result = a");   else $error("FAIL: Test01: Result != a");

    // OR
    data01_s = 64'h0000000000000000;
    data02_s = 64'h0000000000000000;
    aluSel_s = 4'b0001; #40;
    assert (aluZero_s === 1'b1)    $display("OK: Test02: Zero set");   else $error("FAIL: Test02: Zero not set");
    assert (aluResult_s === 64'b0) $display("OK: Test02: Result = 0"); else $error("FAIL: Test02: Result != 0");

    data01_s = 64'h000000000000000f;
    data02_s = 64'h000000000000000a;
    aluSel_s = 4'b0001; #40;
    assert (aluZero_s === 1'b0)                   $display("OK: Test03: Zero not set"); else $error("FAIL: Test03: Zero set");
    assert (aluResult_s === 64'h000000000000000f) $display("OK: Test03: Result = f");   else $error("FAIL: Test03: Result != f");

    // ADD
    data01_s = 64'h0000000000000000;
    data02_s = 64'h0000000000000000;
    aluSel_s = 4'b0010; #40;
    assert (aluZero_s === 1'b1)    $display("OK: Test04: Zero set");   else $error("FAIL: Test04: Zero not set");
    assert (aluResult_s === 64'b0) $display("OK: Test04: Result = 0"); else $error("FAIL: Test04: Result != 0");

    data01_s = 64'h000000000000000f;
    data02_s = 64'h000000000000000a;
    aluSel_s = 4'b0010; #40;
    assert (aluZero_s === 1'b0)                   $display("OK: Test04: Zero not set"); else $error("FAIL: Test04: Zero set");
    assert (aluResult_s === 64'h0000000000000019) $display("OK: Test04: Result = x19");   else $error("FAIL: Test04: Result != x19");

    
    

    
    #100;
    //$finish(1);
    $fatal(1,"End of simulation!");
    //$stop;
  end

endmodule : tb_alu
