`timescale 1ns/1ps

import as_pack::*;

module as_tx (input  logic                  clk_i,
              input  logic                  rst_i,
              input  logic                  br_i,
              input  logic                  start_i,
              input  logic [uart_width-1:0] data_i,
              output logic                  rdy_o,
              output logic                  tx_o
             );
  typedef enum logic [3:0] {idle_st, wait_st, start_st,
                      bit0_st, bit1_st, bit2_st, bit3_st,
                      bit4_st, bit5_st, bit6_st, bit7_st, stop_st} statetype_t;
  statetype_t state_s, nextstate_s;
  logic rdy_s;
  logic [uart_width-1:0] data_s;
  logic [1:0] delay_rdy_s;
  logic falling_edge_s;
  
  // store data input
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      data_s <= {uart_width{1'b0}};
    else
      if(start_i == 1)
        data_s <= data_i;
  end
  
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
      idle_st  :  if(start_i == 1)
                    nextstate_s = wait_st;
      wait_st  :  if(br_i == 1)
                    nextstate_s = start_st;
      start_st :  if(br_i == 1)
                    nextstate_s = bit0_st;
      bit0_st  :  if(br_i == 1)
                    nextstate_s = bit1_st;
      bit1_st  :  if(br_i == 1)
                    nextstate_s = bit2_st;
      bit2_st  :  if(br_i == 1)
                    nextstate_s = bit3_st;
      bit3_st  :  if(br_i == 1)
                    nextstate_s = bit4_st;
      bit4_st  :  if(br_i == 1)
                    nextstate_s = bit5_st;
      bit5_st  :  if(br_i == 1)
                    nextstate_s = bit6_st;
      bit6_st  :  if(br_i == 1)
                    nextstate_s = bit7_st;
      bit7_st  :  if(br_i == 1)
                    nextstate_s = stop_st;
      stop_st  :  if(br_i == 1)
                    nextstate_s = idle_st;
      default:    nextstate_s = idle_st;
    endcase
  end // always_comb

  // FSM block 3: output CLC
  always_comb
  begin
    if( (state_s == stop_st) | (state_s == wait_st) | (state_s == idle_st) )
      tx_o = 1;
    else if(state_s == start_st)
      tx_o = 0;
    else if(state_s == bit0_st)
      tx_o = data_s[0];
    else if(state_s == bit1_st)
      tx_o = data_s[1];
    else if(state_s == bit2_st)
      tx_o = data_s[2];
    else if(state_s == bit3_st)
      tx_o = data_s[3];
    else if(state_s == bit4_st)
      tx_o = data_s[4];
    else if(state_s == bit5_st)
      tx_o = data_s[5];
    else if(state_s == bit6_st)
      tx_o = data_s[6];
    else if(state_s == bit7_st)
      tx_o = data_s[7];
    else
      tx_o = 1;
  end // always_comb

  // generate rdy
  assign rdy_s = (state_s == stop_st) ? 1 : 0;
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
  assign falling_edge_s = delay_rdy_s[1] & (~delay_rdy_s[0]);
  assign rdy_o = falling_edge_s;
  
endmodule : as_tx
