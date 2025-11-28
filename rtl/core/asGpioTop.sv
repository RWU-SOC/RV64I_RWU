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
                     input  logic [reg_width-1:0]      wbdDat_i,  // 64 Bit
                     output logic [reg_width-1:0]      wbdDat_o,  // internal register
                     input  logic                      wbdWe_i,
                     input  logic [wbdSel-1:0]         wbdSel_i, // which byte is valid
                     input  logic                      wbdStb_i, // valid cycle
                     output logic                      wbdAck_o, // normal transaction
                     input  logic                      wbdCyc_i, // high for complete bus cycle
                     output logic                      gpio_irq_o, // GPIO IRQ; input changed
                     // I/O
                     inout  tri   [nr_gpios-1:0]       gpio_io,    // to Pin
                     output logic                      cs_o       // to Pin
                   );

  // address, data, enable
  logic [gpioaddr_width-1:0] addr_s;
  logic [reg_width-1:0]      data_s;    // data from bus/BPI to kernel
  logic [nr_gpios-1:0]       dataok_s;  // data from kernel to BPI
  logic [reg_width-1:0]      dataob_s;  // data from BPI to bus
  logic                      en_s;

  // IRQ
  logic [nr_gpios-1:0]	     irq_s;        // IRQs from kernel
  logic			     irq_comb_s;   // OR of all IRQs
  logic			     irqsc_comb_s; // OR of all irqsc
  logic			     irqsm_comb_s; // OR of all irqsm, mask

  // registers
  logic [reg_width-1:0]      id_reg_s;      // GPIO peripheral ID-register;                    address=00
  logic [reg_width-1:0]      dir_reg_s;     // GPIO direction register;                        address=08
  logic [reg_width-1:0]      data_reg_s;    // GPIO data register;                             address=12
  logic [reg_width-1:0]      irqss_reg_s;   // GPIO Interrupt Request Source Status Register;  address=01
  logic [reg_width-1:0]      irqsc_reg_s;   // GPIO Interrupt Request Source Clear Register;   address=03
  logic [reg_width-1:0]      irqsm_reg_s;   // GPIO Interrupt Request Source Mask Register;    address=02
  logic [reg_width-1:0]      isr_reg_s;     // GPIO Interrupt Set Register;                    address=05
  logic [reg_width-1:0]      ris_reg_s;     // GPIO Raw Interrupt Status Register;             address=06
  logic [reg_width-1:0]      imsc_reg_s;    // GPIO Interrupt Mask Control Register;           address=07
  logic [reg_width-1:0]      mis_reg_s;     // GPIO Masked Interrupt Status Register;          address=09
  
  //--------------------------------------------
  // Slave BPI
  //--------------------------------------------
  as_slave_bpi #(gpioaddr_width, gpiodata_width) 
                            sGpioBpi(.rst_i(rst_i),
                                     .clk_i(clk_i),
                                     .addr_o(addr_s),            // address from BPI; for kernel usage
                                     .dat_from_core_i(dataob_s), // data from kernel; should be mapped onto the wb-bus
                                     .dat_to_core_o(data_s),     // data to kernel; for kernel usage
                                     .wr_o(en_s),                // signal to kernel; for kernel usage
                                     .addr_i(wbdAddr_i),
                                     .dat_i(wbdDat_i),
                                     .dat_o(wbdDat_o),
                                     .we_i(wbdWe_i),
                                     .sel_i(wbdSel_i),
                                     .stb_i(wbdStb_i),
                                     .ack_o(wbdAck_o),
                                     .cyc_i(wbdCyc_i)
                                    );

  //--------------------------------------------
  // Peripheral kernel
  //--------------------------------------------
  as_gpio  mygpio (.rst_i(rst_i),
                   .clk_i(clk_i),
                   .direction_i(dir_reg_s[nr_gpios-1:0]),
                   .addr_i(addr_s),
                   .data_i(data_reg_s[nr_gpios-1:0]),
                   .data_o(dataok_s),
		   .irq_o(irq_s),
                   .en_i(en_s),
                   .gpio_io(gpio_io),
                   .cs_o(cs_o)
                  );

  //--------------------------------------------
  // SRB: IRQ & DMA
  //      in:  clk_i
  //      in:  rst_i
  //      in:  irq_s
  //      in:  en_s
  //      in:  addr_s
  //      in:  data_s
  //      out: dataob_s
  //--------------------------------------------
  assign irq_comb_s   =| irq_s;
  assign irqsc_comb_s =| irqsc_reg_s;
		     
  // IRQSS: 64 bit, rh
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      irqss_reg_s                 <= gpio_irqss_reg_rst_c;
    else
      if(irq_comb_s) // an IRQ is there; one or more of many
        irqss_reg_s[nr_gpios-1:0] <= irq_s;
      else
        if(irqsc_comb_s) // an IRQ clear has been written
        begin
          irqss_reg_s  <= 0;
          // irqsc_reg_s is cleared in its own always block below
        end
  end

  // IRQSC: 64 bit, w
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      irqsc_reg_s        <= gpio_irqsc_reg_rst_c;
    else
      if ( (en_s == 1) & (addr_s == gpio_irqsc_reg_addr_offs_c) )
        irqsc_reg_s      <= data_s;
  end

  // IRQSM: 64 bit, rw
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      irqsm_reg_s        <= gpio_irqsm_reg_rst_c;
    else
      if ( (en_s == 1) & (addr_s == gpio_irqsm_reg_addr_offs_c) )
        irqsm_reg_s      <= data_s;
  end

  assign irqsm_comb_s =|  (irqss_reg_s & irqsm_reg_s); // first bit wise AND, then OR the single bits, input to RIS

  // RIS: 64 bit, rh
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      ris_reg_s                <= gpio_ris_reg_rst_c;
    else
    begin
      ris_reg_s[0]             <= irqsm_comb_s | isr_reg_s[0];
      ris_reg_s[reg_width-1:1] <= 0;
    end
  end

  // ISR: 64 bit, w
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      isr_reg_s        <= gpio_isr_reg_rst_c;
    else
      if ( (en_s == 1) & (addr_s == gpio_isr_reg_addr_offs_c) )
        isr_reg_s      <= data_s;
  end

  // IMSC: 64 bit, rw
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      imsc_reg_s        <= gpio_imsc_reg_rst_c;
    else
      if ( (en_s == 1) & (addr_s == gpio_imsc_reg_addr_offs_c) )
        imsc_reg_s      <= data_s;
  end

  // MIS: 64 bit, rh
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      mis_reg_s        <= gpio_mis_reg_rst_c;
    else
      mis_reg_s      <= imsc_reg_s & ris_reg_s;
  end

  // GPIO IRQ
  assign gpio_irq_o = imsc_reg_s[0] & ris_reg_s[0];
  
  //--------------------------------------------
  // SFR: all other registers
  //      in:  rst_i
  //      in:  clk_i
  //      in:  addr_s
  //      in:  data_s
  //      in:  dataok_s
  //      in:  en_s
  //      out: dataob_s
  //--------------------------------------------
  // Peripheral ID: 64 bit, rw
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      id_reg_s        <= gpio_id_reg_addr_rst_c;
    else
      if ( (en_s == 1) & (addr_s == gpio_id_reg_addr_offs_c) )
        id_reg_s      <= data_s;
  end

  // GPIO direction register: 64 bit, rw
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      dir_reg_s <= gpio_direction_reg_addr_rst_c;
    else
      if ( (en_s == 1) & (addr_s == gpio_direction_reg_addr_offs_c) )
        dir_reg_s <= data_s;
  end

  // GPIO data register: 64 bit, rw
  // ... first 8 bit of the register; muxed input: either gpio_in or data from bus
  genvar i;
  generate
    for (i=0; i < nr_gpios; i++)
    begin
      always_ff @(posedge clk_i, posedge rst_i)
      begin
        if(rst_i == 1)
          data_reg_s[i] <= gpio_data_reg_addr_rst_c[nr_gpios-1:0];
        else
          if (dir_reg_s[i])
            data_reg_s[i] <= dataok_s[i];  // pad to register
          else
            if ( (en_s == 1) & (addr_s == gpio_data_reg_addr_offs_c) )
              data_reg_s[i] <= data_s[i];  // bus to register
      end
    end
  endgenerate

  // ... remaining bits of the data register
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
      data_reg_s[reg_width-1:nr_gpios] <= gpio_data_reg_addr_rst_c;
    else
      if ( (en_s == 1) & (addr_s == gpio_data_reg_addr_offs_c) )
	data_reg_s[reg_width-1:nr_gpios] <= data_s[reg_width-1:nr_gpios];
  end
  
  // read internal (BPI) register or data from core
  always_comb
  begin
    case(addr_s)
      gpio_id_reg_addr_offs_c        : dataob_s = id_reg_s;
      gpio_direction_reg_addr_offs_c : dataob_s = dir_reg_s;
      gpio_data_reg_addr_offs_c      : dataob_s = data_reg_s;
      gpio_irqss_reg_addr_offs_c     : dataob_s = irqss_reg_s;
      gpio_irqsc_reg_addr_offs_c     : dataob_s = 0;
      gpio_irqsm_reg_addr_offs_c     : dataob_s = irqsm_reg_s;
      gpio_imsc_reg_addr_offs_c      : dataob_s = imsc_reg_s;
      gpio_isr_reg_addr_offs_c       : dataob_s = 0;
      gpio_mis_reg_addr_offs_c       : dataob_s = mis_reg_s;
      gpio_ris_reg_addr_offs_c       : dataob_s = ris_reg_s;
      default                        : dataob_s = 0; // should not happen
    endcase
  end
  
  //--------------------------------------------
  // Clock
  //--------------------------------------------

  //--------------------------------------------
  // Sync
  //--------------------------------------------

  //--------------------------------------------
  // FIFO
  //--------------------------------------------
endmodule : as_gpio_top

