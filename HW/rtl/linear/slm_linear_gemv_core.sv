`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: slm_linear_gemv_core
// Function:
//   Shared 4x4x4 GEMV execution core for the projection operators used in
//   Slim-Mamba. The core first preloads the input vector tiles into a local
//   cache, then reuses that cache across all output row tiles. It owns the
//   common preload schedule, weight-bank access, fabric issue/drain timing,
//   result capture, and requantization. Operator-specific wrappers only
//   provide source vector storage and destination writeback policy. The
//   preload phase can also be decoupled from the compute phase by controlling
//   the visible source-tile watermark and compute_enable input.
//---------------------------------------------------------------
module slm_linear_gemv_core #(
    parameter int TILE_SIZE   = 4,
    parameter int DATA_WIDTH  = 16,
    parameter int ACC_WIDTH   = 32,
    parameter int FRAC_BITS   = 8,
    parameter int N_BANK      = 6,
    parameter int WDEPTH      = 1024,
    parameter int WADDR_W     = $clog2(WDEPTH),
    parameter int DATA_W      = 256,
    parameter int IN_DIM      = 128,
    parameter int OUT_DIM     = 512,
    parameter int SRC_ADDR_W  = 5,
    parameter int SCALE_W     = 16,
    parameter int SCALE_FRAC_BITS = 15,
    parameter bit USE_PER_CHANNEL_SCALE = 0,
    parameter bit USE_STREAM_SOURCE = 0,
    parameter string BANK0_INIT_FILE = "",
    parameter string BANK1_INIT_FILE = "",
    parameter string BANK2_INIT_FILE = "",
    parameter string BANK3_INIT_FILE = "",
    parameter string BANK4_INIT_FILE = "",
    parameter string BANK5_INIT_FILE = "",
    parameter string SCALE_INIT_FILE = "",
    parameter int REQUANT_ROUND_MODE = 1,
    parameter int REQUANT_SAT_MODE   = 1
)(
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    input  logic start,
    input  logic compute_enable,
    input  logic [SRC_ADDR_W:0] src_tiles_available,
    output logic busy,
    output logic done,

    output logic                         src_rd_en,
    output logic [SRC_ADDR_W-1:0]        src_rd_addr0,
    output logic [SRC_ADDR_W-1:0]        src_rd_addr1,
    output logic [SRC_ADDR_W-1:0]        src_rd_addr2,
    output logic [SRC_ADDR_W-1:0]        src_rd_addr3,
    input  logic signed [DATA_WIDTH-1:0] src_rd_data0 [TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] src_rd_data1 [TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] src_rd_data2 [TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] src_rd_data3 [TILE_SIZE-1:0],
    input  logic                         src_stream_valid,
    output logic                         src_stream_ready,
    input  logic signed [DATA_WIDTH-1:0] src_stream_data [TILE_SIZE-1:0],

    output logic                         dst_valid,
    input  logic                         dst_ready,
    output logic [$clog2(OUT_DIM / TILE_SIZE)-1:0] dst_tile_index,
    output logic signed [DATA_WIDTH-1:0] dst_data [TILE_SIZE-1:0],

    output logic [1:0]                    fabric_mode,
    output logic [6:0]                    fabric_col_blocks,
    output logic                          fabric_valid_in,
    output logic signed [DATA_WIDTH-1:0]  fabric_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_vec [TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic                          fabric_valid_out
);
    localparam int ROW_GROUPS      = OUT_DIM / (TILE_SIZE * 4);
    localparam int ROWS_PER_GRP    = 4;
    localparam int ROW_TILES       = OUT_DIM / TILE_SIZE;
    localparam int K_GROUPS        = IN_DIM / (TILE_SIZE * 4);
    localparam int PHYS_K_BLOCKS   = IN_DIM / TILE_SIZE;
    localparam int TILE_CYCLE      = K_GROUPS + 3;
    localparam int OUT_PHASE_LAST  = K_GROUPS + 2;
    localparam int SCALE_DEPTH     = ROW_TILES;
    localparam int SCALE_ADDR_W    = $clog2(SCALE_DEPTH);
    localparam int ROW_GRP_W       = (ROW_GROUPS > 1) ? $clog2(ROW_GROUPS) : 1;
    localparam int ROW_TILE_W      = (ROW_TILES > 1) ? $clog2(ROW_TILES) : 1;
    localparam int K_CNT_W         = $clog2(K_GROUPS + 1);
    localparam int TILE_CNT_W      = $clog2(TILE_CYCLE + 2);

    typedef enum logic [2:0] { IDLE, PRELOAD_REQ, RUN_PIPELINE, WAIT_DONE, WRITE, DONE_S } state_t;
    state_t state, next_state;

    logic [ROW_GRP_W-1:0] row_group_idx;
    logic [1:0]           row_subtile_idx;
    logic [ROW_TILE_W-1:0] row_tile_linear;
    logic [ROW_GRP_W-1:0] write_row_group_idx;
    logic [1:0]            write_row_subtile_idx;
    logic [ROW_TILE_W-1:0] write_row_tile_linear;
    logic [SRC_ADDR_W:0]    preload_count;
    logic                   cache_valid;
    logic [K_CNT_W-1:0]    data_cnt;
    logic [TILE_CNT_W-1:0] tile_cnt;
    logic [1:0]            drain_cnt;

    logic [3:0][$clog2(N_BANK)-1:0] w_bank_sel;
    logic [3:0][WADDR_W-1:0]        w_addr_sel;
    logic [3:0]                     w_en_sel;
    logic [3:0]                     w_port_sel;
    logic [3:0][DATA_W-1:0]         w_dout_sel;
    logic                           scale_rd_en;
    logic [SCALE_ADDR_W-1:0]        scale_rd_addr;
    logic [63:0]                    scale_rd_data;

    logic [3:0]                    en_sel, en_sel_reg;
    logic [$clog2(K_GROUPS+5)-1:0] out_phase_cnt;
    logic                          out_phase_active;
    logic                          fetch_fire_d1, fetch_fire_d2, fetch_fire_d3;
    logic                          valid_in, valid_in_d1, valid_in_d2;

    logic signed [DATA_WIDTH-1:0] cur_A0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] cur_A1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] cur_A2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] cur_A3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] cur_B0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] cur_B1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] cur_B2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] cur_B3 [TILE_SIZE-1:0][TILE_SIZE-1:0];

    logic signed [DATA_WIDTH-1:0] A0_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A1_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A2_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A3_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A2_hold1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A3_hold1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A3_hold2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A0_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A1_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A2_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A3_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];

    logic signed [DATA_WIDTH-1:0] B0_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B1_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B2_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B3_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B2_hold1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B3_hold1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B3_hold2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B0_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B1_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B2_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B3_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];

    logic                        seen_valid;
    logic signed [ACC_WIDTH-1:0] final_vec [TILE_SIZE-1:0];
    logic [DATA_WIDTH-1:0]       dst_data_u [TILE_SIZE-1:0];
    logic [ACC_WIDTH-1:0]        final_vec_u [TILE_SIZE-1:0];
    logic [SCALE_W-1:0]          out_scale_vec [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] src_cache [PHYS_K_BLOCKS-1:0][TILE_SIZE-1:0];

    assign row_tile_linear       = row_group_idx * ROWS_PER_GRP + row_subtile_idx;
    assign write_row_tile_linear = write_row_group_idx * ROWS_PER_GRP + write_row_subtile_idx;

    assign fabric_mode       = 2'b00;
    assign fabric_col_blocks = K_GROUPS;
    assign busy              = (state != IDLE && state != DONE_S);
    assign done              = (state == DONE_S);
    assign valid_in          = (state == RUN_PIPELINE) && (data_cnt < K_GROUPS);
    assign src_rd_en         = enable && (state == PRELOAD_REQ) && !cache_valid &&
                               (preload_count < PHYS_K_BLOCKS) &&
                               (preload_count < src_tiles_available) && !USE_STREAM_SOURCE &&
                               !src_stream_valid;
    assign src_stream_ready  = enable && (state == PRELOAD_REQ) && !cache_valid &&
                               (preload_count < PHYS_K_BLOCKS) &&
                               (preload_count < src_tiles_available) && USE_STREAM_SOURCE;
    assign fabric_valid_in   = valid_in_d2;
    assign scale_rd_en       = enable && (state == RUN_PIPELINE) && (data_cnt == '0);
    assign scale_rd_addr     = row_tile_linear[SCALE_ADDR_W-1:0];
    assign dst_valid         = (state == WRITE);
    assign dst_tile_index    = write_row_tile_linear;

    slm_weight_bank_store #(
        .N_BANK          (N_BANK),
        .DEPTH           (WDEPTH),
        .ADDR_W          (WADDR_W),
        .DATA_W          (DATA_W),
        .BANK0_INIT_FILE (BANK0_INIT_FILE),
        .BANK1_INIT_FILE (BANK1_INIT_FILE),
        .BANK2_INIT_FILE (BANK2_INIT_FILE),
        .BANK3_INIT_FILE (BANK3_INIT_FILE),
        .BANK4_INIT_FILE (BANK4_INIT_FILE),
        .BANK5_INIT_FILE (BANK5_INIT_FILE)
    ) u_weight_store (
        .clk      (clk),
        .rst_n    (rst_n),
        .bank_sel (w_bank_sel),
        .addr_sel (w_addr_sel),
        .en_sel   (w_en_sel),
        .port_sel (w_port_sel),
        .dout_sel (w_dout_sel)
    );

    reuse_packed_scale_mem #(
        .DEPTH     (SCALE_DEPTH),
        .ADDR_W    (SCALE_ADDR_W),
        .DATA_W    (64),
        .INIT_FILE (SCALE_INIT_FILE)
    ) u_scale_mem (
        .clk  (clk),
        .en   (scale_rd_en),
        .addr (scale_rd_addr),
        .dout (scale_rd_data)
    );

    always_comb begin
        int aligned_addr;

        src_rd_addr0 = '0;
        src_rd_addr1 = '0;
        src_rd_addr2 = '0;
        src_rd_addr3 = '0;
        w_bank_sel   = '0;
        w_addr_sel   = '0;
        w_en_sel     = '0;
        w_port_sel   = '0;

        if (state == PRELOAD_REQ && preload_count < PHYS_K_BLOCKS &&
            !USE_STREAM_SOURCE && !src_stream_valid) begin
            src_rd_addr0 = preload_count[SRC_ADDR_W-1:0];
        end else if (valid_in) begin
            src_rd_addr0 = data_cnt * 4 + 0;
            src_rd_addr1 = data_cnt * 4 + 1;
            src_rd_addr2 = data_cnt * 4 + 2;
            src_rd_addr3 = data_cnt * 4 + 3;

            aligned_addr = row_tile_linear * K_GROUPS + data_cnt;
            w_bank_sel[0] = 0;
            w_bank_sel[1] = 1;
            w_bank_sel[2] = 2;
            w_bank_sel[3] = 3;
            w_addr_sel[0] = aligned_addr[WADDR_W-1:0];
            w_addr_sel[1] = aligned_addr[WADDR_W-1:0];
            w_addr_sel[2] = aligned_addr[WADDR_W-1:0];
            w_addr_sel[3] = aligned_addr[WADDR_W-1:0];
            w_en_sel      = 4'b1111;
            w_port_sel    = '0;
        end
    end

    always_comb begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
            out_scale_vec[lane] = scale_rd_data[lane*SCALE_W +: SCALE_W];
        end
    end

    always_comb begin
        cur_A0 = '{default:'0};
        cur_A1 = '{default:'0};
        cur_A2 = '{default:'0};
        cur_A3 = '{default:'0};
        cur_B0 = '{default:'0};
        cur_B1 = '{default:'0};
        cur_B2 = '{default:'0};
        cur_B3 = '{default:'0};

        for (int i = 0; i < TILE_SIZE; i++) begin
            cur_A0[i][0] = w_dout_sel[0][(i*TILE_SIZE+0)*DATA_WIDTH +: DATA_WIDTH];
            cur_A0[i][1] = w_dout_sel[0][(i*TILE_SIZE+1)*DATA_WIDTH +: DATA_WIDTH];
            cur_A0[i][2] = w_dout_sel[0][(i*TILE_SIZE+2)*DATA_WIDTH +: DATA_WIDTH];
            cur_A0[i][3] = w_dout_sel[0][(i*TILE_SIZE+3)*DATA_WIDTH +: DATA_WIDTH];
            cur_A1[i][0] = w_dout_sel[1][(i*TILE_SIZE+0)*DATA_WIDTH +: DATA_WIDTH];
            cur_A1[i][1] = w_dout_sel[1][(i*TILE_SIZE+1)*DATA_WIDTH +: DATA_WIDTH];
            cur_A1[i][2] = w_dout_sel[1][(i*TILE_SIZE+2)*DATA_WIDTH +: DATA_WIDTH];
            cur_A1[i][3] = w_dout_sel[1][(i*TILE_SIZE+3)*DATA_WIDTH +: DATA_WIDTH];
            cur_A2[i][0] = w_dout_sel[2][(i*TILE_SIZE+0)*DATA_WIDTH +: DATA_WIDTH];
            cur_A2[i][1] = w_dout_sel[2][(i*TILE_SIZE+1)*DATA_WIDTH +: DATA_WIDTH];
            cur_A2[i][2] = w_dout_sel[2][(i*TILE_SIZE+2)*DATA_WIDTH +: DATA_WIDTH];
            cur_A2[i][3] = w_dout_sel[2][(i*TILE_SIZE+3)*DATA_WIDTH +: DATA_WIDTH];
            cur_A3[i][0] = w_dout_sel[3][(i*TILE_SIZE+0)*DATA_WIDTH +: DATA_WIDTH];
            cur_A3[i][1] = w_dout_sel[3][(i*TILE_SIZE+1)*DATA_WIDTH +: DATA_WIDTH];
            cur_A3[i][2] = w_dout_sel[3][(i*TILE_SIZE+2)*DATA_WIDTH +: DATA_WIDTH];
            cur_A3[i][3] = w_dout_sel[3][(i*TILE_SIZE+3)*DATA_WIDTH +: DATA_WIDTH];

            for (int j = 0; j < TILE_SIZE; j++) begin
                cur_B0[i][j] = src_cache[data_cnt * 4 + 0][j];
                cur_B1[i][j] = src_cache[data_cnt * 4 + 1][j];
                cur_B2[i][j] = src_cache[data_cnt * 4 + 2][j];
                cur_B3[i][j] = src_cache[data_cnt * 4 + 3][j];
            end
        end
    end

    always_comb begin
        en_sel[0] = (state == RUN_PIPELINE) && (tile_cnt >= 0) && (tile_cnt < K_GROUPS);
        en_sel[1] = (state == RUN_PIPELINE) && (tile_cnt >= 1) && (tile_cnt < K_GROUPS + 1);
        en_sel[2] = (state == RUN_PIPELINE) && (tile_cnt >= 2) && (tile_cnt < K_GROUPS + 2);
        en_sel[3] = (state == RUN_PIPELINE) && (tile_cnt >= 3) && (tile_cnt < K_GROUPS + 3);
    end

    for (genvar g = 0; g < TILE_SIZE; g++) begin : gen_final_vec_cast
        assign final_vec_u[g] = final_vec[g];
    end

    requant_round_sat_engine #(
        .TILE_SIZE  (TILE_SIZE),
        .IN_W       (ACC_WIDTH),
        .OUT_W      (DATA_WIDTH),
        .SHIFT      (FRAC_BITS),
        .SCALE_W    (SCALE_W),
        .SCALE_FRAC_BITS(SCALE_FRAC_BITS),
        .SIGNED_IN  (1),
        .SIGNED_OUT (1),
        .USE_SCALE  (USE_PER_CHANNEL_SCALE),
        .ROUND_MODE (REQUANT_ROUND_MODE),
        .SAT_MODE   (REQUANT_SAT_MODE)
    ) u_out_requant (
        .in_vec   (final_vec_u),
        .scale_vec(out_scale_vec),
        .out_vec  (dst_data_u)
    );

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            dst_data[i] = $signed(dst_data_u[i]);
        end
    end

    always_comb begin
        fabric_A0_mat = A0_mat_reg;
        fabric_A1_mat = A1_mat_reg;
        fabric_A2_mat = A2_mat_reg;
        fabric_A3_mat = A3_mat_reg;
        fabric_B0_mat = B0_mat_reg;
        fabric_B1_mat = B1_mat_reg;
        fabric_B2_mat = B2_mat_reg;
        fabric_B3_mat = B3_mat_reg;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (enable && start)
                    next_state = PRELOAD_REQ;
            end
            PRELOAD_REQ: begin
                if (preload_count == PHYS_K_BLOCKS && compute_enable)
                    next_state = RUN_PIPELINE;
            end
            RUN_PIPELINE: begin
                if (data_cnt >= K_GROUPS) begin
                    if (drain_cnt == 0)
                        next_state = WAIT_DONE;
                end
            end
            WAIT_DONE: begin
                if (seen_valid && !fabric_valid_out)
                    next_state = WRITE;
            end
            WRITE: begin
                if (dst_ready) begin
                    if (row_group_idx == ROW_GROUPS-1 && row_subtile_idx == ROWS_PER_GRP-1)
                        next_state = DONE_S;
                    else
                        next_state = RUN_PIPELINE;
                end
            end
            DONE_S: begin
                if (!start)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state               <= IDLE;
            row_group_idx       <= '0;
            row_subtile_idx     <= '0;
            write_row_group_idx <= '0;
            write_row_subtile_idx <= '0;
            preload_count       <= '0;
            cache_valid         <= 1'b0;
            data_cnt            <= '0;
            tile_cnt            <= '0;
            drain_cnt           <= '0;
            fetch_fire_d1       <= 1'b0;
            fetch_fire_d2       <= 1'b0;
            fetch_fire_d3       <= 1'b0;
            en_sel_reg          <= '0;
            valid_in_d1         <= 1'b0;
            valid_in_d2         <= 1'b0;
            seen_valid          <= 1'b0;
            final_vec           <= '{default:'0};
            A0_hold             <= '{default:'0};
            A1_hold             <= '{default:'0};
            A2_hold             <= '{default:'0};
            A3_hold             <= '{default:'0};
            A2_hold1            <= '{default:'0};
            A3_hold1            <= '{default:'0};
            A3_hold2            <= '{default:'0};
            A0_mat_reg          <= '{default:'0};
            A1_mat_reg          <= '{default:'0};
            A2_mat_reg          <= '{default:'0};
            A3_mat_reg          <= '{default:'0};
            B0_hold             <= '{default:'0};
            B1_hold             <= '{default:'0};
            B2_hold             <= '{default:'0};
            B3_hold             <= '{default:'0};
            B2_hold1            <= '{default:'0};
            B3_hold1            <= '{default:'0};
            B3_hold2            <= '{default:'0};
            B0_mat_reg          <= '{default:'0};
            B1_mat_reg          <= '{default:'0};
            B2_mat_reg          <= '{default:'0};
            B3_mat_reg          <= '{default:'0};
            out_phase_cnt       <= '0;
            out_phase_active    <= 1'b0;
            for (int r = 0; r < PHYS_K_BLOCKS; r++) begin
                for (int i = 0; i < TILE_SIZE; i++) begin
                    src_cache[r][i] <= '0;
                end
            end
        end else begin
            state         <= next_state;
            fetch_fire_d1 <= valid_in;
            fetch_fire_d2 <= fetch_fire_d1;
            fetch_fire_d3 <= fetch_fire_d2;
            valid_in_d1   <= valid_in;
            valid_in_d2   <= valid_in_d1;
            en_sel_reg    <= en_sel;

            if (fabric_valid_out) begin
                seen_valid <= 1'b1;
                for (int i = 0; i < TILE_SIZE; i++)
                    final_vec[i] <= fabric_reduced_vec[i];
            end

            if (state == IDLE) begin
                row_group_idx         <= '0;
                row_subtile_idx       <= '0;
                preload_count         <= '0;
                data_cnt              <= '0;
                tile_cnt              <= '0;
                drain_cnt             <= 2'd3;
                write_row_group_idx   <= '0;
                write_row_subtile_idx <= '0;
                seen_valid            <= 1'b0;
                cache_valid           <= cache_valid;
                en_sel_reg            <= '0;
                A0_hold               <= '{default:'0};
                A1_hold               <= '{default:'0};
                A2_hold               <= '{default:'0};
                A3_hold               <= '{default:'0};
                A2_hold1              <= '{default:'0};
                A3_hold1              <= '{default:'0};
                A3_hold2              <= '{default:'0};
                A0_mat_reg            <= '{default:'0};
                A1_mat_reg            <= '{default:'0};
                A2_mat_reg            <= '{default:'0};
                A3_mat_reg            <= '{default:'0};
                B0_hold               <= '{default:'0};
                B1_hold               <= '{default:'0};
                B2_hold               <= '{default:'0};
                B3_hold               <= '{default:'0};
                B2_hold1              <= '{default:'0};
                B3_hold1              <= '{default:'0};
                B3_hold2              <= '{default:'0};
                B0_mat_reg            <= '{default:'0};
                B1_mat_reg            <= '{default:'0};
                B2_mat_reg            <= '{default:'0};
                B3_mat_reg            <= '{default:'0};
                out_phase_cnt         <= '0;
                out_phase_active      <= 1'b0;
            end

            if (state == PRELOAD_REQ) begin
                if (src_stream_valid && src_stream_ready) begin
                    src_cache[preload_count] <= src_stream_data;
                    preload_count <= preload_count + 1'b1;
                end else if (src_rd_en) begin
                    src_cache[preload_count] <= src_rd_data0;
                    preload_count <= preload_count + 1'b1;
                end else if (preload_count == PHYS_K_BLOCKS) begin
                    cache_valid <= 1'b1;
                end

                if (preload_count == PHYS_K_BLOCKS)
                    cache_valid <= 1'b1;

                if (next_state == RUN_PIPELINE) begin
                    data_cnt <= '0;
                    tile_cnt <= '0;
                    drain_cnt <= 2'd3;
                end
            end

            if (state == RUN_PIPELINE) begin
                if (valid_in) begin
                    data_cnt <= data_cnt + 1'b1;
                end else if (drain_cnt != 0) begin
                    drain_cnt <= drain_cnt - 1'b1;
                end

                if (tile_cnt < TILE_CYCLE)
                    tile_cnt <= tile_cnt + 1'b1;

                if (out_phase_active) begin
                    if (out_phase_cnt >= OUT_PHASE_LAST) begin
                        out_phase_active <= 1'b0;
                        out_phase_cnt    <= '0;
                        A0_hold          <= '{default:'0};
                        A1_hold          <= '{default:'0};
                        A2_hold          <= '{default:'0};
                        A3_hold          <= '{default:'0};
                        A2_hold1         <= '{default:'0};
                        A3_hold1         <= '{default:'0};
                        A3_hold2         <= '{default:'0};
                        A0_mat_reg       <= '{default:'0};
                        A1_mat_reg       <= '{default:'0};
                        A2_mat_reg       <= '{default:'0};
                        A3_mat_reg       <= '{default:'0};
                        B0_mat_reg       <= '{default:'0};
                        B1_mat_reg       <= '{default:'0};
                        B2_mat_reg       <= '{default:'0};
                        B3_mat_reg       <= '{default:'0};
                        B0_hold          <= '{default:'0};
                        B1_hold          <= '{default:'0};
                        B2_hold          <= '{default:'0};
                        B3_hold          <= '{default:'0};
                        B2_hold1         <= '{default:'0};
                        B3_hold1         <= '{default:'0};
                        B3_hold2         <= '{default:'0};
                    end else begin
                        out_phase_cnt <= out_phase_cnt + 1'b1;
                    end
                end
            end

            if (state == WAIT_DONE && next_state == WRITE) begin
                write_row_group_idx   <= row_group_idx;
                write_row_subtile_idx <= row_subtile_idx;
            end

            if (fetch_fire_d1) begin
                A0_hold <= cur_A0;
                A1_hold <= cur_A1;
                A2_hold <= cur_A2;
                A3_hold <= cur_A3;
                B0_hold <= cur_B0;
                B1_hold <= cur_B1;
                B2_hold <= cur_B2;
                B3_hold <= cur_B3;
                out_phase_active <= 1'b1;
                out_phase_cnt    <= '0;
                B0_mat_reg       <= cur_B0;
            end

            if (fetch_fire_d2) begin
                A2_hold1 <= A2_hold;
                A3_hold1 <= A3_hold;
                B2_hold1 <= B2_hold;
                B3_hold1 <= B3_hold;
            end

            if (fetch_fire_d3) begin
                A3_hold2 <= A3_hold1;
                B3_hold2 <= B3_hold1;
            end

            if (out_phase_active && out_phase_cnt == K_GROUPS-1)
                A0_mat_reg <= '{default:'0};
            else if (en_sel_reg[0])
                A0_mat_reg <= cur_A0;

            if (out_phase_active && out_phase_cnt == K_GROUPS)
                A1_mat_reg <= '{default:'0};
            else if (en_sel_reg[1])
                A1_mat_reg <= A1_hold;

            if (out_phase_active && out_phase_cnt == K_GROUPS+1)
                A2_mat_reg <= '{default:'0};
            else if (en_sel_reg[2])
                A2_mat_reg <= A2_hold1;

            if (out_phase_active && out_phase_cnt == K_GROUPS+2)
                A3_mat_reg <= '{default:'0};
            else if (en_sel_reg[3])
                A3_mat_reg <= A3_hold2;

            if (out_phase_active && out_phase_cnt == K_GROUPS-1)
                B0_mat_reg <= '{default:'0};
            else if (en_sel_reg[0])
                B0_mat_reg <= cur_B0;

            if (out_phase_active && out_phase_cnt == K_GROUPS)
                B1_mat_reg <= '{default:'0};
            else if (en_sel_reg[1])
                B1_mat_reg <= B1_hold;

            if (out_phase_active && out_phase_cnt == K_GROUPS+1)
                B2_mat_reg <= '{default:'0};
            else if (en_sel_reg[2])
                B2_mat_reg <= B2_hold1;

            if (out_phase_active && out_phase_cnt == K_GROUPS+2)
                B3_mat_reg <= '{default:'0};
            else if (en_sel_reg[3])
                B3_mat_reg <= B3_hold2;

            if (state == WRITE && dst_ready) begin
                seen_valid <= 1'b0;
                data_cnt   <= '0;
                tile_cnt   <= '0;
                drain_cnt  <= 2'd3;
                out_phase_active <= 1'b0;
                out_phase_cnt    <= '0;
                if (row_subtile_idx == ROWS_PER_GRP-1) begin
                    row_subtile_idx <= '0;
                    if (row_group_idx != ROW_GROUPS-1)
                        row_group_idx <= row_group_idx + 1'b1;
                end else begin
                    row_subtile_idx <= row_subtile_idx + 1'b1;
                end
            end
        end
    end
endmodule
