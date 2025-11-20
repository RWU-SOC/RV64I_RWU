`timescale 1ns/1ps

import as_pack::*;

/*****************************************************************/
/* Arrange for sb, sh, etc., before storing the data to the RAM. */
/*****************************************************************/

module as_dmem_front ( input logic [dmem_addr_width-1:0] addr_i,
                       //input  logic [2:0]                addr_i,
                       input logic			 wrEn_i,
                       input logic [6:0]		 opcode_i,
                       input logic [2:0]		 func3_i,
                       input logic [reg_width-1:0]	 dataFromRegFile_i,
                       output logic [7:0]		 byteEn_o,
                       output logic [reg_width-1:0]	 dataToMem_o);
  
  parameter int dwidth = reg_width;
  parameter int awidth = dmem_addr_width;

  logic [reg_width-1:0]	  dataw_s;              // Input data after register
  //logic [reg_width-1:0]	  ram_s[dmemdepth-1:0]; // 64 bit data read from memory; before byte etc. reads
  logic [reg_width-1:0]	  dataWr_s;          // arranges sb, sh, etc. then stores to memory
  logic                   we_s;              // we after register

  // needed for lb, lh, lw, ld, lbu, lhu, ...
  assign dataw_s     = dataFromRegFile_i;
  assign we_s        = wrEn_i;
  //assign ram_s       = dataFromMem_i;
  assign dataToMem_o = dataWr_s;

  /*****************************************************************/
  /* Arrange for sb, sh, etc., before storing the data to the RAM. */
  /*****************************************************************/
  // input decoder - logic block
  always_comb
    if(we_s)
      case (opcode_i)
        7'b0100011 : case (func3_i) // func3; stores
                       3'b000  : if (addr_i[awidth-1:0] % 8 == 0)
                                 begin
                                   dataWr_s[7:0]    = dataw_s[7:0];  // sb, byte aligned
                                   //dataWr_s[63:8]   = dataFromMem_i[addr_i[awidth-1:3]][63:8];
                                   dataWr_s[63:8]   = 0;
				   byteEn_o         = 8'b00000001;
                                 end
                                 else if (addr_i[awidth-1:0] % 8 == 1)
                                 begin
                                   //dataWr_s[7:0]    = dataFromMem_i[addr_i[awidth-1:3]][7:0];
                                   dataWr_s[7:0]    = 0;
                                   dataWr_s[15:8]   = dataw_s[7:0];  // sb, byte aligned
                                   //dataWr_s[63:16]  = dataFromMem_i[addr_i[awidth-1:3]][63:16];
                                   dataWr_s[63:16]  = 0;
				   byteEn_o         = 8'b00000010;
                                 end
                                 else if (addr_i[awidth-1:0] % 8 == 2)
                                 begin
                                   //dataWr_s[15:0]   = dataFromMem_i[addr_i[awidth-1:3]][15:0];
                                   dataWr_s[15:0]   = 0;
                                   dataWr_s[23:16]  = dataw_s[7:0];  // sb, byte aligned
                                   //dataWr_s[63:24]  = dataFromMem_i[addr_i[awidth-1:3]][63:24];
                                   dataWr_s[63:24]  = 0;
				   byteEn_o         = 8'b00000100;
                                 end
                                 else if (addr_i[awidth-1:0] % 8 == 3)
                                 begin
                                   //dataWr_s[23:0]   = dataFromMem_i[addr_i[awidth-1:3]][23:0];
                                   dataWr_s[23:0]   = 0;
                                   dataWr_s[31:24]  = dataw_s[7:0];  // sb, byte aligned
                                   //dataWr_s[63:32]  = dataFromMem_i[addr_i[awidth-1:3]][63:32];
                                   dataWr_s[63:32]  = 0;
				   byteEn_o         = 8'b00001000;
                                 end
                                 else if (addr_i[awidth-1:0] % 8 == 4)
                                 begin
                                   //dataWr_s[31:0]   = dataFromMem_i[addr_i[awidth-1:3]][31:0];
                                   dataWr_s[31:0]   = 0;
                                   dataWr_s[39:32]  = dataw_s[7:0];  // sb, byte aligned
                                   //dataWr_s[63:40]  = dataFromMem_i[addr_i[awidth-1:3]][63:40];
                                   dataWr_s[63:40]  = 0;
				   byteEn_o         = 8'b00010000;
                                 end
                                 else if (addr_i[awidth-1:0] % 8 == 5)
                                 begin
                                   //dataWr_s[39:0]   = dataFromMem_i[addr_i[awidth-1:3]][39:0];
                                   dataWr_s[39:0]   = 0;
                                   dataWr_s[47:40]  = dataw_s[7:0];  // sb, byte aligned
                                   //dataWr_s[63:48]  = dataFromMem_i[addr_i[awidth-1:3]][63:48];
                                   dataWr_s[63:48]  = 0;
				   byteEn_o         = 8'b00100000;
                                 end
                                 else if (addr_i[awidth-1:0] % 8 == 6)
                                 begin
                                   //dataWr_s[47:0]   = dataFromMem_i[addr_i[awidth-1:3]][47:0];
                                   dataWr_s[47:0]   = 0;
                                   dataWr_s[55:48]  = dataw_s[7:0];  // sb, byte aligned
                                   //dataWr_s[63:56]  = dataFromMem_i[addr_i[awidth-1:3]][63:56];
                                   dataWr_s[63:56]  = 0;
				   byteEn_o         = 8'b01000000;
                                 end
                                 else
                                 begin
                                   //dataWr_s[55:0]   = dataFromMem_i[addr_i[awidth-1:3]][55:0];
                                   dataWr_s[55:0]   = 0;
                                   dataWr_s[63:56]  = dataw_s[7:0];  // sb, byte aligned
				   byteEn_o         = 8'b10000000;
                                 end
                       3'b001  : if (addr_i[awidth-1:1] % 4 == 0) 
                                 begin
                                   dataWr_s[15:0]   = dataw_s[15:0]; // sh, half-word aligned
                                   //dataWr_s[63:16]  = dataFromMem_i[addr_i[awidth-1:3]][63:16];
                                   dataWr_s[63:16]  = 0;
				   byteEn_o         = 8'b00000011;
                                 end
                                 else if (addr_i[awidth-1:1] % 4 == 1)
                                 begin
                                   //dataWr_s[15:0]   = dataFromMem_i[addr_i[awidth-1:3]][15:0];
                                   dataWr_s[15:0]   = 0;
                                   dataWr_s[31:16]  = dataw_s[15:0]; // sh, half-word aligned
                                   //dataWr_s[63:32]  = dataFromMem_i[addr_i[awidth-1:3]][63:32];
                                   dataWr_s[63:32]  = 0;
				   byteEn_o         = 8'b00001100;
                                 end
                                 else if (addr_i[awidth-1:1] % 4 == 2)
                                 begin
                                   //dataWr_s[31:0]   = dataFromMem_i[addr_i[awidth-1:3]][31:0];
                                   dataWr_s[31:0]   = 0;
                                   dataWr_s[47:32]  = dataw_s[15:0]; // sh, half-word aligned
                                  // dataWr_s[63:48]  = dataFromMem_i[addr_i[awidth-1:3]][63:48];
                                   dataWr_s[63:48]  = 0;
				   byteEn_o         = 8'b00110000;
                                 end
                                 else
                                 begin
                                   //dataWr_s[47:0]   = dataFromMem_i[addr_i[awidth-1:3]][47:0];
                                   dataWr_s[47:0]   = 0;
                                   dataWr_s[63:48]  = dataw_s[15:0]; // sh, half-word aligned
				   byteEn_o         = 8'b11000000;
                                 end
                       3'b010  : if (addr_i[awidth-1:2] % 2 == 0) 
                                 begin
                                   dataWr_s[31:0]   = dataw_s[31:0]; // sw, word aligned
                                   //dataWr_s[63:32]  = dataFromMem_i[addr_i[awidth-1:3]][63:32];
                                   dataWr_s[63:32]  = 0;
				   byteEn_o         = 8'b00001111;
                                 end
                                 else
                                 begin
                                   //dataWr_s[31:0]  = dataFromMem_i[addr_i[awidth-1:3]][31:0];
                                   dataWr_s[31:0]  = 0;
                                   dataWr_s[63:32] = dataw_s[31:0]; // sw, word aligned
				   byteEn_o         = 8'b11110000;
                                 end
                       3'b011  : begin 
                                   dataWr_s       = dataw_s; // sd
			           byteEn_o       = 8'b11111111;
			         end
                       default : begin 
                                   dataWr_s       = dataw_s; // sd
			           byteEn_o       = 8'b11111111;
			         end
                     endcase
        default : begin 
                    dataWr_s = dataw_s; // sd
	            byteEn_o = 8'b11111111;
	          end
      endcase // case (opcode_s)
    else
    begin
      dataWr_s = dataw_s;
      byteEn_o = 8'b11111111;
    end

  
endmodule : as_dmem_front
