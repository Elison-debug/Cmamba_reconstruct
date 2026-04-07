//---------------------------------------------------------------
// Module: broadcast_tile_gen
// Function:
//   向量到矩阵广播模块，用于将访存读出的向量转换为阵列输入 tile。
//   - mode=0: 列广播 (column broadcast)
//   - mode=1: 行广播 (row broadcast)
//---------------------------------------------------------------
module broadcast_tile_gen #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16
)(
    input  logic  mode,  // 0:列广播, 1:行广播
    input  logic signed [DATA_WIDTH-1:0] vec_in [TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0] mat_out [TILE_SIZE-1:0][TILE_SIZE-1:0]
);

    always_comb begin
        integer i, j;
        for (i = 0; i < TILE_SIZE; i++) begin
            for (j = 0; j < TILE_SIZE; j++) begin
                unique case (mode)
                    1'b0: mat_out[i][j] = vec_in[j]; // 列广播
                    1'b1: mat_out[i][j] = vec_in[i]; // 行广播
                    default: mat_out[i][j] = '0;
                endcase
            end
        end
    end

endmodule
