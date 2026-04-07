`timescale 1ns/1ps

module reuse_z_stream_reader #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int Z_DEPTH    = 64,
    parameter int Z_ADDR_W   = $clog2(Z_DEPTH)
)(
    input  logic clk,
    input  logic rst_n,

    input  logic enable,
    input  logic start,
    output logic busy,
    output logic done,

    output logic                         z_rd_en,
    output logic [Z_ADDR_W-1:0]          z_rd_addr,
    input  logic signed [DATA_WIDTH-1:0] z_rd_data [TILE_SIZE-1:0],

    output logic                         out_valid,
    input  logic                         out_ready,
    output logic signed [DATA_WIDTH-1:0] out_vec [TILE_SIZE-1:0]
);
    typedef enum logic [1:0] {IDLE, RUN, DONE_S} state_t;
    state_t state;

    logic [Z_ADDR_W-1:0] rd_addr_reg;
    logic [Z_ADDR_W:0]   issue_count;
    logic [Z_ADDR_W:0]   recv_count;
    logic                rd_pending;

    assign busy = (state == RUN);
    assign done = (state == DONE_S);

    always_comb begin
        z_rd_en   = 1'b0;
        z_rd_addr = rd_addr_reg;

        if (state == RUN && !rd_pending && (issue_count < Z_DEPTH) && (!out_valid || out_ready)) begin
            z_rd_en   = 1'b1;
            z_rd_addr = rd_addr_reg;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            rd_addr_reg <= '0;
            issue_count <= '0;
            recv_count  <= '0;
            rd_pending  <= 1'b0;
            out_valid   <= 1'b0;
            for (int i = 0; i < TILE_SIZE; i++)
                out_vec[i] <= '0;
        end else begin
            if (out_valid && out_ready)
                out_valid <= 1'b0;

            case (state)
                IDLE: begin
                    rd_addr_reg <= '0;
                    issue_count <= '0;
                    recv_count  <= '0;
                    rd_pending  <= 1'b0;
                    if (enable && start)
                        state <= RUN;
                end

                RUN: begin
                    if (z_rd_en) begin
                        rd_pending  <= 1'b1;
                        rd_addr_reg <= rd_addr_reg + 1'b1;
                        issue_count <= issue_count + 1'b1;
                    end

                    if (rd_pending) begin
                        for (int i = 0; i < TILE_SIZE; i++)
                            out_vec[i] <= z_rd_data[i];
                        out_valid  <= 1'b1;
                        rd_pending <= 1'b0;
                        recv_count <= recv_count + 1'b1;
                    end

                    if ((recv_count == Z_DEPTH) && !rd_pending && !out_valid)
                        state <= DONE_S;
                end

                DONE_S: begin
                    if (!start)
                        state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
