`timescale 1ns/1ps

import as_pack::*;

//-----------------------------------------------
// Wishbone slave BPI
// - Call: as_slave_bpi #(64,64) myBpi ( all ports );
// - First implementation: without any sync-cells -> no delay
//-----------------------------------------------
module as_slave_bpi #( parameter slave_id = 64'hDEADBEEFDEADBEEF,
                       parameter addr_width = 64,
                       parameter data_width = 64 )
                     ( input  logic                  rst_i,
                       input  logic                  clk_i,
                       // kernel side
                       output logic [addr_width-1:0] addr_o,
                       input  logic [data_width-1:0] dat_from_core_i,
                       output logic [data_width-1:0] dat_to_core_o,
                       output logic                  wr_o,
                       // wishbone side
                       input  logic [addr_width-1:0] addr_i,
                       input  logic [data_width-1:0] dat_i,
                       output logic [data_width-1:0] dat_o,
                       input  logic                  we_i,
                       input  logic [wbdSel-1:0]     sel_i, // which byte is valid
                       input  logic                  stb_i, // valid cycle
                       output logic                  ack_o, // normal transaction
                       input  logic                  cyc_i  // high for complete bus cycle
                     );

  logic [data_width-1:0] id_reg_s;
  logic	we_s, sel_s;
  logic [addr_width-1:0] addr_s;
  logic [data_width-1:0] dati_s;
  logic [data_width-1:0] dato_s;
  logic [data_width-1:0] dat_from_core_s;

  // comming from bus
  assign sel_s =& sel_i;
  assign we_s            = we_i & stb_i & sel_s & cyc_i;
  assign addr_s          = addr_i;
  assign dati_s          = dat_i;

  // going to bus
  assign ack_o           = stb_i;
  assign dat_o           = dato_s;

  // comming from functional block
  assign dat_from_core_s = dat_from_core_i;

  // going to functional block
  assign addr_o          = addr_s;
  assign dat_to_core_o   = dati_s;
  assign wr_o            = we_s;

  //--------------------------------------------
  // ID register
  //--------------------------------------------
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
    begin
      id_reg_s        <= slave_id;
    end
    else
    begin
      if ( (we_s == 1) & (addr_s == 0) )
      begin
        id_reg_s      <= dati_s;
      end
    end
  end // always_ff @ (posedge clk_i, posedge rst_i)

  // read internal (BPI) register or data from core
  always_comb
  begin
    case(addr_s)
      0       : dato_s = id_reg_s;
      default : dato_s = dat_from_core_s;
    endcase
  end

endmodule : as_slave_bpi

