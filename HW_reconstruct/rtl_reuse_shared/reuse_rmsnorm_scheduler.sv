//---------------------------------------------------------------
// Module: reuse_rmsnorm_scheduler
// Function:
//   Standalone Q8.8 RMSNorm preprocessor for block input h.
//   - External h_wr_* writes raw h into a local SRAM
//   - start triggers two passes over raw h:
//       1) accumulate mean(x^2)
//       2) write y = x * gamma / rms into downstream h SRAM
//---------------------------------------------------------------
module reuse_rmsnorm_scheduler #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int H_DEPTH = 32,
    parameter int H_ADDR_W = $clog2(H_DEPTH),
    parameter int EPS_Q16 = 1
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
        ST_PREP_NORM,
        ST_NORM,
        ST_DONE
    } state_t;

    localparam int DIM = H_DEPTH * TILE_SIZE;

    state_t state;
    logic                  raw_rd_en;
    logic [H_ADDR_W-1:0]   raw_rd_addr;
    logic signed [DATA_WIDTH-1:0] raw_rd_data [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] gamma_rd_data [TILE_SIZE-1:0];

    logic [H_ADDR_W:0] issue_addr;
    logic [H_ADDR_W-1:0] rd_addr_d0;
    logic [H_ADDR_W-1:0] rd_addr_d1;
    logic rd_valid_d0;
    logic rd_valid_d1;

    logic [63:0] sum_sq_accum;
    logic [31:0] rms_q88_reg;
    logic [63:0] sum_sq_next;
    logic [63:0] mean_sq_q16;
    logic [63:0] rms_q88_next;
    logic signed [63:0] lane_num;
    logic signed [63:0] lane_val;

    function automatic [63:0] isqrt_u64(input [63:0] x_in);
        reg [63:0] x;
        reg [63:0] res;
        reg [63:0] step;
        begin
            x = x_in;
            res = 0;
            step = 64'h4000_0000_0000_0000;
            while (step > x)
                step = step >> 2;
            while (step != 0) begin
                if (x >= (res + step)) begin
                    x = x - (res + step);
                    res = (res >> 1) + step;
                end else begin
                    res = res >> 1;
                end
                step = step >> 2;
            end
            isqrt_u64 = res;
        end
    endfunction

    function automatic logic signed [DATA_WIDTH-1:0] clamp_s16(input signed [63:0] x);
        begin
            if (x > 32767)
                clamp_s16 = 16'sd32767;
            else if (x < -32768)
                clamp_s16 = -16'sd32768;
            else
                clamp_s16 = x[DATA_WIDTH-1:0];
        end
    endfunction

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
        .ADDR_W    (H_ADDR_W)
    ) u_gamma_mem (
        .clk     (clk),
        .wr_en   (gamma_wr_en),
        .wr_addr (gamma_wr_addr),
        .wr_data (gamma_wr_data),
        .en      (raw_rd_en),
        .addr    (raw_rd_addr),
        .rd_data (gamma_rd_data)
    );

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state <= ST_IDLE;
            issue_addr <= '0;
            rd_addr_d0 <= '0;
            rd_addr_d1 <= '0;
            rd_valid_d0 <= 1'b0;
            rd_valid_d1 <= 1'b0;
            sum_sq_accum <= '0;
            rms_q88_reg <= 32'd1;
            norm_wr_en <= 1'b0;
            norm_wr_addr <= '0;
            norm_wr_data <= '{default:'0};
        end else begin
            norm_wr_en <= 1'b0;

            if (raw_rd_en) begin
                issue_addr <= issue_addr + 1'b1;
            end
            rd_valid_d0 <= raw_rd_en;
            rd_valid_d1 <= rd_valid_d0;
            if (raw_rd_en)
                rd_addr_d0 <= raw_rd_addr;
            rd_addr_d1 <= rd_addr_d0;

            case (state)
                ST_IDLE: begin
                    issue_addr <= '0;
                    rd_addr_d0 <= '0;
                    rd_addr_d1 <= '0;
                    rd_valid_d0 <= 1'b0;
                    rd_valid_d1 <= 1'b0;
                    sum_sq_accum <= '0;
                    rms_q88_reg <= 32'd1;
                    if (enable && start)
                        state <= ST_ACCUM;
                end

                ST_ACCUM: begin
                    if (rd_valid_d1) begin
                        sum_sq_next = sum_sq_accum;
                        for (int lane = 0; lane < TILE_SIZE; lane++) begin
                            lane_val = $signed(raw_rd_data[lane]);
                            sum_sq_next = sum_sq_next + (lane_val * lane_val);
                        end
                        sum_sq_accum <= sum_sq_next[63:0];

                        if (rd_addr_d1 == H_DEPTH-1) begin
                            mean_sq_q16 = (sum_sq_next + (DIM / 2)) / DIM;
                            rms_q88_next = isqrt_u64(mean_sq_q16 + EPS_Q16);
                            if (rms_q88_next == 0)
                                rms_q88_next = 1;
                            rms_q88_reg <= rms_q88_next[31:0];
                            issue_addr <= '0;
                            rd_addr_d0 <= '0;
                            rd_addr_d1 <= '0;
                            rd_valid_d0 <= 1'b0;
                            rd_valid_d1 <= 1'b0;
                            state <= ST_PREP_NORM;
                        end
                    end
                end

                ST_PREP_NORM: begin
                    issue_addr <= '0;
                    rd_addr_d0 <= '0;
                    rd_addr_d1 <= '0;
                    rd_valid_d0 <= 1'b0;
                    rd_valid_d1 <= 1'b0;
                    state <= ST_NORM;
                end

                ST_NORM: begin
                    if (rd_valid_d1) begin
                        norm_wr_en <= 1'b1;
                        norm_wr_addr <= rd_addr_d1;
                        for (int lane = 0; lane < TILE_SIZE; lane++) begin
                            lane_num = longint'($signed(raw_rd_data[lane])) * longint'($signed(gamma_rd_data[lane]));
                            norm_wr_data[lane] <= clamp_s16(div_round_nearest_signed(lane_num, rms_q88_reg));
                        end
                        if (rd_addr_d1 == H_DEPTH-1) begin
                            rd_addr_d0 <= '0;
                            rd_addr_d1 <= '0;
                            rd_valid_d0 <= 1'b0;
                            rd_valid_d1 <= 1'b0;
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
