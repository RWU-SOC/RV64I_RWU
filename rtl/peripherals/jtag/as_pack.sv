`timescale 1ns/1ps

package as_pack;
  typedef enum bit [1:0] {RED, YELLOW, GREEN, RDYEL} e_signal;

  function common();
    $display("as Function.");
  endfunction // common

  // general
  localparam int       reg_width        = 64; // = data width
  localparam int       iaddr_width      = 64; // must be = reg_width
  localparam int       daddr_width      = 64;
  localparam int       instr_width      = 32;
  // controls
  localparam int       alusel_width     = 4; // ALU according Hennessy Pat.
  localparam int       aluselrv_width   = 5; // ALU according Harris
  localparam int       dmuxsel_width    = 2;
  localparam int       immsrc_width     = 3;
  localparam int       aluop_width      = 2;
  localparam int       controls01_width = 14; // asMainDec
  // instruction fields
  localparam int       func7_width      = 7;
  localparam int       func3_width      = 3;
  localparam int       opcode_width     = 7;
  // register file
  localparam int       rwaddr_width     = 5;
  localparam int       nr_regs          = 32;
  //parameter int	       nr_regs          = 32;

  // external
  localparam int       nr_gpios         = 8; // 0 - 255
  localparam int       gpio_addr_width  = 4;
  localparam int       cs_width         = 2;

  // tapc
  localparam int       ir_width = 8;
  localparam int       dr1_width = 8;
  localparam int       id_width = 32;
  localparam int       nr_drs = 5; // BY, BS, I-Mem, Scan, USERCODE
   


endpackage
