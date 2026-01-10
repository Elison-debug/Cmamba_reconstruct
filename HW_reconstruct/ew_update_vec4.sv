// ============================================================
// ew_update_vec4.sv
// EMA update stage (mini-top for EMA step):
//   s_new = lam ⊙ s_prev + (1-lam) ⊙ u
//
// Expected formats (recommended):
//   lam: Q0.16 unsigned
    //   s:   Q8.8 signed
    //   u:   Q8.8 signed
// ============================================================
module ew_update_vec4 #(
    parameter int TILE_SIZE  = 4,
    parameter int W          = 16,
    parameter int S_ADDR_W   = 10,   // state depth = 2^S_ADDR_W (example)
    parameter bit USE_RAM    = 1
)(
    input  logic clk,
    input  logic rst_n,

    // input stream (from join)
    input  logic                 in_valid,
    output logic                 in_ready,
    input  logic [W-1:0]         lam_vec [TILE_SIZE-1:0], // Q0.16 unsigned
    input  logic signed [W-1:0]  u_vec   [TILE_SIZE-1:0], // e.g. Q8.8 signed or already aligned

    // state index for this token (你可以来自 tile_id / timestep counter)
    input  logic [S_ADDR_W-1:0]  s_addr,

    // output stream (s_new, y_t)
    output logic                 out_valid,
    input  logic                 out_ready,
    output logic signed [W-1:0]  s_new_vec [TILE_SIZE-1:0]
);

    // ------------------------------------------------------------
    // 0) State storage (s_prev) — external RAM
    // ------------------------------------------------------------
    localparam int MEM_W     = W*TILE_SIZE;
    localparam int MEM_BYTES = MEM_W/8;
    logic signed [W-1:0] s_prev_vec [TILE_SIZE-1:0];
    logic signed [W-1:0] s_prev_vec_w [TILE_SIZE-1:0];
    logic [MEM_W-1:0]    s_dout_packed = '0; // init to avoid X in sim
    wire                  s_dout_unknown = (^s_dout_packed === 1'bx);
    wire [MEM_W-1:0]      s_dout_safe   = s_dout_unknown ? {MEM_W{1'b0}} : s_dout_packed;
    
    // 地址寄存
    logic [S_ADDR_W-1:0] s_addr_r;
    logic [S_ADDR_W-1:0] s_addr_w;

    // 最近一次写入的旁路，用于在 BRAM 尚未返回新数据时提供有效值
    logic                 last_wr_valid;
    logic [S_ADDR_W-1:0]  last_wr_addr;
    logic [MEM_W-1:0]     last_wr_data;
    wire [MEM_W-1:0]      s_dout_mux = (last_wr_valid && (last_wr_addr == s_addr_r)) ? last_wr_data : s_dout_safe;
    logic [MEM_W-1:0]    s_new_packed;


    // FSM: in -> RD1 -> RD2 -> CALC (2-cycle RAM read latency)
    typedef enum logic [2:0] {ST_IDLE, ST_RD1, ST_RD2, ST_CALC, ST_WAIT} st_t;
    st_t st;

    // latch input
    logic [W-1:0]        lam_r [TILE_SIZE-1:0];
    logic signed [W-1:0] u_r   [TILE_SIZE-1:0];

    // intermediate
    logic [W-1:0] one_minus [TILE_SIZE-1:0];
    logic signed [W-1:0] u_aligned [TILE_SIZE-1:0]; // TODO: align u to Q0.16 if needed

    // EWM outputs
    logic ewm1_v, ewm1_r;
    logic ewm2_v, ewm2_r;
    logic [W-1:0] mul_a [TILE_SIZE-1:0];
    logic [W-1:0] mul_b [TILE_SIZE-1:0];

    // EWA output
    logic ewa_v, ewa_r;
    logic [W-1:0] sum_y [TILE_SIZE-1:0];
    wire  state_we;
    logic calc_done; // latch successful CALC handshake

    // ------------------------------------------------------------
    // 1) input accept + state read scheduling
    // ------------------------------------------------------------
    // in_ready: 只有在内部空闲且后续不会阻塞时才接 token
    assign in_ready = (st == ST_IDLE);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            st <= ST_IDLE;
            s_addr_r <= '0;
            out_valid <= 1'b0;
            calc_done <= 1'b0;
            for (int i=0;i<TILE_SIZE;i++) s_new_vec[i] <= '0;
            s_new_packed <= '0;
            for (int i=0;i<TILE_SIZE;i++) begin
                lam_r[i] <= '0;
                u_r[i]   <= '0;
            end
            last_wr_valid <= 1'b0;
            last_wr_addr  <= '0;
            last_wr_data  <= '0;
        end else begin
            // output handshake
            if (out_valid && out_ready) out_valid <= 1'b0;
            if (calc_done && st==ST_WAIT) calc_done <= 1'b0;

            case (st)
                ST_IDLE: begin
                    if (in_valid && in_ready) begin
                        // latch token
                        for (int i=0;i<TILE_SIZE;i++) begin
                            // lam: Q0.16 -> Q8.8
                            lam_r[i] <= lam_vec[i] >>> 8;
                            u_r[i]   <= u_vec[i];
                        end
                        s_addr_r <= s_addr;
                        st <= ST_RD1;
                        calc_done <= 1'b0;
                        // 如果需要，可以在此重置 last_wr_valid，当地址改变时旁路失效
                        if (last_wr_valid && (last_wr_addr != s_addr)) last_wr_valid <= 1'b0;
                    end
                end

                ST_RD1: begin
                    // first read latency cycle
                    st <= ST_RD2;
                end

                ST_RD2: begin
                    // second read latency cycle
                    st <= ST_CALC;
                end

                ST_CALC: begin
                    // 当 EWA 的结果有效并且我们能推出去时，准备写回 + 输出
                    if (ewa_v && ewa_r) begin
                        for (int i=0;i<TILE_SIZE;i++) begin
                            s_new_vec[i]       <= $signed(sum_y[i]);
                            s_new_packed[i*W +: W] <= $signed(sum_y[i]);
                        end
                        out_valid <= 1'b1;
                        calc_done <= 1'b1;
                        st <= ST_WAIT; // 插一拍气泡，下一拍执行写回
                    end
                end

                ST_WAIT: begin
                    // 写回在此拍进行（state_we=1），随后回到 IDLE
                    if (state_we) begin
                        last_wr_valid <= 1'b1;
                        last_wr_addr  <= s_addr_w;
                        last_wr_data  <= s_new_packed;
                    end
                    st <= ST_IDLE;
                end
            endcase
        end
    end

    // ------------------------------------------------------------
    // 2) produce s_prev_vec from mem (sync read model)
    // ------------------------------------------------------------
    // 2-cycle read latency：address 在 ST_RD1 发出，ST_CALC 拍拿到 RAM 输出
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            for (int i=0;i<TILE_SIZE;i++) begin
                s_prev_vec[i] <= '0;
            end
        end else if (st == ST_CALC) begin
            for (int i=0;i<TILE_SIZE;i++) begin
                s_prev_vec[i] <= $signed(s_dout_mux[i*W +: W]);
            end
        end
    end

    // combinational view of RAM output for aligned multiply
    always_comb begin
        for (int i=0;i<TILE_SIZE;i++) begin
            s_prev_vec_w[i] = $signed(s_dout_mux[i*W +: W]);
        end
    end

    // ------------------------------------------------------------
    // 3) compute (1 - lam) and align u
    // ------------------------------------------------------------
    always_comb begin
        for (int i=0;i<TILE_SIZE;i++) begin
            // Q8.8: 1.0 == 0x0100
            one_minus[i] = 16'h0100 - lam_r[i];
            // s、u、lam 都是 Q8.8：乘积 Q16.16，右移 8bits 回到 Q8.8
            u_aligned[i] = u_r[i];
        end
    end

    // ------------------------------------------------------------
    // 5) state RAM instance (True dual port, 64-bit wide, depth=64)
    // ------------------------------------------------------------
    // 在 ST_WAIT 写回，需确保上一拍完成计算
    assign state_we = (st == ST_WAIT) && calc_done;

    // A 口在读流水线阶段保持使能，包含 ST_WAIT 以捕获 2-cycle 延迟输出
    wire ena_a = (st == ST_RD1) || (st == ST_RD2) || (st == ST_CALC) || (st == ST_WAIT);

    // 写地址 = 读地址 + 1，期望下一次读到上一次写入（地址空间回绕）
    assign s_addr_w = s_addr_r + 1'b1;

    s_buffer u_s_buffer (
        .clka   (clk),
        .ena    (ena_a),
        .wea    ({MEM_BYTES{1'b0}}),
        .addra  (s_addr_r),
        .dina   ({MEM_W{1'b0}}),
        .douta  (s_dout_packed),

        .clkb   (clk),
        .enb    (state_we),
        .web    (state_we ? {MEM_BYTES{1'b1}} : {MEM_BYTES{1'b0}}),
        .addrb  (s_addr_w), // 写到下一地址
        .dinb   (s_new_packed),
        .doutb  ()
    );

    // ------------------------------------------------------------
    // 4) Two parallel EWM + one EWA
    // ------------------------------------------------------------
    // EWM1: lam * s_prev
    ewm_vec4 #(
        .TILE_SIZE (TILE_SIZE),
        .IN_W      (W),
        .OUT_W     (W),
        .FRAC_BITS (8),
        .SIGNED_A  (0),
        .SIGNED_B  (1)
    ) u_ewm1 (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (st==ST_CALC),
        .in_ready (ewm1_r),
        .out_ready(ewa_r),
        .out_valid(ewm1_v),
        .a_vec    (lam_r),
        .b_vec    (s_prev_vec_w),
        .y_vec    (mul_a)
    );

    // EWM2: (1-lam) * u
    ewm_vec4 #(
        .TILE_SIZE (TILE_SIZE),
        .IN_W      (W),
        .OUT_W     (W),
        .FRAC_BITS (8),
        .SIGNED_A  (0),
        .SIGNED_B  (1)
    ) u_ewm2 (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (st==ST_CALC),
        .in_ready (ewm2_r),
        .out_ready(ewa_r),
        .out_valid(ewm2_v),
        .a_vec    (one_minus),
        .b_vec    (u_aligned),
        .y_vec    (mul_b)
    );

    // EWA: mul_a + mul_b
    wire both_mul_valid = ewm1_v && ewm2_v;

    ewa_vec4 #(
        .TILE_SIZE (TILE_SIZE),
        .W         (W),
        .SIGNED_IO (1)
    ) u_ewa (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (both_mul_valid),
        .in_ready (ewa_r),
        .out_ready(out_ready),
        .out_valid(ewa_v),
        .a_vec    (mul_a),
        .b_vec    (mul_b),
        .y_vec    (sum_y)
    );

endmodule
