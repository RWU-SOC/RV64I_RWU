/* 
   opcode       || resSrc | dMemWr | dMemRd | bran | aluSrcB | aluSrcA | regWr | jump | immSrc  | aluOp | Meaning
   --------------------------------------------------------------------------------------------------------------
   0000011 (  3)||  01    |  0     |  1     |  0   |  1      |    0    |  1    |  0   |  000    |  xx   | I-type, lw - all
   0010011 ( 19)||  00    |  0     |  0     |  0   |  1      |    0    |  1    |  0   |  000    |  xx   | I-type, ALU
   0010111 ( 23)||  00    |  0     |  0     |  0   |  1      |    1    |  1    |  0   |  100    |  xx   | U-type, auipc
   0011011 ( 27)||  00    |  0     |  0     |  0   |  1      |    0    |  1    |  0   |  000    |  xx   | I-type, 64 bit
   0100011 ( 35)||  00    |  1     |  0     |  0   |  1      |    0    |  0    |  0   |  001    |  xx   | S-type, sw - all
   0110011 ( 51)||  00    |  0     |  0     |  0   |  0      |    0    |  1    |  0   |  xxx    |  xx   | R-type, add, sub, 
   0110111 ( 55)||  00    |  0     |  0     |  0   |  1      |    0    |  1    |  0   |  100    |  xx   | U-type, lui
   0111011 ( 59)||  00    |  0     |  0     |  0   |  0      |    0    |  1    |  0   |  xxx    |  xx   | R-type, 64 bit
   1100011 ( 99)||  00    |  0     |  0     |  1   |  0      |    0    |  0    |  0   |  010    |  xx   | B-type, beq
   1100111 (103)||  10    |  0     |  0     |  0   |  0      |    0    |  1    |  1   |  000    |  xx   | I-type, jalr
   1101111 (111)||  10    |  0     |  0     |  0   |  0      |    0    |  1    |  1   |  011    |  xx   | J-type, jal
 
*/


