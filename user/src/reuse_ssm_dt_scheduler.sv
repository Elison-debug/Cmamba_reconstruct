//---------------------------------------------------------------
// File: mac_mem_controller_combined_dp.sv  (256×256 FULL MATRIX)
// Function:
//   - Unified MAC controller for Slim-Mamba SSM
//   - Supports 4-array systolic + 6-bank dual-port WBUF
//   - Now WBUF stores entire 256×256 matrix (4096 tiles)
//   - Almost no modification to controller logic
//
// [MIN-TAP + XT FIFO INSIDE CONTROLLER]
//   - Add internal vec_fifo_axis_ip to stream out x_t (xt_next) per-tile
//   - Add AXIS-like output ports: xt_axis_TVALID/TREADY/xt_axis_TDATA
//   - Do NOT modify FSM transitions / pipeline datapath
//---------------------------------------------------------------
module reuse_ssm_dt_scheduler #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8,

    // =========== NEW PARAMETERS ===========
    parameter int N_BANK     = 6,             // MUST remain 6 (dual port pairing)
    parameter int WDEPTH     = 683,           // ceil(4096/6)
    parameter int WADDR_W    = $clog2(WDEPTH),// = 10
    parameter int DATA_W     = 256,           // each tile = 256-bit
    // ======================================

    parameter int XT_ADDR_W  = 6              // unchanged
)(
    input  logic clk,
    input  logic rst_n,
    output logic sched_busy,
    output logic                         u_vec_rd_en,
    output logic [XT_ADDR_W-1:0]         u_vec_rd_addr,
    input  logic signed [DATA_WIDTH-1:0] u_vec_rd_data [TILE_SIZE-1:0],

    // ===== AXI-Stream handshakes =====
    input  logic s_axis_TVALID,
    output logic s_axis_TREADY,
    output logic m_axis_TVALID,
    input  logic m_axis_TREADY,

    // ===== Final MAC result =====
    output logic signed [DATA_WIDTH-1:0] reduced_trunc [TILE_SIZE-1:0],

    // ==========================================================
    // [ADD] XT stream output (per-tile x_t vector)
    // ==========================================================
    output logic                         xt_axis_TVALID,
    input  logic                         xt_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0] xt_axis_TDATA [TILE_SIZE-1:0],

    // ==========================================================
    // Shared MAC fabric request/response ports
    // ==========================================================
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

    // 单 tile 有效输入拍数：4x4 = 16 拍
    localparam int TILE_CYCLE = 20; // 16

    // ==========================================================
    // FSM, tile counters — UNCHANGED
    // ==========================================================
    typedef enum logic [2:0] { IDLE, RUN_PIPELINE, WAIT_DONE } state_t;
    state_t state, next_state;
    logic [15:0] data_cnt;
    logic [15:0] tile_cnt;
    (* keep = "true" *) logic [15:0] tile_cnt_for_xt; // duplicate register to localize XT fanout
    logic valid_in, valid_out;
    logic valid_out_q;

    logic [2:0] wbuf_cnt;
    logic wbuf_ready;

    logic [1:0] drain_cnt;
    logic signed [ACC_WIDTH-1:0] reduced_vec [TILE_SIZE-1:0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < TILE_SIZE; i++)
                reduced_trunc[i] <= '0;
        end else if (valid_out) begin
            for (int i = 0; i < TILE_SIZE; i++)
                reduced_trunc[i] <= reduced_vec[i] >>> FRAC_BITS;
        end
    end

    // ==========================================================
