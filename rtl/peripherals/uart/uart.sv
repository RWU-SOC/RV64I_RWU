`timescale 1ns/1ps

import as_pack::*;

module as_uart (input  logic                  clk_i,
                input  logic                  rst_i,
                input  logic                  rx_i,
                output logic                  tx_o,
                input  logic                  start_i,
                input  logic [uart_width-1:0] data_i,
                output logic [uart_width-1:0] data_o,
                output logic                  rdy_rx_o,
                output logic                  rdy_tx_o
               );

  logic br_s, br2_s, start_br_s;

  as_rx uartRx (.clk_i(clk_i),
                .rst_i(rst_i),
                .rx_i(rx_i),
                .br_i(br_s),
                .br2_i(br2_s),
                .start_o(start_br_s),
                .data_o(data_o),
                .rdy_o(rdy_rx_o));
  
  as_tx uartTx (.clk_i(clk_i),
                .rst_i(rst_i),
                .br_i(br_s),
                .start_i(start_i),
                .data_i(data_i),
                .rdy_o(rdy_tx_o),
                .tx_o(tx_o));
  
  as_br uartBr (.clk_i(clk_i),
                .rst_i(rst_i),
                .start_i(start_br_s),
                .br_o(br_s),
                .br2_o(br2_s));
  
endmodule : as_uart

