module reuse_rmsnorm_scheduler #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int H_DEPTH = 32,
    parameter int H_ADDR_W = $clog2(H_DEPTH),
    parameter int EPS_Q16 = 1,
    parameter bit RMS_APPROX_RECIP = 0,
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
        ST_NORM,
        ST_DONE
    } state_t;

    localparam int DIM = H_DEPTH * TILE_SIZE;
    localparam int RECIP_FRAC_BITS = 24;
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
    logic [31:0] recip_q24_reg;
    logic [65:0] isqrt_rem;
    logic [63:0] isqrt_op;
    logic [31:0] isqrt_root;
    logic [5:0]  isqrt_iter;

    logic signed [63:0] norm_lane_q88 [TILE_SIZE-1:0];
    logic [63:0] norm_lane_q88_bits [TILE_SIZE-1:0];
    logic [15:0] norm_quant_out [TILE_SIZE-1:0];
    logic [15:0] norm_dummy_scale [TILE_SIZE-1:0];

    function automatic signed [63:0] div_round_nearest_signed(
        input signed [63:0] num,
        input [31:0] den
    );
        reg [63:0] abs_num;
        begin
            if (den == 0)
                div_round_nearest_signed = 0;
            else if (num >= 0)
                div_round_nearest_signed = (num + $signed({32'd0, (den >> 1)})) / $signed({32'd0, den});
            else begin
                abs_num = -num;
                div_round_nearest_signed = -$signed((abs_num + (den >> 1)) / den);
            end
        end
    endfunction

    function automatic [31:0] recip_pow2_approx_q24(
        input [31:0] den
    );
        integer msb_idx;
        integer sh;
        begin
            if (den == 0) begin
                recip_pow2_approx_q24 = (32'd1 << RECIP_FRAC_BITS);
            end else begin
                msb_idx = 0;
                for (integer i = 0; i < 32; i++) begin
                    if (den[i]) begin
                        msb_idx = i;
                    end
                end
                sh = RECIP_FRAC_BITS - msb_idx;
                if (sh < 0) sh = 0;
                if (sh > 31) sh = 31;
                recip_pow2_approx_q24 = (32'd1 << sh);
            end
        end
    endfunction

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
        .in_vec    (norm_lane_q88_bits),
        .scale_vec (norm_dummy_scale),
        .out_vec   (norm_quant_out)
    );

    always_comb begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
            logic signed [31:0] mul_xg;
            logic signed [63:0] mul_recip;
            logic signed [63:0] rounded;
            if (RMS_APPROX_RECIP) begin
                mul_xg = $signed(raw_rd_data[lane]) * $signed(gamma_rd_data[lane]);
                mul_recip = mul_xg * $signed({1'b0, recip_q24_reg});
                if (mul_recip >= 0)
                    rounded = mul_recip + (64'sd1 <<< (RECIP_FRAC_BITS - 1));
                else
                    rounded = mul_recip - (64'sd1 <<< (RECIP_FRAC_BITS - 1));
                norm_lane_q88[lane] = rounded >>> RECIP_FRAC_BITS;
            end else begin
                norm_lane_q88[lane] = div_round_nearest_signed(
                    longint'($signed(raw_rd_data[lane])) * longint'($signed(gamma_rd_data[lane])),
                    rms_q88_reg
                );
            end
            norm_lane_q88_bits[lane] = norm_lane_q88[lane];
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
            recip_q24_reg <= (32'd1 << RECIP_FRAC_BITS);
            isqrt_rem <= '0;
            isqrt_op <= '0;
            isqrt_root <= '0;
            isqrt_iter <= '0;
            norm_wr_en <= 1'b0;
            norm_wr_addr <= '0;
            norm_wr_data <= '{default:'0};
        end else begin
            norm_wr_en <= 1'b0;

            if (raw_rd_en)
                issue_addr <= issue_addr + 1'b1;
            rd_valid_d0 <= raw_rd_en;
            if (raw_rd_en)
                rd_addr_d0 <= raw_rd_addr;

            case (state)
                ST_IDLE: begin
                    issue_addr <= '0;
                    rd_addr_d0 <= '0;
                    rd_valid_d0 <= 1'b0;
                    sum_sq_accum <= '0;
                    mean_sq_q16_reg <= 64'd0;
                    rms_q88_reg <= 32'd1;
                    recip_q24_reg <= (32'd1 << RECIP_FRAC_BITS);
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
                    if (RMS_APPROX_RECIP) begin
                        recip_q24_reg <= recip_pow2_approx_q24(rms_q88_reg);
                    end else begin
                        if (rms_q88_reg == 0)
                            recip_q24_reg <= (32'd1 << RECIP_FRAC_BITS);
                        else
                            recip_q24_reg <= ((32'd1 << RECIP_FRAC_BITS) + (rms_q88_reg >> 1)) / rms_q88_reg;
                    end
                    state <= ST_NORM;
                end

                ST_NORM: begin
                    if (rd_valid_d0) begin
                        norm_wr_en <= 1'b1;
                        norm_wr_addr <= rd_addr_d0;
                        for (int lane = 0; lane < TILE_SIZE; lane++) begin
                            norm_wr_data[lane] <= $signed(norm_quant_out[lane]);
                        end
                        if (rd_addr_d0 == H_DEPTH-1) begin
                            rd_addr_d0 <= '0;
                            rd_valid_d0 <= 1'b0;
                            state <= ST_DONE;
                        end
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
