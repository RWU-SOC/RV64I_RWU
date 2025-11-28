`timescale 1ns/1ps

import as_pack::*;

module as_adder (input  logic [iaddr_width-1:0] a_i,
                 input  logic [iaddr_width-1:0] b_i,
                 output logic [iaddr_width-1:0] sum_o
                );

  assign sum_o = a_i + b_i;

endmodule : as_adder

