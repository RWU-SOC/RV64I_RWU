`timescale 1ns/1ps

import as_pack::*;

module tap_fsm ( input  logic tck_i,          // Base clock
                 input  logic trst_i,         // Asynchronous reset
                 input  logic tms_i,          // Mode select
                 output logic ir_shift_o,     // For Mux: either shift tdi/tdo or capture data; Monitor only
                 output logic ir_clock_o,     // Clock the IR shift register (Latch?); Monitor only
                 output logic ir_upd_o,       // Clock (activate) the IR hold register; Monitor only
                 output logic dr_shift_o,     // For Mux: either shift tdi/tdo or capture data
                 output logic dr_clock_o,     // Clock the DR shift register (Latch?)
                 output logic dr_upd_o,       // Clock (activate) the DR hold register
                 output logic jtag_rst_o,     // SW-reset of the FSM
                 output logic irdr_select_o,  // Selects between DR or IR TDO output
                 output logic tdo_ena_o       // Drives TDO either to 'Z' or to enable
                );
  typedef enum logic [3:0] {reset_st, run_test_idle_st,
                      select_dr_scan_st, capture_dr_st, shift_dr_st, exit1_dr_st, pause_dr_st, exit2_dr_st, update_dr_st,
                      select_ir_scan_st, capture_ir_st, shift_ir_st, exit1_ir_st, pause_ir_st, exit2_ir_st, update_ir_st} statetype_t;
  statetype_t state_s, nextstate_s;

  logic	trst_s;
  logic	ir_shift_s;    // For Mux: either shift tdi/tdo or capture data
  logic	ir_clock_s;    // Clock the IR shift register (Latch?)
  logic	ir_upd_s;      // Clock (activate) the IR hold register
  logic	ir_cap_s;      // Load parallel data to IR

  logic	dr_shift_s;    // For Mux: either shift tdi/tdo or capture data
  logic	dr_clock_s;    // Clock the DR shift register (Latch?)
  logic	dr_upd_s;      // Clock (activate) the DR hold register
  logic	dr_cap_s;      // Load parallel data to DR

  logic	jtag_rst_s;    // Reset state; also software reset
  logic	irdr_select_s; // Select either IR or DR for TDO
  logic	tdo_ena_s;     // Select TDO or 'Z'

  // make reset invertible if needed (active high <-> active low)
  assign trst_s = trst_i;

  // FSM block 2: delay
  always_ff @(posedge tck_i, posedge trst_s)
  begin
    if(trst_s == 1)
      state_s <= reset_st;
    else
      state_s <= nextstate_s;
  end

  // FSM block 1: nextstate, input CLC
  always_comb 
  begin
    nextstate_s = state_s;
    case(state_s)
      reset_st :          if (tms_i == 0)
                            nextstate_s = run_test_idle_st;
      run_test_idle_st :  if (tms_i == 1)
                            nextstate_s = select_dr_scan_st;
      select_dr_scan_st : if (tms_i == 1)
                            nextstate_s = select_ir_scan_st;
                          else // 0
                            nextstate_s = capture_dr_st;
      capture_dr_st :     if (tms_i == 0)
                            nextstate_s = shift_dr_st;
                          else // 1
                            nextstate_s = exit1_dr_st;
      shift_dr_st :       if (tms_i == 1)
                            nextstate_s = exit1_dr_st;
      exit1_dr_st :       if (tms_i == 0)
                            nextstate_s = pause_dr_st;
                          else // 1
                            nextstate_s = update_dr_st;
      pause_dr_st :       if (tms_i == 1)
                            nextstate_s = exit2_dr_st;
      exit2_dr_st :       if (tms_i == 0)
                            nextstate_s = shift_dr_st;
                          else // 1
                            nextstate_s = update_dr_st;
      update_dr_st :      if (tms_i == 0)
                            nextstate_s = run_test_idle_st;
                          else // 1
                            nextstate_s = select_dr_scan_st;
      select_ir_scan_st : if (tms_i == 1)
                            nextstate_s = reset_st;
                           else // 0
                            nextstate_s = capture_ir_st;
      capture_ir_st :      if (tms_i == 0)
                             nextstate_s = shift_ir_st;
                           else // 1
                             nextstate_s = exit1_ir_st;
      shift_ir_st :        if (tms_i == 1)
                             nextstate_s = exit1_ir_st;
      exit1_ir_st :        if (tms_i == 0)
                             nextstate_s = pause_ir_st;
                           else // 1
                             nextstate_s = update_ir_st;
      pause_ir_st :        if (tms_i == 1)
                             nextstate_s = exit2_ir_st;
      exit2_ir_st :        if (tms_i == 0)
                             nextstate_s = shift_ir_st;
                           else // 1
                             nextstate_s = update_ir_st;
      update_ir_st :       if (tms_i == 0)
                             nextstate_s = run_test_idle_st;
                           else // 1
                             nextstate_s = select_dr_scan_st;
      default :            nextstate_s = reset_st;
    endcase
  end // always_comb

  //----------------------------------------------------------------
  // FSM block 3: output CLC
  //----------------------------------------------------------------
  assign ir_cap_s      = (state_s == capture_ir_st) ? 1 : 0;
  //assign ir_cap_o      = ir_cap_s;
  assign ir_shift_s    = (state_s == shift_ir_st) ? 1 : 0; // Sync. to neg. TCK?
  assign ir_shift_o    = ir_shift_s;
  assign ir_upd_s      = (state_s == update_ir_st) ? 1 : 0;
  assign ir_upd_o      = ir_upd_s;
  assign ir_clock_s    = ((state_s == shift_ir_st) | (state_s == capture_ir_st)) ? 1 : 0; // Sync. to neg. TCK?
  assign ir_clock_o    = ir_clock_s;
  assign dr_cap_s      = (state_s == capture_dr_st) ? 1 : 0;
  //assign dr_cap_o      = dr_cap_s;
  assign dr_shift_s    = (state_s == shift_dr_st) ? 1 : 0; // Sync. to neg. TCK?
  assign dr_shift_o    = dr_shift_s;
  assign dr_upd_s      = (state_s == update_dr_st) ? 1 : 0;
  assign dr_upd_o      = dr_upd_s;
  assign dr_clock_s    = ((state_s == shift_dr_st) | (state_s == capture_dr_st)) ? 1 : 0; // Sync. to neg. TCK?
  assign dr_clock_o    = dr_clock_s;
  assign jtag_rst_s    = (state_s == reset_st) ? 1 : 0; // Sync. to neg. TCK?
  assign jtag_rst_o    = jtag_rst_s;
  assign irdr_select_s = ((state_s == select_ir_scan_st) | (state_s == select_dr_scan_st) |
                          (state_s == capture_dr_st)     | (state_s == shift_dr_st)       |
                          (state_s == exit1_dr_st)       | (state_s == pause_dr_st)       | 
                          (state_s == exit2_dr_st)       | (state_s == update_dr_st)) ? 0 : 1;
  assign irdr_select_o = irdr_select_s;
  assign tdo_ena_s     = ((state_s == shift_ir_st) | (state_s == shift_dr_st) | 
                          (state_s == exit1_dr_st) | (state_s == exit1_ir_st)) ? 1 : 0; // Sync. to neg. TCK?
  assign tdo_ena_o     = tdo_ena_s;

endmodule : tap_fsm