// 1️⃣ WBUF pipeline stage  (only DEPTH changed)
// ==========================================================

    logic [3:0][$clog2(N_BANK)-1:0] bank_sel, bank_sel_reg;
    logic [3:0][WADDR_W-1:0]         addr_sel, addr_sel_reg;
    logic [3:0]                     en_sel,   en_sel_reg;
    logic [3:0]                     port_sel, port_sel_reg;
    logic [3:0][DATA_W-1:0]         w_data, w_data_reg;

    // 打拍后的计数与 phase，降低扇出
    logic [15:0]                    tile_cnt_d;
    logic [1:0]                     phase_reg;

    // per-bank address counter
    logic [WADDR_W-1:0] addr_bank_cnt [N_BANK];

    logic [N_BANK-1:0] bank_hit_mask_comb;
    logic [N_BANK-1:0] bank_hit_mask_comb_next;

    always_comb begin
        logic [2:0] bank_x, bank_y;

        case (phase_reg)
            0: begin bank_x=0; bank_y=3; end
            1: begin bank_x=1; bank_y=4; end
            default: begin bank_x=2; bank_y=5; end
        endcase

        bank_sel[0] = bank_x;
        bank_sel[1] = bank_y;
        bank_sel[2] = bank_x;
        bank_sel[3] = bank_y;

        addr_sel[0] = addr_bank_cnt[bank_sel[0]];
        addr_sel[1] = addr_bank_cnt[bank_sel[1]];
        addr_sel[2] = addr_bank_cnt[bank_sel[2]];
        addr_sel[3] = addr_bank_cnt[bank_sel[3]];

        //array0/array1 走 Port A，array2/array3 走 Port B
        port_sel[0] = 1'b0;
        port_sel[1] = 1'b0;
        port_sel[2] = 1'b1;
        port_sel[3] = 1'b1;

        // 每个 tile 内按 tile_cnt_d 渐进且限定 16 拍窗口：0~15,1~16,2~17,3~18
        en_sel[0] = (state == RUN_PIPELINE) && (tile_cnt_d < 18);
        en_sel[1] = (state == RUN_PIPELINE) && (tile_cnt_d >= 1) && (tile_cnt_d < 19);
        en_sel[2] = (state == RUN_PIPELINE) && (tile_cnt_d >= 2) && (tile_cnt_d < 20);
        en_sel[3] = (state == RUN_PIPELINE) && (tile_cnt_d >= 3) && (tile_cnt_d < 21);
    end

    //-------------------------------
    // mark-bank logic (unchanged)
    //-------------------------------
    always_comb begin
        bank_hit_mask_comb_next = '0;
        if (state == RUN_PIPELINE) begin
            for (int j=0; j<4; j++)
                if (en_sel[j])
                    bank_hit_mask_comb_next[ bank_sel[j] ] = 1'b1;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bank_hit_mask_comb <= '0;
        else
            bank_hit_mask_comb <= bank_hit_mask_comb_next;
    end

    // ==========================================================
    //  WBUF INSTANCE — REPLACED BY slim_multi_bank_wbuf_dp
    // ==========================================================
    slim_multi_bank_wbuf_dp #(
        .N_BANK (N_BANK),
        .DEPTH  (WDEPTH),
        .ADDR_W (WADDR_W),
        .DATA_W (DATA_W)
    ) u_wbuf (
        .clk      (clk),
        .rst_n    (rst_n),

        .bank_sel (bank_sel_reg),
        .addr_sel (addr_sel_reg),
        .en_sel   (en_sel_reg),
        .port_sel (port_sel_reg),

        .dout_sel (w_data)
    );

    // ==========================================================
    // FIXED: per-bank address increment (unchanged)
    // ==========================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int k=0; k<N_BANK; k++)
                addr_bank_cnt[k] <= '0;
            bank_sel_reg <= '0;
            addr_sel_reg <= '0;
            en_sel_reg   <= '0;
            port_sel_reg <= '0;
            w_data_reg   <= '0;
        end else if (state == RUN_PIPELINE) begin

            bank_sel_reg <= bank_sel;
            addr_sel_reg <= addr_sel;
            en_sel_reg   <= en_sel;
            port_sel_reg <= port_sel;
            w_data_reg   <= w_data;

            // ONE increment per bank
            for (int b=0; b<N_BANK; b++) begin
                if (bank_hit_mask_comb[b]) begin
                    if (addr_bank_cnt[b] == WDEPTH-1)
                        addr_bank_cnt[b] <= 0;
                    else
                        addr_bank_cnt[b] <= addr_bank_cnt[b] + 1;
                end
            end
        end
    end

    // ==========================================================
    // 2️⃣ XT pipeline stage
    // ==========================================================
    logic [XT_ADDR_W-1:0] xt_addr;
    logic       xt_en_req, xt_en_reg;
    logic       xt_en_reg_d1;
    logic       xt_switch_req;
    logic [1:0] xt_stage_cnt, xt_stage_cnt_reg;
    logic signed [DATA_WIDTH-1:0] xt_curr [4][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] xt_next [TILE_SIZE-1:0];
    assign u_vec_rd_en   = xt_en_req;
    assign u_vec_rd_addr = xt_addr;

    // --- 控制逻辑（生成 req） ---
    logic xt_init_done;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            xt_addr       <= 0;
            xt_en_req     <= 0;
            xt_switch_req <= 0;
            xt_stage_cnt  <= 0;
            xt_init_done  <= 1'b0;
            for (int ii = 0; ii < 4; ii++) begin
                for (int jj = 0; jj < TILE_SIZE; jj++) begin
                    xt_curr[ii][jj] <= '0;
                end
            end
        end else begin
            xt_en_req <= 0;

            // 1) Tile 起始：进入 RUN_PIPELINE 当拍就预取当前 xt_addr，对应本 tile 使用，并启动渐进切换
            if (state == IDLE && next_state == RUN_PIPELINE) begin
                xt_en_req      <= 1;
                xt_switch_req  <= 1;
                xt_init_done   <= 1'b1;
            end
            // 2) Tile 尾声：预取下一条 xt；切换由起始时统一发起
            else if (state == RUN_PIPELINE && tile_cnt_for_xt == 16'd15) begin
                xt_en_req <= 1;
                xt_addr   <= xt_addr + 1;
            end

            if (xt_switch_req) begin
                xt_stage_cnt <= xt_stage_cnt + 1'b1;
                // 在计数到 3 的当前拍就完成切换
                if (xt_stage_cnt == 2'd3) begin
                    xt_switch_req <= 0;
                    xt_stage_cnt  <= 0;
                    for (int i = 0; i < 4; i++)
                        xt_curr[i] <= xt_next;
                end
            end else begin
                xt_stage_cnt <= 0;
            end
        end
    end

    // --- 🔧 Pipeline寄存器：XT信号打一拍 ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            xt_en_reg        <= 0;
            xt_en_reg_d1     <= 0;
            xt_stage_cnt_reg <= 0;
        end else begin
            xt_en_reg        <= xt_en_req;
            xt_en_reg_d1     <= xt_en_reg;
            xt_stage_cnt_reg <= xt_stage_cnt;
        end
    end

    // --- XT 数据寄存 ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int jj = 0; jj < TILE_SIZE; jj++) begin
                xt_next[jj] <= '0;
            end
        end else if (xt_en_reg_d1) begin
            xt_next <= u_vec_rd_data;
        end
    end

    // ==========================================================
    // [ADD] 2.5️⃣ XT FIFO inside controller (per-tile stream out)
    //   Push condition: xt_en_reg_d1 (i.e., when xt_next is updated)
    //   Data payload: xt_vec (same cycle) or xt_next (registered)
    //
    //   We use xt_next (registered) for clean timing.
    // ==========================================================
    logic xt_fifo_in_valid;
    logic xt_fifo_in_ready;
    logic signed [DATA_WIDTH-1:0] xt_fifo_in_vec [TILE_SIZE-1:0];

    // 直接在 xt_en_reg_d1 脉冲时推送 xt_next，依赖 FIFO ready 做回压
    //assign xt_fifo_in_valid = xt_en_reg_d1;
    assign xt_fifo_in_valid = xt_en_reg_d1 && (tile_cnt_for_xt == 16'd18) && xt_fifo_in_ready;

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) xt_fifo_in_vec[i] = xt_next[i];
    end

    // 回到通用 AXIS FIFO，深度由 IP 保证，ready 回推 xt_fifo_in_ready
    vec_fifo_axis_ip #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_xt_vec_fifo (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (xt_fifo_in_valid),
        .in_ready (xt_fifo_in_ready),
        .in_vec   (xt_fifo_in_vec),
        .out_valid(xt_axis_TVALID),
        .out_ready(xt_axis_TREADY),
        .out_vec  (xt_axis_TDATA)
    );

    // ==========================================================
    // 3️⃣ Broadcast to 4 arrays (replicate vector → matrix rows)
    // ==========================================================
    logic signed [DATA_WIDTH-1:0] B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];

    logic signed [DATA_WIDTH-1:0] B0_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B1_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B2_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B3_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            case (xt_stage_cnt_reg)
                0: begin B0_mat[i] = xt_curr[0]; B1_mat[i] = xt_curr[1]; B2_mat[i] = xt_curr[2]; B3_mat[i] = xt_curr[3]; end
                1: begin B0_mat[i] = xt_next;    B1_mat[i] = xt_curr[1]; B2_mat[i] = xt_curr[2]; B3_mat[i] = xt_curr[3]; end
                2: begin B0_mat[i] = xt_next;    B1_mat[i] = xt_next;    B2_mat[i] = xt_curr[2]; B3_mat[i] = xt_curr[3]; end
                default: begin B0_mat[i] = xt_next; B1_mat[i] = xt_next; B2_mat[i] = xt_next; B3_mat[i] = xt_curr[3]; end
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            B0_mat_reg <= '{default:'0};
            B1_mat_reg <= '{default:'0};
            B2_mat_reg <= '{default:'0};
            B3_mat_reg <= '{default:'0};
        end else begin
            B0_mat_reg <= B0_mat;
            B1_mat_reg <= B1_mat;
            B2_mat_reg <= B2_mat;
            B3_mat_reg <= B3_mat;
        end
    end

    // ==========================================================
    // 4️⃣ Unpack 256-bit → tile matrix
    // ==========================================================
    logic signed [DATA_WIDTH-1:0] A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];

    logic signed [DATA_WIDTH-1:0] A0_mat_reg[TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A1_mat_reg[TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A2_mat_reg[TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A3_mat_reg[TILE_SIZE-1:0][TILE_SIZE-1:0];

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            for (int j = 0; j < TILE_SIZE; j++) begin
                A0_mat[i][j] = w_data_reg[0][(i*TILE_SIZE+j)*DATA_WIDTH +: DATA_WIDTH];
                A1_mat[i][j] = w_data_reg[1][(i*TILE_SIZE+j)*DATA_WIDTH +: DATA_WIDTH];
                A2_mat[i][j] = w_data_reg[2][(i*TILE_SIZE+j)*DATA_WIDTH +: DATA_WIDTH];
                A3_mat[i][j] = w_data_reg[3][(i*TILE_SIZE+j)*DATA_WIDTH +: DATA_WIDTH];
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            A0_mat_reg <= '{default:'0};
            A1_mat_reg <= '{default:'0};
            A2_mat_reg <= '{default:'0};
            A3_mat_reg <= '{default:'0};
        end else begin
            if (state == IDLE) begin
                A0_mat_reg <= '{default:'0};
                A1_mat_reg <= '{default:'0};
                A2_mat_reg <= '{default:'0};
                A3_mat_reg <= '{default:'0};
            end else begin
                if (en_sel_reg[0]) A0_mat_reg <= A0_mat;
                if (en_sel_reg[1]) A1_mat_reg <= A1_mat;
                if (en_sel_reg[2]) A2_mat_reg <= A2_mat;
                if (en_sel_reg[3]) A3_mat_reg <= A3_mat;
            end
        end
    end

    // ==========================================================
    // 5️⃣ Pipeline computation
    // ==========================================================
    (* keep = "true" *) logic signed [ACC_WIDTH-1:0] dummy_mat0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    (* keep = "true" *) logic signed [ACC_WIDTH-1:0] dummy_mat1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    (* keep = "true" *) logic signed [ACC_WIDTH-1:0] dummy_mat2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    (* keep = "true" *) logic signed [ACC_WIDTH-1:0] dummy_mat3 [TILE_SIZE-1:0][TILE_SIZE-1:0];

    logic valid_in_d1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            valid_in_d1 <= 1'b0;
        else
            valid_in_d1 <= valid_in;
    end

    assign fabric_mode       = 2'b00;
    assign fabric_col_blocks = 7'd16;
    assign fabric_valid_in   = valid_in_d1;
    assign sched_busy        = (state != IDLE);
    assign fabric_A0_mat   = A0_mat_reg;
    assign fabric_A1_mat   = A1_mat_reg;
    assign fabric_A2_mat   = A2_mat_reg;
    assign fabric_A3_mat   = A3_mat_reg;
    assign fabric_B0_mat   = B0_mat_reg;
    assign fabric_B1_mat   = B1_mat_reg;
    assign fabric_B2_mat   = B2_mat_reg;
    assign fabric_B3_mat   = B3_mat_reg;

    assign reduced_vec     = fabric_reduced_vec;
    assign dummy_mat0      = fabric_reduced_mat_0;
    assign dummy_mat1      = fabric_reduced_mat_1;
    assign dummy_mat2      = fabric_reduced_mat_2;
    assign dummy_mat3      = fabric_reduced_mat_3;
    assign valid_out       = fabric_valid_out;

    // ==========================================================
    // 6️⃣ FSM + AXI handshake  (UNCHANGED)
    // ==========================================================
    always_comb begin
        next_state = state;
        valid_in = 0;
        s_axis_TREADY = 0;
        m_axis_TVALID = 0;

        case (state)
            IDLE: begin
                s_axis_TREADY = m_axis_TREADY;// 仅当下游准备好时才允许新一轮输入
                if (s_axis_TVALID && s_axis_TREADY) next_state = RUN_PIPELINE;
            end
            RUN_PIPELINE: begin
                valid_in = (state == RUN_PIPELINE) && wbuf_ready && (data_cnt < TILE_CYCLE);
                if (data_cnt == TILE_CYCLE-1) begin
                    if (drain_cnt == 0) next_state = WAIT_DONE;
                    else next_state = RUN_PIPELINE;
                end
            end
            WAIT_DONE: begin
                m_axis_TVALID = (!valid_out &&valid_out_q);
                if (m_axis_TVALID && !m_axis_TREADY)
                    next_state = WAIT_DONE;
                else if (m_axis_TVALID && m_axis_TREADY)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tile_cnt <= 0;
            tile_cnt_for_xt <= 0;
            valid_out_q <= 1'b0;
            tile_cnt_d      <= 16'd0;
            phase_reg       <= 2'd0;
        end else begin
            state <= next_state;
            valid_out_q <= valid_out;

            if (state == RUN_PIPELINE) begin
                if (data_cnt == TILE_CYCLE-1) begin
                    tile_cnt        <= 16'd0;
                    tile_cnt_for_xt <= 16'd0;
                    tile_cnt_d      <= 16'd0;
                    phase_reg       <= 2'd0;
                end else begin
                    tile_cnt        <= tile_cnt + 16'd1;
                    tile_cnt_for_xt <= tile_cnt_for_xt + 16'd1;
                    tile_cnt_d      <= tile_cnt + 16'd1;

                    if (phase_reg == 2'd2)
                        phase_reg <= 2'd0;
                    else
                        phase_reg <= phase_reg + 2'd1;
                end
            end else if (state == IDLE) begin
                tile_cnt        <= 16'd0;
                tile_cnt_for_xt <= 16'd0;
                tile_cnt_d      <= 16'd0;
                phase_reg       <= 2'd0;
            end else begin
                tile_cnt        <= tile_cnt;
                tile_cnt_for_xt <= tile_cnt_for_xt;
                tile_cnt_d      <= tile_cnt_d;
                phase_reg       <= phase_reg;
            end
        end
    end

    // WBUF startup counter to cover register + sync ROM + output register latency
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wbuf_cnt <= '0;
        end else if (state == RUN_PIPELINE) begin
            if (wbuf_cnt != 3)
                wbuf_cnt <= wbuf_cnt + 1;
        end else begin
            wbuf_cnt <= '0;
        end
    end
    assign wbuf_ready = (wbuf_cnt == 3);

    // Drain counter: arm at tile_cnt==TILE_CYCLE-1 to allow last WBUF data to return
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            drain_cnt <= '0;
        end else if (state == RUN_PIPELINE && tile_cnt == TILE_CYCLE-1 && drain_cnt == 0) begin
            drain_cnt <= 2;
        end else if (drain_cnt != 0) begin
            drain_cnt <= drain_cnt - 1'b1;
        end else if (state == IDLE) begin
            drain_cnt <= '0;
        end
    end

    // data_cnt control valid_in count 64 cycles
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_cnt <= '0;
        end else if (state == RUN_PIPELINE) begin
            if (valid_in && data_cnt != TILE_CYCLE)
                data_cnt <= data_cnt + 1'b1;
        end else begin
            data_cnt <= '0;
        end
    end

endmodule
