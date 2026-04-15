//---------------------------------------------------------------
// Module: reuse_ht_sram
// Function:
//   4-read-port activation SRAM for h_t storage.
//   Each address stores one 4-lane vector. The scheduler reads four
//   consecutive addresses per cycle to build one 16-dim input chunk.
//---------------------------------------------------------------
module reuse_ht_sram #(
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
    input  logic [ADDR_W-1:0] rd_addr0,
    input  logic [ADDR_W-1:0] rd_addr1,
    input  logic [ADDR_W-1:0] rd_addr2,
    input  logic [ADDR_W-1:0] rd_addr3,
    output logic signed [DATA_WIDTH-1:0] rd_data0 [TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0] rd_data1 [TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0] rd_data2 [TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0] rd_data3 [TILE_SIZE-1:0]
);
    logic [TILE_SIZE*DATA_WIDTH-1:0] q0, q1, q2, q3;
    logic [TILE_SIZE*DATA_WIDTH-1:0] wr_pack;

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            wr_pack[i*DATA_WIDTH +: DATA_WIDTH] = wr_data[i];
    end

    reuse_ht_multi_copy_ip #(
        .DATA_W (TILE_SIZE*DATA_WIDTH),
        .ADDR_W (ADDR_W)
    ) u_ht_ip (
        .clk     (clk),
        .wr_en   (wr_en),
        .wr_addr (wr_addr),
        .wr_data (wr_pack),
        .rd_en   (rd_en),
        .rd_addr0(rd_addr0),
        .rd_addr1(rd_addr1),
        .rd_addr2(rd_addr2),
        .rd_addr3(rd_addr3),
        .rd_data0(q0),
        .rd_data1(q1),
        .rd_data2(q2),
        .rd_data3(q3)
    );

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            rd_data0[i] = q0[i*DATA_WIDTH +: DATA_WIDTH];
            rd_data1[i] = q1[i*DATA_WIDTH +: DATA_WIDTH];
            rd_data2[i] = q2[i*DATA_WIDTH +: DATA_WIDTH];
            rd_data3[i] = q3[i*DATA_WIDTH +: DATA_WIDTH];
        end
    end
endmodule