/* branch | zero | jump || PCSrc | Meaning
   ---------------------------------------
     0    |  0   |  0   ||  0    | next instr
     0    |  0   |  1   ||  1    | jump
     0    |  1   |  0   ||  0    | next instr, calculation is zero
     0    |  1   |  1   ||  1    | jump, calculation is zero
     1    |  0   |  0   ||  0    | next instr, cond branch - not taken
     1    |  0   |  1   ||  1    | jump, cond branch - not taken
     1    |  1   |  0   ||  1    | cond branch - taken
     1    |  1   |  1   ||  1    | cond branch - taken, jump
 
*/
`timescale 1ns/1ps

import as_pack::*;

module as_controlall (input logic [opcode_width-1:0]	opcode_i,    // opcode field
                      input logic [func3_width-1:0]	func3_i,     // func3 field
                      input logic			func7b5_i,   // bit 5 of func7 field
                      input logic			zero_i,      // don't use for pipeline solution
                      output logic [dmuxsel_width-1:0]	resultSrc_o, // Mux behind DMem
                      output logic			dMemWr_o,    // D-Mem write enable
                      output logic			dMemRd_o,    // D-Mem read enable; almost not needed anymore
                      output logic			PCSrc_o,     // don't use for pipeline solution
                      output logic			aluSrcB_o,   // Mux in front of ALU
                      output logic			aluSrcA_o,   // Mux in front of ALU
                      output logic			regWr_o,     // Register file write enable
                      output logic			jump_o,      // Src for branch target mux: register or PC as input for branch target adder
                      output logic [immsrc_width-1:0]	immSrc_o,    // Selects, how the immediate value will be generated
                      output logic [aluselrv_width-1:0]	aluSel_o,    // ALU control
		      output logic			branch_s_o,  // only for pipeline solution
		      output logic                      jump_s_o     // only for pipeline solution
                     );
// In case of add or sub, the lsb must be 0 for ADD and 1 for SUB.
/* aluSel_o[0]: ADD or SUB (2comp), carry_in
   aluSel_o[1]: somehow in overflow calculation; 1 -> ovl could not be; 0 -> ovl could be
   aluSel_o = 00000 : ADD, ADDI;   works
   aluSel_o = 00001 : SUB;         works
   aluSel_o = 00010 : AND, ANDI;   works
   aluSel_o = 00011 : OR, ORI;     works
   aluSel_o = 00100 : XOR, XORI;   works
   aluSel_o = 00101 : SLT, SLTI;   works
   aluSel_o = 00110 : SLTU, SLTIU; works
   aluSel_o = 00111 :
   aluSel_o = 01000 : SRAW, SRAIW; works
   aluSel_o = 01001 : SRLW, SRLIW; works
   aluSel_o = 01010 : SLLW, SLLIW; works
   aluSel_o = 01011 : SUBW;        works
   aluSel_o = 01100 : ADDW;        works
   aluSel_o = 01101 : SRA, SRAI;   works
   aluSel_o = 01110 : SRL, SRLI;   works
   aluSel_o = 01111 : SLL, SLLI;   works
   aluSel_o = 10000 : BLT;
   aluSel_o = 10001 : BEQ;
   aluSel_o = 10010 : BGE
   aluSel_o = 10011 : BNE;
   aluSel_o = 10100 : BLTU;
   aluSel_o = 10101 : BGEU;
   aluSel_o = 10110 :
   aluSel_o = 10111 :
   aluSel_o = 11000 : 
   aluSel_o = 11001 : 
   aluSel_o = 11010 : 
   aluSel_o = 11011 : 
   aluSel_o = 11100 : 
   aluSel_o = 11101 : 
   aluSel_o = 11110 : 
   aluSel_o = 11111 : 
 */

                    /*regWr_o     = 1;                         // Write to register file:       Yes [d3]
                    immSrc_o    = 3'b000;                      // Instruction format:           I-type
                    aluSrcB_o   = 1;                           // Second register or immediate: immediate
                    aluSrcA_o   = 0;                           // First register or PC:         register
                    dMemWr_o    = 0;                           // Write to D-Mem:               No
                    dMemRd_o    = 1;                           // Read from D-Mem:              Yes
                    resultSrc_o = 2'b01;                       // Mux behind D-Mem:             D-Mem to RegFile
                    branch_s    = 0;                           // Branch:                       No
                    jump_s      = 0;                           // Only for jalr, jal*/
  
                    /*regWr_o     = 1;                         // Write to register file:       Yes [d19]
                    immSrc_o    = 3'b000;                      // Instruction format:           I-type
                    aluSrcB_o   = 1;                           // Second register or immediate: immediate
                    aluSrcA_o   = 0;                           // First register or PC:         register
                    dMemWr_o    = 0;                           // Write to D-Mem:               No
                    dMemRd_o    = 0;                           // Read from D-Mem:              No
                    resultSrc_o = 2'b00;                       // Mux behind D-Mem:             ALU result to RegFile
                    branch_s    = 0;                           // Branch:                       No
                    jump_s      = 0;                           // Only for jalr, jal*/
  
                    /*regWr_o     = 1;                         // Write to register file:       Yes [d23]
                    immSrc_o    = 3'b100;                      // Instruction format:           U-type, lui, auipc
                    aluSrcB_o   = 1;                           // Second register or immediate: immediate
                    aluSrcA_o   = 1;                           // First register or PC:         PC
                    dMemWr_o    = 0;                           // Write to D-Mem:               No
                    dMemRd_o    = 0;                           // Read from D-Mem:              No
                    resultSrc_o = 2'b00;                       // Mux behind D-Mem:             ALU result to RegFile
                    branch_s    = 0;                           // Branch:                       No
                    jump_s      = 0;                           // Only for jalr, jal*/
  
                    /*regWr_o     = 1;                         // Write to register file:       Yes [d27]
                    immSrc_o    = 3'b000;                      // Instruction format:           I-type
                    aluSrcB_o   = 1;                           // Second register or immediate: immediate
                    aluSrcA_o   = 0;                           // First register or PC:         register
                    dMemWr_o    = 0;                           // Write to D-Mem:               No
                    dMemRd_o    = 0;                           // Read from D-Mem:              No
                    resultSrc_o = 2'b00;                       // Mux behind D-Mem:             ALU result to RegFile
                    branch_s    = 0;                           // Branch:                       No
                    jump_s      = 0;                           // Only for jalr, jal*/
  
                    /*regWr_o     = 0;                         // Write to register file:       No [d35]
                    immSrc_o    = 3'b001;                      // Instruction format:           S-type
                    aluSrcB_o   = 1;                           // Second register or immediate: immediate
                    aluSrcA_o   = 0;                           // First register or PC:         register
                    dMemWr_o    = 1;                           // Write to D-Mem:               Yes
                    dMemRd_o    = 0;                           // Read from D-Mem:              No
                    resultSrc_o = 2'b00;                       // Mux behind D-Mem:             ALU result to RegFile
                    branch_s    = 0;                           // Branch:                       No
                    jump_s      = 0;                           // Only for jalr, jal*/
  
                    /*regWr_o     = 1;                         // Write to register file:       Yes [d51]
                    immSrc_o    = 3'bxxx;                      // Instruction format:           R-type, no immediate needed
                    aluSrcB_o   = 0;                           // Second register or immediate: register
                    aluSrcA_o   = 0;                           // First register or PC:         register
                    dMemWr_o    = 0;                           // Write to D-Mem:               No
                    dMemRd_o    = 0;                           // Read from D-Mem:              No
                    resultSrc_o = 2'b00;                       // Mux behind D-Mem:             ALU result to RegFile
                    branch_s    = 0;                           // Branch:                       No
                    jump_s      = 0;                           // Only for jalr, jal*/
  
                    /*regWr_o     = 1;                         // Write to register file:       Yes [d55]
                    immSrc_o    = 3'b100;                      // Instruction format:           U-type, lui, auipc
                    aluSrcB_o   = 1;                           // Second register or immediate: immediate
                    aluSrcA_o   = 0;                           // First register or PC:         register
                    dMemWr_o    = 0;                           // Write to D-Mem:               No
                    dMemRd_o    = 0;                           // Read from D-Mem:              No
                    resultSrc_o = 2'b00;                       // Mux behind D-Mem:             ALU result to RegFile
                    branch_s    = 0;                           // Branch:                       No
                    jump_s      = 0;                           // Only for jalr, jal*/

                    /*regWr_o     = 1;                         // Write to register file:       Yes [d59]
                    immSrc_o    = 3'bxxx;                      // Instruction format:           R-type, no immediate needed
                    aluSrcB_o   = 0;                           // Second register or immediate: register
                    aluSrcA_o   = 0;                           // First register or PC:         register
                    dMemWr_o    = 0;                           // Write to D-Mem:               No
                    dMemRd_o    = 0;                           // Read from D-Mem:              No
                    resultSrc_o = 2'b00;                       // Mux behind D-Mem:             ALU result to RegFile
                    branch_s    = 0;                           // Branch:                       No
                    jump_s      = 0;                           // Only for jalr, jal*/

                    /*regWr_o     = 0;                         // Write to register file:       No [d99]
                    immSrc_o    = 3'b010;                      // Instruction format:           B-type
                    aluSrcB_o   = 0;                           // Second register or immediate: register
                    aluSrcA_o   = 0;                           // First register or PC:         register
                    dMemWr_o    = 0;                           // Write to D-Mem:               No
                    dMemRd_o    = 0;                           // Read from D-Mem:              No
                    resultSrc_o = 2'b00;                       // Mux behind D-Mem:             ALU result to RegFile
                    branch_s    = 1;                           // Branch:                       Yes
                    jump_s      = 0;                           // Only for jalr, jal*/

                    /*regWr_o     = 1;                         // Write to register file:       Yes [d103]
                    immSrc_o    = 3'b000;                      // Instruction format:           I-type
                    aluSrcB_o   = 1;                           // Second register or immediate: immediate
                    aluSrcA_o   = 0;                           // First register or PC:         register
                    dMemWr_o    = 0;                           // Write to D-Mem:               No
                    dMemRd_o    = 0;                           // Read from D-Mem:              No
                    resultSrc_o = 2'b10;                       // Mux behind D-Mem:             D-Mem to RegFile
                    branch_s    = 0;                           // Branch:                       No
                    jump_s      = 1;                           // Only for jalr, jal*/

                    /*regWr_o     = 1;                         // Write to register file:       Yes [d111]
                    immSrc_o    = 3'b011;                      // Instruction format:           J-type
                    aluSrcB_o   = 0;                           // Second register or immediate: register
                    aluSrcA_o   = 0;                           // First register or PC:         register
                    dMemWr_o    = 0;                           // Write to D-Mem:               No
                    dMemRd_o    = 0;                           // Read from D-Mem:              No
                    resultSrc_o = 2'b10;                       // Mux behind D-Mem:             D-Mem to RegFile
                    branch_s    = 0;                           // Branch:                       No
                    jump_s      = 1;                           // Only for jalr, jal*/

  

  logic                        branch_s;        // Identifies a branch instruction from opcode
  logic                        zero_s;          // Is equal to zero_i; comes from ALU
  logic                        jump_s;          // Identifies jalr and jal from opcode
  logic [controls01_width-1:0] controls_s;      // Concatenates all controls
  logic                        rTypeSubtract_s; // Subtraction to be activated or addition

  // Concatenate controls
  assign {regWr_o,immSrc_o,aluSrcB_o,aluSrcA_o,dMemWr_o,dMemRd_o,resultSrc_o,branch_s,jump_s} = controls_s;

  // Distinguish between add and sub
  assign rTypeSubtract_s = func7b5_i & opcode_i[5];

  // Determines, what the next address should be: +4 or branch target.
  // 1 -> branch: if branch instr and zero flag
  // 1 -> branch: if jal/jalr (jump_s)
  // 0 -> no branch: else
  assign zero_s = zero_i;
  assign PCSrc_o = (branch_s & zero_s) | jump_s;
  
  // Only for pipeline; needed purely there
  assign branch_s_o = branch_s;
  assign jump_s_o = jump_s;

  // Only for jalr. jump_s = 1 AND immSrc = "000"
  assign jump_o = jump_s & (~immSrc_o[0]) & (~immSrc_o[1]) & (~immSrc_o[2]); // for jalr; immSrc = 000

  always_comb 
  begin
    unique case(opcode_i)
      3 :         begin // d3
                    controls_s  = 14'b1_000_1_0_0_1_01_0_0;    // I-type loads
                    aluSel_o    = 5'b00000;                    // ADD
                  end
      19 :        begin // d19
                    controls_s = 14'b1_000_1_0_0_0_00_0_0;     // I-type, ALU
                    case(func3_i)
                      0      : if(rTypeSubtract_s)
                                 aluSel_o = 5'b00001;          // SUBI (not existant)
                               else
                                 aluSel_o = 5'b00000;          // ADDI
                      1      : aluSel_o = 5'b01111;            // SLLI
                      2      : aluSel_o = 5'b00101;            // SLTI
                      3      : aluSel_o = 5'b00110;            // SLTIU
                      5      : if (func7b5_i == 0)
                                 aluSel_o = 5'b01110;          // SRLI
                               else
                                 aluSel_o = 5'b01101;          // SRAI
                      4      : aluSel_o = 5'b00100;            // XORI
                      3'b110 : aluSel_o = 5'b00011;            // ORI
                      3'b111 : aluSel_o = 5'b00010;            // ANDI
                      default: aluSel_o = 5'b00000;
                    endcase
                  end
      23 :        begin // 23
                    controls_s  = 14'b1_100_1_1_0_0_00_0_0;    // U-type, auipc
                    aluSel_o    = 5'b00000;                    // ADD
                  end
      27 :        begin // 27
                    controls_s = 14'b1_000_1_0_0_0_00_0_0;     // I-type, ALU WORD
                    case(func3_i)
                      0      : if (rTypeSubtract_s)
                                 aluSel_o = 5'b01011;          // SUBIW (not existant)
                               else
                                 aluSel_o = 5'b01100;          // ADDIW
                      1      : aluSel_o = 5'b01010;            // SLLIW
                      5      : if (func7b5_i == 0)
                                 aluSel_o = 5'b01001;          // SRLIW
                               else
                                 aluSel_o = 5'b01000;          // SRAIW
                      default: aluSel_o   = 5'b00000;
                    endcase
                  end
      35 :        begin // d35
                    controls_s = 14'b0_001_1_0_1_0_00_0_0;     // S-type stores
                    aluSel_o   = 5'b00000;                     // ADD
                  end
      51 :        begin // d51
                    controls_s = 14'b1_000_0_0_0_0_00_0_0;    // R-type; RV32I
                    case(func3_i)
                      0      : if (rTypeSubtract_s)
                                 aluSel_o = 5'b00001;         // SUB
                               else
                                 aluSel_o = 5'b00000;         // ADD
                      1      : aluSel_o = 5'b01111;           // SLL
                      2      : aluSel_o = 5'b00101;           // SLT
                      3      : aluSel_o = 5'b00110;           // SLTU
                      5      : if (func7b5_i == 0)
                                 aluSel_o = 5'b01110;         // SRL
                               else
                                 aluSel_o = 5'b01101;         // SRA
                      4      : aluSel_o = 5'b00100;           // XOR
                      3'b110 : aluSel_o = 5'b00011;           // OR
                      3'b111 : aluSel_o = 5'b00010;           // AND
                      default: aluSel_o = 5'b00000;
                    endcase
                  end
      55 :        begin
                    controls_s = 14'b1_100_1_0_0_0_00_0_0;    // U-type, lui
                    aluSel_o   = 5'b00000;                    // ADD
                  end
      59 :        begin // d59
                    controls_s = 14'b1_000_0_0_0_0_00_0_0;    // R-type; RV64I
                    case(func3_i)
                      0      : if (rTypeSubtract_s)
                                 aluSel_o = 5'b01011;         // SUBW
                               else
                                 aluSel_o = 5'b01100;         // ADDW
                      1      : aluSel_o = 5'b01010;           // SLLW
                      5      : if (func7b5_i == 0)
                                 aluSel_o = 5'b01001;         // SRLW
                               else
                                 aluSel_o = 5'b01000;         // SRAW
                      default: aluSel_o   = 5'b00000;
                    endcase
                  end
      99 :        begin // d99
                    controls_s = 14'b0_010_0_0_0_0_00_1_0;     // B-type, beq
                    case(func3_i)
                      0       : begin                          // beq
                                  aluSel_o   = 5'b10001;       // SUB
                                end
                      1       : begin                          // bne
                                  aluSel_o   = 5'b10011;       // SUB
                                end
                      4       : begin                          // blt
                                  aluSel_o   = 5'b10000;       // <
                                end
                      5       : begin                          // bge
                                  aluSel_o   = 5'b10010;       // >=
                                end
                      6       : begin                          // bltu
                                  aluSel_o   = 5'b10100;       // <
                                end
                      7       : begin                          // bgeu
                                  aluSel_o   = 5'b10101;       // >=
                                end
                      default : begin
                                  aluSel_o   = 5'b00000;
                                end
                    endcase;
                  end
      103 :       begin
                    controls_s = 14'b1_000_1_0_0_0_10_0_1;     // I-Type jalr
                    aluSel_o   = 5'b00000;                     // ADD
                  end
      7'b1101111: begin // d111
                    controls_s = 14'b1_011_0_0_0_0_10_0_1;     // J-Type jal
                    aluSel_o   = 5'b00000;                     // ADD
                  end
      default:    begin
                    controls_s = 14'b0_000_0_0_0_0_00_0_0;
                    aluSel_o   = 5'b00000;
                  end
    endcase
  end

endmodule : as_controlall
