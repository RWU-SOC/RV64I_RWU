`timescale 1ns/1ps

import as_pack::*;

/*****************************************************************/
/* Arrange for sb, sh, etc., before storing the data to the RAM. */
/*****************************************************************/

module as_dmem_back ( input  logic [dmem_addr_width-1:0] addr_i,
                //input  logic [11:0]                 addr_i,
                input  logic                       rdEn_i,
                input  logic [6:0]                 opcode_i,
                input  logic [2:0]                 func3_i,
                input  logic [reg_width-1:0]       dataRd_i,
                output logic [reg_width-1:0]       data_o);
  
  //parameter int dwidth = reg_width;
  parameter int awidth = dmem_addr_width;

  //logic [reg_width-1:0]	  dataw_s;              // Input data after register
  //logic [reg_width-1:0]	  ram_s[dmemdepth-1:0]; // 64 bit data read from memory; before byte etc. reads
  //logic [reg_width-1:0]	  dataWr_s;          // arranges sb, sh, etc. then stores to memory
  //logic                   we_s;              // we after register

  // needed for lb, lh, lw, ld, lbu, lhu, ...
  //assign dataw_s     = dataFromRegFile_i;
  //assign we_s        = wrEn_i;
  //assign ram_s       = dataFromMem_i;
  //assign dataToMem_o = dataWr_s;
  
  /********************************************************/
  /* Arrange for load byte, half-word, word, double word. */
  /********************************************************/
  // output decoder - logic block
  always_comb
  if (rdEn_i)
    case (opcode_i)
      7'b0000011 : case (func3_i) // func3; loads; word alligned
		     3'b000 :  if (addr_i[awidth-1:0] % 8 == 0)
                                 data_o = {{56{dataRd_i[7]}}, dataRd_i[7:0]};    // lb, byte aligned
                               else if (addr_i[awidth-1:0] % 8 == 1)
                                 data_o = {{56{dataRd_i[15]}},  dataRd_i[15:8]}; // lb, byte aligned
                               else if (addr_i[awidth-1:0] % 8 == 2)
                                 data_o = {{56{dataRd_i[23]}},  dataRd_i[23:16]}; // lb, byte aligned
                               else if (addr_i[awidth-1:0] % 8 == 3)
                                 data_o = {{56{dataRd_i[31]}},  dataRd_i[31:24]}; // lb, byte aligned
                               else if (addr_i[awidth-1:0] % 8 == 4)
                                 data_o = {{56{dataRd_i[39]}},  dataRd_i[39:32]}; // lb, byte aligned
                               else if (addr_i[awidth-1:0] % 8 == 5)
                                 data_o = {{56{dataRd_i[47]}},  dataRd_i[47:40]}; // lb, byte aligned
                               else if (addr_i[awidth-1:0] % 8 == 6)
                                 data_o = {{56{dataRd_i[55]}},  dataRd_i[55:48]}; // lb, byte aligned
                               else
                                 data_o = {{56{dataRd_i[63]}},  dataRd_i[63:56]}; // lb, byte aligned
		     3'b001 :  if (addr_i[awidth-1:1] % 4 == 0)
                                 data_o = {{48{dataRd_i[15]}}, dataRd_i[15:0]};  // lh, half-word aligned
                               else if (addr_i[awidth-1:1] % 4 == 1)
                                 data_o = {{48{dataRd_i[31]}}, dataRd_i[31:16]}; // lh, half-word aligned
                               else if (addr_i[awidth-1:1] % 4 == 2)
                                 data_o = {{48{dataRd_i[47]}}, dataRd_i[47:32]}; // lh, half-word aligned
                               else
                                 data_o = {{48{dataRd_i[63]}}, dataRd_i[63:48]}; // lh, half-word aligned
		     3'b010 :  if (addr_i[awidth-1:2] % 2 == 0)
                                 data_o = {{40{dataRd_i[31]}}, dataRd_i[31:0]};  // lw, word aligned
                               else
                                 data_o = {{40{dataRd_i[63]}}, dataRd_i[63:32]}; // lw, word aligned
                     3'b011 :  data_o = dataRd_i; // ld, double word aligned
		     3'b100 :  if (addr_i[awidth-1:0] % 8 == 0)
                                 data_o = {56'b0, dataRd_i[7:0]};  // lbu, byte aligned
                               else if (addr_i[awidth-1:0] % 8 == 1)
                                 data_o = {56'b0, dataRd_i[15:8]}; // lbu, byte aligned
                               else if (addr_i[awidth-1:0] % 8 == 2)
                                 data_o = {56'b0, dataRd_i[23:16]}; // lbu, byte aligned
                               else if (addr_i[awidth-1:0] % 8 == 3)
                                 data_o = {56'b0, dataRd_i[31:24]}; // lbu, byte aligned
                               else if (addr_i[awidth-1:0] % 8 == 4)
                                 data_o = {56'b0, dataRd_i[39:32]}; // lbu, byte aligned
                               else if (addr_i[awidth-1:0] % 8 == 5)
                                 data_o = {56'b0, dataRd_i[47:40]}; // lbu, byte aligned
                               else if (addr_i[awidth-1:0] % 8 == 6)
                                 data_o = {56'b0, dataRd_i[55:48]}; // lbu, byte aligned
                               else
                                 data_o = {56'b0, dataRd_i[63:56]}; // lbu, byte aligned
		     3'b101 :  if (addr_i[awidth-1:1] % 4 == 0)
                                 data_o = {48'b0, dataRd_i[15:0]};  // lhu, half-word aligned
                               else if (addr_i[awidth-1:1] % 4 == 1)
                                 data_o = {48'b0, dataRd_i[31:16]}; // lhu, half-word aligned
                               else if (addr_i[awidth-1:1] % 4 == 2)
                                 data_o = {48'b0, dataRd_i[47:32]}; // lhu, half-word aligned
                               else
                                 data_o = {48'b0, dataRd_i[63:48]}; // lhu, half-word aligned
		     3'b110 :  if (addr_i[awidth-1:2] % 2 == 0)
                                 data_o = {40'b0, dataRd_i[31:0]}; // lwu, word aligned
                               else
                                 data_o = {40'b0, dataRd_i[63:32]}; // lwu, word aligned
		     default : data_o = dataRd_i; // ld
                   endcase // case (func3_s)
      default : data_o = dataRd_i;
    endcase // case (opcode_s)
  else
    data_o = dataRd_i;
  
endmodule : as_dmem_back
