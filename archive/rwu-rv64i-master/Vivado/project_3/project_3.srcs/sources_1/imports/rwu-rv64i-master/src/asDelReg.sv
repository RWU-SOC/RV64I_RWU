`timescale 1ns/1ps

import as_pack::*;

module as_delay_reg #(parameter data_width = 1)
                    (input  logic clk_i,
                     input  logic rst_i,
                     input  logic [data_width-1:0] d_i,
                     output logic [data_width-1:0] d_o
                    );

  always_ff @(posedge clk_i, negedge rst_i) 
  begin
    if(rst_i == 1)
    begin
      d_o <= {data_width{1'b0}};
    end
    else
    begin
      d_o <= d_i; // nonblocking assignment
    end
  end

endmodule : as_delay_reg
