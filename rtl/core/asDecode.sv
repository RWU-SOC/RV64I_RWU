`timescale 1ns/1ps

import as_pack::*;

module as_decode (input  logic [daddr_width-1:0] addr_i,
                  output logic [chipsel-1:0]     cs_o);

  always_comb 
  begin
    case (addr_i) inside
      [64'h00000000_00000000:64'h00000000_0000FFFF]: begin cs_o = 4'b0001; end // interner Speicherbereich; 64 kbit, 8 kByte
      [64'h00000000_00010000:64'h00000000_0001000F]: begin cs_o = 4'b0010; end // externer (GPIO) Speicherbereich
      [64'h00000000_00010010:64'h00000000_0001001F]: begin cs_o = 4'b0100; end // externer (QSPI) Speicherbereich
      [64'h00000000_00010020:64'h00000000_0001002F]: begin cs_o = 4'b1000; end // externer (CGU) Speicherbereich
      default:                                       begin cs_o = 4'b0000; end
    endcase
  end
  
  
endmodule : as_decode
