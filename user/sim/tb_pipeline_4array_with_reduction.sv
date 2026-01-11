`timescale 1ns/1ps
module tb_pipeline_4array_with_reduction_v3;

    // ---------------- 参数 ----------------
    localparam int TILE_SIZE  = 4;
    localparam int DATA_WIDTH = 16;
    localparam int ACC_WIDTH  = 32;
    localparam int FRAC_BITS  = 8;
    localparam int ROWS = 40;
    localparam int K    = 256;
    localparam int FLUSH_CYCLES = 24;

    // ---------------- 信号定义 ----------------
    logic clk, rst_n;
    logic [1:0] mode;
    logic valid_in, valid_reduced;
    logic signed [DATA_WIDTH-1:0] A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] reduced_vec [TILE_SIZE-1:0];

    // ---------------- DUT ----------------
    pipeline_4array_with_reduction #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .mode(mode), .valid_in(valid_in),
        .A0_mat(A0_mat), .A1_mat(A1_mat), .A2_mat(A2_mat), .A3_mat(A3_mat),
        .B0_mat(B0_mat), .B1_mat(B1_mat), .B2_mat(B2_mat), .B3_mat(B3_mat),
        .reduced_vec(reduced_vec), .valid_reduced(valid_reduced)
    );

    // ---------------- 时钟 ----------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ---------------- 数据存储 ----------------
    logic signed [DATA_WIDTH-1:0] A_mem [ROWS-1:0][K-1:0];
    logic signed [DATA_WIDTH-1:0] B_mem [K-1:0];
    longint signed golden_mac [ROWS-1:0];

    // ---------------- 工具函数 ----------------
    function automatic logic signed [DATA_WIDTH-1:0] to_dw(input integer val);
        logic signed [DATA_WIDTH-1:0] tmp;
        begin tmp = val; to_dw = tmp; end
    endfunction

    // ---------------- 初始化任务 ----------------
    task automatic init_data;
        int r, k;
        begin
            for (r = 0; r < ROWS; r++)
                for (k = 0; k < K; k++)
                    A_mem[r][k] = to_dw(((r % 5) - 2) * (1 << FRAC_BITS) + ((k % 7) - 3));
            for (k = 0; k < K; k++)
                B_mem[k] = to_dw(((k % 9) - 4) * (1 << (FRAC_BITS-1)));
        end
    endtask

    // ---------------- golden (MAC) ----------------
    task automatic compute_golden_mac;
        int r, k;
        begin
            for (r = 0; r < ROWS; r++) begin
                golden_mac[r] = 0;
                for (k = 0; k < K; k++)
                    golden_mac[r] += longint'(A_mem[r][k]) * longint'(B_mem[k]);
            end
        end
    endtask

    // ---------------- Tile 构建任务 ----------------
    task automatic build_tile_by_array(
        input int array_id,
        input int row_base,
        input int k_base
    );
        int i, j, offset;
        begin
            offset = array_id * 4;

            // === A tile ===
            for (i = 0; i < TILE_SIZE; i++)
                for (j = 0; j < TILE_SIZE; j++) begin
                    case (array_id)
                        0: A0_mat[i][j] = A_mem[row_base + i][k_base + offset + j];
                        1: A1_mat[i][j] = A_mem[row_base + i][k_base + offset + j];
                        2: A2_mat[i][j] = A_mem[row_base + i][k_base + offset + j];
                        3: A3_mat[i][j] = A_mem[row_base + i][k_base + offset + j];
                    endcase
                end

            // === B tile === (矩阵，每行重复 B_mem 段)
            for (i = 0; i < TILE_SIZE; i++)
                for (j = 0; j < TILE_SIZE; j++) begin
                    case (array_id)
                        0: B0_mat[i][j] = B_mem[k_base + offset + j];
                        1: B1_mat[i][j] = B_mem[k_base + offset + j];
                        2: B2_mat[i][j] = B_mem[k_base + offset + j];
                        3: B3_mat[i][j] = B_mem[k_base + offset + j];
                    endcase
                end
        end
    endtask

    // ---------------- 节拍化送数任务 ----------------
    task automatic send_tile_pipeline(
        input int row_base,
        input int k_base
    );
        begin
            for (int arr = 0; arr < 4; arr++) begin
                build_tile_by_array(arr, row_base, k_base);
                valid_in = 1'b1;
                @(posedge clk);
            end
        end
    endtask

    // ---------------- 驱动序列 (MAC 模式) ----------------
    task automatic run_mac_mode(input int num_rows);
        int rb, kb;
        begin
            $display("\n===== MAC MODE TEST START =====");
            mode = 2'b00;
            for (rb = 0; rb < num_rows; rb += TILE_SIZE) begin
                for (kb = 0; kb < K; kb += 16)
                    send_tile_pipeline(rb, kb);
                repeat (6) @(posedge clk);
            end
            repeat (8) @(posedge clk);
            $display("MAC mode finished.\n");
        end
    endtask

    // ---------------- 主过程 ----------------
    initial begin
        clk = 0;
        rst_n = 0;
        valid_in = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
        init_data();
        compute_golden_mac();

        // === MAC 多组测试 ===
        run_mac_mode(3 * TILE_SIZE);
        repeat (FLUSH_CYCLES) @(posedge clk);
        valid_in = 0;
        repeat (5) @(posedge clk);

        $display("\n===== Simulation Finished =====");
        $finish;
    end

endmodule

// `timescale 1ns/1ps
// module tb_pipeline_4array_with_reduction_v2;

