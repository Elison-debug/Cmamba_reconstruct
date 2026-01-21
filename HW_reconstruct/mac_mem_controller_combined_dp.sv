//---------------------------------------------------------------
// File: mac_mem_controller_combined.sv (timing-optimized version)
// Function:
//   - Unified MAC controller for Mamba SSM
//   - Includes synchronized WBUF + XT pipelines
//   - Fully AXI-Stream compatible
//---------------------------------------------------------------
module mac_mem_controller_combined_dp #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8,
    parameter int N_BANK     = 6,
    parameter int ADDR_W     = 4,   // WBUF address width
    parameter int DEPTH      = 11,
    parameter int DATA_W     = 256,
    parameter int XT_ADDR_W  = 6     // XT ROM address width (e.g., depth 64)
)(
    input  logic clk,
    input  logic rst_n,

    // ===== AXI-Stream handshakes =====
    input  logic s_axis_TVALID,   // 上游发来的数据有效信号
    output logic s_axis_TREADY,   // 告诉上游：我能接收
    output logic m_axis_TVALID,   // 输出给下游：数据有效
    input  logic m_axis_TREADY,   // 从下游接收的：准备好信号

    // ===== Final MAC result =====
    output logic signed [ACC_WIDTH-1:0] reduced_vec [TILE_SIZE-1:0]
);

    // ==========================================================
    // FSM States
    // ==========================================================
    typedef enum logic [2:0] {
        IDLE, RUN_PIPELINE, WAIT_DONE
    } state_t;
    state_t state, next_state;

    logic [15:0] tile_cnt;
    (* keep = "true" *) logic [15:0] tile_cnt_for_xt; // duplicate register to localize XT fanout
    logic run_pipeline_d; // registered version of RUN_PIPELINE to break long paths
    logic valid_in, valid_out;
    // Track previous valid_out and last handshake to align WAIT_DONE exit
    logic valid_out_q;
    //ogic last_handshake_q;
    // Delay valid_in until WBUF data is stable
    logic [2:0] wbuf_cnt; // counts cycles in RUN_PIPELINE
    logic       wbuf_ready;
    // Per-bank address counters for WBUF addressing
    logic [ADDR_W-1:0] addr_bank_cnt [N_BANK];
    // Drain cycles after reaching tile_cnt==63 to capture last WBUF returns
    logic [1:0] drain_cnt;

    // ==========================================================
    // 1️⃣ WBUF pipeline stage  (UPDATED & FIXED)
    // ==========================================================

    // bank_sel, addr_sel, en_sel, port_sel
    logic [3:0][$clog2(N_BANK)-1:0] bank_sel, bank_sel_reg;
    logic [3:0][ADDR_W-1:0]         addr_sel, addr_sel_reg;
    logic [3:0]                     en_sel, en_sel_reg;
    logic [3:0]                     port_sel, port_sel_reg;
    logic [3:0][DATA_W-1:0]         w_data, w_data_reg;
    logic [N_BANK-1:0] bank_hit_mask_comb;
    logic [N_BANK-1:0] bank_hit_mask_comb_next;

    logic [1:0] phase;
    assign phase = tile_cnt % 3;
    
    // --- NEW: bank mapping (3-cycle pattern) ---
    always_comb begin
        logic [2:0] bank_x, bank_y;

        case (phase)
            0: begin bank_x = 0; bank_y = 3; end
            1: begin bank_x = 1; bank_y = 4; end
            default: begin bank_x = 2; bank_y = 5; end
        endcase

        bank_sel[0] = bank_x;
        bank_sel[1] = bank_y;
        bank_sel[2] = bank_x;
        bank_sel[3] = bank_y;

        addr_sel[0] = addr_bank_cnt[bank_sel[0]];
        addr_sel[1] = addr_bank_cnt[bank_sel[1]];
        addr_sel[2] = addr_bank_cnt[bank_sel[2]];
        addr_sel[3] = addr_bank_cnt[bank_sel[3]];

        port_sel[0] = 1'b0;
        port_sel[1] = 1'b0;
        port_sel[2] = 1'b1;
        port_sel[3] = 1'b1;

        // gradual warm-up
        en_sel[0] = (state == RUN_PIPELINE);
        en_sel[1] = (state == RUN_PIPELINE && tile_cnt >= 1);
        en_sel[2] = (state == RUN_PIPELINE && tile_cnt >= 2);
        en_sel[3] = (state == RUN_PIPELINE && tile_cnt >= 3);
    end

    // mark banks touched in the current cycle (use registered selectors that actually drive WBUF reads)
    always_comb begin
        bank_hit_mask_comb_next = '0;
        if (state == RUN_PIPELINE && tile_cnt != 16'd63) begin
            for (int j = 0; j < 4; j++) begin
                if (en_sel[j])
                    bank_hit_mask_comb_next[bank_sel[j]] = 1'b1;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bank_hit_mask_comb <= '0;
        else
            bank_hit_mask_comb <= bank_hit_mask_comb_next;
    end

    // --- WBUF instance ---
    multi_bank_wbuf_dp #(
        .N_BANK (N_BANK),
        .DEPTH  (DEPTH),
        .ADDR_W (ADDR_W),
        .DATA_W (DATA_W)
    ) u_wbuf (
        .clk(clk),
        .rst_n(rst_n),
        .bank_sel(bank_sel_reg),
        .addr_sel(addr_sel_reg),
        .en_sel(en_sel_reg),
        .port_sel(port_sel_reg),
        .dout_sel(w_data)
    );

    // ==========================================================
    // FIXED PART: Correct per-bank address increment logic
    // ==========================================================

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bank_sel_reg <= '0;
            addr_sel_reg <= '0;
            en_sel_reg   <= '0;
            port_sel_reg <= '0;
            w_data_reg   <= '0;

            for (int k = 0; k < N_BANK; k++)
                addr_bank_cnt[k] <= '0;

        end else if (state == RUN_PIPELINE) begin

            // pipeline registers
            bank_sel_reg <= bank_sel;
            addr_sel_reg <= addr_sel;
            en_sel_reg   <= en_sel;
            port_sel_reg <= port_sel;
            w_data_reg   <= w_data;

            // ---------------------------------------------
            // FIX: count only ONCE per bank per cycle
            // ---------------------------------------------

            // increment each bank once only
            for (int b = 0; b < N_BANK; b++) begin
                if (bank_hit_mask_comb[b]) begin
                    if (addr_bank_cnt[b] >= DEPTH-1)
                        addr_bank_cnt[b] <= '0;
                    else
                        addr_bank_cnt[b] <= addr_bank_cnt[b] + 1;
                end
            end
        end else if (drain_cnt != 0) begin
            // Drain阶段：保持 bank/addr/en 不变，仅采样最后返回的数据
            w_data_reg <= w_data;
        end else if (state == IDLE) begin
            for (int k = 0; k < N_BANK; k++)
                addr_bank_cnt[k] <= '0;
        end
    end

    // ==========================================================
    // 2️⃣ XT pipeline stage
    // ==========================================================
    logic [XT_ADDR_W-1:0] xt_addr, xt_addr_reg;
    // logic       xt_en, xt_en_req, xt_en_reg;
    logic       xt_en_req, xt_en_reg;
    logic       xt_en_reg_d1;
    //logic       xt_switch_req, xt_switch_req_reg;
    logic       xt_switch_req;
    logic [1:0] xt_stage_cnt, xt_stage_cnt_reg;
    logic signed [DATA_WIDTH-1:0] xt_vec [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] xt_curr [4][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] xt_next [TILE_SIZE-1:0];

    // --- XT ROM 实例 ---
    xt_input_buf #(
        .ADDR_W(XT_ADDR_W),
        .DATA_W(DATA_WIDTH),
        .TILE_SIZE(TILE_SIZE)
    ) u_xt (
        .clk(clk),
        .en((state == RUN_PIPELINE) || (state == IDLE && next_state == RUN_PIPELINE)),
        .addr(xt_addr_reg),
        .dout_vec(xt_vec)
    );

    // --- 控制逻辑（生成 req） ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            xt_addr       <= 0;
            xt_en_req     <= 0;
            xt_switch_req <= 0;
            xt_stage_cnt  <= 0;
            // 清零 xt_curr，避免复位后为 X
            for (int ii = 0; ii < 4; ii++) begin
                for (int jj = 0; jj < TILE_SIZE; jj++) begin
                    xt_curr[ii][jj] <= '0;
                end
            end
        end else begin
            xt_en_req <= 0;
            // 1) Tile 起始：进入 RUN_PIPELINE 当拍就预取当前 xt_addr，对应本 tile 使用
            if (state == IDLE && next_state == RUN_PIPELINE) begin
                xt_en_req     <= 1;      // 触发对当前 xt_addr 的读取
                xt_switch_req <= 1;      // 启动 3 拍渐进切换（与 WBUF 暖机对齐）
                // xt_addr 不自增：本 tile 使用当前地址
            end
            // 2) Tile 结束过渡：
            //    在 tile_cnt==60 预取下一条 xt（保证 61 开始切换时 xt_next 已就绪）；
            //    在 tile_cnt==61 启动 3 拍渐进切换（61/62/63）。
            else if (state == RUN_PIPELINE && tile_cnt_for_xt == 16'd59) begin
                xt_en_req <= 1;
                xt_addr   <= xt_addr + 1;
            end else if (state == RUN_PIPELINE && tile_cnt_for_xt == 16'd61) begin
                xt_switch_req <= 1;
            end
            if (xt_switch_req) begin
                xt_stage_cnt <= xt_stage_cnt + 1;
                if (xt_stage_cnt == 3) begin
                    xt_switch_req <= 0;
                    xt_stage_cnt  <= 0;
                    for (int i = 0; i < 4; i++)
                        xt_curr[i] <= xt_next;
                end
            end
        end
    end

    // --- 🔧 Pipeline寄存器：XT信号打一拍 ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            xt_en_reg        <= 0;
            xt_en_reg_d1     <= 0;
            xt_addr_reg      <= 0;
            //xt_switch_req_reg<= 0;
            xt_stage_cnt_reg <= 0;
        end else begin
            xt_en_reg        <= xt_en_req;
            xt_en_reg_d1     <= xt_en_reg;
            xt_addr_reg      <= xt_addr;
            //xt_switch_req_reg<= xt_switch_req;
            xt_stage_cnt_reg <= xt_stage_cnt;
        end
    end

    // --- XT 数据寄存 ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 清零 xt_next，避免复位后为 X
            for (int jj = 0; jj < TILE_SIZE; jj++) begin
                xt_next[jj] <= '0;
            end
        end else if (xt_en_reg_d1) begin
            xt_next <= xt_vec;
        end
    end

    // ==========================================================
    // 3️⃣ Broadcast to 4 arrays (replicate vector → matrix rows)
    // ==========================================================
    logic signed [DATA_WIDTH-1:0] B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    
    // [NEW] pipeline register for timing
    logic signed [DATA_WIDTH-1:0] B0_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B1_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B2_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B3_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    
    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            case (xt_stage_cnt_reg)
                0: begin B0_mat[i] = xt_next; B1_mat[i] = xt_curr[1]; B2_mat[i] = xt_curr[2]; B3_mat[i] = xt_curr[3]; end
                1: begin B0_mat[i] = xt_next; B1_mat[i] = xt_next;   B2_mat[i] = xt_curr[2]; B3_mat[i] = xt_curr[3]; end
                2: begin B0_mat[i] = xt_next; B1_mat[i] = xt_next;   B2_mat[i] = xt_next;    B3_mat[i] = xt_curr[3]; end
                default: begin B0_mat[i] = xt_next; B1_mat[i] = xt_next; B2_mat[i] = xt_next; B3_mat[i] = xt_next; end
            endcase
        end
    end
    // Pipeline register for B matrices// [ADD] pipeline the B*_mat signals
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            B0_mat_reg <= '{default:'0};
            B1_mat_reg <= '{default:'0};
            B2_mat_reg <= '{default:'0};
            B3_mat_reg <= '{default:'0};
        end else if (state == RUN_PIPELINE) begin
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

    // ==========================================================
    // 5️⃣ Pipeline computation
    // ==========================================================
    (* keep = "true" *) logic signed [ACC_WIDTH-1:0] dummy_mat0 [TILE_SIZE-1:0][TILE_SIZE-1:0]; // unused sink
    (* keep = "true" *) logic signed [ACC_WIDTH-1:0] dummy_mat1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    (* keep = "true" *) logic signed [ACC_WIDTH-1:0] dummy_mat2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    (* keep = "true" *) logic signed [ACC_WIDTH-1:0] dummy_mat3 [TILE_SIZE-1:0][TILE_SIZE-1:0];


    pipeline_4array_with_reduction #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .FRAC_BITS(FRAC_BITS)
    ) u_pipeline (
        .clk(clk),
        .rst_n(rst_n),
        .mode(2'b00),
        .valid_in(valid_in),
        .A0_mat(A0_mat), .A1_mat(A1_mat), .A2_mat(A2_mat), .A3_mat(A3_mat),
        .B0_mat(B0_mat_reg), .B1_mat(B1_mat_reg), .B2_mat(B2_mat_reg), .B3_mat(B3_mat_reg),
        .reduced_vec(reduced_vec),
        .reduced_mat_0(dummy_mat0),
        .reduced_mat_1(dummy_mat1),
        .reduced_mat_2(dummy_mat2),
        .reduced_mat_3(dummy_mat3),
        .valid_reduced(valid_out)
    );
    
    // ==========================================================
    // 6️⃣ FSM + AXI handshake
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
                // 仅在 tile_cnt < 63 时对下游有效；尾部进入 drain 收尾
                valid_in = wbuf_ready && (tile_cnt < 16'd63);
                if (tile_cnt == 16'd63) begin
                    if (drain_cnt == 0) next_state = WAIT_DONE;
                    else                next_state = RUN_PIPELINE; // 停留以采样最后返回
                end
            end
            // WAIT_DONE: begin
            //     // 仅在 valid_out 的最后一拍后打一拍 TVALID 脉冲
            //     m_axis_TVALID = (!valid_out && valid_out_q);
            //     if (!valid_out && valid_out_q && m_axis_TREADY) next_state = IDLE;
            // end
            WAIT_DONE: begin
                m_axis_TVALID = (!valid_out && valid_out_q);
                if (m_axis_TVALID && !m_axis_TREADY)
                    next_state = WAIT_DONE; // 保持等待
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
            run_pipeline_d <= 1'b0;
        end else begin
            state <= next_state;
            valid_out_q <= valid_out;
            run_pipeline_d <= (state == RUN_PIPELINE); // register state, cut path
            if (run_pipeline_d && tile_cnt != 16'd63) begin
                tile_cnt <= tile_cnt + 1;
                tile_cnt_for_xt <= tile_cnt + 1;
            end else if (state == IDLE) begin
                tile_cnt <= 16'd0;
                tile_cnt_for_xt <= 16'd0;
            end else begin
                tile_cnt <= tile_cnt;
                tile_cnt_for_xt <= tile_cnt;
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

    // Drain counter: arm at tile_cnt==63 to allow last WBUF data to return
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            drain_cnt <= '0;
        end else if (state == RUN_PIPELINE && tile_cnt == 16'd63 && drain_cnt == 0) begin
            drain_cnt <= 2; // 两拍用于接收最后一批返回
        end else if (drain_cnt != 0) begin
            drain_cnt <= drain_cnt - 1'b1;
        end else if (state == IDLE) begin
            drain_cnt <= '0;
        end
    end

endmodule
