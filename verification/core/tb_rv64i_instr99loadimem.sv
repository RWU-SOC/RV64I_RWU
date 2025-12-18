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
  tri [nr_gpios-1:0]	      gpio_s; // gpio
  logic [gpio_addr_width-1:0] gpioAddr_s;
  logic			      cs_s;

  // initial load I-Mem
  logic [instr_width-1:0]     iram_s[imemdepth-1:0]; // I-Mem
  logic	[instr_width-1:0]     instr_s;               // one instruction

  logic	[imem_addr_width-1:0] imScanAddr_s;
  logic [instr_width-1:0]     imScanData_s;
  logic			      imScanWe_s;
  logic [im_scan_length-1:0]  imScanTdi_s;
  
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

  assign instr_s = iram_s[0];

  initial
  begin
    fd = $fopen("./error.txt", "a");
    trst_s <= 0;
    tdi_s  <= 0;
    tms_s  <= 0;
  end
  
  // clock
  always
  begin
    clk_s <= 1; #clk_2_t; clk_s <= 0; #clk_2_t; 
  end

  // TCK
  always
  begin
    tck_s <= 0; #tclk_2_t; tck_s <= 1; #tclk_2_t; 
  end

  // Load I-Mem - im_scan_length
  initial
  begin
    rst_s = 1;
    jtag_sw_rst(tclk_2_t);
    jtag_load_ir(tclk_2_t, 8'h80);

    //imScanAddr_s = { {(imem_addr_width-12){1'b0}}, 12'b111111110000 };
    //imScanData_s = {instr_width{4'ha}};
    //imScanWe_s   = 1;
    //imScanTdi_s  = {imScanAddr_s, imScanData_s, imScanWe_s};
    //jtag_shift_in_imdr_to_rti(tclk_2_t, imScanTdi_s);
    //imScanAddr_s = { {(imem_addr_width-12){1'b0}}, 12'b111111110100 };
    //imScanData_s = {instr_width{4'h5}};
    //imScanWe_s   = 1;
    //imScanTdi_s  = {imScanAddr_s, imScanData_s, imScanWe_s};
    //jtag_shift_in_imdr_to_rti(tclk_2_t, imScanTdi_s);
    // erase I-Mem
    jtag_shift_in_imdr_to_rti(tclk_2_t, 43'b0000000000_00000000000000000000000000000000_1); // LSB=we=1
    jtag_shift_in_imdr_to_rti(tclk_2_t, 43'b0000000100_00000000000000000000000000000000_1);
    jtag_shift_in_imdr_to_rti(tclk_2_t, 43'b0000001000_00000000000000000000000000000000_1);
    jtag_shift_in_imdr_to_rti(tclk_2_t, 43'b0000001100_00000000000000000000000000000000_1);
    jtag_shift_in_imdr_to_rti(tclk_2_t, 43'b0000010000_00000000000000000000000000000000_1);
    // load new program to I-Mem
    assign imScanAddr_s = 10'b0000000000;
    assign imScanData_s = iram_s[0];
    jtag_shift_in_imdr_to_rti(tclk_2_t, {imScanAddr_s, imScanData_s, 1'b1});
    assign imScanAddr_s = 10'b0000000100;
    assign imScanData_s = iram_s[1];
    jtag_shift_in_imdr_to_rti(tclk_2_t, {imScanAddr_s, imScanData_s, 1'b1});
    assign imScanAddr_s = 10'b0000001000;
    assign imScanData_s = iram_s[2];
    jtag_shift_in_imdr_to_rti(tclk_2_t, {imScanAddr_s, imScanData_s, 1'b1});
    assign imScanAddr_s = 10'b0000001100;
    assign imScanData_s = iram_s[3];
    jtag_shift_in_imdr_to_rti(tclk_2_t, {imScanAddr_s, imScanData_s, 1'b1});
    assign imScanAddr_s = 10'b0000010000;
    assign imScanData_s = iram_s[4];
    jtag_shift_in_imdr_to_rti(tclk_2_t, {imScanAddr_s, imScanData_s, 1'b1});

    jtag_shift_in_imdr_to_rti(tclk_2_t, 45'b000000000000_01001010101010101010101010001000_0);
    #(50*2*tclk_2_t);
    
    rst_s = 0;
    #(1*2*tclk_2_t);
    
  end

  // check results
  always @(negedge clk_s)
  begin
    if(cs_s === 1)
    begin
      $display("CS detected");
      //if((gpioAddr_s === 4)) 
        case(gpio_s)
          29      : begin $display("Instr 99 - lui - load I-Mem: 0x%0h", gpio_s);  $display("Simulation succeeded"); #100; #(1*2*clk_2_t); $fdisplay(fd,"%s - Load I-Mem: Test ok", get_time()); $fclose(fd); $stop; end
          default : begin $display("Unexpected GPIO: 0x%0h", gpio_s); $fdisplay(fd,"%s - Load I-Mem: Test fail", get_time()); $fclose(fd); $stop;  end
        endcase
      //else // (gpioAddr_s === 4)
      //begin
      //  $display("Simulating: time=%0t addr=0x%0h data=0x%0h cs=0x%0h+++",$time, gpioAddr_s, gpio_s, cs_s);
      //  $stop;
      //end
    end // cs_s
  end // negedge

//------------------------------------------
// Functions
//------------------------------------------

  task jtag_sw_rst(int clk_2_t);
  begin
    tms_s = 1; #(5*2*clk_2_t);
  end
  endtask // jtag_sw_rst

  task jtag_load_ir(int clk_2_t, logic [7:0] ir);
  begin
    // from reset
    tms_s = 0; #(2*clk_2_t); // Run-Test-Idle
    tms_s = 1; #(2*clk_2_t); // Select-DR-Scan
    tms_s = 1; #(2*clk_2_t); // Select-IR-Scan
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Capture-IR
    tdi_s = ir[7]; tms_s = 0; #(2*clk_2_t); // Shift-IR
    tdi_s = ir[6]; tms_s = 0; #(2*clk_2_t); // Shift-IR
    tdi_s = ir[5]; tms_s = 0; #(2*clk_2_t); // Shift-IR
    tdi_s = ir[4]; tms_s = 0; #(2*clk_2_t); // Shift-IR
    tdi_s = ir[3]; tms_s = 0; #(2*clk_2_t); // Shift-IR
    tdi_s = ir[2]; tms_s = 0; #(2*clk_2_t); // Shift-IR
    tdi_s = ir[1]; tms_s = 0; #(2*clk_2_t); // Shift-IR
    tdi_s = ir[0]; tms_s = 1; #(2*clk_2_t); // Exit1-IR
    tdi_s = 0; tms_s = 1; #(2*clk_2_t); // Update-IR
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Run-Test_idle
  end
  endtask // jtag_load_ir

  task jtag_shift_in_dr_to_pause(int clk_2_t, logic [sc01_length_in-1:0] dr);
  begin
    // from run-test-idle
    tdi_s = 0; tms_s = 1; #(2*clk_2_t); // Select-DR-Scan
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Capture-DR
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Shift-DR ??
    for(int i=sc01_length_in-1;i>0;i--)
    begin
      tdi_s = dr[i]; tms_s = 0; #(2*clk_2_t); // Shift-DR
    end
    tdi_s = dr[0]; tms_s = 1; #(2*clk_2_t); // Exit1-DR
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Pause-DR
  end
  endtask // jtag_shift_in_dr_to_pause

  task jtag_shift_out_dr(int clk_2_t);
  begin
    // from pause
    tdi_s = 0; tms_s = 1; #(2*clk_2_t); // Exit2-DR;
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Shift-DR; // shift out ??
    for(int i=sc01_length_out-1;i>0;i--)
    begin
      tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Shift-DR; // shift out
    end
    tdi_s = 0; tms_s = 1; #(2*clk_2_t); // Exit1-DR  // shift out
    tdi_s = 0; tms_s = 1; #(2*clk_2_t); // Update-DR;
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Run-Test_idle
  end
  endtask // jtag_shift_in_dr_to_pause

  task jtag_shift_in_imdr_to_rti(int clk_2_t, logic [im_length_in-1:0] dr);
  begin
    // from run-test-idle
    tdi_s = 0; tms_s = 1; #(2*clk_2_t); // Select-DR-Scan
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Capture-DR
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Shift-DR ??
    for(int i=im_length_in-1;i>0;i--)
    begin
      tdi_s = dr[i]; tms_s = 0; #(2*clk_2_t); // Shift-DR
    end
    tdi_s = dr[0]; tms_s = 1; #(2*clk_2_t); // Exit1-DR
    tdi_s = 0; tms_s = 1; #(2*clk_2_t); // Update-DR
    tdi_s = 0; tms_s = 0; #(2*clk_2_t); // Run-Test_idle
  end
  endtask // jtag_shift_in_imdr_to_pause

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