//     // ---------------- 参数 ----------------
//     localparam int TILE_SIZE  = 4;
//     localparam int DATA_WIDTH = 16;
//     localparam int ACC_WIDTH  = 32;
//     localparam int FRAC_BITS  = 8;
//     localparam int ROWS = 40;
//     localparam int K    = 256;
//     localparam int FLUSH_CYCLES = 24; // flush pipeline between modes

//     // ---------------- 信号定义 ----------------
//     logic clk, rst_n;
//     logic [1:0] mode;
//     logic valid_in, valid_reduced;
//     logic signed [DATA_WIDTH-1:0] A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
//     logic signed [DATA_WIDTH-1:0] A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
//     logic signed [DATA_WIDTH-1:0] A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
//     logic signed [DATA_WIDTH-1:0] A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
//     logic signed [DATA_WIDTH-1:0] B0_vec [TILE_SIZE-1:0];
//     logic signed [DATA_WIDTH-1:0] B1_vec [TILE_SIZE-1:0];
//     logic signed [DATA_WIDTH-1:0] B2_vec [TILE_SIZE-1:0];
//     logic signed [DATA_WIDTH-1:0] B3_vec [TILE_SIZE-1:0];
//     logic signed [ACC_WIDTH-1:0] reduced_vec [TILE_SIZE-1:0];

//     // ---------------- DUT ----------------
//     pipeline_4array_with_reduction #(
//         .TILE_SIZE (TILE_SIZE),
//         .DATA_WIDTH(DATA_WIDTH),
//         .ACC_WIDTH (ACC_WIDTH),
//         .FRAC_BITS (FRAC_BITS)
//     ) dut (
//         .clk(clk), .rst_n(rst_n),
//         .mode(mode), .valid_in(valid_in),
//         .A0_mat(A0_mat), .A1_mat(A1_mat), .A2_mat(A2_mat), .A3_mat(A3_mat),
//         .B0_vec(B0_vec), .B1_vec(B1_vec), .B2_vec(B2_vec), .B3_vec(B3_vec),
//         .reduced_vec(reduced_vec), .valid_reduced(valid_reduced)
//     );

//     // ---------------- 时钟 ----------------
//     initial begin
//         clk = 0;
//         forever #5 clk = ~clk;
//     end

//     // ---------------- 数据存储 ----------------
//     logic signed [DATA_WIDTH-1:0] A_mem [ROWS-1:0][K-1:0];
//     logic signed [DATA_WIDTH-1:0] B_mem [K-1:0];
//     longint signed golden_mac [ROWS-1:0];

//     // ---------------- 工具函数 ----------------
//     function automatic logic signed [DATA_WIDTH-1:0] to_dw(input integer val);
//         logic signed [DATA_WIDTH-1:0] tmp;
//         begin tmp = val; to_dw = tmp; end
//     endfunction

//     // ---------------- 初始化任务 ----------------
//     task automatic init_data;
//         int r, k;
//         begin
//             for (r = 0; r < ROWS; r++)
//                 for (k = 0; k < K; k++)
//                     A_mem[r][k] = to_dw(((r % 5) - 2) * (1 << FRAC_BITS) + ((k % 7) - 3));
//             for (k = 0; k < K; k++)
//                 B_mem[k] = to_dw(((k % 9) - 4) * (1 << (FRAC_BITS-1)));
//         end
//     endtask

//     // ---------------- golden (MAC) ----------------
//     task automatic compute_golden_mac;
//         int r, k;
//         begin
//             for (r = 0; r < ROWS; r++) begin
//                 golden_mac[r] = 0;
//                 for (k = 0; k < K; k++)
//                     golden_mac[r] += longint'(A_mem[r][k]) * longint'(B_mem[k]);
//             end
//         end
//     endtask

