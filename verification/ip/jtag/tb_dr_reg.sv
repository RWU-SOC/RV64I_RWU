`timescale 1ns/1ps

import as_pack::*;

module tb_dr_reg ();
  // constants, types and parameter
  parameter clk_2_t = 5; // 5 ns; given by timescale
  //int	    j=0;
  //string    check_str;
  // internal signals
  logic	tck_s;
  logic trst_s;
  logic	mode_s;
  logic                 dr_shift_s;
  logic                 dr_clock_s;
  logic                 dr_upd_s;
  logic [dr1_width-1:0] datai_s;
  logic                 seri_s;
  logic [dr1_width-1:0] datao_s;
  logic                 sero_s;

  // DUT
  dr_reg #(.dr_width(8)) DUT (tck_s,trst_s,mode_s,dr_shift_s,dr_clock_s,dr_upd_s,datai_s,seri_s,datao_s,sero_s);

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
    mode_s     = 0; // functional mode
    dr_shift_s = 0;
    dr_clock_s = 0;
    dr_upd_s   = 0;
    datai_s    = 8'h00;;
    seri_s     = 0; #(2*clk_2_t);
    assert (datao_s === 8'h00) $display("@ %0t - OK: PAR_DAT_O = 0x%0h", $time, datao_s); else $error("@ %0t - FAIL: PAR_DAT_O = 0x%0h", $time, datao_s);
    assert (sero_s === 0)  $display("@ %0t - OK: SER_DAT_O = 0x%0h", $time, sero_s);  else $error("@ %0t - FAIL: SER_DAT_O = 0x%0h", $time, sero_s);

    // parallel load -> shift out
    mode_s     = 1;
    datai_s    = 8'had; // 1010_1101
    dr_shift_s = 0;
    dr_clock_s = 1; #(2*clk_2_t); // parallel load to master
    datai_s    = 8'b0;
    dr_clock_s = 0; #(2*clk_2_t);
    dr_upd_s   = 1; #(2*clk_2_t); // shift out
    assert (datao_s === 8'had) $display("@ %0t - OK: PAR_DAT_O = 0x%0h", $time, datao_s); else $error("@ %0t - FAIL: PAR_DAT_O = 0x%0h", $time, datao_s);
    dr_upd_s   = 0; #(2*clk_2_t);
    dr_shift_s = 1;
    assert (sero_s === 1)  $display("@ %0t - OK: SER_DAT_O = 0x%0h", $time, sero_s);  else $error("@ %0t - FAIL: SER_DAT_O = 0x%0h", $time, sero_s);
    dr_clock_s = 1; #(2*clk_2_t); // shift out
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
    dr_shift_s = 0;
    dr_clock_s = 0; #(2*clk_2_t);

    // serially shift in; 0110_1001
    mode_s = 1;
    seri_s = 0;
    dr_clock_s = 1;
    dr_shift_s = 1; #(2*clk_2_t);
    seri_s = 1; #(2*clk_2_t);
    seri_s = 1; #(2*clk_2_t);
    seri_s = 0; #(2*clk_2_t);
    seri_s = 1; #(2*clk_2_t);
    seri_s = 0; #(2*clk_2_t);
    seri_s = 0; #(2*clk_2_t);
    seri_s = 1; #(2*clk_2_t);
    dr_shift_s = 0;
    dr_clock_s = 0; #(2*clk_2_t);
    dr_upd_s   = 1; #(2*clk_2_t);
    assert (datao_s === 8'h69) $display("@ %0t - OK: PAR_DAT_O = 0x%0h", $time, datao_s); else $error("@ %0t - FAIL: PAR_DAT_O = 0x%0h", $time, datao_s);
    dr_upd_s   = 0; #(2*clk_2_t);

    // functional mode
    mode_s  = 0;
    datai_s = 8'haa; #(2*clk_2_t);
    assert (datao_s === 8'haa) $display("@ %0t - OK: PAR_DAT_O = 0x%0h", $time, datao_s); else $error("@ %0t - FAIL: PAR_DAT_O = 0x%0h", $time, datao_s);
    datai_s = 8'h55; #(2*clk_2_t);
    assert (datao_s === 8'h55) $display("@ %0t - OK: PAR_DAT_O = 0x%0h", $time, datao_s); else $error("@ %0t - FAIL: PAR_DAT_O = 0x%0h", $time, datao_s);
     
    $stop;
  end

 

endmodule : tb_dr_reg
