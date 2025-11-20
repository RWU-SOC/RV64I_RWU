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

  // memories & peripherals
  localparam int       dmemdepth        = 1024; // amount of double words (if reg_width = 64); 1024 doubles = 8192 bytes => addr_width = 13
  localparam int       dmem_addr_width  = 13;   // address for all bytes (8192 double words * 8 Bytes = 65536 Bytes => 16 bit address)
  localparam int       imemdepth        = 8192; // 12 bit address, but the lower 2 will not be used; word alligned
  localparam int       imem_addr_width  = 15;   // (8192 words accessible => 15 - 2 bits address)
  localparam int       cgu_addr_width   = 4;
  

  // external
  localparam int       nr_gpios         = 8; // 0 - 255
  localparam int       gpio_addr_width  = 4;
  localparam int       cs_width         = 2;

  // tapc
  localparam int       ir_width = 8;
  //localparam int       dr1_width = 8;
  localparam int       id_width = 32;
  localparam int       nr_drs = 5; // BY, BS, I-Mem, Scan, USERCODE
  localparam int       im_addr_width = imem_addr_width; // #address lines
  localparam int       im_data_width = instr_width;     // #data lines
  localparam int       im_scan_length = im_addr_width + im_data_width + 1; // +1 for w_en

  localparam int       chipsel = 4;
  localparam int       wbdSel = 8;

  // CGU
  // Division factors: f_zybo = 125 MHz
  //                   div = 2:   f = 62.5 MHz
  //                   div = 4:   f = 31.25 MHz
  //                   div = 5:   f = 25 MHz
  //                   div = 25:  f = 5 MHz
  //                   div = 200: f = 625 kHz
  //                   div = 400: f = 312.5 kHz
  localparam int       clk_zybo_per = 8;    // ns, f = 125 MHz
  //localparam int       clk_core_per = 1600; // ns, f = 625 kHz
  localparam int       clk_core_div = 80;
  //localparam int       clk_qspi_per = 200;  // ns, 20 Mbit/s -> f = 5 MHz -> div = 25
  localparam int       clk_qspi_div = 4;
  localparam int       clk_bus1_div = 80;
  localparam int       clk_bus2_div = 100;

  
  
  
  

endpackage
