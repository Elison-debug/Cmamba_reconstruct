module bias_ROM (
  input  wire        clka,
  input  wire        ena,
  input  wire [5:0]  addra,
  output reg  [63:0] douta
);
  (* rom_style = "block" *) reg [63:0] mem [0:63];
  integer i;

  initial begin
    for (i = 0; i < 64; i = i + 1)
      mem[i] = 64'd0;
  end

  always @(posedge clka) begin
    if (ena)
      douta <= mem[addra];
  end
endmodule
