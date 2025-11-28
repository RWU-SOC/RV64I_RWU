`timescale 1ns/1ps

import as_pack::*;

//-----------------------------------------------
// Wishbone master BPI
// - Call: as_master_bpi #(64,64) myBpi ( all ports );
// - First implementation: without any sync-cells -> no delayx
//-----------------------------------------------
module as_master_bpi #( parameter master_id  = 64'hDEADBEEFDEADBEEF,
                        parameter addr_width = 64,
                        parameter data_width = 64)
                      ( input                         rst_i,
                        input                         clk_i,
                        // master side
                        input  logic [addr_width-1:0] addr_i,
                        input  logic [data_width-1:0] dat_from_core_i,
                        output logic [data_width-1:0] dat_to_core_o,
                        input  logic                  wr_i,
                        // wishbone side
                        output logic [addr_width-1:0] wb_m_addr_o,
                        input  logic [data_width-1:0] wb_m_dat_i,
                        output logic [data_width-1:0] wb_m_dat_o,
                        output logic                  wb_m_we_o,
                        output logic [wbdSel-1:0]  wb_m_sel_o, // which byte is valid
                        output logic                  wb_m_stb_o, // valid cycle
                        input  logic                  wb_m_ack_i, // normal transaction
                        output logic                  wb_m_cyc_o  // high for complete bus cycle
                      );
  
  logic [data_width-1:0] id_reg_s;
  logic ack_s, wr_s;
  logic [addr_width-1:0] addr_s;
  logic [data_width-1:0] dati_s;
  logic [data_width-1:0] dato_s;
  
  //------------------------------
  // comming from master
  //------------------------------
  assign addr_s = addr_i;
  assign dati_s = dat_from_core_i;
  assign wr_s   = wr_i;
  
  //------------------------------
  // going to master
  //------------------------------
  assign dat_to_core_o  = dato_s;
  
  //------------------------------
  // going to bus
  //------------------------------
  assign wb_m_addr_o   = addr_s;
  assign wb_m_dat_o    = dati_s;
  assign wb_m_we_o     = wr_s;
  assign wb_m_sel_o    = {wbdSel{1'b1}};  // Solve it!
  assign wb_m_stb_o    = 1'b1;               // Solve it!
  assign wb_m_cyc_o    = 1'b1;               // Solve it!

  //------------------------------
  // comming from bus
  //------------------------------
  assign dato_s        = wb_m_dat_i;
  assign ack_s         = wb_m_ack_i; // Solve it!

  //--------------------------------------------
  // ID register (dummy register, not readable, re-think function )
  //--------------------------------------------
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
    begin
      id_reg_s        <= master_id;
    end
    else
    begin
      if ( (wr_s == 1) & (addr_s == 0) )
      begin
        id_reg_s      <= dati_s;
      end
    end
  end // always_ff @ (posedge clk_i, posedge rst_i)

endmodule : as_master_bpi

