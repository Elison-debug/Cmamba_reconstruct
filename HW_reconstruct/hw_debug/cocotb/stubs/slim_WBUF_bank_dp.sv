`timescale 1ns/1ps

module slim_WBUF_bank_dp (
  input  wire         clka,
  input  wire         ena,
  input  wire [9:0]   addra,
  output reg [255:0]  douta,
  input  wire         clkb,
  input  wire         enb,
  input  wire [9:0]   addrb,
  output reg [255:0]  doutb
);
  reg [255:0] mem [0:682];
  integer i;
  initial begin
    for (i = 0; i < 683; i = i + 1) mem[i] = 256'h0;
    douta = 256'h0;
    doutb = 256'h0;
  end
  always @(posedge clka) begin
    if (ena) douta <= mem[addra];
  end
  always @(posedge clkb) begin
    if (enb) doutb <= mem[addrb];
  end
endmodule
