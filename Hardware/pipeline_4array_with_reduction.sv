//---------------------------------------------------------------
// Module: pipeline_4array_with_reduction (v4 - tile-only version)
// Function:
//   - MAC 模式 (3'b000): 时间累加规约（仅使用 array4 的结果）
//   - OUTER 模式 (3'b011): 空间规约（4 个阵列结果并行规约后相加）
//   - 支持 tile-only 接口 (A_mat, B_mat)，广播逻辑由访存模块完成。
//---------------------------------------------------------------
module pipeline_4array_with_reduction #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [2:0] mode,
    input  logic valid_in,

    // --- A/B 矩阵 tile 输入 ---
    input  logic signed [DATA_WIDTH-1:0] A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],

    input  logic signed [DATA_WIDTH-1:0] B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],

    // --- 最终输出 ---
    output logic signed [ACC_WIDTH-1:0] reduced_vec [TILE_SIZE-1:0],
    // [MODIFIED] ↓ 新增四个矩阵输出
    output logic signed [ACC_WIDTH-1:0] reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0] reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0] reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0] reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic                        valid_reduced
);

    // ==========================================================
    // 1. 连接 pipeline_4array_top (tile-only)
    // ==========================================================
    logic signed [ACC_WIDTH-1:0] result_out_0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] result_out_1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] result_out_2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] result_out_3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic                        valid_array4;
    logic                        done_tile;

    pipeline_4array_top #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS)
    ) u_pipeline_4array_top (
        .clk(clk),
        .rst_n(rst_n),
        .mode(mode),
        .valid_in(valid_in),
        .valid_out(valid_array4),
        .done_tile(done_tile),
        .A0_mat(A0_mat), .A1_mat(A1_mat), .A2_mat(A2_mat), .A3_mat(A3_mat),
        .B0_mat(B0_mat), .B1_mat(B1_mat), .B2_mat(B2_mat), .B3_mat(B3_mat),
        .result_out_0(result_out_0),
        .result_out_1(result_out_1),
        .result_out_2(result_out_2),
        .result_out_3(result_out_3)
    );

    // ==========================================================
    // 2. 阵列级规约
    //    - MAC: 时间规约，只使用 array4 的结果
    //    - OUTER: 空间规约，四阵列结果并行求和
    // ==========================================================
    logic signed [ACC_WIDTH-1:0] vec0 [TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] vec1 [TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] vec2 [TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] vec3 [TILE_SIZE-1:0];
    logic valid0, valid1, valid2, valid3;

    reduction_accumulator #(.TILE_SIZE(TILE_SIZE), .ACC_WIDTH(ACC_WIDTH)) u_red0 (
        .clk(clk), .rst_n(rst_n), .mode(mode),
        .valid_in(valid_array4), .clear(done_tile),
        .mat_in(result_out_0), .vec_out(vec0), .valid_out(valid0)
    );
    reduction_accumulator #(.TILE_SIZE(TILE_SIZE), .ACC_WIDTH(ACC_WIDTH)) u_red1 (
        .clk(clk), .rst_n(rst_n), .mode(mode),
        .valid_in(valid_array4), .clear(done_tile),
        .mat_in(result_out_1), .vec_out(vec1), .valid_out(valid1)
    );
    reduction_accumulator #(.TILE_SIZE(TILE_SIZE), .ACC_WIDTH(ACC_WIDTH)) u_red2 (
        .clk(clk), .rst_n(rst_n), .mode(mode),
        .valid_in(valid_array4), .clear(done_tile),
        .mat_in(result_out_2), .vec_out(vec2), .valid_out(valid2)
    );
    reduction_accumulator #(.TILE_SIZE(TILE_SIZE), .ACC_WIDTH(ACC_WIDTH)) u_red3 (
        .clk(clk), .rst_n(rst_n), .mode(mode),
        .valid_in(valid_array4), .clear(done_tile),
        .mat_in(result_out_3), .vec_out(vec3), .valid_out(valid3)
    );

    // ==========================================================
    // 3. 最终规约：根据模式决定输出
    // ==========================================================
    logic is_vec_mode, is_outer_mode;
    assign is_vec_mode   = (mode == 3'b000 || mode == 3'b100|| mode == 3'b010);
    assign is_outer_mode = (mode == 3'b011);

    always_comb begin
        reduced_vec   = '{default:'0};
        reduced_mat_0 = '{default:'0};
        reduced_mat_1 = '{default:'0};
        reduced_mat_2 = '{default:'0};
        reduced_mat_3 = '{default:'0};
        for (int j = 0; j < TILE_SIZE; j++) begin
            if (is_outer_mode)
                // --- OUTER 模式: 空间规约 ---
                // C_h=ht⊗C_raw  //C_raw(d_state, 1), ht(d_inner, 1) → C_h(d_inner, d_state) → Reduction: C_h(d_inner, 1)
                reduced_vec[j] = vec0[j] + vec1[j] + vec2[j] + vec3[j];
            else if (is_vec_mode)
                // --- VEC 模式: 仅使用 array4 累加结果 ---
                // --- MAC 模式: 仅使用 array4 累加结果 ---
                reduced_vec[j] = vec3[j];
            else begin
                for (int i = 0; i < TILE_SIZE; i++) begin
                    reduced_mat_0[i][j] = result_out_0[i][j];
                    reduced_mat_1[i][j] = result_out_1[i][j];
                    reduced_mat_2[i][j] = result_out_2[i][j];
                    reduced_mat_3[i][j] = result_out_3[i][j];
                end
            end
        end
    end

    assign valid_reduced = is_outer_mode ? (valid0 & valid1 & valid2 & valid3)
                                         : valid3;

endmodule
