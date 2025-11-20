`timescale 1ns/1ps

import as_pack::*;

module as_br (input  logic clk_i,
              input  logic rst_i,
              input  logic start_i,
              output logic br_o,
              output logic br2_o
             );
  int cnt_s;

  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
    begin
      cnt_s <= 0;
    end
    else
    begin
      if( (cnt_s >= br_cnt_max) | (start_i == 1) )
        cnt_s <= 0;
      else
	cnt_s <= cnt_s + 1;
    end
  end // always_ff @ (posedge clk_i, posedge rst_i)

  assign br_o  = (cnt_s == 0) ? 1 : 0;
  assign br2_o = (cnt_s == br2_cnt_max) ? 1 : 0;  

endmodule : as_br

