`timescale 1ns/1ps

module mm_gated_state_update_stage #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int STATE_ADDR_W = 6,
    parameter int SCALE_W = 32
)(
    input  logic clk,
    input  logic rst_n,
    input  logic state_frame_start,
    input  logic state_continuous_en,
    input  logic state_force_clear,
    output logic state_clear_done,
    input  logic in_valid,
    output logic in_ready,
    input  logic [STATE_ADDR_W-1:0] in_addr,
    input  logic [DATA_WIDTH-1:0] lam_vec [TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] u_vec [TILE_SIZE-1:0],
    input  logic [SCALE_W-1:0] u_to_state_scale_vec [TILE_SIZE-1:0],
    input  logic [SCALE_W-1:0] state_to_q88_scale_vec [TILE_SIZE-1:0],
    output logic out_valid,
    input  logic out_ready,
    output logic [STATE_ADDR_W-1:0] out_addr,
    output logic signed [DATA_WIDTH-1:0] h_q88_vec [TILE_SIZE-1:0]
);
    logic signed [DATA_WIDTH-1:0] state_mem [0:(1<<STATE_ADDR_W)-1][TILE_SIZE-1:0];
    logic full;
    logic [STATE_ADDR_W-1:0] addr_q;
    logic [STATE_ADDR_W-1:0] wr_addr_q;
    logic wr_valid_q;
    logic signed [DATA_WIDTH-1:0] wr_data_q [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] out_q [TILE_SIZE-1:0];

    function automatic logic signed [63:0] f_rshift_rne(
        input logic signed [63:0] x,
        input int shift
    );
        logic signed [63:0] q;
        logic signed [63:0] r;
        logic signed [63:0] base;
        logic signed [63:0] half;
        begin
            if (shift <= 0) begin
                return x;
            end
            base = 64'sd1 <<< shift;
            q = x / base;
            r = x % base;
            if (r < 0) begin
                r = r + base;
                q = q - 1;
            end
            half = base >>> 1;
            if ((r > half) || ((r == half) && q[0])) begin
                q = q + 1;
            end
            return q;
        end
    endfunction

    function automatic logic signed [DATA_WIDTH-1:0] f_clip_s16(
        input logic signed [63:0] x
    );
        begin
            if (x > 64'sd32767) begin
                return 16'sd32767;
            end
            if (x < -64'sd32768) begin
                return -16'sd32768;
            end
            return x[DATA_WIDTH-1:0];
        end
    endfunction

    assign in_ready = !full || (out_valid && out_ready);
    assign out_valid = full;
    assign out_addr = addr_q;

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            h_q88_vec[i] = out_q[i];
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            full <= 1'b0;
            addr_q <= '0;
            wr_addr_q <= '0;
            wr_valid_q <= 1'b0;
            state_clear_done <= 1'b0;
            for (int a = 0; a < (1<<STATE_ADDR_W); a++) begin
                for (int i = 0; i < TILE_SIZE; i++) begin
                    state_mem[a][i] <= '0;
                end
            end
            for (int i = 0; i < TILE_SIZE; i++) begin
                wr_data_q[i] <= '0;
                out_q[i] <= '0;
            end
        end else begin
            state_clear_done <= 1'b0;
            if (state_force_clear || (state_frame_start && !state_continuous_en)) begin
                full <= 1'b0;
                addr_q <= '0;
                wr_addr_q <= '0;
                wr_valid_q <= 1'b0;
                for (int a = 0; a < (1<<STATE_ADDR_W); a++) begin
                    for (int i = 0; i < TILE_SIZE; i++) begin
                        state_mem[a][i] <= '0;
                    end
                end
                for (int i = 0; i < TILE_SIZE; i++) begin
                    wr_data_q[i] <= '0;
                    out_q[i] <= '0;
                end
                state_clear_done <= 1'b1;
            end else
            if (in_valid && in_ready) begin
                addr_q <= in_addr;
                wr_addr_q <= in_addr + 1'b1;
                wr_valid_q <= 1'b1;
                for (int i = 0; i < TILE_SIZE; i++) begin
                    logic signed [63:0] u_state_mul;
                    logic signed [63:0] u_state_q15;
                    logic signed [63:0] hold_term;
                    logic signed [63:0] write_term;
                    logic signed [63:0] new_state_acc;
                    logic signed [63:0] new_state_q15;
                    logic signed [63:0] state_to_q88_mul;
                    logic signed [DATA_WIDTH-1:0] s_prev_i;
                    logic [DATA_WIDTH-1:0] lam_q15_i;
                    logic [DATA_WIDTH-1:0] one_minus_q15_i;

                    s_prev_i = (wr_valid_q && (wr_addr_q == in_addr)) ? wr_data_q[i] : state_mem[in_addr][i];

                    u_state_mul = $signed(u_vec[i]) * $signed({1'b0, u_to_state_scale_vec[i]});
                    u_state_q15 = f_rshift_rne(u_state_mul, 16);
                    u_state_q15 = $signed(f_clip_s16(u_state_q15));

                    lam_q15_i = lam_vec[i] >> 1;
                    one_minus_q15_i = 16'd32768 - lam_q15_i;

                    hold_term = $signed({1'b0, lam_q15_i}) * $signed(s_prev_i);
                    write_term = $signed({1'b0, one_minus_q15_i}) * $signed(u_state_q15[DATA_WIDTH-1:0]);
                    new_state_acc = hold_term + write_term;
                    new_state_q15 = f_rshift_rne(new_state_acc, 15);
                    new_state_q15 = $signed(f_clip_s16(new_state_q15));

                    state_mem[in_addr + 1'b1][i] <= new_state_q15[DATA_WIDTH-1:0];
                    wr_data_q[i] <= new_state_q15[DATA_WIDTH-1:0];

                    state_to_q88_mul = $signed(new_state_q15[DATA_WIDTH-1:0]) * $signed({1'b0, state_to_q88_scale_vec[i]});
                    out_q[i] <= f_clip_s16(f_rshift_rne(state_to_q88_mul, 16));
                end
                full <= 1'b1;
            end else if (out_valid && out_ready) begin
                full <= 1'b0;
            end
        end
    end
endmodule


