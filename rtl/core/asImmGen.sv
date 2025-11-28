import as_pack::*;

`timescale 1ns/1ps

module as_immgen (input  logic [instr_width-1:7]  instr_i,
                  input  logic [immsrc_width-1:0] sel_i,
                  output logic [reg_width-1:0]    imm_o
                 );

  always_comb
    case(sel_i)
      // I-type:         sign ext,       immediate (12b)
      0 : imm_o = {{52{instr_i[31]}},instr_i[31:20]};
      // S-type:         sign ext,       immediate1 (7), immediate2 (5)
      1 : imm_o = {{52{instr_i[31]}},instr_i[31:25],instr_i[11:7]};
      // B-type:         sign ext,        imm1 (1), immediate2 (6),immediate3 (4), *2
      2 : imm_o = {{52{instr_i[31]}},instr_i[7],instr_i[30:25],instr_i[11:8],1'b0};
      // J-type:         sign ext,       immediate1 (8),imm2 (1),   immediate3 (10),  *2
      3 : imm_o = {{44{instr_i[31]}},instr_i[19:12],instr_i[20],instr_i[30:21],1'b0};
      // U-type      sign ext.         imm            zero
      4 : imm_o = {{32{instr_i[31]}}, instr_i[31:12], 12'b0}; // lui, auipc
      default: imm_o = {reg_width{1'b0}};
    endcase
                  
endmodule : as_immgen

