`timescale 1ns/1ps

import as_pack::*;

module tb_control ();
  logic	clk_s;
  logic	rst_n_s;

  logic [opcode_width-1:0]   opcode_s;
  logic [func3_width-1:0]    func3_s;
  logic			     func7b5_s; // bit 5 of func7
  logic			     zero_s;
  logic [dmuxsel_width-1:0]  resultSrc_s; // Mux behind DMem
  logic			     dMemWr_s;
  logic			     dMemRd_s;
  logic			     PCSrc_s;
  logic			     aluSrc_s; // Mux in front of ALU
  logic			     regWr_s;
  logic			     jump_s;
  logic [immsrc_width-1:0]   immSrc_s;
  logic [aluselrv_width-1:0] aluSel_s;


  // DUT
  as_control DUT(opcode_s,func3_s,func7b5_s,zero_s,resultSrc_s,dMemWr_s,
                 dMemRd_s,PCSrc_s,aluSrc_s,regWr_s,jump_s,immSrc_s,aluSel_s);

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
    // init
    opcode_s = 7'b0000000;
    func3_s  = 3'b000;
    func7b5_s = 0;
    zero_s    = 0; #40;
    assert (resultSrc_s === 2'b00) $display("OK: Test00: DMem-Mux-Sel");   else $error("FAIL: Test00: DMem-Mux-Sel");
    assert (dMemWr_s === 0)        $display("OK: Test00: DMemWr");         else $error("FAIL: Test00: DMemWr");
    assert (dMemRd_s === 0)        $display("OK: Test00: DMemRd");         else $error("FAIL: Test00: DMemRd");
    assert (PCSrc_s === 0)         $display("OK: Test00: PC-Mux-Sel");     else $error("FAIL: Test00: PC-Mux-Sel");
    assert (aluSrc_s === 0)        $display("OK: Test00: ALU-Mux-Sel");    else $error("FAIL: Test00: ALU-Mux-Sel");
    assert (regWr_s === 0)         $display("OK: Test00: RegWr");          else $error("FAIL: Test00: RegWr");
    assert (jump_s === 0)          $display("OK: Test00: Jump");           else $error("FAIL: Test00: Jump");
    assert (immSrc_s === 2'b00)    $display("OK: Test00: ImmSrc");         else $error("FAIL: Test00: ImmSrc");
    assert (aluSel_s === 3'b000)   $display("OK: Test00: ALU-Sel");        else $error("FAIL: Test00: ALU-Sel");

    // I-type, lb
    opcode_s = 7'b0000011;
    func3_s  = 3'b000;
    func7b5_s = 0;
    zero_s    = 0; #40;
    assert (resultSrc_s === 2'b00) $display("OK: Test00: DMem-Mux-Sel");   else $error("FAIL: Test00: DMem-Mux-Sel");
    assert (dMemWr_s === 0)        $display("OK: Test00: DMemWr");         else $error("FAIL: Test00: DMemWr");
    assert (dMemRd_s === 0)        $display("OK: Test00: DMemRd");         else $error("FAIL: Test00: DMemRd");
    assert (PCSrc_s === 0)         $display("OK: Test00: PC-Mux-Sel");     else $error("FAIL: Test00: PC-Mux-Sel");
    assert (aluSrc_s === 0)        $display("OK: Test00: ALU-Mux-Sel");    else $error("FAIL: Test00: ALU-Mux-Sel");
    assert (regWr_s === 0)         $display("OK: Test00: RegWr");          else $error("FAIL: Test00: RegWr");
    assert (jump_s === 0)          $display("OK: Test00: Jump");           else $error("FAIL: Test00: Jump");
    assert (immSrc_s === 2'b00)    $display("OK: Test00: ImmSrc");         else $error("FAIL: Test00: ImmSrc");
    assert (aluSel_s === 3'b000)   $display("OK: Test00: ALU-Sel");        else $error("FAIL: Test00: ALU-Sel");

   

    
    #100;
    //$finish(1);
    $fatal(1,"End of simulation!");
    //$stop;
  end

endmodule : tb_control
