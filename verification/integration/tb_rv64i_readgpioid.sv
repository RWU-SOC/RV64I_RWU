`timescale 1ns/1ps

import as_pack::*;

module tb_rv64i ();
  parameter tclk_2_t = 20; // 10 ns; given by timescale
  parameter clk_2_t = 5;   // 5 ns; given by timescale

  parameter sc01_length_in = 2;
  parameter sc01_length_out = 2;
  parameter im_length_in = im_scan_length;
  parameter im_length_out = im_scan_length;

  logic clk_s, clk_dummy_s;
  logic	rst_s;
  logic	tck_s, trst_s, tms_s, tdi_s, tdo_s;
  tri [nr_gpios-1:0]	      gpio_s; // gpio
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
              .gpio_io(gpio_s),
              //.gpioAddr_o(gpioAddr_s),
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

  always
  begin
    clk_dummy_s <= 1; #10000; clk_dummy_s <= 0; #10000;
  end
  //assign gpio_s[7] = 1'b1;
  assign gpio_s[7] = clk_dummy_s;

  // check results
  always @(negedge clk_s)
  begin
    if(cs_s === 1)
    begin
      $display("CS detected");
        case(gpio_s)
          129   : begin $display("GPIO ID Read Passed!: 0x%0h", gpio_s);  
                        $display("Simulation succeeded"); #100; #(1*2*clk_2_t); 
                        $fdisplay(fd,"%s - readgpioid: Test ok", get_time()); 
                        $fclose(fd); 
                        $stop; 
                  end
          default : begin $display("Unexpected GPIO: 0x%0h", gpio_s); 
                          $fdisplay(fd,"%s - readgpioid: Test fail", get_time()); 
                          $fclose(fd); 
                          $stop;  
                    end
        endcase
    end // cs_s
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
