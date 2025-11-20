`timescale 1ns/1ps

import as_pack::*;

module as_datapath (input  logic                      clk_i,
                    input  logic                      rst_i,
                    input  logic [dmuxsel_width-1:0]  resultSrc_i,
                    input  logic                      PCSrc_i,
                    input  logic                      aluSrcB_i,
                    input  logic                      aluSrcA_i,
                    input  logic                      regWr_i,
                    input  logic [immsrc_width-1:0]   immSrc_i,
                    input  logic [aluselrv_width-1:0] aluSel_i,
                    input  logic                      jumpJalr_i,
                    output logic                      zero_o,
                    output logic [iaddr_width-1:0]    pc_o,
                    input  logic [instr_width-1:0]    instr_i,
                    output logic [daddr_width-1:0]    aluResult_o,
                    output logic [reg_width-1:0]      writeDat_o,
                    input  logic [reg_width-1:0]      readDat_i);



  // PC
  logic [iaddr_width-1:0] PCnext_s; // next PC
  logic [iaddr_width-1:0] PCp4_s;   // linear code
  logic [iaddr_width-1:0] PCbr_s;   // branch target; PCTarget
  logic	[iaddr_width-1:0] PCorRS1_s;
  // Immediate extention
  logic [reg_width-1:0] immExt_s;
  // Register file
  logic [reg_width-1:0] srcA_s, regA_s;
  logic [reg_width-1:0] srcB_s;
  // D-Mem
  logic [reg_width-1:0] result_s;
  // ALU
  logic                 nega_s,carry_s,overflow_s;

  //--------------------------------------------
  // PC, Program Counter
  //--------------------------------------------
  as_pc pc (.clk_i(clk_i),
            .rst_i(rst_i),
            .PCnext_i(PCnext_s),
            .PC_o(pc_o)
           );

  //--------------------------------------------
  // Adder +4 for the address of the next instruction
  //--------------------------------------------
  as_adder add4 (.a_i(pc_o),
                 .b_i(64'd4),
                 .sum_o(PCp4_s)
                ); // replace 64 by constant !!!!!!!!!!

  //--------------------------------------------
  // Mux for jumps of jalr instruction or normal branches.
  //         - pc_o   : jalr
  //         - regA_s : normal branch
  //--------------------------------------------
  as_mux2 jalrmux(.d0_i(pc_o),
                  .d1_i(regA_s),
                  .sel_i(jumpJalr_i),
                  .y_o(PCorRS1_s)
                 );

  //--------------------------------------------
  // Adder for the branch targets
  //--------------------------------------------
  as_adder addbranch (.a_i(PCorRS1_s),
                      .b_i(immExt_s),
                      .sum_o(PCbr_s)
                     );

  //--------------------------------------------
  // Mux for the PC, either +4 or branch target
  //--------------------------------------------
  as_mux2 pcmux (.d0_i(PCp4_s),
                 .d1_i(PCbr_s),
                 .sel_i(PCSrc_i),
                 .y_o(PCnext_s)
                );

  //--------------------------------------------
  // Register file
  //--------------------------------------------
  as_regfile regfile (.clk_i(clk_i),
                      .rst_i(rst_i),
                      .we_i(regWr_i),
                      .instr_i(instr_i),
                      .wdata01_i(result_s),
                      .rdata01_o(regA_s),
                      .rdata02_o(writeDat_o)
                     );

  //--------------------------------------------
  // Immediate generation
  //--------------------------------------------
  as_immgen extend (.instr_i(instr_i),
                    .sel_i(immSrc_i),
                    .imm_o(immExt_s)
                   );

  //--------------------------------------------
  // ALU: input mux for regB or immediate
  //--------------------------------------------
  as_mux2 alumuxB (.d0_i(writeDat_o),
                   .d1_i(immExt_s),
                   .sel_i(aluSrcB_i),
                   .y_o(srcB_s)
                  );

  //--------------------------------------------
  // ALU: input mux for regA or PC
  //--------------------------------------------
  as_mux2 alumuxA (.d0_i(regA_s),
                   .d1_i(pc_o),
                   .sel_i(aluSrcA_i),
                   .y_o(srcA_s)
                  );
   
  //--------------------------------------------
  // ALU
  //--------------------------------------------
  as_alurv alu (.data01_i(srcA_s),
                .data02_i(srcB_s),
                .aluSel_i(aluSel_i),
                .aluZero_o(zero_o),
                .aluNega_o(nega_s),
                .aluCarr_o(carry_s),
                .aluOver_o(overflow_s),
                .aluResult_o(aluResult_o)
               );

  //--------------------------------------------
  // Mux for aluResult, dmem or PC+4 to register file
  //--------------------------------------------
  as_mux3 dmmux (.d0_i(aluResult_o),
                 .d1_i(readDat_i),
                 .d2_i(PCp4_s),
                 .sel_i(resultSrc_i),
                 .y_o(result_s)
                );

endmodule : as_datapath

