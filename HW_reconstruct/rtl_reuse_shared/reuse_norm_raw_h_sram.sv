//---------------------------------------------------------------
// Module: reuse_norm_raw_h_sram
// Function:
//   Raw-H SRAM used by RMSNorm pre-processing.
//   Simulation exposes mem_sim for TB preload.
//   Synthesis maps to the same inproj_ht_sram_ip BRAM used by in_proj.
//---------------------------------------------------------------
module reuse_norm_raw_h_sram #(
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
    logic [TILE_SIZE*DATA_WIDTH-1:0] q_d1;
    logic [TILE_SIZE*DATA_WIDTH-1:0] q;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            for (int i = 0; i < DEPTH; i++)
                mem_sim[i] <= '0;
            q_d1 <= '0;
            q <= '0;
        end else begin
            if (wr_en) begin
                for (int i = 0; i < TILE_SIZE; i++)
                    mem_sim[wr_addr][i*DATA_WIDTH +: DATA_WIDTH] <= wr_data[i];
            end
            if (rd_en)
                q_d1 <= mem_sim[rd_addr];
            q <= q_d1;
        end
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
`endif

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            rd_data[i] = q[i*DATA_WIDTH +: DATA_WIDTH];
    end
endmodule
