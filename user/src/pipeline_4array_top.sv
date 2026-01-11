//---------------------------------------------------------------
// Module: pipeline_4array_top (v17 - tile-only version)
//   Mode Encoding (2-bit):
//   -----------------------------------------------------------
//   | mode | Operation Description          | Formula                           | Output Shape |
//   |------|--------------------------------|-----------------------------------|---------------|
//   | 00   | MAC (Matrix × Vector)          | RAW=Wx_pj⊙x_t; Δ_t=W_Δ⊙Δ_raw    | Vector (d_state×1) |
//   | 01   | EWM-Vector (Vector × Vector)   | D_x = D ⊙ x_t                    | Vector (d_inner×1) |
//   | 10   | EWA-Vector (Vector + Vector)   | y = C_h + D_x; Δ_t_b=Δ_t+dt_bias  | Vector (d_inner×1) |
//   -----------------------------------------------------------
// Function:
//   输入接口：A 为矩阵 tile；B 为矩阵 tile（广播由上层控制）。
//   顶层实现流水线控制与 tile 分发。
//---------------------------------------------------------------
module pipeline_4array_top #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [1:0] mode,
    input  logic valid_in,
    output logic valid_out,
    output logic done_tile,

    // --- 4 组 A 矩阵 tile 输入 ---
    input  logic signed [DATA_WIDTH-1:0] A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],

    // --- 4 组 B 矩阵 tile 输入 ---
    input  logic signed [DATA_WIDTH-1:0] B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],

    // --- 4 组输出矩阵 ---
    output logic signed [ACC_WIDTH-1:0] result_out_0 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0] result_out_1 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0] result_out_2 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0] result_out_3 [TILE_SIZE-1:0][TILE_SIZE-1:0]
);

    // ==========================================================
    // Mode 映射
    // ==========================================================
    logic [1:0] pe_mode;
    assign pe_mode = mode; // mode 与 pe_mode 一一对应

    // ==========================================================
    // 内部信号定义
    // ==========================================================
    localparam int COL_BLOCKS = 256 / (TILE_SIZE * 4);
    logic [6:0] col_cnt;

    logic v1, v2, v3, v4;
    logic is_mac_mode;

    assign is_mac_mode = (mode == 2'b00);

    logic signed [ACC_WIDTH-1:0] acc_1_out [TILE_SIZE-1:0][TILE_SIZE-1:0],
                                acc_2_out [TILE_SIZE-1:0][TILE_SIZE-1:0],
                                acc_3_out [TILE_SIZE-1:0][TILE_SIZE-1:0],
                                acc_4_out [TILE_SIZE-1:0][TILE_SIZE-1:0];

    logic signed [ACC_WIDTH-1:0] acc_in_1 [TILE_SIZE-1:0][TILE_SIZE-1:0],
                                acc_in_2 [TILE_SIZE-1:0][TILE_SIZE-1:0],
                                acc_in_3 [TILE_SIZE-1:0][TILE_SIZE-1:0],
                                acc_in_4 [TILE_SIZE-1:0][TILE_SIZE-1:0];

    logic v_in_1, v_in_2, v_in_3, v_in_4;

    // ==========================================================
    // 流水线控制逻辑
    // ==========================================================
    assign v_in_1 = valid_in;
    assign v_in_2 = is_mac_mode ? v1 : valid_in;
    assign v_in_3 = is_mac_mode ? v2 : valid_in;
    assign v_in_4 = is_mac_mode ? v3 : valid_in;

    always_comb begin
        integer i, j;
        for (i = 0; i < TILE_SIZE; i++) begin
            for (j = 0; j < TILE_SIZE; j++) begin
                acc_in_1[i][j] = '0;
                acc_in_2[i][j] = is_mac_mode ? acc_1_out[i][j] : '0;
                acc_in_3[i][j] = is_mac_mode ? acc_2_out[i][j] : '0;
                acc_in_4[i][j] = is_mac_mode ? acc_3_out[i][j] : '0;
            end
        end
    end

    // ==========================================================
    // 4 个阵列实例
    // ==========================================================
    array4x4 #(
        .TILE_SIZE(TILE_SIZE), .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH), .FRAC_BITS(FRAC_BITS)
    ) u_array1 (
        .clk(clk), .rst_n(rst_n),
        .valid_in(v_in_1), .valid_out(v1),
        .pe_mode(pe_mode),
        .a_in(A0_mat), .b_in(B0_mat),
        .acc_in(acc_in_1), .result_out(acc_1_out)
    );

    array4x4 #(
        .TILE_SIZE(TILE_SIZE), .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH), .FRAC_BITS(FRAC_BITS)
    ) u_array2 (
        .clk(clk), .rst_n(rst_n),
        .valid_in(v_in_2), .valid_out(v2),
        .pe_mode(pe_mode),
        .a_in(A1_mat), .b_in(B1_mat),
        .acc_in(acc_in_2), .result_out(acc_2_out)
    );

    array4x4 #(
        .TILE_SIZE(TILE_SIZE), .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH), .FRAC_BITS(FRAC_BITS)
    ) u_array3 (
        .clk(clk), .rst_n(rst_n),
        .valid_in(v_in_3), .valid_out(v3),
        .pe_mode(pe_mode),
        .a_in(A2_mat), .b_in(B2_mat),
        .acc_in(acc_in_3), .result_out(acc_3_out)
    );

    array4x4 #(
        .TILE_SIZE(TILE_SIZE), .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH), .FRAC_BITS(FRAC_BITS)
    ) u_array4 (
        .clk(clk), .rst_n(rst_n),
        .valid_in(v_in_4), .valid_out(v4),
        .pe_mode(pe_mode),
        .a_in(A3_mat), .b_in(B3_mat),
        .acc_in(acc_in_4), .result_out(acc_4_out)
    );

    // ==========================================================
    // 输出 & Tile 完成信号
    // ==========================================================
    assign result_out_0 = acc_1_out;
    assign result_out_1 = acc_2_out;
    assign result_out_2 = acc_3_out;
    assign result_out_3 = acc_4_out;

    assign valid_out = is_mac_mode ? v4 : v1;

    // ==========================================================
    // 5. Tile 完成检测逻辑 (用于驱动 reduction 清零)
    // ==========================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_cnt   <= '0;
            done_tile <= 1'b0;
        end
        else if (is_mac_mode) begin
            // 以 valid_out 为计数基准，遇到空拍立即重置，避免跨 tile 累计
            if (!valid_out) begin
                col_cnt   <= '0;
                done_tile <= 1'b0;
            end else if (col_cnt == COL_BLOCKS - 1) begin
                col_cnt   <= '0;
                done_tile <= 1'b1;   // 每个 tile 完成时拉高一拍
            end else begin
                col_cnt   <= col_cnt + 1;
                done_tile <= 1'b0;
            end
        end
        else begin
            // 非 MAC 模式清零
            col_cnt   <= '0;
            done_tile <= 1'b0;
        end
    end

endmodule
