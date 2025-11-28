`timescale 1ns/1ps

import as_pack::*;

module as_mux3 (input  logic [reg_width-1:0] d0_i,
                input  logic [reg_width-1:0] d1_i,
                input  logic [reg_width-1:0] d2_i,
                input  logic [1:0]           sel_i,
                output logic [reg_width-1:0] y_o);

  assign y_o = sel_i[1] ? d2_i : (sel_i[0] ? d1_i : d0_i);
                    
endmodule : as_mux3
