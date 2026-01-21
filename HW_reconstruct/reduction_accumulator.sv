//---------------------------------------------------------------
// Module: reduction_accumulator (stage-retimed, same interface)
//---------------------------------------------------------------
module reduction_accumulator #(
    parameter int TILE_SIZE  = 4,
    parameter int ACC_WIDTH  = 32
)(
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    input  logic [1:0] mode,
    input  logic clear,
    input  logic signed [ACC_WIDTH-1:0] mat_in [TILE_SIZE-1:0][TILE_SIZE-1:0],

    output logic signed [ACC_WIDTH-1:0] vec_out [TILE_SIZE-1:0],
    output logic valid_out
);

    // ----------------------------------------------------------
    // Mode 判定
    // ----------------------------------------------------------
    logic is_mac_mode;
    assign is_mac_mode   = (mode == 2'b00);

    // ----------------------------------------------------------
    // Level 1: 4→2 并行加法
    // ----------------------------------------------------------
    logic signed [ACC_WIDTH-1:0] sum_l1 [TILE_SIZE-1:0][1:0];
    always_comb begin
        for (int j = 0; j < TILE_SIZE; j++) begin
            sum_l1[j][0] = mat_in[0][j] + mat_in[1][j];
            sum_l1[j][1] = mat_in[2][j] + mat_in[3][j];
        end
    end

    // ----------------------------------------------------------
    // Level 2: 2→1 加法 (列规约完成)
    // ----------------------------------------------------------
    logic signed [ACC_WIDTH-1:0] col_sum [TILE_SIZE-1:0];
    always_comb begin
        for (int j = 0; j < TILE_SIZE; j++)
            col_sum[j] = sum_l1[j][0] + sum_l1[j][1];
    end

    // ----------------------------------------------------------
    // Stage0 registers: capture col_sum + control (守住接口语义)
    // ----------------------------------------------------------
    logic signed [ACC_WIDTH-1:0] col_sum_q [TILE_SIZE-1:0];
    logic                        valid_q;
    logic                        mac_mode_q;
    logic                        clear_q;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_q      <= 1'b0;
            mac_mode_q   <= 1'b0;
            clear_q      <= 1'b0;
            for (int j = 0; j < TILE_SIZE; j++)
                col_sum_q[j] <= '0;
        end else begin
            valid_q      <= valid_in;
            mac_mode_q   <= is_mac_mode;
            clear_q      <= clear;
            if (valid_in) begin
                for (int j = 0; j < TILE_SIZE; j++)
                    col_sum_q[j] <= col_sum[j];
            end
            if (clear) begin
                for (int j = 0; j < TILE_SIZE; j++)
                    col_sum_q[j] <= '0;
            end
        end
    end

    // ----------------------------------------------------------
    // Stage1: 输出寄存器 (MAC累加 / OUTER单拍)
    // ----------------------------------------------------------
    logic signed [ACC_WIDTH-1:0] acc_vec [TILE_SIZE-1:0];
    logic valid_reg;
    logic suppress_valid; // 清零后屏蔽本 tile 剩余拍的 valid

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int j = 0; j < TILE_SIZE; j++)
                acc_vec[j] <= '0;
            valid_reg <= 1'b0;
            suppress_valid <= 1'b0;
        end
        else if (clear_q) begin
            // 清零拍不输出有效结果
            for (int j = 0; j < TILE_SIZE; j++)
                acc_vec[j] <= '0;
            valid_reg <= 1'b0;
            suppress_valid <= 1'b1;
        end
        else if (valid_q) begin
            if (!suppress_valid) begin
                if (mac_mode_q) begin
                    for (int j = 0; j < TILE_SIZE; j++)
                        acc_vec[j] <= acc_vec[j] + col_sum_q[j];
                end else begin
                    for (int j = 0; j < TILE_SIZE; j++)
                        acc_vec[j] <= col_sum_q[j];
                end
                valid_reg <= 1'b1;
            end else begin
                valid_reg <= 1'b0;
            end
        end
        else begin
            valid_reg <= 1'b0;
            if (!valid_q)
                suppress_valid <= 1'b0; // 等待一个空拍解除屏蔽，进入下一个 tile
        end
    end

    assign vec_out   = acc_vec;
    assign valid_out = valid_reg;

endmodule
