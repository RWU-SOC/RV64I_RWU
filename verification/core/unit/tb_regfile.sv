`timescale 1ns/1ps
module tb_regfile ();
  logic	clk_s;
  logic	rst_n_s;
  logic	we_s;
  logic [4:0] raddr01_s;
  logic [4:0] raddr02_s;
  logic [4:0] waddr01_s;
  logic [63:0] wdata01_s;
  logic [63:0] rdata01_s;
  logic [63:0] rdata02_s;

  // DUT
  as_regfile DUT(clk_s,rst_n_s,we_s,raddr01_s,raddr02_s,waddr01_s,
                 wdata01_s,rdata01_s,rdata02_s);

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
    we_s = 0;
    raddr01_s = 5'b0;
    raddr02_s = 5'b0;
    waddr01_s = 5'b0;
    wdata01_s = 64'b0; #40;
    assert (rdata01_s === 64'b0) $display("OK: Test00 Out01 = 0"); else $error("FAIL: Test00 Out01 = 0");
    assert (rdata02_s === 64'b0) $display("OK: Test00 Out02 = 0"); else $error("FAIL: Test00 Out02 = 0");

    // write data
    we_s      = 1;
    waddr01_s = 5'b00000; // should not work
    wdata01_s = 64'hdeadbeefdeadbeef; #10;
    we_s      = 0;
    assert (rdata01_s === 64'b0) $display("OK: Test01 Out01 = 0"); else $error("FAIL: Test01 Out01 = 0");
    assert (rdata02_s === 64'b0) $display("OK: Test01 Out02 = 0"); else $error("FAIL: Test01 Out02 = 0");

    // write data
    we_s      = 1;
    raddr01_s = 5'b00001;
    raddr02_s = 5'b00000;
    waddr01_s = 5'b00001;
    wdata01_s = 64'hdeadbeefdeadbeef; #10;
    we_s      = 0;
    assert (rdata01_s === 64'hdeadbeefdeadbeef) $display("OK: Test02 Out01"); else $error("FAIL: Test02 Out01");
    assert (rdata02_s === 64'h0000000000000000) $display("OK: Test02 Out02"); else $error("FAIL: Test02 Out02");

    // write data
    we_s      = 1;
    raddr01_s = 5'b00000;
    raddr02_s = 5'b00010;
    waddr01_s = 5'b00010;
    wdata01_s = 64'hcafebeefbeefcafe; #10;
    we_s      = 0;
    assert (rdata01_s === 64'h0000000000000000) $display("OK: Test03 Out01"); else $error("FAIL: Test03 Out01");
    assert (rdata02_s === 64'hcafebeefbeefcafe) $display("OK: Test03 Out02"); else $error("FAIL: Test03 Out02");


    
    #100;
    //$finish(1);
    $fatal(1,"End of simulation!");
    //$stop;
  end

endmodule : tb_regfile
