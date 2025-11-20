`timescale 1ns/1ps

import as_pack::*;

module as_cpu (input  logic                       clk_i,
               input  logic                       rst_i,
               // Scan Chain
               output logic                       sc01_tdo_o,   // scan: serial out
               input  logic                       sc01_tdi_i,   // scan: serial in
               input  logic                       sc01_shift_i, // scan: shift enable
               input  logic                       sc01_clock_i, // scan: clock enabe
               // Instruction bus
               input  logic [instr_width-1:0]     wbiBusDataRd_i, // data out from imem
               output logic [instr_width-1:0]     wbiBusDataWr_o, // data in to imem            -- not connected
               output logic [iaddr_width-1:0]     wbiBusAddr_o,   // address for imem
               output logic                       wbiBusWe_o,     // we for mem                 -- not needed
               output logic [7:0]                 wbiBusSel_o,    // sel for mem                -- not needed
               output logic                       wbiBusStb_o,    // stb for mem                -- not needed
               input  logic                       wbiBusAck_i,    // ack for mem                -- not used
               output logic                       wbiBusCyc_o,    // cyc for mem                -- not needed
               // Data bus
               input  logic [reg_width-1:0]       wbdBusDataRd_i, // data out from dmem
               output logic [reg_width-1:0]       wbdBusDataWr_o, // data in to dmem
               output logic [daddr_width-1:0]     wbdBusAddr_o,   // address for dmem
               output logic                       wbdBusWe_o,     // we for mem
               output logic [7:0]                 wbdBusSel_o,    // sel for mem
               output logic                       wbdBusStb_o,    // stb for mem
               input  logic                       wbdBusAck_i,    // ack for mem
               output logic                       wbdBusCyc_o,    // cyc for mem
               output logic                       dMemRd_o,       // read enable for dmem ---replace
               output logic                       dMemWr_o        // write enable for dmem ---replace
              );  


  // Umbau
  logic aluSrcA_s,aluSrcB_s,regWr_s,jump_s,zero_s,PCsrc_s;
  logic [dmuxsel_width-1:0]  resultSrc_s;
  logic [immsrc_width-1:0]   immSrc_s;
  logic [aluselrv_width-1:0] aluSel_s;

  // instruction
  logic [instr_width-1:0]     iBusDataRd_s; // data out from imem
  //logic [instr_width-1:0]     iBusDataWr_s; // data in to imem            -- not connected
  logic [iaddr_width-1:0]     iBusAddr_s;   // address for imem

  // data
  logic [reg_width-1:0]       dBusDataRd_s; // data out from dmem
  logic [reg_width-1:0]       dBusDataWr_s; // data in to dmem
  logic [daddr_width-1:0]     dBusAddr_s;   // address for dmem
  logic                       dMemRd_s;     // read enable for dmem
  logic                       dMemWr_s;     // write enable for dmem

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

  logic	and_in01_s;
  logic	sc01_01_s;
  logic	sc01_02_s;
  logic	sc01_03_s;
  logic	and_in02_s;
  logic	and_out_s;
  logic	to_some_pin1_s;
  logic	to_some_pin2_s;

  // Needed delay because of synchronous output D-Mem
  //logic	regWrDel_s;
  //logic [63:0] dBusAddrDel_s;
  //logic [63:0] pcP4Del_s;
  //logic [1:0] selMux3Del_s;
  
  
  

  
  //--------------------------------------------
  // Master BPI Instruction Bus
  //--------------------------------------------
  as_master_bpi #(1, 64, 32) mInstrBpi(
                                   .rst_i(rst_i),
                                   .clk_i(clk_i),
                                   .addr_i(iBusAddr_s),
                                   .dat_from_core_i('b0),         // not connected
                                   .dat_to_core_o(iBusDataRd_s),
                                   .wr_i(1'b0),
                                   .wb_m_addr_o(wbiBusAddr_o),
                                   .wb_m_dat_i(wbiBusDataRd_i),
                                   .wb_m_dat_o(wbiBusDataWr_o),  // not connected
                                   .wb_m_we_o(wbiBusWe_o),       // not needed
                                   .wb_m_sel_o(wbiBusSel_o),     // not needed
                                   .wb_m_stb_o(wbiBusStb_o),     // not needed
                                   .wb_m_ack_i(wbiBusAck_i),     // not used
                                   .wb_m_cyc_o(wbiBusCyc_o)      // not needed
                                  );

  //--------------------------------------------
  // Master BPI Data Bus
  //--------------------------------------------
  as_master_bpi #(2, 64, 64) mDataBpi(
                                   .rst_i(rst_i),
                                   .clk_i(clk_i),
                                   .addr_i(dBusAddr_s),
                                   .dat_from_core_i(dBusDataWr_s),
                                   .dat_to_core_o(dBusDataRd_s),
                                   .wr_i(dMemWr_s),
                                   .wb_m_addr_o(wbdBusAddr_o),
                                   .wb_m_dat_i(wbdBusDataRd_i),
                                   .wb_m_dat_o(wbdBusDataWr_o),
                                   .wb_m_we_o(wbdBusWe_o),
                                   .wb_m_sel_o(wbdBusSel_o),
                                   .wb_m_stb_o(wbdBusStb_o),
                                   .wb_m_ack_i(wbdBusAck_i),
                                   .wb_m_cyc_o(wbdBusCyc_o)
                                  );
  assign dMemRd_o = dMemRd_s;
  assign dMemWr_o = dMemWr_s;

  //assign wbdBusAddr_o   = dBusAddr_s;
  //assign wbdBusDataWr_o = dBusDataWr_s;
  //assign dBusDataRd_s   = wbdBusDataRd_i;
  
  //--------------------------------------------
  // PC, Program Counter
  //--------------------------------------------
  as_pc pc (.clk_i(clk_i),
            .rst_i(rst_i),
            .PCnext_i(PCnext_s),
            .PC_o(iBusAddr_s) // PC
           );

  //--------------------------------------------
  // Adder +4 for the address of the next instruction
  //--------------------------------------------
  as_adder add4 (.a_i(iBusAddr_s), // PC
                 .b_i(64'd4),
                 .sum_o(PCp4_s)
                ); // replace 64 by constant !!!!!!!!!!

  //--------------------------------------------
  // Mux for jumps of jalr instruction or normal branches.
  //         - pc_o   : jalr
  //         - regA_s : normal branch
  //--------------------------------------------
  as_mux2 jalrmux(.d0_i(iBusAddr_s), // PC
                  .d1_i(regA_s),
                  .sel_i(jump_s),
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
                 .sel_i(PCsrc_s),
                 .y_o(PCnext_s)
                );

  //--------------------------------------------
  // Register file
  //--------------------------------------------
  //as_delay_reg #(5) wraddrdelay (clk_i, rst_i, iBusDataRd_s[11:7], regWrAddrDel_s);
  //as_delay_reg #(1) wrenabledelay (clk_i, rst_i, regWr_s, regWrDel_s);
  as_regfile regfile (.clk_i(clk_i),
                      .rst_i(rst_i),
                      .we_i(regWr_s),                  // delay
                      //.we_i(regWrDel_s),                  // delay
                      .raddr01_i(iBusDataRd_s[19:15]),
                      .raddr02_i(iBusDataRd_s[24:20]),
                      .waddr01_i(iBusDataRd_s[11:7]),  // delay
                      //.waddr01_i(regWrAddrDel_s),  // delay
                      .wdata01_i(result_s),
                      .rdata01_o(regA_s),
                      .rdata02_o(dBusDataWr_s)
                     );

  //--------------------------------------------
  // Immediate generation
  //--------------------------------------------
  as_immgen extend (.instr_i(iBusDataRd_s[instr_width-1:7]),
                    .sel_i(immSrc_s),
                    .imm_o(immExt_s)
                   );

  //--------------------------------------------
  // ALU: input mux for regB or immediate
  //--------------------------------------------
  as_mux2 alumuxB (.d0_i(dBusDataWr_s),
                   .d1_i(immExt_s),
                   .sel_i(aluSrcB_s),
                   .y_o(srcB_s)
                  );

  //--------------------------------------------
  // ALU: input mux for regA or PC
  //--------------------------------------------
  as_mux2 alumuxA (.d0_i(regA_s),
                   .d1_i(iBusAddr_s), // PC
                   .sel_i(aluSrcA_s),
                   .y_o(srcA_s)
                  );

  //--------------------------------------------
  // ALU
  //--------------------------------------------
  as_alurv alu (.data01_i(srcA_s),
                .data02_i(srcB_s),
                .aluSel_i(aluSel_s),
                .aluZero_o(zero_s),
                .aluNega_o(nega_s),
                .aluCarr_o(carry_s),
                .aluOver_o(overflow_s),
                .aluResult_o(dBusAddr_s)
               );

  //--------------------------------------------
  // Mux for aluResult, dmem or PC+4 to register file
  //--------------------------------------------
  //as_delay_reg #(64) dBusDelay (clk_i, rst_i, dBusAddr_s, dBusAddrDel_s);
  //as_delay_reg #(5) mux3SelDelay (clk_i, rst_i, resultSrc_s, selMux3Del_s);
  //as_delay_reg #(5) PC4Delay (clk_i, rst_i, PCp4_s, pcP4Del_s);
  as_mux3 dmmux (.d0_i(dBusAddr_s),    // delay
                 //.d0_i(dBusAddrDel_s),    // delay
                 .d1_i(dBusDataRd_s),
                 .d2_i(PCp4_s),        // delay
                 //.d2_i(pcP4Del_s),        // delay
                 .sel_i(resultSrc_s),  // delay
                 //.sel_i(selMux3Del_s),  // delay
                 .y_o(result_s)
                );

  //--------------------------------------------
  // Instruction decoder
  //--------------------------------------------
  as_controlall control (.opcode_i(iBusDataRd_s[6:0]),
                      .func3_i(iBusDataRd_s[14:12]),
                      .func7b5_i(iBusDataRd_s[30]),
                      .zero_i(zero_s),
                      .resultSrc_o(resultSrc_s),
                      .dMemWr_o(dMemWr_s),
                      .dMemRd_o(dMemRd_s),
                      .PCSrc_o(PCsrc_s),
                      .aluSrcB_o(aluSrcB_s),
                      .aluSrcA_o(aluSrcA_s),
                      .regWr_o(regWr_s),
                      .jump_o(jump_s),
                      .immSrc_o(immSrc_s),
                      .aluSel_o(aluSel_s)
                      );

  //--------------------------------------------
  // Test Scan Chain
  //--------------------------------------------
  //assign clk_mux_s = (sc01_clock_i == 1) ? tck_i : clk_i;
  scan_cell sc01 (clk_i, rst_i, sc01_shift_i, 1'b0, sc01_tdi_i, and_in01_s, sc01_01_s);
  scan_cell sc02 (clk_i, rst_i, sc01_shift_i, 1'b0, sc01_01_s, and_in02_s, sc01_02_s);
  assign and_out_s = and_in01_s & and_in02_s;
  scan_cell sc03 (clk_i, rst_i, sc01_shift_i, and_out_s, sc01_02_s, to_some_pin1_s, sc01_03_s);
  scan_cell sc04 (clk_i, rst_i, sc01_shift_i, 1'b0, sc01_03_s, to_some_pin2_s, sc01_tdo_o);


 
endmodule : as_cpu
