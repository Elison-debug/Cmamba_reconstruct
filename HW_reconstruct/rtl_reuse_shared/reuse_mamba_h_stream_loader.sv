`timescale 1ns/1ps
module reuse_mamba_h_stream_loader #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int H_ADDR_W   = 5
) (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic [15:0] rows_cfg,
    output logic busy,
    output logic done,

    input  logic                         s_axis_tvalid,
    output logic                         s_axis_tready,
    input  logic [TILE_SIZE*DATA_WIDTH-1:0] s_axis_tdata,
    input  logic                         s_axis_tlast,

    output logic                         h_wr_en,
    output logic [H_ADDR_W-1:0]          h_wr_addr,
    output logic signed [DATA_WIDTH-1:0] h_wr_data [TILE_SIZE-1:0]
);
    logic [15:0] rows_left;
    logic [H_ADDR_W-1:0] wr_addr_q;

    assign s_axis_tready = busy;

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            h_wr_data[i] = s_axis_tdata[i*DATA_WIDTH +: DATA_WIDTH];
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            busy     <= 1'b0;
            done     <= 1'b0;
            h_wr_en  <= 1'b0;
            h_wr_addr<= '0;
            rows_left<= '0;
            wr_addr_q<= '0;
        end else begin
            done    <= 1'b0;
            h_wr_en <= 1'b0;

            if (start && !busy) begin
                busy      <= 1'b1;
                rows_left <= rows_cfg;
                wr_addr_q <= '0;
                h_wr_addr <= '0;
            end else if (busy && s_axis_tvalid && s_axis_tready) begin
                h_wr_en   <= 1'b1;
                h_wr_addr <= wr_addr_q;
                wr_addr_q <= wr_addr_q + 1'b1;
                if (rows_left != 0)
                    rows_left <= rows_left - 1'b1;
                if ((rows_left == 16'd1) || s_axis_tlast) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end
            end
        end
    end
endmodule
