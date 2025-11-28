`timescale 1ns/1ps

import as_pack::*;

module as_dmem_core (input  logic                       clk_i,
                     input  logic [dmem_addr_width-1:3] addr_i,
                     input  logic                       wrEn_i,
                     input  logic                       rdEn_i,
                     input  logic [reg_width-1:0]       data_i,
                     input  logic [7:0]                 byteEn_i,
                     output logic [reg_width-1:0]       data_o
               );
  //logic [dmem_addr_width-4:0] addr_s;
  //assign addr_s = addr_i[dmem_addr_width-1:3];
  
  (* ram_style = "distributed" *) logic [reg_width-1:0] ram_s[dmemdepth-1:0]; // MEMORY; x double words capacity
  //(* ram_style = "block" *) logic [reg_width-1:0] ram_s[dmemdepth-1:0]; // MEMORY; x double words capacity

  /****************************************/
  /* Write to RAM.                        */
  /****************************************/
  genvar i;
  generate
  for(i=0;i<8;i++) // go through all bytes; 8 here is #bytes
  always @(posedge clk_i)
  begin
    if(wrEn_i == 1)
      if(byteEn_i[i])
        ram_s[addr_i[dmem_addr_width-1:3]][((i+1)*8)-1:i*8] <= data_i[((i+1)*8)-1:i*8]; // 8 here is #bits per byte
  end
  endgenerate

  /******************************************************/
  /* Read the RAM.                                      */
  /******************************************************/
  /*always @(posedge clk_i)
  begin
    if(rdEn_i == 1)
      data_o <= ram_s[addr_i[dmem_addr_width-1:3]]; // block ram
  end*/
  assign data_o = ram_s[addr_i[dmem_addr_width-1:3]]; // distributed ram

  
endmodule : as_dmem_core



