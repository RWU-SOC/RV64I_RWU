`timescale 1ns/1ps

import as_pack::*;

module as_rx (input  logic                  clk_i,
              input  logic                  rst_i,
              input  logic                  rx_i,
              input  logic                  br_i,
              input  logic                  br2_i,
              output logic                  start_o,
              output logic [uart_width-1:0] data_o,
              output logic                  rdy_o
             );
  typedef enum logic [3:0] {idle_st, wait_st, start_st,start_br_st,
                      bit0_st, bit1_st, bit2_st, bit3_st,
                      bit4_st, bit5_st, bit6_st, bit7_st, stop_st} statetype_t;
  statetype_t state_s, nextstate_s;
  logic rdy_s;
  logic [uart_width-1:0] data_s;
  logic [1:0] delay_rdy_s;
  logic [1:0] delay_rx_s;
  logic falling_rdy_edge_s;
  logic falling_rx_edge_s;

  // generate start - falling edge of start bit
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      delay_rx_s <= 2'b00;
    else
    begin
      delay_rx_s[0] <= rx_i;
      delay_rx_s[1] <= delay_rx_s[0];
    end
  end
  assign falling_rx_edge_s = delay_rx_s[1] & (~delay_rx_s[0]);

  
  // FSM block 1: delay
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      state_s <= idle_st;
    else
      state_s <= nextstate_s;
  end

  // FSM block 2: nextstate, input CLC
  always_comb 
  begin
    nextstate_s = state_s;
    case(state_s)
      idle_st  :    if(falling_rx_edge_s == 1)
                      nextstate_s = start_br_st;
      start_br_st :  nextstate_s = wait_st;
      wait_st     :  if(br_i == 1)
                       nextstate_s = start_st;
      start_st    :  if(br_i == 1)
                       nextstate_s = bit0_st;
      bit0_st     :  if(br_i == 1)
                       nextstate_s = bit1_st;
      bit1_st     :  if(br_i == 1)
                       nextstate_s = bit2_st;
      bit2_st     :  if(br_i == 1)
                       nextstate_s = bit3_st;
      bit3_st     :  if(br_i == 1)
                       nextstate_s = bit4_st;
      bit4_st     :  if(br_i == 1)
                       nextstate_s = bit5_st;
      bit5_st     :  if(br_i == 1)
                       nextstate_s = bit6_st;
      bit6_st     :  if(br_i == 1)
                       nextstate_s = bit7_st;
      bit7_st     :  if(br_i == 1)
                       nextstate_s = stop_st;
      stop_st     :  if(br_i == 1)
                       nextstate_s = idle_st;
      default:    nextstate_s = idle_st;
    endcase
  end // always_comb

  // FSM block 3: output CLC
  // generate rdy in the middle of stop bit
  assign rdy_s = ( (state_s == stop_st) && (br2_i == 1) ) ? 1 : 0;
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      delay_rdy_s <= 2'b00;
    else
    begin
      delay_rdy_s[0] <= rdy_s;
      delay_rdy_s[1] <= delay_rdy_s[0];
    end
  end
  assign falling_rdy_edge_s = delay_rdy_s[1] & (~delay_rdy_s[0]);
  assign rdy_o = falling_rdy_edge_s;

  // start br counter
  assign start_o = (state_s == start_br_st) ? 1 : 0;

  // generate and sample data output
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      data_s <= {uart_width{1'b0}};
    else
    begin
      if((state_s == bit0_st) && (br2_i == 1) )
	data_s[0] <= rx_i;
      if((state_s == bit1_st) && (br2_i == 1) )
	data_s[1] <= rx_i;
      if((state_s == bit2_st) && (br2_i == 1) )
	data_s[2] <= rx_i;
      if((state_s == bit3_st) && (br2_i == 1) )
	data_s[3] <= rx_i;
      if((state_s == bit4_st) && (br2_i == 1) )
	data_s[4] <= rx_i;
      if((state_s == bit5_st) && (br2_i == 1) )
	data_s[5] <= rx_i;
      if((state_s == bit6_st) && (br2_i == 1) )
	data_s[6] <= rx_i;
      if((state_s == bit7_st) && (br2_i == 1) )
	data_s[7] <= rx_i;
    end
  end // always_ff @ (posedge clk_i, posedge rst_i)

  // sync data
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      data_o <= {uart_width{1'b0}};
    else
      if(rdy_o == 1)
	data_o <= data_s;
  end
  
  
  
endmodule : as_rx
