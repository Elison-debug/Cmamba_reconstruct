`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: reuse_ssm_dt_scheduler
// Function:
//   CPP-aligned dt_proj scheduler using the shared 4x4x4 MAC fabric.
//   One transaction computes one output row tile (4 channels).
//---------------------------------------------------------------
module reuse_ssm_dt_scheduler #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8,
    parameter int N_BANK     = 6,
    parameter int WDEPTH     = 1024,
    parameter int WADDR_W    = $clog2(WDEPTH),
    parameter int DATA_W     = 256,
    parameter int XT_ADDR_W  = 6,
    parameter int SCALE_W            = 16,
    parameter int SCALE_FRAC_BITS    = 15,
    parameter bit USE_PER_CHANNEL_SCALE = 0,
    parameter string DT_BANK0_INIT_FILE = "",
    parameter string DT_BANK1_INIT_FILE = "",
    parameter string DT_BANK2_INIT_FILE = "",
    parameter string DT_BANK3_INIT_FILE = "",
    parameter string DT_SCALE_INIT_FILE = "",
    parameter int REQUANT_ROUND_MODE = 1,
    parameter int REQUANT_SAT_MODE   = 1
)(
    input  logic clk,
    input  logic rst_n,
    output logic sched_busy,

    output logic                         u_vec_rd_en,
    output logic [XT_ADDR_W-1:0]         u_vec_rd_addr,
    input  logic signed [DATA_WIDTH-1:0] u_vec_rd_data [TILE_SIZE-1:0],

    input  logic s_axis_TVALID,
    output logic s_axis_TREADY,
    output logic m_axis_TVALID,
    input  logic m_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0] reduced_trunc [TILE_SIZE-1:0],

    output logic                         xt_axis_TVALID,
    input  logic                         xt_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0] xt_axis_TDATA [TILE_SIZE-1:0],

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
    localparam int ROW_TILES   = (1 << XT_ADDR_W);     // 64
    localparam int GROUPS      = ROW_TILES / 4;        // 16
    localparam int TILE_CYCLE  = GROUPS + 3;
    localparam int CNT_W       = $clog2(GROUPS + 1);
    localparam int TILE_CNT_W  = $clog2(TILE_CYCLE + 1);
    localparam int SCALE_DEPTH = ROW_TILES;
    localparam int SCALE_ADDR_W = $clog2(SCALE_DEPTH);

    typedef enum logic [2:0] {
        IDLE,
        PRELOAD_REQ,
        RUN_PIPELINE,
        WAIT_DONE,
        DONE_S
    } state_t;

    state_t state, next_state;

    logic [XT_ADDR_W-1:0] row_idx;
    logic [XT_ADDR_W:0]   preload_count;
    logic                 cache_valid;

    logic [CNT_W-1:0]     data_cnt;
    logic [CNT_W-1:0]     fetch_group_d1;
    logic [XT_ADDR_W-1:0] b_row_idx0_d1, b_row_idx1_d1, b_row_idx2_d1, b_row_idx3_d1;
    logic [CNT_W-1:0]     group_idx;
    logic [CNT_W-1:0]     group_data_q;
    logic [TILE_CNT_W-1:0] tile_cnt;
    logic                  valid_in;
    logic                  valid_in_d1, valid_in_d2;
    logic                  fetch_fire_d1, fetch_fire_d2, fetch_fire_d3;
    logic [3:0]            arr_en_sel, arr_en_sel_reg;
    logic                  issue_valid, issue_p0, issue_p1, issue_p2;
    logic                  seen_valid_out;

    logic                  xt_pending;
    logic signed [DATA_WIDTH-1:0] xt_payload [TILE_SIZE-1:0];

    logic [WADDR_W-1:0]             w_addr_cur;
    logic                           w_rd_en_cur;
    logic [3:0][DATA_W-1:0]         w_dout_sel;
    logic                           scale_rd_en;
    logic [SCALE_ADDR_W-1:0]        scale_rd_addr;
    logic [63:0]                    scale_rd_data;

    logic signed [DATA_WIDTH-1:0]   x_cache [ROW_TILES-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   cur_A0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   cur_A1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   cur_A2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   cur_A3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   cur_B0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   cur_B1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   cur_B2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   cur_B3 [TILE_SIZE-1:0][TILE_SIZE-1:0];

    logic signed [DATA_WIDTH-1:0]   A1_hold  [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   A2_hold  [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   A3_hold  [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   A2_hold1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   A3_hold1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   A3_hold2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   B1_hold  [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   B2_hold  [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   B3_hold  [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   B2_hold1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   B3_hold1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   B3_hold2 [TILE_SIZE-1:0][TILE_SIZE-1:0];

    logic signed [DATA_WIDTH-1:0]   A0_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   A1_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   A2_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   A3_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   B0_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   B1_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   B2_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]   B3_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic [DATA_WIDTH-1:0]          reduced_trunc_u [TILE_SIZE-1:0];
    logic [ACC_WIDTH-1:0]           fabric_reduced_vec_u [TILE_SIZE-1:0];
    logic [SCALE_W-1:0]             out_scale_vec [TILE_SIZE-1:0];

    assign sched_busy        = (state != IDLE && state != DONE_S);
    assign fabric_mode       = 2'b00;
    assign fabric_col_blocks = GROUPS[6:0];
    assign valid_in          = (state == RUN_PIPELINE) && (data_cnt < GROUPS);
    assign issue_valid       = valid_in;
    assign group_idx         = data_cnt;
    assign group_data_q      = fetch_group_d1;
    assign fabric_valid_in   = valid_in_d2;
    assign s_axis_TREADY     = (state == IDLE);
    assign m_axis_TVALID     = (state == DONE_S);
    assign xt_axis_TVALID    = xt_pending;
    assign scale_rd_en       = (state == RUN_PIPELINE) && (data_cnt == '0);
    assign scale_rd_addr     = row_idx[SCALE_ADDR_W-1:0];

    assign fabric_A0_mat = A0_mat_reg;
    assign fabric_A1_mat = A1_mat_reg;
    assign fabric_A2_mat = A2_mat_reg;
    assign fabric_A3_mat = A3_mat_reg;
    assign fabric_B0_mat = B0_mat_reg;
    assign fabric_B1_mat = B1_mat_reg;
    assign fabric_B2_mat = B2_mat_reg;
    assign fabric_B3_mat = B3_mat_reg;

    reuse_packed_scale_mem #(
        .DEPTH     (SCALE_DEPTH),
        .ADDR_W    (SCALE_ADDR_W),
        .DATA_W    (64),
        .INIT_FILE (DT_SCALE_INIT_FILE)
    ) u_scale_mem (
        .clk  (clk),
        .en   (scale_rd_en),
        .addr (scale_rd_addr),
        .dout (scale_rd_data)
    );

    for (genvar g = 0; g < TILE_SIZE; g++) begin : gen_reduced_vec_cast
        assign fabric_reduced_vec_u[g] = fabric_reduced_vec[g];
        assign out_scale_vec[g] = scale_rd_data[g*SCALE_W +: SCALE_W];
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
    ) u_reduced_requant (
        .in_vec  (fabric_reduced_vec_u),
        .scale_vec(out_scale_vec),
        .out_vec (reduced_trunc_u)
    );

`ifdef SYNTHESIS
    reuse_weight_bank_rom #(
        .DEPTH     (WDEPTH),
        .ADDR_W    (WADDR_W),
        .DATA_W    (DATA_W),
        .INIT_FILE (DT_BANK0_INIT_FILE)
    ) u_dt_wbuf_bank0 (
        .clk    (clk),
        .en_a   (w_rd_en_cur),
        .addr_a (w_addr_cur),
        .dout_a (w_dout_sel[0]),
        .en_b   (1'b0),
        .addr_b ('0),
        .dout_b ()
    );
    reuse_weight_bank_rom #(
        .DEPTH     (WDEPTH),
        .ADDR_W    (WADDR_W),
        .DATA_W    (DATA_W),
        .INIT_FILE (DT_BANK1_INIT_FILE)
    ) u_dt_wbuf_bank1 (
        .clk    (clk),
        .en_a   (w_rd_en_cur),
        .addr_a (w_addr_cur),
        .dout_a (w_dout_sel[1]),
        .en_b   (1'b0),
        .addr_b ('0),
        .dout_b ()
    );
    reuse_weight_bank_rom #(
        .DEPTH     (WDEPTH),
        .ADDR_W    (WADDR_W),
        .DATA_W    (DATA_W),
        .INIT_FILE (DT_BANK2_INIT_FILE)
    ) u_dt_wbuf_bank2 (
        .clk    (clk),
        .en_a   (w_rd_en_cur),
        .addr_a (w_addr_cur),
        .dout_a (w_dout_sel[2]),
        .en_b   (1'b0),
        .addr_b ('0),
        .dout_b ()
    );
    reuse_weight_bank_rom #(
        .DEPTH     (WDEPTH),
        .ADDR_W    (WADDR_W),
        .DATA_W    (DATA_W),
        .INIT_FILE (DT_BANK3_INIT_FILE)
    ) u_dt_wbuf_bank3 (
        .clk    (clk),
        .en_a   (w_rd_en_cur),
        .addr_a (w_addr_cur),
        .dout_a (w_dout_sel[3]),
        .en_b   (1'b0),
        .addr_b ('0),
        .dout_b ()
    );
`else
    logic [DATA_W-1:0] dt_wbuf_mem_sim0 [0:WDEPTH-1];
    logic [DATA_W-1:0] dt_wbuf_mem_sim1 [0:WDEPTH-1];
    logic [DATA_W-1:0] dt_wbuf_mem_sim2 [0:WDEPTH-1];
    logic [DATA_W-1:0] dt_wbuf_mem_sim3 [0:WDEPTH-1];
    logic [DATA_W-1:0] dt_wbuf_dout_r [4];

    initial begin : init_dt_wbuf_mem_sim
        for (int addr = 0; addr < WDEPTH; addr++) begin
            dt_wbuf_mem_sim0[addr] = '0;
            dt_wbuf_mem_sim1[addr] = '0;
            dt_wbuf_mem_sim2[addr] = '0;
            dt_wbuf_mem_sim3[addr] = '0;
        end
        if (DT_BANK0_INIT_FILE != "") $readmemh(DT_BANK0_INIT_FILE, dt_wbuf_mem_sim0);
        if (DT_BANK1_INIT_FILE != "") $readmemh(DT_BANK1_INIT_FILE, dt_wbuf_mem_sim1);
        if (DT_BANK2_INIT_FILE != "") $readmemh(DT_BANK2_INIT_FILE, dt_wbuf_mem_sim2);
        if (DT_BANK3_INIT_FILE != "") $readmemh(DT_BANK3_INIT_FILE, dt_wbuf_mem_sim3);
    end

    function automatic [DATA_W-1:0] dt_mem_read_sim(input int bank_idx, input [WADDR_W-1:0] addr_idx);
        case (bank_idx)
            0: dt_mem_read_sim = dt_wbuf_mem_sim0[addr_idx];
            1: dt_mem_read_sim = dt_wbuf_mem_sim1[addr_idx];
            2: dt_mem_read_sim = dt_wbuf_mem_sim2[addr_idx];
            3: dt_mem_read_sim = dt_wbuf_mem_sim3[addr_idx];
            default: dt_mem_read_sim = '0;
        endcase
    endfunction

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            for (int b = 0; b < 4; b++)
                dt_wbuf_dout_r[b] <= '0;
        end else if (w_rd_en_cur) begin
            for (int b = 0; b < 4; b++)
                dt_wbuf_dout_r[b] <= dt_mem_read_sim(b, w_addr_cur);
        end
    end
    always_comb begin
        for (int b = 0; b < 4; b++)
            w_dout_sel[b] = dt_wbuf_dout_r[b];
    end
`endif

    always_comb begin
        u_vec_rd_en   = 1'b0;
        u_vec_rd_addr = '0;
        if (state == PRELOAD_REQ && preload_count < ROW_TILES) begin
            u_vec_rd_en   = 1'b1;
            u_vec_rd_addr = preload_count[XT_ADDR_W-1:0];
        end
    end

    assign w_rd_en_cur = valid_in;
    assign w_addr_cur  = row_idx * GROUPS + data_cnt;

    always_comb begin
        arr_en_sel[0] = (state == RUN_PIPELINE) && (tile_cnt >= 0) && (tile_cnt < GROUPS);
        arr_en_sel[1] = (state == RUN_PIPELINE) && (tile_cnt >= 1) && (tile_cnt < GROUPS + 1);
        arr_en_sel[2] = (state == RUN_PIPELINE) && (tile_cnt >= 2) && (tile_cnt < GROUPS + 2);
        arr_en_sel[3] = (state == RUN_PIPELINE) && (tile_cnt >= 3) && (tile_cnt < GROUPS + 3);
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
            for (int j = 0; j < TILE_SIZE; j++) begin
                cur_A0[i][j] = w_dout_sel[0][(i*TILE_SIZE+j)*DATA_WIDTH +: DATA_WIDTH];
                cur_A1[i][j] = w_dout_sel[1][(i*TILE_SIZE+j)*DATA_WIDTH +: DATA_WIDTH];
                cur_A2[i][j] = w_dout_sel[2][(i*TILE_SIZE+j)*DATA_WIDTH +: DATA_WIDTH];
                cur_A3[i][j] = w_dout_sel[3][(i*TILE_SIZE+j)*DATA_WIDTH +: DATA_WIDTH];

                if (fetch_group_d1 < GROUPS) begin
                    cur_B0[i][j] = x_cache[b_row_idx0_d1][j];
                    cur_B1[i][j] = x_cache[b_row_idx1_d1][j];
                    cur_B2[i][j] = x_cache[b_row_idx2_d1][j];
                    cur_B3[i][j] = x_cache[b_row_idx3_d1][j];
                end
            end
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (s_axis_TVALID && s_axis_TREADY) begin
                    if (!cache_valid || row_idx == '0)
                        next_state = PRELOAD_REQ;
                    else
                        next_state = RUN_PIPELINE;
                end
            end
            PRELOAD_REQ: begin
                if (preload_count == ROW_TILES)
                    next_state = RUN_PIPELINE;
            end
            RUN_PIPELINE: begin
                if (tile_cnt == TILE_CYCLE)
                    next_state = WAIT_DONE;
            end
            WAIT_DONE: begin
                if (seen_valid_out && !fabric_valid_out)
                    next_state = DONE_S;
            end
            DONE_S: begin
                if (m_axis_TREADY)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state          <= IDLE;
            row_idx        <= '0;
            preload_count  <= '0;
            cache_valid    <= 1'b0;
            data_cnt       <= '0;
            fetch_group_d1 <= '0;
            b_row_idx0_d1  <= '0;
            b_row_idx1_d1  <= '0;
            b_row_idx2_d1  <= '0;
            b_row_idx3_d1  <= '0;
            tile_cnt       <= '0;
            valid_in_d1    <= 1'b0;
            valid_in_d2    <= 1'b0;
            fetch_fire_d1  <= 1'b0;
            fetch_fire_d2  <= 1'b0;
            fetch_fire_d3  <= 1'b0;
            arr_en_sel_reg <= '0;
            issue_p0       <= 1'b0;
            issue_p1       <= 1'b0;
            issue_p2       <= 1'b0;
            seen_valid_out <= 1'b0;
            xt_pending     <= 1'b0;
            A1_hold        <= '{default:'0};
            A2_hold        <= '{default:'0};
            A3_hold        <= '{default:'0};
            A2_hold1       <= '{default:'0};
            A3_hold1       <= '{default:'0};
            A3_hold2       <= '{default:'0};
            B1_hold        <= '{default:'0};
            B2_hold        <= '{default:'0};
            B3_hold        <= '{default:'0};
            B2_hold1       <= '{default:'0};
            B3_hold1       <= '{default:'0};
            B3_hold2       <= '{default:'0};
            A0_mat_reg     <= '{default:'0};
            A1_mat_reg     <= '{default:'0};
            A2_mat_reg     <= '{default:'0};
            A3_mat_reg     <= '{default:'0};
            B0_mat_reg     <= '{default:'0};
            B1_mat_reg     <= '{default:'0};
            B2_mat_reg     <= '{default:'0};
            B3_mat_reg     <= '{default:'0};
            for (int i = 0; i < TILE_SIZE; i++) begin
                reduced_trunc[i] <= '0;
                xt_payload[i]    <= '0;
            end
            for (int r = 0; r < ROW_TILES; r++) begin
                for (int i = 0; i < TILE_SIZE; i++) begin
                    x_cache[r][i] <= '0;
                end
            end
        end else begin
            state          <= next_state;
            valid_in_d1    <= valid_in;
            valid_in_d2    <= valid_in_d1;
            fetch_fire_d1  <= valid_in;
            fetch_fire_d2  <= fetch_fire_d1;
            fetch_fire_d3  <= fetch_fire_d2;
            arr_en_sel_reg <= arr_en_sel;
            issue_p0       <= issue_valid;
            issue_p1       <= issue_p0;
            issue_p2       <= issue_p1;

            if (fabric_valid_out) begin
                seen_valid_out <= 1'b1;
                for (int i = 0; i < TILE_SIZE; i++)
                    reduced_trunc[i] <= $signed(reduced_trunc_u[i]);
            end

            if (xt_pending && xt_axis_TREADY)
                xt_pending <= 1'b0;

            case (state)
                IDLE: begin
                    preload_count  <= '0;
                    data_cnt       <= '0;
                    fetch_group_d1 <= '0;
                    b_row_idx0_d1  <= '0;
                    b_row_idx1_d1  <= '0;
                    b_row_idx2_d1  <= '0;
                    b_row_idx3_d1  <= '0;
                    tile_cnt       <= '0;
                    valid_in_d1    <= 1'b0;
                    valid_in_d2    <= 1'b0;
                    fetch_fire_d1  <= 1'b0;
                    fetch_fire_d2  <= 1'b0;
                    fetch_fire_d3  <= 1'b0;
                    arr_en_sel_reg <= '0;
                    issue_p0       <= 1'b0;
                    issue_p1       <= 1'b0;
                    issue_p2       <= 1'b0;
                    seen_valid_out <= 1'b0;
                    A1_hold        <= '{default:'0};
                    A2_hold        <= '{default:'0};
                    A3_hold        <= '{default:'0};
                    A2_hold1       <= '{default:'0};
                    A3_hold1       <= '{default:'0};
                    A3_hold2       <= '{default:'0};
                    B1_hold        <= '{default:'0};
                    B2_hold        <= '{default:'0};
                    B3_hold        <= '{default:'0};
                    B2_hold1       <= '{default:'0};
                    B3_hold1       <= '{default:'0};
                    B3_hold2       <= '{default:'0};
                    A0_mat_reg     <= '{default:'0};
                    A1_mat_reg     <= '{default:'0};
                    A2_mat_reg     <= '{default:'0};
                    A3_mat_reg     <= '{default:'0};
                    B0_mat_reg     <= '{default:'0};
                    B1_mat_reg     <= '{default:'0};
                    B2_mat_reg     <= '{default:'0};
                    B3_mat_reg     <= '{default:'0};

                    if (s_axis_TVALID && s_axis_TREADY && cache_valid && row_idx != '0) begin
                        xt_pending <= 1'b1;
                        for (int i = 0; i < TILE_SIZE; i++)
                            xt_payload[i] <= x_cache[row_idx][i];
                    end
                end

                PRELOAD_REQ: begin
                    if (preload_count > 0 && preload_count <= ROW_TILES)
                        x_cache[preload_count - 1'b1] <= u_vec_rd_data;

                    if (preload_count < ROW_TILES)
                        preload_count <= preload_count + 1'b1;
                    else
                        cache_valid <= 1'b1;

                    if (next_state == RUN_PIPELINE) begin
                        data_cnt  <= '0;
                        tile_cnt  <= '0;
                        xt_pending <= 1'b1;
                        for (int i = 0; i < TILE_SIZE; i++)
                            xt_payload[i] <= x_cache[row_idx][i];
                    end
                end

                RUN_PIPELINE: begin
                    if (data_cnt < GROUPS)
                        data_cnt <= data_cnt + 1'b1;

                    if (tile_cnt < TILE_CYCLE)
                        tile_cnt <= tile_cnt + 1'b1;

                    if (valid_in) begin
                        fetch_group_d1 <= data_cnt;
                        b_row_idx0_d1  <= data_cnt * 4 + 0;
                        b_row_idx1_d1  <= data_cnt * 4 + 1;
                        b_row_idx2_d1  <= data_cnt * 4 + 2;
                        b_row_idx3_d1  <= data_cnt * 4 + 3;
                    end

                    if (fetch_fire_d1) begin
                        A1_hold <= cur_A1;
                        A2_hold <= cur_A2;
                        A3_hold <= cur_A3;
                        B1_hold <= cur_B1;
                        B2_hold <= cur_B2;
                        B3_hold <= cur_B3;
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

                    if (arr_en_sel_reg[0]) begin
                        A0_mat_reg <= cur_A0;
                        B0_mat_reg <= cur_B0;
                    end else begin
                        A0_mat_reg <= '{default:'0};
                        B0_mat_reg <= '{default:'0};
                    end

                    if (arr_en_sel_reg[1]) begin
                        A1_mat_reg <= A1_hold;
                        B1_mat_reg <= B1_hold;
                    end else begin
                        A1_mat_reg <= '{default:'0};
                        B1_mat_reg <= '{default:'0};
                    end

                    if (arr_en_sel_reg[2]) begin
                        A2_mat_reg <= A2_hold1;
                        B2_mat_reg <= B2_hold1;
                    end else begin
                        A2_mat_reg <= '{default:'0};
                        B2_mat_reg <= '{default:'0};
                    end

                    if (arr_en_sel_reg[3]) begin
                        A3_mat_reg <= A3_hold2;
                        B3_mat_reg <= B3_hold2;
                    end else begin
                        A3_mat_reg <= '{default:'0};
                        B3_mat_reg <= '{default:'0};
                    end
                end

                WAIT_DONE: begin
                    A0_mat_reg <= '{default:'0};
                    A1_mat_reg <= '{default:'0};
                    A2_mat_reg <= '{default:'0};
                    A3_mat_reg <= '{default:'0};
                    B0_mat_reg <= '{default:'0};
                    B1_mat_reg <= '{default:'0};
                    B2_mat_reg <= '{default:'0};
                    B3_mat_reg <= '{default:'0};
                end

                DONE_S: begin
                    if (m_axis_TREADY) begin
                        if (row_idx == ROW_TILES-1)
                            row_idx <= '0;
                        else
                            row_idx <= row_idx + 1'b1;
                    end
                end
            endcase
        end
    end

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            xt_axis_TDATA[i] = xt_payload[i];
    end

endmodule
