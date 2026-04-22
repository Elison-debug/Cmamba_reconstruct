`timescale 1ns/1ps

module reuse_mamba_4block_chain_top #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8,
    parameter int N_BANK     = 6,
    parameter int WDEPTH     = 1024,
    parameter int WADDR_W    = $clog2(WDEPTH),
    parameter int DATA_W     = 256,
    parameter int XT_ADDR_W  = 6,
    parameter int D          = 256,
    parameter int PIPE_LAT   = 4,
    parameter int ADDR_BITS  = 11,
    parameter string LUT_FILE = "sigmoid_lut_q016_2048.hex",
    parameter int S_ADDR_W   = 6,
    parameter int G_FRAC_BITS = 8,
    parameter string STAGE_DIR_B0 = "",
    parameter string STAGE_DIR_B1 = "",
    parameter string STAGE_DIR_B2 = "",
    parameter string STAGE_DIR_B3 = ""
) (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    output logic busy,
    output logic done,

    input  logic                         h_wr_en,
    input  logic [4:0]                   h_wr_addr,
    input  logic signed [DATA_WIDTH-1:0] h_wr_data [TILE_SIZE-1:0],

    output logic                         y_valid,
    input  logic                         y_ready,
    output logic signed [DATA_WIDTH-1:0] y_data [TILE_SIZE-1:0]
);
    localparam int H_ROWS = 32;
    localparam int U_ROWS = 64;

    function automatic logic signed [DATA_WIDTH-1:0] sat_add_s16(
        input logic signed [DATA_WIDTH-1:0] a,
        input logic signed [DATA_WIDTH-1:0] b
    );
        logic signed [DATA_WIDTH:0] s;
        begin
            s = $signed(a) + $signed(b);
            if (s > 17'sd32767) sat_add_s16 = 16'sd32767;
            else if (s < -17'sd32768) sat_add_s16 = -16'sd32768;
            else sat_add_s16 = s[DATA_WIDTH-1:0];
        end
    endfunction

    localparam string B0_IN0 = {STAGE_DIR_B0, "/inproj_wbuf_bank0.mem"};
    localparam string B0_IN1 = {STAGE_DIR_B0, "/inproj_wbuf_bank1.mem"};
    localparam string B0_IN2 = {STAGE_DIR_B0, "/inproj_wbuf_bank2.mem"};
    localparam string B0_IN3 = {STAGE_DIR_B0, "/inproj_wbuf_bank3.mem"};
    localparam string B0_IN4 = {STAGE_DIR_B0, "/inproj_wbuf_bank4.mem"};
    localparam string B0_IN5 = {STAGE_DIR_B0, "/inproj_wbuf_bank5.mem"};
    localparam string B0_INS = {STAGE_DIR_B0, "/inproj_scale_q15.mem"};
    localparam string B0_DT0 = {STAGE_DIR_B0, "/dt_wbuf_bank0.mem"};
    localparam string B0_DT1 = {STAGE_DIR_B0, "/dt_wbuf_bank1.mem"};
    localparam string B0_DT2 = {STAGE_DIR_B0, "/dt_wbuf_bank2.mem"};
    localparam string B0_DT3 = {STAGE_DIR_B0, "/dt_wbuf_bank3.mem"};
    localparam string B0_DTS = {STAGE_DIR_B0, "/dt_scale_q15.mem"};
    localparam string B0_OUT0 = {STAGE_DIR_B0, "/outproj_wbuf_bank0.mem"};
    localparam string B0_OUT1 = {STAGE_DIR_B0, "/outproj_wbuf_bank1.mem"};
    localparam string B0_OUT2 = {STAGE_DIR_B0, "/outproj_wbuf_bank2.mem"};
    localparam string B0_OUT3 = {STAGE_DIR_B0, "/outproj_wbuf_bank3.mem"};
    localparam string B0_OUT4 = {STAGE_DIR_B0, "/outproj_wbuf_bank4.mem"};
    localparam string B0_OUT5 = {STAGE_DIR_B0, "/outproj_wbuf_bank5.mem"};
    localparam string B0_OUTS = {STAGE_DIR_B0, "/outproj_scale_q15.mem"};
    localparam string B0_GAM  = {STAGE_DIR_B0, "/norm_gamma_s16_q8p8.mem"};
    localparam string B0_BIAS = {STAGE_DIR_B0, "/bias_ROM.mem"};
    localparam string B0_SUS  = {STAGE_DIR_B0, "/state_u_to_state_q16.mem"};
    localparam string B0_STQ  = {STAGE_DIR_B0, "/state_to_q88_q16.mem"};

    localparam string B1_IN0 = {STAGE_DIR_B1, "/inproj_wbuf_bank0.mem"};
    localparam string B1_IN1 = {STAGE_DIR_B1, "/inproj_wbuf_bank1.mem"};
    localparam string B1_IN2 = {STAGE_DIR_B1, "/inproj_wbuf_bank2.mem"};
    localparam string B1_IN3 = {STAGE_DIR_B1, "/inproj_wbuf_bank3.mem"};
    localparam string B1_IN4 = {STAGE_DIR_B1, "/inproj_wbuf_bank4.mem"};
    localparam string B1_IN5 = {STAGE_DIR_B1, "/inproj_wbuf_bank5.mem"};
    localparam string B1_INS = {STAGE_DIR_B1, "/inproj_scale_q15.mem"};
    localparam string B1_DT0 = {STAGE_DIR_B1, "/dt_wbuf_bank0.mem"};
    localparam string B1_DT1 = {STAGE_DIR_B1, "/dt_wbuf_bank1.mem"};
    localparam string B1_DT2 = {STAGE_DIR_B1, "/dt_wbuf_bank2.mem"};
    localparam string B1_DT3 = {STAGE_DIR_B1, "/dt_wbuf_bank3.mem"};
    localparam string B1_DTS = {STAGE_DIR_B1, "/dt_scale_q15.mem"};
    localparam string B1_OUT0 = {STAGE_DIR_B1, "/outproj_wbuf_bank0.mem"};
    localparam string B1_OUT1 = {STAGE_DIR_B1, "/outproj_wbuf_bank1.mem"};
    localparam string B1_OUT2 = {STAGE_DIR_B1, "/outproj_wbuf_bank2.mem"};
    localparam string B1_OUT3 = {STAGE_DIR_B1, "/outproj_wbuf_bank3.mem"};
    localparam string B1_OUT4 = {STAGE_DIR_B1, "/outproj_wbuf_bank4.mem"};
    localparam string B1_OUT5 = {STAGE_DIR_B1, "/outproj_wbuf_bank5.mem"};
    localparam string B1_OUTS = {STAGE_DIR_B1, "/outproj_scale_q15.mem"};
    localparam string B1_GAM  = {STAGE_DIR_B1, "/norm_gamma_s16_q8p8.mem"};
    localparam string B1_BIAS = {STAGE_DIR_B1, "/bias_ROM.mem"};
    localparam string B1_SUS  = {STAGE_DIR_B1, "/state_u_to_state_q16.mem"};
    localparam string B1_STQ  = {STAGE_DIR_B1, "/state_to_q88_q16.mem"};

    localparam string B2_IN0 = {STAGE_DIR_B2, "/inproj_wbuf_bank0.mem"};
    localparam string B2_IN1 = {STAGE_DIR_B2, "/inproj_wbuf_bank1.mem"};
    localparam string B2_IN2 = {STAGE_DIR_B2, "/inproj_wbuf_bank2.mem"};
    localparam string B2_IN3 = {STAGE_DIR_B2, "/inproj_wbuf_bank3.mem"};
    localparam string B2_IN4 = {STAGE_DIR_B2, "/inproj_wbuf_bank4.mem"};
    localparam string B2_IN5 = {STAGE_DIR_B2, "/inproj_wbuf_bank5.mem"};
    localparam string B2_INS = {STAGE_DIR_B2, "/inproj_scale_q15.mem"};
    localparam string B2_DT0 = {STAGE_DIR_B2, "/dt_wbuf_bank0.mem"};
    localparam string B2_DT1 = {STAGE_DIR_B2, "/dt_wbuf_bank1.mem"};
    localparam string B2_DT2 = {STAGE_DIR_B2, "/dt_wbuf_bank2.mem"};
    localparam string B2_DT3 = {STAGE_DIR_B2, "/dt_wbuf_bank3.mem"};
    localparam string B2_DTS = {STAGE_DIR_B2, "/dt_scale_q15.mem"};
    localparam string B2_OUT0 = {STAGE_DIR_B2, "/outproj_wbuf_bank0.mem"};
    localparam string B2_OUT1 = {STAGE_DIR_B2, "/outproj_wbuf_bank1.mem"};
    localparam string B2_OUT2 = {STAGE_DIR_B2, "/outproj_wbuf_bank2.mem"};
    localparam string B2_OUT3 = {STAGE_DIR_B2, "/outproj_wbuf_bank3.mem"};
    localparam string B2_OUT4 = {STAGE_DIR_B2, "/outproj_wbuf_bank4.mem"};
    localparam string B2_OUT5 = {STAGE_DIR_B2, "/outproj_wbuf_bank5.mem"};
    localparam string B2_OUTS = {STAGE_DIR_B2, "/outproj_scale_q15.mem"};
    localparam string B2_GAM  = {STAGE_DIR_B2, "/norm_gamma_s16_q8p8.mem"};
    localparam string B2_BIAS = {STAGE_DIR_B2, "/bias_ROM.mem"};
    localparam string B2_SUS  = {STAGE_DIR_B2, "/state_u_to_state_q16.mem"};
    localparam string B2_STQ  = {STAGE_DIR_B2, "/state_to_q88_q16.mem"};

    localparam string B3_IN0 = {STAGE_DIR_B3, "/inproj_wbuf_bank0.mem"};
    localparam string B3_IN1 = {STAGE_DIR_B3, "/inproj_wbuf_bank1.mem"};
    localparam string B3_IN2 = {STAGE_DIR_B3, "/inproj_wbuf_bank2.mem"};
    localparam string B3_IN3 = {STAGE_DIR_B3, "/inproj_wbuf_bank3.mem"};
    localparam string B3_IN4 = {STAGE_DIR_B3, "/inproj_wbuf_bank4.mem"};
    localparam string B3_IN5 = {STAGE_DIR_B3, "/inproj_wbuf_bank5.mem"};
    localparam string B3_INS = {STAGE_DIR_B3, "/inproj_scale_q15.mem"};
    localparam string B3_DT0 = {STAGE_DIR_B3, "/dt_wbuf_bank0.mem"};
    localparam string B3_DT1 = {STAGE_DIR_B3, "/dt_wbuf_bank1.mem"};
    localparam string B3_DT2 = {STAGE_DIR_B3, "/dt_wbuf_bank2.mem"};
    localparam string B3_DT3 = {STAGE_DIR_B3, "/dt_wbuf_bank3.mem"};
    localparam string B3_DTS = {STAGE_DIR_B3, "/dt_scale_q15.mem"};
    localparam string B3_OUT0 = {STAGE_DIR_B3, "/outproj_wbuf_bank0.mem"};
    localparam string B3_OUT1 = {STAGE_DIR_B3, "/outproj_wbuf_bank1.mem"};
    localparam string B3_OUT2 = {STAGE_DIR_B3, "/outproj_wbuf_bank2.mem"};
    localparam string B3_OUT3 = {STAGE_DIR_B3, "/outproj_wbuf_bank3.mem"};
    localparam string B3_OUT4 = {STAGE_DIR_B3, "/outproj_wbuf_bank4.mem"};
    localparam string B3_OUT5 = {STAGE_DIR_B3, "/outproj_wbuf_bank5.mem"};
    localparam string B3_OUTS = {STAGE_DIR_B3, "/outproj_scale_q15.mem"};
    localparam string B3_GAM  = {STAGE_DIR_B3, "/norm_gamma_s16_q8p8.mem"};
    localparam string B3_BIAS = {STAGE_DIR_B3, "/bias_ROM.mem"};
    localparam string B3_SUS  = {STAGE_DIR_B3, "/state_u_to_state_q16.mem"};
    localparam string B3_STQ  = {STAGE_DIR_B3, "/state_to_q88_q16.mem"};

    logic blk_start_pulse [0:3];
    logic blk_busy        [0:3];
    logic blk_done        [0:3];
    logic blk_y_valid     [0:3];
    logic blk_y_ready     [0:3];
    logic signed [DATA_WIDTH-1:0] blk_y_data [0:3][TILE_SIZE-1:0];
    logic blk_h_wr_en     [0:3];
    logic [4:0] blk_h_wr_addr [0:3];
    logic signed [DATA_WIDTH-1:0] blk_h_wr_data [0:3][TILE_SIZE-1:0];

    logic signed [DATA_WIDTH-1:0] h0_shadow [0:H_ROWS-1][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] residual_cur [0:H_ROWS-1][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] residual_next [0:H_ROWS-1][TILE_SIZE-1:0];

    typedef enum logic [1:0] {
        ST_IDLE    = 2'd0,
        ST_RUN     = 2'd1,
        ST_PRELOAD = 2'd2,
        ST_LAUNCH  = 2'd3
    } chain_state_t;
    chain_state_t state;

    logic [1:0] cur_blk;
    logic [5:0] y_row_cnt;
    logic [5:0] preload_row_cnt;

    always_comb begin
        for (int b = 0; b < 4; b++) begin
            blk_h_wr_en[b] = 1'b0;
            blk_h_wr_addr[b] = 5'd0;
            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                blk_h_wr_data[b][lane] = '0;
            end
        end

        if (!busy && h_wr_en) begin
            blk_h_wr_en[0] = 1'b1;
            blk_h_wr_addr[0] = h_wr_addr;
            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                blk_h_wr_data[0][lane] = h_wr_data[lane];
            end
        end else if (state == ST_PRELOAD && (cur_blk < 2'd3)) begin
            blk_h_wr_en[cur_blk + 1'b1] = 1'b1;
            blk_h_wr_addr[cur_blk + 1'b1] = preload_row_cnt[4:0];
            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                blk_h_wr_data[cur_blk + 1'b1][lane] = residual_next[preload_row_cnt][lane];
            end
        end
    end

    always_comb begin
        for (int b = 0; b < 4; b++) begin
            blk_y_ready[b] = 1'b0;
        end
        if (state == ST_RUN) begin
            if (cur_blk == 2'd3) begin
                blk_y_ready[3] = y_ready;
            end else begin
                blk_y_ready[cur_blk] = 1'b1;
            end
        end
    end

    always_comb begin
        y_valid = (state == ST_RUN && cur_blk == 2'd3) ? blk_y_valid[3] : 1'b0;
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
            y_data[lane] = blk_y_data[3][lane];
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state <= ST_IDLE;
            busy <= 1'b0;
            done <= 1'b0;
            cur_blk <= 2'd0;
            y_row_cnt <= 6'd0;
            preload_row_cnt <= 6'd0;
            for (int b = 0; b < 4; b++) begin
                blk_start_pulse[b] <= 1'b0;
            end
            for (int r = 0; r < H_ROWS; r++) begin
                for (int lane = 0; lane < TILE_SIZE; lane++) begin
                    h0_shadow[r][lane] <= '0;
                    residual_cur[r][lane] <= '0;
                    residual_next[r][lane] <= '0;
                end
            end
        end else begin
            done <= 1'b0;
            for (int b = 0; b < 4; b++) begin
                blk_start_pulse[b] <= 1'b0;
            end

            if (!busy && h_wr_en) begin
                for (int lane = 0; lane < TILE_SIZE; lane++) begin
                    h0_shadow[h_wr_addr][lane] <= h_wr_data[lane];
                end
            end

            case (state)
                ST_IDLE: begin
                    if (start && !busy) begin
                        busy <= 1'b1;
                        cur_blk <= 2'd0;
                        y_row_cnt <= 6'd0;
                        preload_row_cnt <= 6'd0;
                        for (int r = 0; r < H_ROWS; r++) begin
                            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                                residual_cur[r][lane] <= h0_shadow[r][lane];
                            end
                        end
                        blk_start_pulse[0] <= 1'b1;
                        state <= ST_RUN;
                    end
                end

                ST_RUN: begin
                    if (blk_y_valid[cur_blk] && blk_y_ready[cur_blk]) begin
                        if (cur_blk < 2'd3) begin
                            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                                residual_next[y_row_cnt][lane] <= sat_add_s16(residual_cur[y_row_cnt][lane], blk_y_data[cur_blk][lane]);
                            end
                        end
                        if (y_row_cnt == 6'd31) begin
                            if (cur_blk == 2'd3) begin
                                busy <= 1'b0;
                                done <= 1'b1;
                                state <= ST_IDLE;
                            end else begin
                                preload_row_cnt <= 6'd0;
                                state <= ST_PRELOAD;
                            end
                        end else begin
                            y_row_cnt <= y_row_cnt + 6'd1;
                        end
                    end
                end

                ST_PRELOAD: begin
                    if (preload_row_cnt == 6'd31) begin
                        for (int r = 0; r < H_ROWS; r++) begin
                            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                                residual_cur[r][lane] <= residual_next[r][lane];
                            end
                        end
                        cur_blk <= cur_blk + 2'd1;
                        y_row_cnt <= 6'd0;
                        state <= ST_LAUNCH;
                    end else begin
                        preload_row_cnt <= preload_row_cnt + 6'd1;
                    end
                end

                ST_LAUNCH: begin
                    blk_start_pulse[cur_blk] <= 1'b1;
                    state <= ST_RUN;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

    reuse_mamba_block_top #(
        .TILE_SIZE(TILE_SIZE), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH), .FRAC_BITS(FRAC_BITS),
        .N_BANK(N_BANK), .WDEPTH(WDEPTH), .WADDR_W(WADDR_W), .DATA_W(DATA_W), .XT_ADDR_W(XT_ADDR_W),
        .D(D), .PIPE_LAT(PIPE_LAT), .ADDR_BITS(ADDR_BITS), .LUT_FILE(LUT_FILE), .S_ADDR_W(S_ADDR_W), .G_FRAC_BITS(G_FRAC_BITS),
        .INPROJ_BANK0_INIT_FILE(B0_IN0), .INPROJ_BANK1_INIT_FILE(B0_IN1), .INPROJ_BANK2_INIT_FILE(B0_IN2),
        .INPROJ_BANK3_INIT_FILE(B0_IN3), .INPROJ_BANK4_INIT_FILE(B0_IN4), .INPROJ_BANK5_INIT_FILE(B0_IN5),
        .INPROJ_SCALE_INIT_FILE(B0_INS), .DT_BANK0_INIT_FILE(B0_DT0), .DT_BANK1_INIT_FILE(B0_DT1),
        .DT_BANK2_INIT_FILE(B0_DT2), .DT_BANK3_INIT_FILE(B0_DT3), .DT_SCALE_INIT_FILE(B0_DTS),
        .OUTPROJ_BANK0_INIT_FILE(B0_OUT0), .OUTPROJ_BANK1_INIT_FILE(B0_OUT1), .OUTPROJ_BANK2_INIT_FILE(B0_OUT2),
        .OUTPROJ_BANK3_INIT_FILE(B0_OUT3), .OUTPROJ_BANK4_INIT_FILE(B0_OUT4), .OUTPROJ_BANK5_INIT_FILE(B0_OUT5),
        .OUTPROJ_SCALE_INIT_FILE(B0_OUTS), .ENABLE_RMSNORM(1), .NORM_GAMMA_INIT_FILE(B0_GAM), .BIAS_INIT_FILE(B0_BIAS),
        .USE_SCALED_STATE_SCAN(1), .STATE_U_TO_STATE_SCALE_INIT_FILE(B0_SUS), .STATE_TO_Q88_SCALE_INIT_FILE(B0_STQ)
    ) u_blk0 (
        .clk(clk), .rst_n(rst_n), .block_auto_mode(1'b1), .block_start(blk_start_pulse[0]), .block_busy(blk_busy[0]), .block_done(blk_done[0]),
        .s_axis_TVALID(1'b0), .s_axis_TREADY(), .g_axis_TVALID(1'b0), .g_axis_TREADY(), .g_axis_TDATA('{default:'0}),
        .y_axis_TVALID(blk_y_valid[0]), .y_axis_TREADY(blk_y_ready[0]), .y_axis_TDATA(blk_y_data[0]),
        .inproj_enable(1'b1), .inproj_start(1'b0), .inproj_busy(), .inproj_done(),
        .h_wr_en(blk_h_wr_en[0]), .h_wr_addr(blk_h_wr_addr[0]), .h_wr_data(blk_h_wr_data[0]),
        .u_rd_en(1'b0), .u_rd_addr('0), .u_rd_data(), .z_rd_en(1'b0), .z_rd_addr('0), .z_rd_data(),
        .outproj_enable(1'b1), .outproj_busy()
    );

    reuse_mamba_block_top #(
        .TILE_SIZE(TILE_SIZE), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH), .FRAC_BITS(FRAC_BITS),
        .N_BANK(N_BANK), .WDEPTH(WDEPTH), .WADDR_W(WADDR_W), .DATA_W(DATA_W), .XT_ADDR_W(XT_ADDR_W),
        .D(D), .PIPE_LAT(PIPE_LAT), .ADDR_BITS(ADDR_BITS), .LUT_FILE(LUT_FILE), .S_ADDR_W(S_ADDR_W), .G_FRAC_BITS(G_FRAC_BITS),
        .INPROJ_BANK0_INIT_FILE(B1_IN0), .INPROJ_BANK1_INIT_FILE(B1_IN1), .INPROJ_BANK2_INIT_FILE(B1_IN2),
        .INPROJ_BANK3_INIT_FILE(B1_IN3), .INPROJ_BANK4_INIT_FILE(B1_IN4), .INPROJ_BANK5_INIT_FILE(B1_IN5),
        .INPROJ_SCALE_INIT_FILE(B1_INS), .DT_BANK0_INIT_FILE(B1_DT0), .DT_BANK1_INIT_FILE(B1_DT1),
        .DT_BANK2_INIT_FILE(B1_DT2), .DT_BANK3_INIT_FILE(B1_DT3), .DT_SCALE_INIT_FILE(B1_DTS),
        .OUTPROJ_BANK0_INIT_FILE(B1_OUT0), .OUTPROJ_BANK1_INIT_FILE(B1_OUT1), .OUTPROJ_BANK2_INIT_FILE(B1_OUT2),
        .OUTPROJ_BANK3_INIT_FILE(B1_OUT3), .OUTPROJ_BANK4_INIT_FILE(B1_OUT4), .OUTPROJ_BANK5_INIT_FILE(B1_OUT5),
        .OUTPROJ_SCALE_INIT_FILE(B1_OUTS), .ENABLE_RMSNORM(1), .NORM_GAMMA_INIT_FILE(B1_GAM), .BIAS_INIT_FILE(B1_BIAS),
        .USE_SCALED_STATE_SCAN(1), .STATE_U_TO_STATE_SCALE_INIT_FILE(B1_SUS), .STATE_TO_Q88_SCALE_INIT_FILE(B1_STQ)
    ) u_blk1 (
        .clk(clk), .rst_n(rst_n), .block_auto_mode(1'b1), .block_start(blk_start_pulse[1]), .block_busy(blk_busy[1]), .block_done(blk_done[1]),
        .s_axis_TVALID(1'b0), .s_axis_TREADY(), .g_axis_TVALID(1'b0), .g_axis_TREADY(), .g_axis_TDATA('{default:'0}),
        .y_axis_TVALID(blk_y_valid[1]), .y_axis_TREADY(blk_y_ready[1]), .y_axis_TDATA(blk_y_data[1]),
        .inproj_enable(1'b1), .inproj_start(1'b0), .inproj_busy(), .inproj_done(),
        .h_wr_en(blk_h_wr_en[1]), .h_wr_addr(blk_h_wr_addr[1]), .h_wr_data(blk_h_wr_data[1]),
        .u_rd_en(1'b0), .u_rd_addr('0), .u_rd_data(), .z_rd_en(1'b0), .z_rd_addr('0), .z_rd_data(),
        .outproj_enable(1'b1), .outproj_busy()
    );

    reuse_mamba_block_top #(
        .TILE_SIZE(TILE_SIZE), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH), .FRAC_BITS(FRAC_BITS),
        .N_BANK(N_BANK), .WDEPTH(WDEPTH), .WADDR_W(WADDR_W), .DATA_W(DATA_W), .XT_ADDR_W(XT_ADDR_W),
        .D(D), .PIPE_LAT(PIPE_LAT), .ADDR_BITS(ADDR_BITS), .LUT_FILE(LUT_FILE), .S_ADDR_W(S_ADDR_W), .G_FRAC_BITS(G_FRAC_BITS),
        .INPROJ_BANK0_INIT_FILE(B2_IN0), .INPROJ_BANK1_INIT_FILE(B2_IN1), .INPROJ_BANK2_INIT_FILE(B2_IN2),
        .INPROJ_BANK3_INIT_FILE(B2_IN3), .INPROJ_BANK4_INIT_FILE(B2_IN4), .INPROJ_BANK5_INIT_FILE(B2_IN5),
        .INPROJ_SCALE_INIT_FILE(B2_INS), .DT_BANK0_INIT_FILE(B2_DT0), .DT_BANK1_INIT_FILE(B2_DT1),
        .DT_BANK2_INIT_FILE(B2_DT2), .DT_BANK3_INIT_FILE(B2_DT3), .DT_SCALE_INIT_FILE(B2_DTS),
        .OUTPROJ_BANK0_INIT_FILE(B2_OUT0), .OUTPROJ_BANK1_INIT_FILE(B2_OUT1), .OUTPROJ_BANK2_INIT_FILE(B2_OUT2),
        .OUTPROJ_BANK3_INIT_FILE(B2_OUT3), .OUTPROJ_BANK4_INIT_FILE(B2_OUT4), .OUTPROJ_BANK5_INIT_FILE(B2_OUT5),
        .OUTPROJ_SCALE_INIT_FILE(B2_OUTS), .ENABLE_RMSNORM(1), .NORM_GAMMA_INIT_FILE(B2_GAM), .BIAS_INIT_FILE(B2_BIAS),
        .USE_SCALED_STATE_SCAN(1), .STATE_U_TO_STATE_SCALE_INIT_FILE(B2_SUS), .STATE_TO_Q88_SCALE_INIT_FILE(B2_STQ)
    ) u_blk2 (
        .clk(clk), .rst_n(rst_n), .block_auto_mode(1'b1), .block_start(blk_start_pulse[2]), .block_busy(blk_busy[2]), .block_done(blk_done[2]),
        .s_axis_TVALID(1'b0), .s_axis_TREADY(), .g_axis_TVALID(1'b0), .g_axis_TREADY(), .g_axis_TDATA('{default:'0}),
        .y_axis_TVALID(blk_y_valid[2]), .y_axis_TREADY(blk_y_ready[2]), .y_axis_TDATA(blk_y_data[2]),
        .inproj_enable(1'b1), .inproj_start(1'b0), .inproj_busy(), .inproj_done(),
        .h_wr_en(blk_h_wr_en[2]), .h_wr_addr(blk_h_wr_addr[2]), .h_wr_data(blk_h_wr_data[2]),
        .u_rd_en(1'b0), .u_rd_addr('0), .u_rd_data(), .z_rd_en(1'b0), .z_rd_addr('0), .z_rd_data(),
        .outproj_enable(1'b1), .outproj_busy()
    );

    reuse_mamba_block_top #(
        .TILE_SIZE(TILE_SIZE), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH), .FRAC_BITS(FRAC_BITS),
        .N_BANK(N_BANK), .WDEPTH(WDEPTH), .WADDR_W(WADDR_W), .DATA_W(DATA_W), .XT_ADDR_W(XT_ADDR_W),
        .D(D), .PIPE_LAT(PIPE_LAT), .ADDR_BITS(ADDR_BITS), .LUT_FILE(LUT_FILE), .S_ADDR_W(S_ADDR_W), .G_FRAC_BITS(G_FRAC_BITS),
        .INPROJ_BANK0_INIT_FILE(B3_IN0), .INPROJ_BANK1_INIT_FILE(B3_IN1), .INPROJ_BANK2_INIT_FILE(B3_IN2),
        .INPROJ_BANK3_INIT_FILE(B3_IN3), .INPROJ_BANK4_INIT_FILE(B3_IN4), .INPROJ_BANK5_INIT_FILE(B3_IN5),
        .INPROJ_SCALE_INIT_FILE(B3_INS), .DT_BANK0_INIT_FILE(B3_DT0), .DT_BANK1_INIT_FILE(B3_DT1),
        .DT_BANK2_INIT_FILE(B3_DT2), .DT_BANK3_INIT_FILE(B3_DT3), .DT_SCALE_INIT_FILE(B3_DTS),
        .OUTPROJ_BANK0_INIT_FILE(B3_OUT0), .OUTPROJ_BANK1_INIT_FILE(B3_OUT1), .OUTPROJ_BANK2_INIT_FILE(B3_OUT2),
        .OUTPROJ_BANK3_INIT_FILE(B3_OUT3), .OUTPROJ_BANK4_INIT_FILE(B3_OUT4), .OUTPROJ_BANK5_INIT_FILE(B3_OUT5),
        .OUTPROJ_SCALE_INIT_FILE(B3_OUTS), .ENABLE_RMSNORM(1), .NORM_GAMMA_INIT_FILE(B3_GAM), .BIAS_INIT_FILE(B3_BIAS),
        .USE_SCALED_STATE_SCAN(1), .STATE_U_TO_STATE_SCALE_INIT_FILE(B3_SUS), .STATE_TO_Q88_SCALE_INIT_FILE(B3_STQ)
    ) u_blk3 (
        .clk(clk), .rst_n(rst_n), .block_auto_mode(1'b1), .block_start(blk_start_pulse[3]), .block_busy(blk_busy[3]), .block_done(blk_done[3]),
        .s_axis_TVALID(1'b0), .s_axis_TREADY(), .g_axis_TVALID(1'b0), .g_axis_TREADY(), .g_axis_TDATA('{default:'0}),
        .y_axis_TVALID(blk_y_valid[3]), .y_axis_TREADY(blk_y_ready[3]), .y_axis_TDATA(blk_y_data[3]),
        .inproj_enable(1'b1), .inproj_start(1'b0), .inproj_busy(), .inproj_done(),
        .h_wr_en(blk_h_wr_en[3]), .h_wr_addr(blk_h_wr_addr[3]), .h_wr_data(blk_h_wr_data[3]),
        .u_rd_en(1'b0), .u_rd_addr('0), .u_rd_data(), .z_rd_en(1'b0), .z_rd_addr('0), .z_rd_data(),
        .outproj_enable(1'b1), .outproj_busy()
    );

endmodule