//     // ---------------- 节拍化 tile 构建 ----------------
//     task automatic build_tile_by_array(
//         input int array_id,
//         input int row_base,
//         input int k_base
//     );
//         int i, j, offset;
//         begin
//             offset = array_id * 4;
//             for (i = 0; i < TILE_SIZE; i++)
//                 for (j = 0; j < TILE_SIZE; j++) begin
//                     case (array_id)
//                         0: A0_mat[i][j] = A_mem[row_base + i][k_base + offset + j];
//                         1: A1_mat[i][j] = A_mem[row_base + i][k_base + offset + j];
//                         2: A2_mat[i][j] = A_mem[row_base + i][k_base + offset + j];
//                         3: A3_mat[i][j] = A_mem[row_base + i][k_base + offset + j];
//                     endcase
//                 end
//             for (j = 0; j < TILE_SIZE; j++) begin
//                 case (array_id)
//                     0: B0_vec[j] = B_mem[k_base + offset + j];
//                     1: B1_vec[j] = B_mem[k_base + offset + j];
//                     2: B2_vec[j] = B_mem[k_base + offset + j];
//                     3: B3_vec[j] = B_mem[k_base + offset + j];
//                 endcase
//             end
//         end
//     endtask

//     // ---------------- 节拍化送数任务 ----------------
//     task automatic send_tile_pipeline(
//         input int row_base,
//         input int k_base
//     );
//         begin
//             for (int arr = 0; arr < 4; arr++) begin
//                 build_tile_by_array(arr, row_base, k_base);
//                 valid_in = 1'b1;
//                 @(posedge clk);
//             end
//             //valid_in = 0;
//             //@(posedge clk);
//         end
//     endtask

//     // ---------------- 驱动序列 (MAC 模式) ----------------
//     task automatic run_mac_mode(input int num_rows);
//         int rb, kb;
//         begin
//             $display("\n===== MAC MODE TEST START =====");
//             mode = 2'b00;
//             for (rb = 0; rb < num_rows; rb += TILE_SIZE) begin
//                 for (kb = 0; kb < K; kb += 16) begin
//                     send_tile_pipeline(rb, kb);
//                 end
//                 repeat (6) @(posedge clk); // 每行完稍作间隔
//             end
//             repeat (8) @(posedge clk);
//             $display("MAC mode finished.\n");
//         end
//     endtask

//     // ---------------- 驱动序列 (OUTER 模式) ----------------
//     task automatic run_outer_mode(input int num_groups);
//         int i, j, g;
//         begin
//             $display("\n===== OUTER MODE TEST START =====");
//             mode = 2'b01;

//             for (g = 0; g < num_groups; g++) begin
//                 valid_in = 1'b1;
//                 // 模拟多组不同的 h_t × C_raw
//                 for (i = 0; i < TILE_SIZE; i++)
//                     for (j = 0; j < TILE_SIZE; j++) begin
//                         A0_mat[i][j] = to_dw((i + 1 + g) * (1 << FRAC_BITS));
//                         A1_mat[i][j] = to_dw((i + 1 + g) * (1 << FRAC_BITS));
//                         A2_mat[i][j] = to_dw((i + 1 + g) * (1 << FRAC_BITS));
//                         A3_mat[i][j] = to_dw((i + 1 + g) * (1 << FRAC_BITS));
//                     end
//                 for (j = 0; j < TILE_SIZE; j++) begin
//                     B0_vec[j] = to_dw(j + 1 + g);
//                     B1_vec[j] = to_dw(j + 5 + g);
//                     B2_vec[j] = to_dw(j + 9 + g);
//                     B3_vec[j] = to_dw(j + 13 + g);
//                 end
//                 @(posedge clk);
//                 //valid_in = 0;
//                 //repeat (4) @(posedge clk);
//                 for (i = 0; i < TILE_SIZE; i++)
//                     $display("OUTER[%0d] reduced_vec[%0d] = %0d", g, i, reduced_vec[i]);
//             end

//             $display("OUTER mode finished.\n");
//         end
//     endtask

//     // ---------------- 主过程 ----------------
//     initial begin
//         clk = 0;
//         rst_n = 0;
//         valid_in = 0;
//         repeat (5) @(posedge clk);
//         rst_n = 1;
//         init_data();
//         compute_golden_mac();

//         // === MAC 多组测试 ===
//         run_mac_mode(3 * TILE_SIZE); // 测试3个row block
//         repeat (FLUSH_CYCLES) @(posedge clk); // flush pipeline
//         valid_in = 0;
//         repeat (5) @(posedge clk);
//         // === OUTER 多组测试 ===
//         run_outer_mode(3); // 测试3组 outer 数据
//         repeat (10) @(posedge clk);

//         $display("\n===== Simulation Finished =====");
//         $finish;
//     end

// endmodule
