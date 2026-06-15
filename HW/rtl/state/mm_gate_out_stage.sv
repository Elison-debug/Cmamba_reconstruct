`timescale 1ns/1ps

module mm_gate_out_stage #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int STATE_ADDR_W = 6
)(
    input  logic clk,
    input  logic rst_n,
    input  logic h_valid,
    output logic h_ready,
    input  logic [STATE_ADDR_W-1:0] h_addr,
    input  logic signed [DATA_WIDTH-1:0] h_vec [TILE_SIZE-1:0],
    input  logic g_valid,
    output logic g_ready,
    input  logic signed [DATA_WIDTH-1:0] g_vec [TILE_SIZE-1:0],
    output logic out_valid,
    input  logic out_ready,
    output logic [STATE_ADDR_W-1:0] out_addr,
    output logic signed [DATA_WIDTH-1:0] out_vec [TILE_SIZE-1:0]
);
    logic gate_full;
    logic signed [DATA_WIDTH-1:0] gate_q [TILE_SIZE-1:0];

    logic out_full;
    logic [STATE_ADDR_W-1:0] out_addr_q;
    logic signed [DATA_WIDTH-1:0] out_vec_q [TILE_SIZE-1:0];

    logic accept_h;
    logic accept_g;

    assign out_valid = out_full;
    assign out_addr = out_addr_q;

    assign g_ready = !gate_full;
    assign h_ready = gate_full && (!out_full || out_ready);

    assign accept_g = g_valid && g_ready;
    assign accept_h = h_valid && h_ready;

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            out_vec[i] = out_vec_q[i];
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            gate_full <= 1'b0;
            out_full <= 1'b0;
            out_addr_q <= '0;
            for (int i = 0; i < TILE_SIZE; i++) begin
                gate_q[i] <= '0;
                out_vec_q[i] <= '0;
            end
        end else begin
            if (out_full && out_ready) begin
                out_full <= 1'b0;
            end

            if (accept_g) begin
                gate_full <= 1'b1;
                for (int i = 0; i < TILE_SIZE; i++) begin
                    gate_q[i] <= g_vec[i];
                end
            end

            if (accept_h) begin
                gate_full <= 1'b0;
                out_full <= 1'b1;
                out_addr_q <= h_addr;
                for (int i = 0; i < TILE_SIZE; i++) begin
                    out_vec_q[i] <= ($signed(h_vec[i]) * $signed(gate_q[i])) >>> 8;
                end
            end
        end
    end
endmodule


