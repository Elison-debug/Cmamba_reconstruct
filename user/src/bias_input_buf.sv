module bias_input_buf #(
    parameter int ADDR_W = 6,      // 64-depth
    parameter int DATA_W = 16,
    parameter int TILE_SIZE = 4
)(
    input  logic clk,
    input  logic en,
    input  logic [ADDR_W-1:0] addr,
    output logic signed [DATA_W-1:0] dout_vec [TILE_SIZE-1:0]
);

    logic [63:0] rom_dout;

`ifdef SYNTHESIS
    bias_rom u_bias_rom (
        .clka(clk),
        .ena(en),
        .addra(addr),
        .douta(rom_dout)
    );
`else
    localparam int DEPTH = 1<<ADDR_W;
    logic [63:0] mem_sim [DEPTH];

    initial begin
        for (int i=0;i<DEPTH;i++) mem_sim[i] = '0;
    end

    always_ff @(posedge clk) begin
        if (en)
            rom_dout <= mem_sim[addr];
    end
`endif

    always_comb begin
        if (!en) begin
            dout_vec = '{default:'0};
        end else begin
            dout_vec[0] = $signed(rom_dout[15:0]);
            dout_vec[1] = $signed(rom_dout[31:16]);
            dout_vec[2] = $signed(rom_dout[47:32]);
            dout_vec[3] = $signed(rom_dout[63:48]);
        end
    end

endmodule
