`timescale 1ns/1ps

package as_pack;
  localparam int       clk_freq         = 125000000;
  localparam int       baud_rate        = 9600;
  localparam int       br_cnt_max       = clk_freq/baud_rate; // should be int
  localparam int       br2_cnt_max      = br_cnt_max/2;
  localparam int       uart_width       = 8;
  
endpackage
