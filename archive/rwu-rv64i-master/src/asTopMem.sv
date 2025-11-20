`timescale 1ns/1ps

import as_pack::*;

//--------------------------------------------
// 2Do:
// - Insert a dummy BS chain. It should consist of one I, one O and one I/O
// - Insert WB bus for instruction and for data.                                (Done)
// - Design WB master BPI and WB slave BPI. Implement WB.                       (Done)
// - Design a GPIO peripheral.                                                  (Done)
// - implement IRQs
//--------------------------------------------


module as_top_mem (input logic                       clk_i,
                  input  logic                       rst_i,
                  // JTAG
                  input  logic                       tck_i,      // Test Clock
                  input  logic                       trst_i,     // TAPC reset
                  input  logic                       tms_i,      // Test Mode Select
                  input  logic                       tdi_i,      // Test Data In
                  output logic                       tdo_o,      // Test Data Out
                  // GPIO
                  output logic [nr_gpios-1:0]        gpio_o,     // data of data bus (write to dmem)
                  output logic [gpio_addr_width-1:0] gpioAddr_o, // addr of data bus
                  output logic                       cs_o
                 );

  // data bus
  logic [reg_width-1:0]   dBusDataRdDmem_s; // data out from dmem
  logic [reg_width-1:0]   dBusDataRdGpio_s; // data out from GPIO
  logic [reg_width-1:0]   dBusDataRdQspi_s; // data out from QSPI
  logic [reg_width-1:0]   dBusDataRdCgu_s;  // data out from CGU
  logic [reg_width-1:0]   dBusDataRd_s; // data out of MUX
  logic [reg_width-1:0]   dBusDataWr_s; // data in to dmem
  logic [daddr_width-1:0] dBusAddr_s;   // address for dmem
  logic			  dMemRd_s;     // read enable for dmem
  logic			  dMemWr_s;     // write enable for dmem
  
  // instruction bus
  logic [instr_width-1:0] iBusDataRd_s; // data out from imem = Instruction
  logic [instr_width-1:0] iBusDataWr_s; // data in to imem            -- not connected
  logic [iaddr_width-1:0] iBusAddr_s;   // address for imem
  logic			  iMemWr_s;     // write enable for imem      -- not connected

  // JTAG
  logic tap_rst_s;
  logic	sc01_tdo_s, sc01_tdi_s, sc01_shift_s, sc01_clock_s;
  logic im_tdo_s, im_tdi_s, im_shift_s, im_clock_s, im_upd_s, im_mode_s;
  logic bs_tdo_s, bs_tdi_s, bs_shift_s, bs_clock_s, bs_upd_s, bs_mode_s;
  // JTAG: I-Mem scan chain
  logic [im_scan_length-1:0] im_datai_s, im_datao_s;
  // JTAG: I-Mem Address MUX
  logic [iaddr_width-1:0] iBusAddr2_s;   // address for imem
  logic [iaddr_width-1:0] im_addr_s;   // address for imem from chain
  logic			  mux_sel_s;

  logic wbdwe_s;
  logic wbdstb1_s;
  logic wbdstbGpio_s;
  logic wbdstbCgu_s;
  logic wbdcyc_s;
  logic [wbdSel-1:0]          sel_s;
  logic	[nr_gpios-1:0]        asGpio_s;
  logic [gpio_addr_width-1:0] asGpioAdr_s;
  logic asGpioCs_s;
  logic	wdbAckGpio_s;
  logic	wdbAckQspi_s;
  logic	wdbAckCgu_s;

  logic	wbdstDMem_s;
  logic	wdbAckDmem_s;
  logic [dmem_addr_width-1:0] adr_bpi_2_dmem_s;
  logic [reg_width-1:0]       dat_dmem_2_bpi_s;
  logic [reg_width-1:0]       dat_bpi_2_dmem_s;
  logic	wr_bpi_2_dmem_s;

  logic	wdbAckAll_s;

  logic [chipsel-1:0] csx_s; // one bit per peripheral

  logic clk_core_s, clk_qspi_s, clk_bus1_s, clk_bus2_s;

  // arbiter
  logic	gnt0_s, wbdcycarb_s;
  
  assign gpio_o      = asGpio_s;
  assign gpioAddr_o  = asGpioAdr_s;
  assign cs_o        = asGpioCs_s;

  //--------------------------------------------
  // Memory Map Data Bus:
  // 64'h00000000_00000000:
  // 64'h00000000_0000FFFF - D-Mem, 64 kB = 8192 double words
  //-------------------------------
  // 64'h00000000_00010000:
  // 64'h00000000_0001000F - GPIO,  16 B = 15 different pin header + 1 register
  //-------------------------------
  // 64'h00000000_00010010:
  // 64'h00000000_0001001F - QSPI,  16 B = 16 register
  //-------------------------------
  // 64'h00000000_00010020:
  // 64'h00000000_0001002F - CGU,   16 B = 16 register
  //--------------------------------------------

  //--------------------------------------------
  // Address Decoder
  //--------------------------------------------
  as_decode addressDecode (dBusAddr_s, csx_s);
  
  //--------------------------------------------
  // Data Mux: Peripherals to Master
  //--------------------------------------------
  assign dBusDataRdQspi_s = {reg_width{1'b0}};
  always_comb 
  begin
    case(csx_s) // one hot code
      0  :       dBusDataRd_s = {reg_width{1'b0}};
      1  :       dBusDataRd_s = dBusDataRdDmem_s;
      2  :       dBusDataRd_s = dBusDataRdGpio_s;
      4  :       dBusDataRd_s = dBusDataRdQspi_s;
      8  :       dBusDataRd_s = dBusDataRdCgu_s;
      default:   dBusDataRd_s = {reg_width{1'b0}};
    endcase
  end // always_comb
  
  //--------------------------------------------
  // GPIO Peripheral
  //--------------------------------------------
  assign wbdstbGpio_s = wbdstb1_s & wbdcycarb_s & csx_s[1];

  as_gpio_top #(gpio_addr_width,reg_width) 
                            asGpio(.rst_i(rst_i),
                                   .clk_i(clk_core_s),
                                   .wbdAddr_i(dBusAddr_s[gpio_addr_width-1:0]),
                                   .wbdDat_i(dBusDataWr_s),
                                   .wbdDat_o(dBusDataRdGpio_s), 
                                   .wbdWe_i(wbdwe_s),
                                   .wbdSel_i(sel_s),
                                   .wbdStb_i(wbdstbGpio_s),
                                   .wbdAck_o(wdbAckGpio_s),
                                   .wbdCyc_i(wbdcycarb_s),
                                   .gpio_o(asGpio_s),
                                   .gpioAdr_o(asGpioAdr_s),
                                   .cs_o(asGpioCs_s)
                                  );

  //--------------------------------------------
  // CGU
  //--------------------------------------------
  assign wbdstbCgu_s = wbdstb1_s & wbdcycarb_s & csx_s[3];

  as_cgu #(cgu_addr_width) 
         cgu (.clk_i(clk_i),
              .rst_i(rst_i),
              .wbdAddr_i(dBusAddr_s[cgu_addr_width-1:0]),
              .wbdDat_i(dBusDataWr_s),
              .wbdDat_o(dBusDataRdCgu_s),
              .wbdWe_i(wbdwe_s),
              .wbdSel_i(sel_s),
              .wbdStb_i(wbdstbCgu_s),
              .wbdAck_o(wdbAckCgu_s),
              .wbdCyc_i(wbdcycarb_s),
	      .clk_bus1_o(clk_bus1_s),
              .clk_bus2_o(clk_bus2_s),
              .clk_qspi_o(clk_qspi_s),
              .clk_core_o(clk_core_s)
             );
  
  //--------------------------------------------
  // CPU
  //--------------------------------------------
  assign wdbAckQspi_s = 1'b0;
  
  assign wdbAckAll_s = (wdbAckDmem_s | wdbAckGpio_s | wdbAckQspi_s | wdbAckCgu_s) & gnt0_s;
  
  as_cpu cpu (.clk_i(clk_core_s),
              .rst_i(rst_i),
              .sc01_tdo_o(sc01_tdo_s),
              .sc01_tdi_i(sc01_tdi_s),
              .sc01_shift_i(sc01_shift_s),
              .sc01_clock_i(sc01_clock_s),
              .wbiBusDataRd_i(iBusDataRd_s),
              .wbiBusDataWr_o(), // iBusDataWr_s
              .wbiBusAddr_o(iBusAddr_s),
              .wbiBusWe_o(),  // not needed for I-Mem
              .wbiBusSel_o(), // not needed for I-Mem
              .wbiBusStb_o(), // not needed for I-Mem
              .wbiBusAck_i(1'b1), // constant 1 
              .wbiBusCyc_o(),  // not needed for I-Mem
              .wbdBusDataRd_i(dBusDataRd_s),
              .wbdBusDataWr_o(dBusDataWr_s),
              .wbdBusAddr_o(dBusAddr_s),
              .wbdBusWe_o(wbdwe_s),
              .wbdBusSel_o(sel_s),
              .wbdBusStb_o(wbdstb1_s),
              .wbdBusAck_i(wdbAckAll_s),
              .wbdBusCyc_o(wbdcyc_s),
              .dMemRd_o(dMemRd_s), // kann fast weg ???
              .dMemWr_o(dMemWr_s) // kann weg
             );

  //--------------------------------------------
  // Arbiter
  //--------------------------------------------
  assign wbdcycarb_s = wbdcyc_s;
  assign gnt0_s      = wbdcyc_s;

  //--------------------------------------------
  // Instruction memory
  //--------------------------------------------
  assign im_addr_s    = im_datao_s[im_scan_length-1:instr_width+1];
  assign iMemWr_s     = im_datao_s[0] & (~im_clock_s);
  assign iBusDataWr_s = im_datao_s[instr_width:1];
  assign mux_sel_s    = im_datao_s[0] & (~im_clock_s);
  assign iBusAddr2_s = (mux_sel_s == 0) ? iBusAddr_s[imem_addr_width-1:0] : im_addr_s;
  as_imem imem (.clk_i(clk_core_s),
                .addr_i(iBusAddr2_s[imem_addr_width-1:0]),
                .data_i(iBusDataWr_s),
                .wr_i(iMemWr_s),
                .data_o(iBusDataRd_s)
               );

  //--------------------------------------------
  // data memory
  //--------------------------------------------
  logic rd_dmem_s;
  assign rd_dmem_s = ~wbdwe_s;
  
  assign wbdstDMem_s = wbdstb1_s & wbdcycarb_s & csx_s[0];

  as_slave_bpi #(64'h0000000000000002, dmem_addr_width, reg_width ) 
                            sDmemBpi(.rst_i(rst_i),
                                     .clk_i(clk_core_s),
                                     .addr_o(adr_bpi_2_dmem_s),
                                     .dat_from_core_i(dat_dmem_2_bpi_s),
                                     .dat_to_core_o(dat_bpi_2_dmem_s),
                                     .wr_o(wr_bpi_2_dmem_s),
                                     .addr_i(dBusAddr_s[dmem_addr_width-1:0]),
                                     .dat_i(dBusDataWr_s),
                                     .dat_o(dBusDataRdDmem_s),
                                     .we_i(wbdwe_s),
                                     .sel_i(sel_s),
                                     .stb_i(wbdstDMem_s),
                                     .ack_o(wdbAckDmem_s),
                                     .cyc_i(wbdcycarb_s)
                                    );
  
  as_dmem dmem (.clk_i(clk_core_s),
                .addr_i(adr_bpi_2_dmem_s),     // from BPI
                .wrEn_i(wr_bpi_2_dmem_s),      // from BPI
                .rdEn_i(rd_dmem_s),             // from master ???? dMemRd_s
                .opcode_i(iBusDataRd_s[6:0]),  // from master
                .func3_i(iBusDataRd_s[14:12]), // from master
                .data_i(dat_bpi_2_dmem_s),     // from BPI
                .data_o(dat_dmem_2_bpi_s)      // to BPI
               );
  
  //--------------------------------------------
  // JTAG
  //--------------------------------------------
  assign bs_tdo_s = 1'b0;
  
  jtag as_jtag (.tck_i(tck_i),
                .trst_i(trst_i),
                .tms_i(tms_i),
                .tdi_i(tdi_i),
                .tdo_o(tdo_o),
                .tap_rst_o(tap_rst_s),
                .sc01_tdo_i(sc01_tdo_s),
                .sc01_tdi_o(sc01_tdi_s),
                .sc01_shift_o(sc01_shift_s),
                .sc01_clock_o(sc01_clock_s),
                .im_tdo_i(im_tdo_s),
                .im_tdi_o(im_tdi_s),
                .im_shift_o(im_shift_s),
                .im_clock_o(im_clock_s),
                .im_upd_o(im_upd_s),
                .im_mode_o(im_mode_s),
                .bs_tdo_i(bs_tdo_s),
                .bs_tdi_o(bs_tdi_s),
                .bs_shift_o(bs_shift_s),
                .bs_clock_o(bs_clock_s),
                .bs_upd_o(bs_upd_s),
                .bs_mode_o(bs_mode_s)
               );

  //--------------------------------------------
  // Scan chain for I-Mem
  //--------------------------------------------
  assign im_datai_s  = {im_scan_length{1'b0}}; // paralell load
  dr_reg #(.dr_width(im_scan_length)) 
       imem_load (.tck_i(tck_i),
                  .trst_i(tap_rst_s),
                  .mode_i(im_mode_s),
                  .dr_shift_i(im_shift_s),
                  .dr_clock_i(im_clock_s),
                  .dr_upd_i(im_upd_s),
                  .data_i(im_datai_s),// parallel in to chain
                  .ser_i(im_tdi_s),
                  .data_o(im_datao_s),// to I-Mem, parallel access of scan chain
                  .ser_o(im_tdo_s)
		 );
 
endmodule : as_top_mem
