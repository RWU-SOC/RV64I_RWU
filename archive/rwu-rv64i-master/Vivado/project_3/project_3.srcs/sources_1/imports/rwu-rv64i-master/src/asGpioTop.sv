`timescale 1ns/1ps

import as_pack::*;

//-----------------------------------------------
// Wishbone slave: GPIO
//-----------------------------------------------
module as_gpio_top #( parameter gpioaddr_width = 64,
                      parameter	gpiodata_width = 64 )
                   ( input  logic                  rst_i,
                     input  logic                  clk_i,
                     // wishbone side
                     input  logic [gpioaddr_width-1:0] wbdAddr_i, // 4 Bit (more for internal register)
                     input  logic [gpiodata_width-1:0] wbdDat_i,  // 64 Bit
                     output logic [gpiodata_width-1:0] wbdDat_o,  // internal register
                     input  logic                  wbdWe_i,
                     input  logic [wbdSel-1:0]     wbdSel_i, // which byte is valid
                     input  logic                  wbdStb_i, // valid cycle
                     output logic                  wbdAck_o, // normal transaction
                     input  logic                  wbdCyc_i, // high for complete bus cycle
                     // I/O
                     output logic [nr_gpios-1:0]        gpio_o,    // to Pin
                     output logic [gpio_addr_width-1:0] gpioAdr_o, // to Pin
                     output logic                       cs_o       // to Pin
                   );

  logic [gpioaddr_width-1:0] addr_s;
  logic [gpiodata_width-1:0] data_s;
  logic                      en_s;

  
  as_slave_bpi #(64'h0000000000000001, gpioaddr_width, gpiodata_width) 
                            sGpioBpi(.rst_i(rst_i),
                                     .clk_i(clk_i),
                                     .addr_o(addr_s),
                                     .dat_from_core_i('b0), // open
                                     .dat_to_core_o(data_s),
                                     .wr_o(en_s),
                                     .addr_i(wbdAddr_i),
                                     .dat_i(wbdDat_i),
                                     .dat_o(wbdDat_o),
                                     .we_i(wbdWe_i),
                                     .sel_i(wbdSel_i),
                                     .stb_i(wbdStb_i),
                                     .ack_o(wbdAck_o),
                                     .cyc_i(wbdCyc_i)
                                    );

  as_gpio  mygpio (.rst_i(rst_i),
                   .clk_i(clk_i),
                   .addr_i(addr_s),
                   .data_i(data_s[nr_gpios-1:0]),
                   .en_i(en_s),
                   .gpio_o(gpio_o),
                   .gpioAdr_o(gpioAdr_o),
                   .cs_o(cs_o)
                  );
endmodule : as_gpio_top

