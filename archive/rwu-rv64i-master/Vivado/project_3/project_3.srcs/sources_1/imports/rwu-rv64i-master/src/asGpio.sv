`timescale 1ns/1ps

import as_pack::*;

module as_gpio ( input  logic                       rst_i,
                 input  logic                       clk_i,
                 input  logic [gpio_addr_width-1:0] addr_i,    // from BPI/WB-Bus
                 input  logic [nr_gpios-1:0]        data_i,    // from BPI/WB-Bus
                 input  logic                       en_i,
                 output logic [nr_gpios-1:0]        gpio_o,    // to Pin
                 output logic [gpio_addr_width-1:0] gpioAdr_o, // to Pin
                 output logic                       cs_o       // to Pin   
                );

  //--------------------------------------------
  // register gpio
  //--------------------------------------------
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
    begin
      gpio_o        <= 0;
      gpioAdr_o     <= 0;
      cs_o          <= 0;
    end
    else
    begin
      if (en_i == 1)
      begin
        gpio_o        <= data_i[nr_gpios-1:0];
        gpioAdr_o     <= addr_i;
        cs_o          <= en_i;
      end
      else
        cs_o          <= 0;
    end
  end // always_ff @ (posedge clk_i, posedge rst_i)
  
endmodule : as_gpio

