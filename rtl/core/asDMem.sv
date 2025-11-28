`timescale 1ns/1ps

import as_pack::*;

module as_dmem (input  logic                       clk_i,
                input  logic [dmem_addr_width-1:0] addr_i,
                input  logic                       wrEn_i,
                input  logic                       rdEn_i,
                input  logic [6:0]                 opcode_i,
                input  logic [2:0]                 func3_i,
                input  logic [reg_width-1:0]       data_i,
                output logic [reg_width-1:0]       data_o
               );

  (* ram_style = "distributed" *) logic [reg_width-1:0] ram_s[dmemdepth-1:0]; // MEMORY; x double words capacity
  logic [reg_width-1:0]	  dataRd_s;          // 64 bit data read from memory; before byte etc. reads
  logic [reg_width-1:0]	  dataWr_s;          // arranges sb, sh, etc. then stores to memory
  logic [7:0] byteEn_s;
  

  /*****************************************************************/
  /* Arrange for sb, sh, etc., before storing the data to the RAM. */
  /*****************************************************************/
  as_dmem_front dMemStore (.addr_i(addr_i), // maximal modulo 8 calculation
                           .wrEn_i(wrEn_i),
                           .opcode_i(opcode_i),
                           .func3_i(func3_i),
                           .dataFromRegFile_i(data_i),
                           .byteEn_o(byteEn_s),
                           .dataToMem_o(dataWr_s)
                          );
  
  /*****************************************************************/
  /* Data Memory                                                   */
  /*****************************************************************/
  as_dmem_core asDMem (.clk_i(clk_i),
                       .addr_i(addr_i[dmem_addr_width-1:3]),
                       .wrEn_i(wrEn_i),
                       .rdEn_i(rdEn_i),
                       .data_i(dataWr_s),
                       .byteEn_i(byteEn_s),
                       .data_o(dataRd_s)
                      );

  /********************************************************/
  /* Arrange for load byte, half-word, word, double word. */
  /********************************************************/
  // output decoder - logic block
  as_dmem_back dMemLoad (.addr_i(addr_i), // maximal modulo 8 calculation
                         .rdEn_i(rdEn_i),
                         .opcode_i(opcode_i),
                         .func3_i(func3_i),
                         .dataRd_i(dataRd_s),
                         .data_o(data_o)
                        );
  
endmodule : as_dmem



