`timescale 1ns/1ps

import as_pack::*;

module tb_rv64i ();
  parameter tclk_2_t = 20; // 10 ns; given by timescale
  parameter clk_2_t = 5;   // 5 ns; given by timescale

  parameter sc01_length_in = 2;
  parameter sc01_length_out = 2;
  parameter im_length_in = im_scan_length;
  parameter im_length_out = im_scan_length;

  logic clk_s;
  logic	rst_s;
  logic	tck_s, trst_s, tms_s, tdi_s, tdo_s;
  logic [nr_gpios-1:0]	      gpio_s; // gpio
  logic [gpio_addr_width-1:0] gpioAddr_s;
  logic			      cs_s;

  // initial load I-Mem
  logic [instr_width-1:0]     iram_s[imemdepth-1:0]; // I-Mem

  int fd;

  as_top_mem DUT (.clk_i(clk_s),
              .rst_i(rst_s),
              .tck_i(tck_s),
              .trst_i(trst_s),
              .tms_i(tms_s),
              .tdi_i(tdi_s),
              .tdo_o(tdo_s),
              .gpio_o(gpio_s),
              .gpioAddr_o(gpioAddr_s),
              .cs_o(cs_s)
             );
  // read instructions
  initial
    $readmemh("riscvtest.mem",iram_s);

  // reset
  initial
  begin
    rst_s <= 1; #(10*2*clk_2_t); rst_s <= 0;
  end

  initial
  begin
    fd = $fopen("./error.txt", "a");
  end

  // clock
  always
  begin
    clk_s <= 1; #clk_2_t; clk_s <= 0; #clk_2_t; 
  end

  // TCK
  initial
  begin
    tck_s <= 0;
    tms_s <= 0;
    tdi_s <= 0;
    trst_s <= 0;
  end


  // check results
  always @(negedge clk_s)
  begin
    if(cs_s === 1)
    begin
      $display("CS detected");
      if((gpioAddr_s === 4)) 
        case(gpio_s)
            1     : begin $display("Instr 04 - load byteu01: 0x%0h", gpio_s);  end
            2     : begin $display("Instr 04 - load byteu02: 0x%0h", gpio_s);  end
            3     : begin $display("Instr 04 - load byteu03: 0x%0h", gpio_s);  end
            4     : begin $display("Instr 04 - load byteu04: 0x%0h", gpio_s);  end
            5     : begin $display("Instr 04 - load byteu05: 0x%0h", gpio_s);  end
            6     : begin $display("Instr 04 - load byteu06: 0x%0h", gpio_s);  end
            7     : begin $display("Instr 04 - load byteu07: 0x%0h", gpio_s);  end
          128     : begin $display("Instr 04 - load byteu08 (check for sign extend in wave): 0x%0h", gpio_s);  $display("Simulation succeeded"); #100; #(1*2*clk_2_t); $fdisplay(fd,"%s - load byteu: Test ok", get_time()); $fclose(fd); $stop; end
          default : begin $display("Unexpected GPIO: 0x%0h", gpio_s); $fdisplay(fd,"%s - load byteu: Test fail", get_time()); $fclose(fd); $stop;  end
        endcase
      else // (gpioAddr_s === 4)
      begin
        $display("Simulating: time=%0t addr=0x%0h data=0x%0h cs=0x%0h+++",$time, gpioAddr_s, gpio_s, cs_s);
        $stop;
      end
    end // cs_s
    //end // loading
  end // negedge

//------------------------------------------
// Functions
//------------------------------------------
  function string get_time();
    int    file_pointer;
    
    //Stores time and date to file sys_time
    //void'($system("date +%X--%x > sys_time"));
    void'($system("date +%x > sys_time"));
    //Open the file sys_time with read access
    file_pointer = $fopen("sys_time","r");
    //assin the value from file to variable
    void'($fscanf(file_pointer,"%s",get_time));
    //close the file
    $fclose(file_pointer);
    void'($system("rm sys_time"));
  endfunction

endmodule : tb_rv64i
