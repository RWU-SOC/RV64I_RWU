`timescale 1ns/1ps

import as_pack::*;

module as_rv64i (input  logic                   clk_i,
                 input  logic                   rst_i,
                 output logic [iaddr_width-1:0] pc_o,    // addr of instr. bus
                 input  logic [instr_width-1:0] instr_i, // data of instr. bus
                 output logic                   dMemWr_o,
                 output logic                   dMemRd_o,
                 output logic [daddr_width-1:0] aluResult_o, // addr of data bus
                 output logic [reg_width-1:0]   writeDat_o,  // data out of data bus
                 input  logic [reg_width-1:0]   readDat_i    // data in of data bus
                );


  logic [dmuxsel_width-1:0]  resultSrc_s;
  logic [immsrc_width-1:0]   immSrc_s;
  logic [aluselrv_width-1:0] aluSel_s;
  logic aluSrcA_s,aluSrcB_s,regWr_s,jump_s,zero_s,PCsrc_s;

  as_controlall control (.opcode_i(instr_i[6:0]),
                      .func3_i(instr_i[14:12]),
                      .func7b5_i(instr_i[30]),
                      .zero_i(zero_s),
                      .resultSrc_o(resultSrc_s),
                      .dMemWr_o(dMemWr_o),
                      .dMemRd_o(dMemRd_o),
                      .PCSrc_o(PCsrc_s),
                      .aluSrcB_o(aluSrcB_s),
                      .aluSrcA_o(aluSrcA_s),
                      .regWr_o(regWr_s),
                      .jump_o(jump_s), // wohin???
                      .immSrc_o(immSrc_s),
                      .aluSel_o(aluSel_s)
                      );
  as_datapath datapath (.clk_i(clk_i),
                        .rst_i(rst_i),
                        .resultSrc_i(resultSrc_s),
                        .PCSrc_i(PCsrc_s),
                        .aluSrcB_i(aluSrcB_s),
                        .aluSrcA_i(aluSrcA_s),
                        .regWr_i(regWr_s),
                        .immSrc_i(immSrc_s),
                        .aluSel_i(aluSel_s),
                        .jumpJalr_i(jump_s),
                        .zero_o(zero_s),
                        .pc_o(pc_o),
                        .instr_i(instr_i),
                        .aluResult_o(aluResult_o),
                        .writeDat_o(writeDat_o),
                        .readDat_i(readDat_i)
                       );

endmodule : as_rv64i
