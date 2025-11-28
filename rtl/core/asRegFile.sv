import as_pack::*;

`timescale 1ns/1ps

module as_regfile (input  logic                    clk_i,
                   input  logic	                   rst_i,
                   input  logic	                   we_i,
                   input  logic [rwaddr_width-1:0] raddr01_i,
                   input  logic [rwaddr_width-1:0] raddr02_i,
                   input  logic [rwaddr_width-1:0] waddr01_i,
                   input  logic [reg_width-1:0]    wdata01_i,
                   output logic [reg_width-1:0]    rdata01_o,
                   output logic [reg_width-1:0]    rdata02_o
                  );

  logic [reg_width-1:0]    regfile_s[nr_regs-1:0];
  logic [rwaddr_width-1:0] raddr01_s;
  logic [rwaddr_width-1:0] raddr02_s;
  logic [rwaddr_width-1:0] waddr01_s;

  assign raddr01_s = raddr01_i;
  assign raddr02_s = raddr02_i;
  assign waddr01_s = waddr01_i;

  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      foreach(regfile_s[i])
      begin
        regfile_s[i] <= {reg_width{1'b0}};
      end
    else
    begin
      if(we_i) regfile_s[waddr01_s] <= wdata01_i;
    end
  end

  assign rdata01_o = (raddr01_s != 0) ? regfile_s[raddr01_s] : 0;
  assign rdata02_o = (raddr02_s != 0) ? regfile_s[raddr02_s] : 0;
    
endmodule : as_regfile
