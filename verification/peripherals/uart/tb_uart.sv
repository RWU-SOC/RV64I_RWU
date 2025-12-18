`timescale 1ns/1ps

import as_pack::*;

module tb_uart ();
  parameter clk_2_t = 4;

  logic clk_s;
  logic	rst_s;
  logic	rx_s, tx_s, start_s, rdy_rx_s, rdy_tx_s;
  logic [uart_width-1:0] datai_s, datao_s;

  // reset
  initial
  begin
    rst_s <= 1; #(10*2*clk_2_t); rst_s <= 0;
  end

  // clock
  always
  begin
    clk_s <= 1; #clk_2_t; clk_s <= 0; #clk_2_t; 
  end
  
  as_uart DUT (.clk_i(clk_s),
                .rst_i(rst_s),
                .rx_i(rx_s),
                .tx_o(tx_s),
                .start_i(start_s),
                .data_i(datai_s),
                .data_o(datao_s),
                .rdy_rx_o(rdy_rx_s),
                .rdy_tx_o(rdy_tx_s)
               );

  initial
  begin
    // wait for reset done
    datai_s = 8'b00000000;
    start_s = 0;
    rx_s    = 1; #(12*2*clk_2_t);
    
    // TX
    datai_s = 8'b01010101; #(1*2*clk_2_t);
    start_s = 1; #(1*2*clk_2_t);
    start_s = 0; #(1*2*clk_2_t);
    #104000;
    #104000;
    #104000;
    #104000;
    #104000;
    #104000;
    #104000;
    #104000;
    #104000;
    #104000;
    #104000;
    #104000;

    // RX
    rx_s    = 0; #104000;
    rx_s    = 1; #104000;
    rx_s    = 1; #104000;
    rx_s    = 0; #104000;
    rx_s    = 0; #104000;
    rx_s    = 1; #104000;
    rx_s    = 0; #104000;
    rx_s    = 1; #104000;
    rx_s    = 0; #104000;
    rx_s    = 1; #104000;
    rx_s    = 1; #104000;
    #104000;
    
    $stop;
  end
  
endmodule : tb_uart

