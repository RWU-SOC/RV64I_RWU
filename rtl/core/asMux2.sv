`timescale 1ns/1ps

import as_pack::*;

module as_mux2 (input  logic [reg_width-1:0] d0_i,
                input  logic [reg_width-1:0] d1_i,
                input  logic                 sel_i,
                output logic [reg_width-1:0] y_o);

  assign y_o = sel_i ? d1_i : d0_i;
                    
endmodule : as_mux2
