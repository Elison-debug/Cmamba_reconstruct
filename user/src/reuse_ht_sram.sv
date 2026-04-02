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
`ifndef SYNTHESIS
    logic [TILE_SIZE*DATA_WIDTH-1:0] mem_sim [DEPTH];
    logic [TILE_SIZE*DATA_WIDTH-1:0] q0, q1, q2, q3;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < DEPTH; i++)
                mem_sim[i] <= '0;
            q0 <= '0; q1 <= '0; q2 <= '0; q3 <= '0;
        end else begin
            if (wr_en) begin
                for (int i = 0; i < TILE_SIZE; i++)
                    mem_sim[wr_addr][i*DATA_WIDTH +: DATA_WIDTH] <= wr_data[i];
            end
            if (rd_en) begin
                q0 <= mem_sim[rd_addr0];
                q1 <= mem_sim[rd_addr1];
                q2 <= mem_sim[rd_addr2];
                q3 <= mem_sim[rd_addr3];
            end
        end
    end

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            rd_data0[i] = q0[i*DATA_WIDTH +: DATA_WIDTH];
            rd_data1[i] = q1[i*DATA_WIDTH +: DATA_WIDTH];
            rd_data2[i] = q2[i*DATA_WIDTH +: DATA_WIDTH];
            rd_data3[i] = q3[i*DATA_WIDTH +: DATA_WIDTH];
        end
    end
`else
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
`endif
endmodule

//---------------------------------------------------------------
// Module: reuse_ht_sram_sp
// Function:
//   Single-read-port activation SRAM for in_proj h_t storage.
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
