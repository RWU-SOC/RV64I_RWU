`timescale 1ns/1ps

import as_pack::*;

module as_cgu #(parameter cguaddr_width = 64)
              (input  logic clk_i, // external clock (Zybo: 125 MHz)
               input  logic rst_i,
               // wishbone side
               input  logic [cguaddr_width-1:0] wbdAddr_i, // 4 Bit (=> 16 register)
               input  logic [reg_width-1:0]   wbdDat_i,  // 64 Bit
               output logic [reg_width-1:0]   wbdDat_o,  // internal register
               input  logic                   wbdWe_i,   // write enable
               input  logic [wbdSel-1:0]      wbdSel_i,  // which byte is valid
               input  logic                   wbdStb_i,  // valid cycle
               output logic                   wbdAck_o,  // normal transaction
               input  logic                   wbdCyc_i,  // high for complete bus cycle
	       // I/O
	       output logic clk_bus1_o,
               output logic clk_bus2_o,
               output logic clk_qspi_o,
               output logic clk_core_o);

  //--------------------------------------------
  // Slave BPI for the CGU
  //--------------------------------------------
  as_slave_bpi #(64'h0000000000000003, cguaddr_width, reg_width) 
                            sGpioBpi(.rst_i(rst_i),          // general reset
                                     .clk_i(clk_i),          // bus clock
                                     .addr_o(),              // address to CGU kernel
                                     .dat_from_core_i('b0),  // data from CGU kernel
                                     .dat_to_core_o(),       // data to CGU kernel
                                     .wr_o(),                // we to CGU kernel
                                     .addr_i(wbdAddr_i),     // WB
                                     .dat_i(wbdDat_i),       // WB
                                     .dat_o(wbdDat_o),       // WB
                                     .we_i(wbdWe_i),         // WB
                                     .sel_i(wbdSel_i),       // WB
                                     .stb_i(wbdStb_i),       // WB
                                     .ack_o(wbdAck_o),       // WB
                                     .cyc_i(wbdCyc_i)        // WB
                                    );

  
  //--------------------------------------------
  // CGU
  //--------------------------------------------
  as_cgucore CGUCore (.clk_i(clk_i),
                      .rst_i(rst_i),
                      .clk_bus1_o(clk_bus1_o),
                      .clk_bus2_o(clk_bus2_o),
                      .clk_qspi_o(clk_qspi_o),
                      .clk_core_o(clk_core_o)
                     );
  
endmodule : as_cgu
