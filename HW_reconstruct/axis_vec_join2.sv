module axis_vec_join2 #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16
)(
    input  logic clk,
    input  logic rst_n,

    // ---- stream A: lambda ----
    input  logic                         a_valid,
    output logic                         a_ready,
    input  logic [DATA_WIDTH-1:0]        a_vec [TILE_SIZE-1:0],

    // ---- stream B: x_t ----
    input  logic                         b_valid,
    output logic                         b_ready,
    input  logic [DATA_WIDTH-1:0]        b_vec [TILE_SIZE-1:0],

    // ---- joined output ----
    output logic                         out_valid,
    input  logic                         out_ready,
    output logic [DATA_WIDTH-1:0]        lam_vec [TILE_SIZE-1:0],
    output logic [DATA_WIDTH-1:0]        xt_vec  [TILE_SIZE-1:0]
);
    // 小型环形 FIFO，每路独立，深度=4，支持同拍 push/pop
    localparam int DEPTH = 4;
    localparam int PTR_W = $clog2(DEPTH);

    logic [DATA_WIDTH-1:0] a_mem [DEPTH-1:0][TILE_SIZE-1:0];
    logic [DATA_WIDTH-1:0] b_mem [DEPTH-1:0][TILE_SIZE-1:0];
    logic [PTR_W-1:0] a_wr, a_rd, b_wr, b_rd;
    logic [PTR_W:0]   a_count, b_count;

    assign a_ready = (a_count < DEPTH);
    assign b_ready = (b_count < DEPTH);

    assign out_valid = (a_count != 0) && (b_count != 0);
    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            lam_vec[i] = a_mem[a_rd][i];
            xt_vec[i]  = b_mem[b_rd][i];
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_wr <= '0; a_rd <= '0; a_count <= '0;
            b_wr <= '0; b_rd <= '0; b_count <= '0;
            for (int d=0; d<DEPTH; d++) begin
                for (int i=0; i<TILE_SIZE; i++) begin
                    a_mem[d][i] <= '0;
                    b_mem[d][i] <= '0;
                end
            end
        end else begin
            // 计算握手
            logic push_a, push_b, pop;
            push_a = a_valid && a_ready;
            push_b = b_valid && b_ready;
            pop    = out_valid && out_ready;

            // push A
            if (push_a) begin
                for (int i=0; i<TILE_SIZE; i++) a_mem[a_wr][i] <= a_vec[i];
                a_wr <= a_wr + 1'b1;
            end
            // push B
            if (push_b) begin
                for (int i=0; i<TILE_SIZE; i++) b_mem[b_wr][i] <= b_vec[i];
                b_wr <= b_wr + 1'b1;
            end
            // pop（同步弹出）
            if (pop) begin
                a_rd <= a_rd + 1'b1;
                b_rd <= b_rd + 1'b1;
            end

            // 更新计数，支持同拍 push+pop
            a_count <= a_count + (push_a ? 1 : 0) - (pop ? 1 : 0);
            b_count <= b_count + (push_b ? 1 : 0) - (pop ? 1 : 0);
        end
    end
endmodule
