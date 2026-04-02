//---------------------------------------------------------------
// Module: reuse_vec_out_sram
// Function:
//   Simple vector SRAM used for u_t / z_t outputs of in_proj.
//---------------------------------------------------------------
module reuse_vec_out_sram #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int DEPTH = 64,
    parameter int ADDR_W = $clog2(DEPTH)
)(
    input  logic clk,
    input  logic rst_n,
    input  logic wr_en,
    input  logic [ADDR_W-1:0] wr_addr,
    input  logic signed [DATA_WIDTH-1:0] wr_data [TILE_SIZE-1:0],
    input  logic rd_en,
    input  logic [ADDR_W-1:0] rd_addr,
    output logic signed [DATA_WIDTH-1:0] rd_data [TILE_SIZE-1:0],
    input  logic rd2_en,
    input  logic [ADDR_W-1:0] rd2_addr,
    output logic signed [DATA_WIDTH-1:0] rd2_data [TILE_SIZE-1:0]
);
`ifndef SYNTHESIS
    logic [TILE_SIZE*DATA_WIDTH-1:0] mem_sim [DEPTH];
    logic [TILE_SIZE*DATA_WIDTH-1:0] q;
    logic [TILE_SIZE*DATA_WIDTH-1:0] q2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < DEPTH; i++)
                mem_sim[i] <= '0;
            q <= '0;
            q2 <= '0;
        end else begin
            if (wr_en) begin
                for (int i = 0; i < TILE_SIZE; i++)
                    mem_sim[wr_addr][i*DATA_WIDTH +: DATA_WIDTH] <= wr_data[i];
            end
            if (rd_en)
                q <= mem_sim[rd_addr];
            if (rd2_en)
                q2 <= mem_sim[rd2_addr];
        end
    end

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            rd_data[i] = q[i*DATA_WIDTH +: DATA_WIDTH];
            rd2_data[i] = q2[i*DATA_WIDTH +: DATA_WIDTH];
        end
    end
`else
    logic [TILE_SIZE*DATA_WIDTH-1:0] q;
    logic [TILE_SIZE*DATA_WIDTH-1:0] q2;
    logic [TILE_SIZE*DATA_WIDTH-1:0] wr_pack;

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            wr_pack[i*DATA_WIDTH +: DATA_WIDTH] = wr_data[i];
    end

    reuse_vec_out_sram_ip #(
        .DATA_W (TILE_SIZE*DATA_WIDTH),
        .ADDR_W (ADDR_W)
    ) u_vec_ip (
        .clk     (clk),
        .wr_en   (wr_en),
        .wr_addr (wr_addr),
        .wr_data (wr_pack),
        .rd_en   (rd_en),
        .rd_addr (rd_addr),
        .rd_data (q),
        .rd2_en  (rd2_en),
        .rd2_addr(rd2_addr),
        .rd2_data(q2)
    );

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            rd_data[i] = q[i*DATA_WIDTH +: DATA_WIDTH];
            rd2_data[i] = q2[i*DATA_WIDTH +: DATA_WIDTH];
        end
    end
`endif
endmodule
