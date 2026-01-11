`timescale 1ns/1ps
//======================================================================
// tb_top_mac_plus_bias_pure_ip.sv  (PURE IP VERSION, Vivado-safe syntax)
// Fixes for your errors/warnings:
//  - "syntax error near '['": caused by using (1000+i)[DATA_WIDTH-1:0] in function.
//    => replaced with explicit cast: $signed(16'(1000+global_i)).
//  - VRFC warnings about block variables needing automatic/static:
//    => declare variables outside loops OR declare them as automatic in a task/function.
//    Here I move declarations outside for-loops.
//
// Notes:
//  1) This TB does NOT define behavioral bias_ROM.
//  2) You must compile the Vivado-generated bias_ROM simulation sources.
//  3) For bias ROM init: uncomment the correct internal array name (mem/mem_sim/ram/...)
//======================================================================

module tb_top_mac_plus_bias_pure_ip;

    // ---------------- Parameters ----------------
    localparam int TILE_SIZE  = 4;
    localparam int DATA_WIDTH = 16;
    localparam int ACC_WIDTH  = 32;
    localparam int FRAC_BITS  = 8;
    localparam int N_BANK     = 6;
    localparam int DEPTH      = 683;
    localparam int WADDR_W    = $clog2(DEPTH);
    localparam int DATA_W     = 256;
    localparam int XT_ADDR_W  = 6;

    localparam int D          = 256;
    // 实测 bias 链路总延迟为 4 拍（ROM + 对齐寄存 + 输出保持）
    localparam int PIPE_LAT   = 4;

    // ---------------- DUT ports ----------------
    logic clk, rst_n;
    logic s_axis_TVALID, s_axis_TREADY;

    logic                     bias_out_valid;
    logic                     bias_out_ready;
    logic signed [DATA_WIDTH-1:0] bias_out_vec [TILE_SIZE-1:0];

    // ---------------- Clock ----------------
    initial begin
        clk = 0;
        forever #1 clk = ~clk;   // 500 MHz
    end

    // ---------------- Reset ----------------
    initial begin
        rst_n = 0;
        s_axis_TVALID   = 0;
        bias_out_ready  = 1;     // no backpressure first
        #10;
        rst_n = 1;
    end

    // ---------------- DUT ----------------
    top_mac_plus_bias #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS),
        .N_BANK    (N_BANK),
        .WDEPTH    (DEPTH),
        .WADDR_W   (WADDR_W),
        .DATA_W    (DATA_W),
        .XT_ADDR_W (XT_ADDR_W),
        .D         (D),
        .PIPE_LAT  (PIPE_LAT)
    ) u_top (
        .clk           (clk),
        .rst_n         (rst_n),
        .s_axis_TVALID (s_axis_TVALID),
        .s_axis_TREADY (s_axis_TREADY),
        .bias_out_valid(bias_out_valid),
        .bias_out_ready(bias_out_ready),
        .bias_out_vec  (bias_out_vec)
    );

    // ==========================================================
    //   Initialize WBUF + XT + Bias ROM (PURE IP)
    // ==========================================================
    integer b, addr, w;
    integer tile_id;
    integer element_id;
    integer value;
    logic [DATA_W-1:0] line;

    integer a;
    integer base;
    logic [63:0] word;

    initial begin
        // 初始化中间变量，避免波形前期显示 X
        b          = 0;
        addr       = 0;
        w          = 0;
        tile_id    = 0;
        element_id = 0;
        value      = 0;
        line       = '0;
        a          = 0;
        base       = 0;
        word       = '0;

        #5;

        // ---------------- WBUF init ----------------
        $display("[%0t] 🔧 Initializing 6-bank WBUF (DEPTH=683)...", $time);
        for (b = 0; b < N_BANK; b = b + 1) begin
            for (addr = 0; addr < DEPTH; addr = addr + 1) begin
                line = '0;
                tile_id = b + addr * N_BANK;   // 0~4095

                for (w = 0; w < 16; w = w + 1) begin
                    element_id = tile_id * 16 + w;
                    value      = 1 + element_id;
                    line[w*DATA_WIDTH +: DATA_WIDTH] = value[DATA_WIDTH-1:0];
                end

                u_top.u_mac.u_wbuf.mem_sim[b][addr] = line;
            end
        end

        // ---------------- XT init ----------------
        $display("[%0t] 🔧 Initializing XT ROM (64 entries)...", $time);
        for (addr = 0; addr < 64; addr = addr + 1) begin
            u_top.u_mac.u_xt.mem_sim[addr] = {
                16'(4*addr + 4),
                16'(4*addr + 3),
                16'(4*addr + 2),
                16'(4*addr + 1)
            };
        end

        // ---------------- bias ROM init ----------------
        $display("[%0t] 🔧 Initializing bias_ROM IP (64x64b)...", $time);
        for (a = 0; a < 64; a = a + 1) begin
            base = a * 4;
            word = {
                16'(1000 + base + 3),
                16'(1000 + base + 2),
                16'(1000 + base + 1),
                16'(1000 + base + 0)
            };

            // !!! Choose the hierarchy that matches your IP sim model !!!
            // 这里选择 bias_add_regslice_ip 内建的仿真 mem_sim
            u_top.u_bias_add.mem_sim[a] = word;
            // 其他可能的层次（保留注释以便切换）:
            // u_top.u_bias_add.u_bias_rom.mem[a] = word;
            // u_top.u_bias_add.u_bias_rom.ram[a] = word;
            // u_top.u_bias_add.u_bias_rom.U0.mem[a] = word;
        end

        $display("[%0t] ✅ Init done", $time);
    end

    // ==========================================================
    // AXIS "start tile" sender
    // ==========================================================
    task automatic send_tile;
    begin
        @(posedge clk);
        s_axis_TVALID = 1;
        wait (s_axis_TREADY);
        @(posedge clk);
        s_axis_TVALID = 0;
        $display("[%0t] 🚀 Tile started", $time);
    end
    endtask

    // ==========================================================
    // Scoreboard (single in-flight, sparse inputs)
    // ==========================================================
    integer tb_cycle;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) tb_cycle <= 0;
        else        tb_cycle <= tb_cycle + 1;
    end

    integer tb_tile_idx;

    logic exp_valid;
    integer exp_due_cycle;
    logic signed [DATA_WIDTH-1:0] exp_vec [TILE_SIZE-1:0];

    function automatic logic signed [DATA_WIDTH-1:0] bias_lane(input int tile_idx_f, input int lane_f);
        int gi;
        begin
            gi = tile_idx_f*4 + lane_f;
            // FIX: no slicing on integer expression; explicit cast to 16-bit signed
            bias_lane = $signed(16'(1000 + gi));
        end
    endfunction

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tb_tile_idx   <= 0;
            exp_valid     <= 1'b0;
            exp_due_cycle <= 0;
            exp_vec       <= '{default:'0};
        end else begin
            // accept into bias = adapter stream fires
            if (u_top.ad_valid && u_top.ad_ready) begin
                for (int i = 0; i < TILE_SIZE; i = i + 1) begin
                    exp_vec[i] <= u_top.ad_vec[i] + bias_lane(tb_tile_idx, i);
                end
                exp_due_cycle <= tb_cycle + PIPE_LAT;
                exp_valid     <= 1'b1;

                $display("[%0t] ✅ accept_in: tile_idx=%0d, due_cycle=%0d",
                         $time, tb_tile_idx, tb_cycle + PIPE_LAT);

                if (tb_tile_idx == 63) tb_tile_idx <= 0;
                else                   tb_tile_idx <= tb_tile_idx + 1;
            end

            // output fires
            if (bias_out_valid && bias_out_ready) begin
                $display("[%0t] 📤 bias_out_fire @cycle=%0d", $time, tb_cycle);

                if (!exp_valid) begin
                    $error("[%0t] ❌ Output fired but TB has no expected record!", $time);
                end else begin
                    if (tb_cycle != exp_due_cycle) begin
                        $error("[%0t] ❌ Timing mismatch: got=%0d exp=%0d (PIPE_LAT=%0d)",
                               $time, tb_cycle, exp_due_cycle, PIPE_LAT);
                    end else begin
                        $display("[%0t] ✅ Timing OK (PIPE_LAT=%0d)", $time, PIPE_LAT);
                    end

                    for (int i = 0; i < TILE_SIZE; i = i + 1) begin
                        if (bias_out_vec[i] !== exp_vec[i]) begin
                            $error("[%0t] ❌ Data mismatch lane%0d: got=%0d exp=%0d",
                                   $time, i, bias_out_vec[i], exp_vec[i]);
                        end
                    end
                    $display("[%0t] ✅ Bias add data OK", $time);
                end

                exp_valid <= 1'b0;
            end
        end
    end

    // ==========================================================
    // Stimulus
    // ==========================================================
    initial begin
        wait(rst_n);
        @(posedge clk);

        repeat (3) @(posedge clk);

        for (int i = 0; i < 3; i = i + 1) begin
            send_tile();
            repeat (80) @(posedge clk);
        end

        repeat (100) @(posedge clk);
        $display("[%0t] ✅ Simulation Finished", $time);
        $finish;
    end

endmodule
