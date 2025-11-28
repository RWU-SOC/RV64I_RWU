`timescale 1ns/1ps

import as_pack::*;

module tb_ir_reg ();
  // constants, types and parameter
  parameter clk_2_t = 5; // 5 ns; given by timescale
  //int	    j=0;
  //string    check_str;
  // internal signals
  logic	tck_s;
  logic trst_s;
  logic [ir_width-1:0] ir_rst_s;
  logic                ir_shift_s;
  logic                ir_clock_s;
  logic                ir_upd_s;
  logic [ir_width-1:0] datai_s;
  logic                seri_s;
  logic [ir_width-1:0] datao_s;
  logic                sero_s;

  // DUT
  ir_reg DUT (tck_s,trst_s,ir_rst_s,ir_shift_s,ir_clock_s,ir_upd_s,datai_s,seri_s,datao_s,sero_s);

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
    ir_rst_s   = 8'hde;
    ir_shift_s = 0;
    ir_clock_s = 0;
    ir_upd_s   = 0;
    datai_s    = 8'h00;;
    seri_s     = 0; #(2*clk_2_t);
    assert (datao_s === 8'hde) $display("@ %0t - OK: PAR_DAT_O = 0x%0h", $time, datao_s); else $error("@ %0t - FAIL: PAR_DAT_O = 0x%0h", $time, datao_s);
    assert (sero_s === 0)  $display("@ %0t - OK: SER_DAT_O = 0x%0h", $time, sero_s);  else $error("@ %0t - FAIL: SER_DAT_O = 0x%0h", $time, sero_s);

    // parallel load -> shift out
    datai_s    = 8'had; // 1010_1101
    ir_shift_s = 0;
    ir_clock_s = 1; #(2*clk_2_t); // parallel load to master
    datai_s    = 8'b0;
    ir_clock_s = 0; #(2*clk_2_t);
    ir_upd_s   = 1; #(2*clk_2_t); // shift out
    assert (datao_s === 8'had) $display("@ %0t - OK: PAR_DAT_O = 0x%0h", $time, datao_s); else $error("@ %0t - FAIL: PAR_DAT_O = 0x%0h", $time, datao_s);
    ir_upd_s   = 0; #(2*clk_2_t);
    ir_shift_s = 1;
    assert (sero_s === 1)  $display("@ %0t - OK: SER_DAT_O = 0x%0h", $time, sero_s);  else $error("@ %0t - FAIL: SER_DAT_O = 0x%0h", $time, sero_s);
    ir_clock_s = 1; #(2*clk_2_t); // shift out
    assert (sero_s === 0)  $display("@ %0t - OK: SER_DAT_O = 0x%0h", $time, sero_s);  else $error("@ %0t - FAIL: SER_DAT_O = 0x%0h", $time, sero_s);
    #(1*2*clk_2_t); // shift out
    assert (sero_s === 1)  $display("@ %0t - OK: SER_DAT_O = 0x%0h", $time, sero_s);  else $error("@ %0t - FAIL: SER_DAT_O = 0x%0h", $time, sero_s);
    #(1*2*clk_2_t); // shift out
    assert (sero_s === 0)  $display("@ %0t - OK: SER_DAT_O = 0x%0h", $time, sero_s);  else $error("@ %0t - FAIL: SER_DAT_O = 0x%0h", $time, sero_s);
    #(1*2*clk_2_t); // shift out
    assert (sero_s === 1)  $display("@ %0t - OK: SER_DAT_O = 0x%0h", $time, sero_s);  else $error("@ %0t - FAIL: SER_DAT_O = 0x%0h", $time, sero_s);
    #(1*2*clk_2_t); // shift out
    assert (sero_s === 1)  $display("@ %0t - OK: SER_DAT_O = 0x%0h", $time, sero_s);  else $error("@ %0t - FAIL: SER_DAT_O = 0x%0h", $time, sero_s);
    #(1*2*clk_2_t); // shift out
    assert (sero_s === 0)  $display("@ %0t - OK: SER_DAT_O = 0x%0h", $time, sero_s);  else $error("@ %0t - FAIL: SER_DAT_O = 0x%0h", $time, sero_s);
    #(1*2*clk_2_t); // shift out
    assert (sero_s === 1)  $display("@ %0t - OK: SER_DAT_O = 0x%0h", $time, sero_s);  else $error("@ %0t - FAIL: SER_DAT_O = 0x%0h", $time, sero_s);
    #(1*2*clk_2_t); // shift out
    ir_shift_s = 0;
    ir_clock_s = 0; #(2*clk_2_t);

    // serially shift in; 0110_1001
    seri_s = 0;
    ir_clock_s = 1;
    ir_shift_s = 1; #(2*clk_2_t);
    seri_s = 1; #(2*clk_2_t);
    seri_s = 1; #(2*clk_2_t);
    seri_s = 0; #(2*clk_2_t);
    seri_s = 1; #(2*clk_2_t);
    seri_s = 0; #(2*clk_2_t);
    seri_s = 0; #(2*clk_2_t);
    seri_s = 1; #(2*clk_2_t);
    ir_shift_s = 0;
    ir_clock_s = 0; #(2*clk_2_t);
    ir_upd_s   = 1; #(2*clk_2_t);
    assert (datao_s === 8'h69) $display("@ %0t - OK: PAR_DAT_O = 0x%0h", $time, datao_s); else $error("@ %0t - FAIL: PAR_DAT_O = 0x%0h", $time, datao_s);
    ir_upd_s   = 0; #(2*clk_2_t);
     
    $stop;
  end

 

endmodule : tb_ir_reg
