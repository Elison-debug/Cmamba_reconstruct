//---------------------------------------------------------------
// Module: pipeline_4array_with_reduction (v4 - tile-only version)
// Function:
//   - MAC 模式 (2'b00): 时间累加规约（仅使用 array4 的结果）
//   - 其他模式 (2'b01/2'b10): 单拍输出（不再区分 OUTER）
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
    input  logic [1:0] mode,
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
    //    - 当前仅保留单条规约路径，使用 array4 的结果
    // ==========================================================
    logic signed [ACC_WIDTH-1:0] vec3 [TILE_SIZE-1:0];
    logic                        valid3;

    reduction_accumulator #(.TILE_SIZE(TILE_SIZE), .ACC_WIDTH(ACC_WIDTH)) u_red3 (
        .clk(clk), .rst_n(rst_n), .mode(mode),
        .valid_in(valid_array4), .clear(done_tile),
        .mat_in(result_out_3), .vec_out(vec3), .valid_out(valid3)
    );

    // ==========================================================
    // 3. 最终规约：根据模式决定输出
    // ==========================================================
    logic is_vec_mode;
    assign is_vec_mode   = (mode == 2'b00 || mode == 2'b01 || mode == 2'b10);

    always_comb begin
        reduced_vec   = '{default:'0};
        reduced_mat_0 = '{default:'0};
        reduced_mat_1 = '{default:'0};
        reduced_mat_2 = '{default:'0};
        reduced_mat_3 = '{default:'0};
        for (int j = 0; j < TILE_SIZE; j++) begin
            if (is_vec_mode) begin
                reduced_vec[j] = vec3[j];
            end else begin
                for (int i = 0; i < TILE_SIZE; i++) begin
                    reduced_mat_0[i][j] = result_out_0[i][j];
                    reduced_mat_1[i][j] = result_out_1[i][j];
                    reduced_mat_2[i][j] = result_out_2[i][j];
                    reduced_mat_3[i][j] = result_out_3[i][j];
                end
            end
        end
    end

    assign valid_reduced = valid3;

endmodule
