`timescale 1ns/1ps
module reuse_mamba_h_stream_loader #(
    parameter TILE_SIZE  = 4,
    parameter DATA_WIDTH = 16,
    parameter H_ADDR_W   = 5
) (
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    input  wire [15:0] rows_cfg,
    output reg  busy,
    output reg  done,

    input  wire                              s_axis_tvalid,
    output wire                              s_axis_tready,
    input  wire [TILE_SIZE*DATA_WIDTH-1:0]   s_axis_tdata,
    input  wire                              s_axis_tlast,

    output reg                               h_wr_en,
    output reg  [H_ADDR_W-1:0]               h_wr_addr,
    output wire [TILE_SIZE*DATA_WIDTH-1:0]   h_wr_data
);
    reg [15:0] rows_left;
    reg [H_ADDR_W-1:0] wr_addr_q;

    assign s_axis_tready = busy;
    assign h_wr_data = s_axis_tdata;

    always @(posedge clk) begin
        if (!rst_n) begin
            busy      <= 1'b0;
            done      <= 1'b0;
            h_wr_en   <= 1'b0;
            h_wr_addr <= {H_ADDR_W{1'b0}};
            rows_left <= 16'd0;
            wr_addr_q <= {H_ADDR_W{1'b0}};
        end else begin
            done    <= 1'b0;
            h_wr_en <= 1'b0;

            if (start && !busy) begin
                busy      <= 1'b1;
                rows_left <= rows_cfg;
                wr_addr_q <= {H_ADDR_W{1'b0}};
                h_wr_addr <= {H_ADDR_W{1'b0}};
            end else if (busy && s_axis_tvalid && s_axis_tready) begin
                h_wr_en   <= 1'b1;
                h_wr_addr <= wr_addr_q;
                wr_addr_q <= wr_addr_q + 1'b1;

                if (rows_left != 16'd0)
                    rows_left <= rows_left - 1'b1;

                // Complete exactly after rows_cfg beats. Do not terminate early on
                // upstream TLAST; loader framing is row-count based.
                if (rows_left == 16'd1) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end
            end
        end
    end
endmodule
