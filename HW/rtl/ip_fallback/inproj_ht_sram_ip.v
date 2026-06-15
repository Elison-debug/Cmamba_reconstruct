module inproj_ht_sram_ip (
  input  wire        clka,
  input  wire        ena,
  input  wire [0:0]  wea,
  input  wire [4:0]  addra,
  input  wire [63:0] dina,
  output reg  [63:0] douta,
  input  wire        clkb,
  input  wire        enb,
  input  wire [0:0]  web,
  input  wire [4:0]  addrb,
  input  wire [63:0] dinb,
  output reg  [63:0] doutb
);
  (* ram_style = "block" *) reg [63:0] mem [0:31];

  always @(posedge clka) begin
    if (ena) begin
      douta <= mem[addra];
      if (wea[0])
        mem[addra] <= dina;
    end
  end

  always @(posedge clkb) begin
    if (enb) begin
      doutb <= mem[addrb];
      if (web[0])
        mem[addrb] <= dinb;
    end
  end
endmodule
