`timescale 1ns/1ps

import as_pack::*;

module as_imem (input  logic                       clk_i,
                input  logic [imem_addr_width-1:0] addr_i,
                input  logic [instr_width-1:0]     data_i,
                input  logic                       wr_i,
                output logic [instr_width-1:0]     data_o
               );

  parameter int mdepth = imemdepth;

  (* ram_style = "distributed" *) logic [instr_width-1:0] iram_s[mdepth-1:0]; // x words capacity
  //(* ram_style = "block" *) logic [instr_width-1:0] iram_s[mdepth-1:0]; // x words capacity

  /*initial
  begin
    ram_s[0]  = 32'h00500113;
    ram_s[1]  = 32'h00C00193;
    ram_s[2]  = 32'hFF718393;
    ram_s[3]  = 32'h0023E233;
    ram_s[4]  = 32'h0041F2B3;
    ram_s[5]  = 32'h004282B3;
    ram_s[6]  = 32'h02728863;
    ram_s[7]  = 32'h0041A233;
    ram_s[8]  = 32'h00020463;
    ram_s[9]  = 32'h00000293;
    ram_s[10] = 32'h0023A233;
    ram_s[11] = 32'h005203B3;
    ram_s[12] = 32'h402383B3;
    ram_s[13] = 32'h0471AA23;
    ram_s[14] = 32'h06002103;
    ram_s[15] = 32'h005104B3;
    ram_s[16] = 32'h008001EF;
    ram_s[17] = 32'h00100113;
    ram_s[18] = 32'h00910133;
    ram_s[19] = 32'h0A21AE23;
    ram_s[20] = 32'h00210063;
  end*/

  /******************************************************/
  /* Initial setting.                                   */
  /******************************************************/
  initial
    $readmemh("riscvtest.mem",iram_s);

  /****************************************/
  /* Write to RAM.                        */
  /****************************************/
  always @(posedge(clk_i)) 
  begin
    if( wr_i == 1 )
      iram_s[addr_i[imem_addr_width-1:2]] <= data_i;
  end

  /******************************************************/
  /* Read the RAM.                                      */
  /******************************************************/
  /*always @(posedge clk_i)
  begin
    data_o <= iram_s[addr_i[imem_addr_width-1:2]];
  end*/
  assign data_o = iram_s[addr_i[imem_addr_width-1:2]]; // word aligned
                    
endmodule : as_imem
