`timescale 1ns/1ps

import as_pack::*;

module as_alurv (input  logic [reg_width-1:0]      data01_i,
                 input  logic [reg_width-1:0]      data02_i,
                 input  logic [aluselrv_width-1:0] aluSel_i,
                 output logic                      aluZero_o,
                 output logic                      aluNega_o,
                 output logic                      aluCarr_o,
                 output logic                      aluOver_o,
                 output logic [reg_width-1:0]      aluResult_o
                );

  // double add
  //logic	aluCont1_s;              // inverted aluSel_i[1]
  logic	[reg_width-1:0] sum_s;   // sum of the adder; double
  logic [reg_width-1:0]	cinvb_s; // conditional inverted data02_i

  // word add
  logic	[31:0] sumw_s;           // sum of the adder; word
  logic [31:0] cinvbw_s;         // conditional inverted data02_i

  // shift word
  logic [31:0] sllw_s, srlw_s;
  logic signed [31:0] sraw_s, data01w_s;
  logic	sltiu_s;

  // control, flags
  logic signed [reg_width-1:0] data01_s; // must be signed for arithmetic shift
  logic signed [reg_width-1:0] data02_s; // must be signed for arithmetic shift
  logic carry_s;                 // carry of the adder; double
  logic carryw_s;                // carry of the adder; word
  logic overf_s;                 // overflow

  // double add/sub
  // if aluSel_i[0] = 0, it is an add instruction
  // => the second operand must be taken as it is
  // => the carry-in in the addition is 0
  // if aluSel_i[0] = 1, it is an sub instruction
  // => the second operand must be the 2-complement
  // => the carry-in in the addition is 1 which acts as the +1
  assign cinvb_s = aluSel_i[0] ? ~data02_i : data02_i;          // for 2comp
  assign {carry_s, sum_s}   = data01_i + cinvb_s + aluSel_i[0]; // ... carry in acts as the +1

  // word add/sub
  assign cinvbw_s = aluSel_i[0] ? ~data02_i[31:0] : data02_i[31:0];      // for 2comp
  assign {carryw_s, sumw_s}   = data01_i[31:0] + cinvbw_s + aluSel_i[0]; // ... carry in

  // control, flags, shift
  assign data01_s = data01_i;
  assign data02_s = data02_i;
  assign data01w_s = data01_i[31:0];

//Overflow occurs when the result-value affects the sign:
//– overflow when adding two positives yields a negative
//– or, adding two negatives gives a positive
//– or, subtract a negative from a positive and get a negative
//– or, subtract a positive from a negative and get a positive

//  assign overf_s = (An & Bn & (not Sn) & (not aluSel_i[0])) | ((not An) & (not Bn) & Sn & (not aluSel_i[0])) |
//                   ((not An) & Bn & Sn & aluSel_i[0])       | (An & (not Bn) & (not Sn) & aluSel_i[0])

  assign overf_s = ( data01_i[reg_width-1] & data02_i[reg_width-1] & (~sum_s[reg_width-1]) & (~aluSel_i[0]) ) |
		   ( (~data01_i[reg_width-1]) & (~data02_i[reg_width-1]) & sum_s[reg_width-1] & (~aluSel_i[0]) ) |
		   ( (~data01_i[reg_width-1]) & data02_i[reg_width-1] & sum_s[reg_width-1] & aluSel_i[0] ) |
		   ( (~data02_i[reg_width-1]) & data01_i[reg_width-1] & (~sum_s[reg_width-1]) & aluSel_i[0] );
  
  assign sllw_s = data01_i[31:0] <<  data02_i[4:0];
  assign srlw_s = data01_i[31:0] >>  data02_i[4:0];
  assign sraw_s = data01w_s >>> data02_i[4:0];
  
  always_comb
    if(data01_i < data02_i)
      sltiu_s = 1;
    else
      sltiu_s = 0;

  always_comb 
  begin
    case(aluSel_i)
      0  :       aluResult_o = sum_s;                        // ADD
      1  :       aluResult_o = sum_s;                        // SUB
      2  :       aluResult_o = data01_i & data02_i;          // AND
      3  :       aluResult_o = data01_i | data02_i;          // OR
      4  :       aluResult_o = data01_i ^ data02_i;          // XOR
      5  :       aluResult_o = {{reg_width-1{1'b0}}, sltiu_s}; // SLT (zero extended)
      6  :       aluResult_o = {{reg_width-1{1'b0}}, sltiu_s}; // SLTU (zero extended)
      8  :       aluResult_o = {{32{sraw_s[31]}},sraw_s};    // SRAW
      9  :       aluResult_o = {{32{srlw_s[31]}},srlw_s};    // SRLW
      10 :       aluResult_o = {{32{sllw_s[31]}},sllw_s};    // SLLW
      11 :       aluResult_o = {{32{sumw_s[31]}},sumw_s};    // SUBW
      12 :       aluResult_o = {{32{sumw_s[31]}},sumw_s};    // ADDW
      13 :       aluResult_o = data01_s >>> data02_i[4:0];   // SRA
      14 :       aluResult_o = data01_i >>  data02_i[4:0];   // SRL
      15 :       aluResult_o = data01_i <<  data02_i[4:0];   // SLL
      17 :       aluResult_o = sum_s;                        // SUB - BEQ
      19 :       aluResult_o = sum_s;                        // SUB - BNE
      default: aluResult_o = {reg_width{1'b0}};              // BLT, BGE, BLTU, BGEU
    endcase
  end // always_comb

  // for branches (aluZero_o not necessarily indicates a zero, but a branch)
  always_comb
  begin
    case(aluSel_i)
      17      : aluZero_o = (sum_s == 0) ? 1 : 0;           // BEQ
      19      : aluZero_o = (sum_s == 0) ? 0 : 1;           // BNE
      16      : aluZero_o = (data01_s < data02_s) ? 1 : 0;  // BLT
      18      : aluZero_o = (data01_s >= data02_s) ? 1 : 0; // BGE
      20      : aluZero_o = (data01_i < data02_i) ? 1 : 0;  // BLTU
      21      : aluZero_o = (data01_i >= data02_i) ? 1 : 0; // BGEU
      default : aluZero_o = (aluResult_o == 0) ? 1 : 0;
    endcase
  end


  //assign aluZero_o = (aluResult_o == 0) ? 1 : 0;
  assign aluNega_o = aluResult_o[reg_width-1];
  assign aluCarr_o = carry_s | carryw_s;
  assign aluOver_o = overf_s;

endmodule : as_alurv

