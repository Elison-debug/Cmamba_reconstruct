`timescale 1ns/1ps
//---------------------------------------------------------------
// Testbench for mac_mem_controller_combined
// - 验证：连续送入2个tile的访存与xt同步是否正确
// - 在仿真中直接初始化WBUF和XT ROM的内容（无需COE文件）
//---------------------------------------------------------------
module tb_mac_mem_controller_combined;

    // ---------------- 参数设置 ----------------
    localparam int TILE_SIZE  = 4;
    localparam int DATA_WIDTH = 16;
    localparam int ACC_WIDTH  = 32;
    localparam int FRAC_BITS  = 8;
    localparam int N_BANK     = 12;
    localparam int ADDR_W     = 10;
    localparam int DATA_W     = 256;

    // ---------------- DUT 端口 ----------------
    logic clk, rst_n;
    logic s_axis_TVALID, s_axis_TREADY;
    logic m_axis_TVALID, m_axis_TREADY;
    logic signed [ACC_WIDTH-1:0] reduced_vec [TILE_SIZE-1:0];

    // ---------------- 时钟与复位 ----------------
    initial begin
        clk = 0;
        forever #1 clk = ~clk; // 2ns周期 => 500MHz
    end

    initial begin
        rst_n = 0;
        s_axis_TVALID = 0;
        m_axis_TREADY = 1;
        #10;
        rst_n = 1;
    end

    // ---------------- DUT 实例 ----------------
    mac_mem_controller_combined #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS),
        .N_BANK    (N_BANK),
        .ADDR_W    (ADDR_W),
        .DATA_W    (DATA_W)
    ) u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_axis_TVALID(s_axis_TVALID),
        .s_axis_TREADY(s_axis_TREADY),
        .m_axis_TVALID(m_axis_TVALID),
        .m_axis_TREADY(m_axis_TREADY),
        .reduced_vec(reduced_vec)
    );

    // ==========================================================
    // 初始化块：为所有WBUF和XT ROM写入伪数据
    // ==========================================================
    initial begin
        // 等待DUT内模块实例化完成
        #5;

        // ---------- 初始化 WBUF ----------
        $display("[%0t] 🔧 Initializing WBUF banks...", $time);
        for (int b = 0; b < 12; b++) begin
            for (int addr = 0; addr < 64; addr++) begin
                // 为每个地址打包16个16-bit权重到256-bit
                logic [DATA_W-1:0] line = '0;
                for (int w = 0; w < 16; w++) begin
                    // 简单非零递增模式：便于观测拆片是否正确
                    line[w*DATA_WIDTH +: DATA_WIDTH] = 16'((b*1000) + (addr*16) + w + 1);
                end
                u_dut.u_wbuf.mem_sim[b][addr] = line;
            end
        end

        // ---------- 初始化 XT ROM ----------
        $display("[%0t] 🔧 Initializing X_T_ROM...", $time);
        for (int addr = 0; addr < 16; addr++) begin
            // 每个地址输出4个16-bit数据，总计64-bit
            // 低位存 xt[0]，高位存 xt[3]
            u_dut.u_xt.mem_sim[addr] = {
                16'(4*addr + 4),
                16'(4*addr + 3),
                16'(4*addr + 2),
                16'(4*addr + 1)
            };
        end
    end

    // ==========================================================
    // 驱动输入
    // 模拟 AXI Stream 接口：连续送 2 个 tile 任务
    // ==========================================================
    initial begin
        wait(rst_n == 1);
        @(posedge clk);

        $display("[%0t] 🚀 Start feeding tile 1...", $time);
        s_axis_TVALID = 1;
        wait (s_axis_TREADY);
        @(posedge clk);
        s_axis_TVALID = 0;

        // 模拟tile 1执行阶段（64拍）
        repeat (70) @(posedge clk);

        $display("[%0t] 🚀 Start feeding tile 2...", $time);
        s_axis_TVALID = 1;
        wait (s_axis_TREADY);
        @(posedge clk);
        s_axis_TVALID = 0;

        // 模拟tile 2执行阶段
        repeat (70) @(posedge clk);

        $display("[%0t] ✅ Done sending 2 tiles.", $time);
        repeat (20) @(posedge clk);
        $finish;
    end

    // ==========================================================
    // 输出监视
    // ==========================================================
    always_ff @(posedge clk) begin
        if (m_axis_TVALID && m_axis_TREADY) begin
            $display("[%0t] ✅ Output valid:", $time);
            for (int i = 0; i < TILE_SIZE; i++)
                $display("    reduced_vec[%0d] = %0d", i, reduced_vec[i]);
        end
    end

endmodule
