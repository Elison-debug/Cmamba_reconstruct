`timescale 1ns/1ps

module s_buffer (
  input  wire        clka,
  input  wire        ena,
  input  wire [0:0]  wea,
  input  wire [5:0]  addra,
  input  wire [63:0] dina,
  output reg  [63:0] douta,
  input  wire        clkb,
  input  wire        enb,
  input  wire [0:0]  web,
  input  wire [5:0]  addrb,
  input  wire [63:0] dinb,
  output reg  [63:0] doutb
);
  reg [63:0] mem [0:63];
  integer i;
  initial begin
    for (i = 0; i < 64; i = i + 1) mem[i] = 64'h0;
    douta = 64'h0;
    doutb = 64'h0;
  end
  always @(posedge clka) begin
    if (ena) begin
      if (wea[0]) mem[addra] <= dina;
      douta <= mem[addra];
    end
  end
  always @(posedge clkb) begin
    if (enb) begin
      if (web[0]) mem[addrb] <= dinb;
      doutb <= mem[addrb];
    end
  end
endmodule
