//---------------------------------------------------------------
// Module: reuse_ht_sram_sp
// Function:
//   Single-read-port activation SRAM for in_proj h_t storage.
//   Each address stores one 4-lane vector (64-bit when TILE_SIZE=4, DATA_WIDTH=16).
//---------------------------------------------------------------
module reuse_ht_sram_sp #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int DEPTH = 32,
    parameter int ADDR_W = $clog2(DEPTH)
)(
    input  logic clk,
    input  logic rst_n,
    input  logic wr_en,
    input  logic [ADDR_W-1:0] wr_addr,
    input  logic signed [DATA_WIDTH-1:0] wr_data [TILE_SIZE-1:0],
    input  logic rd_en,
    input  logic [ADDR_W-1:0] rd_addr,
    output logic signed [DATA_WIDTH-1:0] rd_data [TILE_SIZE-1:0]
);
`ifndef SYNTHESIS
    logic [TILE_SIZE*DATA_WIDTH-1:0] mem_sim [DEPTH];
    logic [TILE_SIZE*DATA_WIDTH-1:0] q;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < DEPTH; i++)
                mem_sim[i] <= '0;
            q <= '0;
        end else begin
            if (wr_en) begin
                for (int i = 0; i < TILE_SIZE; i++)
                    mem_sim[wr_addr][i*DATA_WIDTH +: DATA_WIDTH] <= wr_data[i];
            end
            if (rd_en)
                q <= mem_sim[rd_addr];
        end
    end

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            rd_data[i] = q[i*DATA_WIDTH +: DATA_WIDTH];
    end
`else
    logic [TILE_SIZE*DATA_WIDTH-1:0] q;
    logic [TILE_SIZE*DATA_WIDTH-1:0] wr_pack;

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            wr_pack[i*DATA_WIDTH +: DATA_WIDTH] = wr_data[i];
    end

    inproj_ht_sram_ip u_ht_ip (
        .clka (clk),
        .ena  (wr_en),
        .wea  (wr_en),
        .addra(wr_addr),
        .dina (wr_pack),
        .douta(),
        .clkb (clk),
        .enb  (rd_en),
        .web  (1'b0),
        .addrb(rd_addr),
        .dinb ('0),
        .doutb(q)
    );

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            rd_data[i] = q[i*DATA_WIDTH +: DATA_WIDTH];
    end
`endif
endmodule
