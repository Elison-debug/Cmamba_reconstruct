`timescale 1ns/1ps
module reuse_mamba_g_stream_loader #(
    parameter TILE_SIZE  = 4,
    parameter DATA_WIDTH = 16,
    parameter G_DEPTH    = 64,
    parameter G_ADDR_W   = $clog2(G_DEPTH)
) (
    input  wire                             clk,
    input  wire                             rst_n,

    // load phase: receive one AXIS packet from board/DMA and store locally
    input  wire                             load_start,
    input  wire [15:0]                      rows_cfg,
    output reg                              load_busy,
    output reg                              load_done,

    input  wire                             s_axis_tvalid,
    output wire                             s_axis_tready,
    input  wire [TILE_SIZE*DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire                             s_axis_tlast,

    // play phase: feed the inner core using the timing it expects
    input  wire                             play_start,
    output reg                              play_busy,
    output reg                              play_done,

    output wire                             g_axis_tvalid,
    input  wire                             g_axis_tready,
    output wire [TILE_SIZE*DATA_WIDTH-1:0]  g_axis_tdata
);
    localparam PACK_W = TILE_SIZE*DATA_WIDTH;

    reg [PACK_W-1:0] g_mem [0:G_DEPTH-1];
    reg [15:0]       rows_left_load;
    reg [15:0]       rows_loaded;
    reg [G_ADDR_W-1:0] wr_addr_q;
    reg [G_ADDR_W-1:0] rd_addr_q;

    wire load_fire = load_busy && s_axis_tvalid && s_axis_tready;
    wire play_fire = play_busy && g_axis_tvalid && g_axis_tready;

    assign s_axis_tready = load_busy;
    assign g_axis_tvalid = play_busy;
    assign g_axis_tdata  = g_mem[rd_addr_q];

    integer i;
    always @(posedge clk) begin
        if (!rst_n) begin
            load_busy      <= 1'b0;
            load_done      <= 1'b0;
            play_busy      <= 1'b0;
            play_done      <= 1'b0;
            rows_left_load <= 16'd0;
            rows_loaded    <= 16'd0;
            wr_addr_q      <= {G_ADDR_W{1'b0}};
            rd_addr_q      <= {G_ADDR_W{1'b0}};
            for (i = 0; i < G_DEPTH; i = i + 1)
                g_mem[i] <= {PACK_W{1'b0}};
        end else begin
            load_done <= 1'b0;
            play_done <= 1'b0;

            if (load_start && !load_busy && !play_busy) begin
                load_busy      <= 1'b1;
                rows_left_load <= rows_cfg;
                rows_loaded    <= 16'd0;
                wr_addr_q      <= {G_ADDR_W{1'b0}};
                rd_addr_q      <= {G_ADDR_W{1'b0}};
            end

            if (load_fire) begin
                g_mem[wr_addr_q] <= s_axis_tdata;
                wr_addr_q        <= wr_addr_q + 1'b1;
                rows_loaded      <= rows_loaded + 1'b1;
                if (rows_left_load != 16'd0)
                    rows_left_load <= rows_left_load - 1'b1;

                if ((rows_left_load == 16'd1) || s_axis_tlast) begin
                    load_busy <= 1'b0;
                    load_done <= 1'b1;
                end
            end

            if (play_start && !load_busy && !play_busy && (rows_loaded != 16'd0)) begin
                play_busy <= 1'b1;
                rd_addr_q <= {G_ADDR_W{1'b0}};
            end else if (play_fire) begin
                if (rd_addr_q == rows_loaded - 1'b1) begin
                    play_busy <= 1'b0;
                    play_done <= 1'b1;
                end else begin
                    rd_addr_q <= rd_addr_q + 1'b1;
                end
            end
        end
    end
endmodule
