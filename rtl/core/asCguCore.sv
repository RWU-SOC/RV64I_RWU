`timescale 1ns/1ps

import as_pack::*;

module as_cgucore (input  logic clk_i, // external clock (Zybo: 125 MHz)
                   input  logic rst_i,
                   output logic clk_bus1_o,
                   output logic clk_bus2_o,
                   output logic clk_qspi_o,
                   output logic clk_core_o);
  int cnt1_s,cnt2_s,cnt3_s,cnt4_s;

  // core clock
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
    begin
      cnt1_s <= 0;
    end
    else
    begin
      if( cnt1_s >= (clk_core_div-1) )
        cnt1_s <= 0;
      else
	cnt1_s <= cnt1_s + 1;
    end
  end // always_ff @ (posedge clk_i, posedge rst_i)
  
  assign clk_core_o  = (cnt1_s < (clk_core_div/2)) ? 1 : 0;

  // qspi clock
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
    begin
      cnt2_s <= 0;
    end
    else
    begin
      if( cnt2_s >= (clk_qspi_div-1) )
        cnt2_s <= 0;
      else
	cnt2_s <= cnt2_s + 1;
    end
  end // always_ff @ (posedge clk_i, posedge rst_i)
  
  assign clk_qspi_o  = (cnt2_s < ((clk_qspi_div-1)/2)) ? 1 : 0;

  // bus1 clock
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
    begin
      cnt3_s <= 0;
    end
    else
    begin
      if( cnt3_s >= (clk_bus1_div-1) )
        cnt3_s <= 0;
      else
	cnt3_s <= cnt3_s + 1;
    end
  end // always_ff @ (posedge clk_i, posedge rst_i)
  
  assign clk_bus1_o  = (cnt3_s < (clk_bus1_div/2)) ? 1 : 0;

  // bus2 clock
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
    begin
      cnt4_s <= 0;
    end
    else
    begin
      if( cnt4_s >= (clk_bus2_div-1) )
        cnt4_s <= 0;
      else
	cnt4_s <= cnt4_s + 1;
    end
  end // always_ff @ (posedge clk_i, posedge rst_i)
  
  assign clk_bus2_o  = (cnt4_s < (clk_bus2_div/2)) ? 1 : 0;
  
endmodule : as_cgucore
