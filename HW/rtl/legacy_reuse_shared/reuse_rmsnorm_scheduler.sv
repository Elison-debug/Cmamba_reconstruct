module reuse_rmsnorm_scheduler #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int H_DEPTH = 32,
    parameter int H_ADDR_W = $clog2(H_DEPTH),
    parameter int EPS_Q16 = 1,
    parameter string NORM_GAMMA_INIT_FILE = "",
    parameter int NORM_OUT_ROUND_MODE = 1,
    parameter int NORM_OUT_SAT_MODE   = 1
)(
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    input  logic start,
    output logic busy,
    output logic done,

    input  logic                         h_wr_en,
    input  logic [H_ADDR_W-1:0]          h_wr_addr,
    input  logic signed [DATA_WIDTH-1:0] h_wr_data [TILE_SIZE-1:0],
    input  logic                         gamma_wr_en,
    input  logic [H_ADDR_W-1:0]          gamma_wr_addr,
    input  logic signed [DATA_WIDTH-1:0] gamma_wr_data [TILE_SIZE-1:0],

    output logic                         norm_wr_en,
    output logic [H_ADDR_W-1:0]          norm_wr_addr,
    output logic signed [DATA_WIDTH-1:0] norm_wr_data [TILE_SIZE-1:0]
);
    typedef enum logic [2:0] {
        ST_IDLE,
        ST_ACCUM,
        ST_ISQRT,
        ST_PREP_NORM,
        ST_RECIP,
        ST_NORM,
        ST_DONE
    } state_t;

    localparam int DIM = H_DEPTH * TILE_SIZE;
    localparam int RECIP_FRAC_EXACT = 30;
    state_t state;

    logic                        raw_rd_en;
    logic [H_ADDR_W-1:0]         raw_rd_addr;
    logic signed [DATA_WIDTH-1:0] raw_rd_data [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] gamma_rd_data [TILE_SIZE-1:0];

    logic [H_ADDR_W:0] issue_addr;
    logic [H_ADDR_W-1:0] rd_addr_d0;
    logic rd_valid_d0;

    logic [63:0] sum_sq_accum;
    logic [63:0] sum_sq_next;
    logic signed [63:0] lane_val;

    logic [63:0] mean_sq_q16_reg;
    logic [31:0] rms_q88_reg;
    logic [31:0] recip_q_reg;
    logic [63:0] recip_num_reg;
    logic [31:0] recip_den_reg;
    logic [63:0] recip_rem_reg;
    logic [31:0] recip_quot_reg;
    logic [5:0]  recip_iter_reg;
    logic [65:0] isqrt_rem;
    logic [63:0] isqrt_op;
    logic [31:0] isqrt_root;
    logic [5:0]  isqrt_iter;

    logic signed [63:0] norm_lane_q88 [TILE_SIZE-1:0];
    logic [63:0] norm_lane_q88_bits [TILE_SIZE-1:0];
    logic signed [63:0] norm_lane_q88_calc [TILE_SIZE-1:0];
    logic [63:0] norm_lane_q88_calc_bits [TILE_SIZE-1:0];
    logic                         norm_src_valid;
    logic [H_ADDR_W-1:0]          norm_src_addr;
    logic signed [DATA_WIDTH-1:0] norm_src_raw [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] norm_src_gamma [TILE_SIZE-1:0];
    logic                         norm_pipe_valid;
    logic [H_ADDR_W-1:0]          norm_pipe_addr;
    logic signed [63:0]           norm_pipe_q88 [TILE_SIZE-1:0];
    logic [63:0]                  norm_pipe_q88_bits [TILE_SIZE-1:0];
    logic [15:0] norm_quant_out [TILE_SIZE-1:0];
    logic [15:0] norm_dummy_scale [TILE_SIZE-1:0];

    assign busy = (state != ST_IDLE && state != ST_DONE);
    assign done = (state == ST_DONE);
    assign raw_rd_en = enable && ((state == ST_ACCUM) || (state == ST_NORM)) && (issue_addr < H_DEPTH);
    assign raw_rd_addr = issue_addr[H_ADDR_W-1:0];

    reuse_norm_raw_h_sram #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (H_DEPTH),
        .ADDR_W    (H_ADDR_W)
    ) u_raw_h_sram (
        .clk    (clk),
        .rst_n  (rst_n),
        .wr_en  (h_wr_en),
        .wr_addr(h_wr_addr),
        .wr_data(h_wr_data),
        .rd_en  (raw_rd_en),
        .rd_addr(raw_rd_addr),
        .rd_data(raw_rd_data)
    );

    reuse_norm_weight_mem #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (H_DEPTH),
        .ADDR_W    (H_ADDR_W),
        .INIT_FILE (NORM_GAMMA_INIT_FILE)
    ) u_gamma_mem (
        .clk    (clk),
        .en     (raw_rd_en),
        .addr   (raw_rd_addr),
        .rd_data(gamma_rd_data)
    );

    requant_round_sat_engine #(
        .TILE_SIZE        (TILE_SIZE),
        .IN_W             (64),
        .OUT_W            (DATA_WIDTH),
        .SHIFT            (0),
        .SCALE_W          (16),
        .SCALE_FRAC_BITS  (0),
        .SIGNED_IN        (1),
        .SIGNED_OUT       (1),
        .USE_SCALE        (0),
        .ROUND_MODE       (NORM_OUT_ROUND_MODE),
        .SAT_MODE         (NORM_OUT_SAT_MODE)
    ) u_norm_out_quant (
        .in_vec    (norm_pipe_q88_bits),
        .scale_vec (norm_dummy_scale),
        .out_vec   (norm_quant_out)
    );

    always_comb begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
            logic signed [31:0] mul_xg;
            logic signed [63:0] mul_recip;
            logic signed [63:0] rounded;
            mul_xg = $signed(norm_src_raw[lane]) * $signed(norm_src_gamma[lane]);
            mul_recip = mul_xg * $signed({1'b0, recip_q_reg});
            if (mul_recip >= 0)
                rounded = mul_recip + (64'sd1 <<< (RECIP_FRAC_EXACT - 1));
            else
                rounded = mul_recip - (64'sd1 <<< (RECIP_FRAC_EXACT - 1));
            norm_lane_q88_calc[lane] = rounded >>> RECIP_FRAC_EXACT;
            norm_lane_q88_calc_bits[lane] = norm_lane_q88_calc[lane];
            norm_lane_q88[lane] = norm_pipe_q88[lane];
            norm_lane_q88_bits[lane] = norm_pipe_q88_bits[lane];
            norm_dummy_scale[lane] = 16'd1;
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state <= ST_IDLE;
            issue_addr <= '0;
            rd_addr_d0 <= '0;
            rd_valid_d0 <= 1'b0;
            sum_sq_accum <= '0;
            mean_sq_q16_reg <= 64'd0;
            rms_q88_reg <= 32'd1;
            recip_q_reg <= (32'd1 << RECIP_FRAC_EXACT);
            recip_num_reg <= '0;
            recip_den_reg <= 32'd1;
            recip_rem_reg <= '0;
            recip_quot_reg <= '0;
            recip_iter_reg <= '0;
            isqrt_rem <= '0;
            isqrt_op <= '0;
            isqrt_root <= '0;
            isqrt_iter <= '0;
            norm_wr_en <= 1'b0;
            norm_wr_addr <= '0;
            norm_wr_data <= '{default:'0};
            norm_pipe_valid <= 1'b0;
            norm_pipe_addr <= '0;
            norm_pipe_q88 <= '{default:'0};
            norm_pipe_q88_bits <= '{default:'0};
            norm_src_valid <= 1'b0;
            norm_src_addr <= '0;
            norm_src_raw <= '{default:'0};
            norm_src_gamma <= '{default:'0};
        end else begin
            norm_wr_en <= 1'b0;
            if (norm_pipe_valid) begin
                norm_wr_en <= 1'b1;
                norm_wr_addr <= norm_pipe_addr;
                for (int lane = 0; lane < TILE_SIZE; lane++) begin
                    norm_wr_data[lane] <= $signed(norm_quant_out[lane]);
                end
            end

            if (raw_rd_en)
                issue_addr <= issue_addr + 1'b1;
            rd_valid_d0 <= raw_rd_en;
            if (raw_rd_en)
                rd_addr_d0 <= raw_rd_addr;

            norm_src_valid <= rd_valid_d0;
            norm_src_addr <= rd_addr_d0;
            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                norm_src_raw[lane] <= raw_rd_data[lane];
                norm_src_gamma[lane] <= gamma_rd_data[lane];
            end

            norm_pipe_valid <= norm_src_valid;
            norm_pipe_addr <= norm_src_addr;
            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                norm_pipe_q88[lane] <= norm_lane_q88_calc[lane];
                norm_pipe_q88_bits[lane] <= norm_lane_q88_calc_bits[lane];
            end

            case (state)
                ST_IDLE: begin
                    issue_addr <= '0;
                    rd_addr_d0 <= '0;
                    rd_valid_d0 <= 1'b0;
                    sum_sq_accum <= '0;
                    mean_sq_q16_reg <= 64'd0;
                    rms_q88_reg <= 32'd1;
                    recip_q_reg <= (32'd1 << RECIP_FRAC_EXACT);
                    recip_num_reg <= '0;
                    recip_den_reg <= 32'd1;
                    recip_rem_reg <= '0;
                    recip_quot_reg <= '0;
                    recip_iter_reg <= '0;
                    norm_pipe_valid <= 1'b0;
                    norm_pipe_addr <= '0;
                    norm_pipe_q88 <= '{default:'0};
                    norm_pipe_q88_bits <= '{default:'0};
                    norm_src_valid <= 1'b0;
                    norm_src_addr <= '0;
                    norm_src_raw <= '{default:'0};
                    norm_src_gamma <= '{default:'0};
                    if (enable && start)
                        state <= ST_ACCUM;
                end

                ST_ACCUM: begin
                    if (rd_valid_d0) begin
                        sum_sq_next = sum_sq_accum;
                        for (int lane = 0; lane < TILE_SIZE; lane++) begin
                            lane_val = $signed(raw_rd_data[lane]);
                            sum_sq_next = sum_sq_next + (lane_val * lane_val);
                        end
                        sum_sq_accum <= sum_sq_next;

                        if (rd_addr_d0 == H_DEPTH-1) begin
                            mean_sq_q16_reg <= ((sum_sq_next + (DIM / 2)) / DIM) + EPS_Q16;
                            isqrt_rem <= '0;
                            isqrt_op <= ((sum_sq_next + (DIM / 2)) / DIM) + EPS_Q16;
                            isqrt_root <= '0;
                            isqrt_iter <= '0;
                            issue_addr <= '0;
                            rd_addr_d0 <= '0;
                            rd_valid_d0 <= 1'b0;
                            state <= ST_ISQRT;
                        end
                    end
                end

                ST_ISQRT: begin
                    logic [65:0] rem_shift;
                    logic [63:0] op_shift;
                    logic [32:0] root_shift;
                    logic [65:0] trial;
                    logic [31:0] root_next;

                    rem_shift = {isqrt_rem[63:0], isqrt_op[63:62]};
                    op_shift = {isqrt_op[61:0], 2'b00};
                    root_shift = {isqrt_root, 1'b0};
                    trial = {32'd0, root_shift, 1'b1};
                    if (rem_shift >= trial) begin
                        isqrt_rem <= rem_shift - trial;
                        root_next = root_shift[31:0] + 1'b1;
                        isqrt_root <= root_next;
                    end else begin
                        isqrt_rem <= rem_shift;
                        root_next = root_shift[31:0];
                        isqrt_root <= root_next;
                    end
                    isqrt_op <= op_shift;
                    isqrt_iter <= isqrt_iter + 1'b1;
                    if (isqrt_iter == 6'd31) begin
                        rms_q88_reg <= (root_next == 0) ? 32'd1 : root_next;
                        state <= ST_PREP_NORM;
                    end
                end

                ST_PREP_NORM: begin
                    issue_addr <= '0;
                    rd_addr_d0 <= '0;
                    rd_valid_d0 <= 1'b0;
                    if (rms_q88_reg == 0) begin
                        recip_q_reg <= (32'd1 << RECIP_FRAC_EXACT);
                        state <= ST_NORM;
                    end else begin
                        recip_num_reg <= ((64'd1 << RECIP_FRAC_EXACT) + (rms_q88_reg >> 1));
                        recip_den_reg <= rms_q88_reg;
                        recip_rem_reg <= 64'd0;
                        recip_quot_reg <= 32'd0;
                        recip_iter_reg <= 6'd32;
                        state <= ST_RECIP;
                    end
                end

                ST_RECIP: begin
                    logic [63:0] rem_shift;
                    logic [63:0] rem_next;
                    logic [31:0] quot_next;
                    logic        bit_in;

                    bit_in = recip_num_reg[recip_iter_reg-1];
                    rem_shift = {recip_rem_reg[62:0], bit_in};
                    quot_next = recip_quot_reg;

                    if (rem_shift >= {32'd0, recip_den_reg}) begin
                        rem_next = rem_shift - {32'd0, recip_den_reg};
                        quot_next[recip_iter_reg-1] = 1'b1;
                    end else begin
                        rem_next = rem_shift;
                    end

                    recip_rem_reg <= rem_next;
                    recip_quot_reg <= quot_next;
                    recip_iter_reg <= recip_iter_reg - 1'b1;

                    if (recip_iter_reg == 6'd1) begin
                        recip_q_reg <= quot_next;
                        state <= ST_NORM;
                    end
                end

                ST_NORM: begin
                    if (norm_pipe_valid && (norm_pipe_addr == H_DEPTH-1) && !norm_src_valid && !rd_valid_d0) begin
                        rd_addr_d0 <= '0;
                        rd_valid_d0 <= 1'b0;
                        norm_src_valid <= 1'b0;
                        norm_pipe_valid <= 1'b0;
                        state <= ST_DONE;
                    end
                end

                ST_DONE: begin
                    if (!start)
                        state <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule
