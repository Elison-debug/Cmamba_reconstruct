`timescale 1ns/1ps
//======================================================================
// TB for top_mac_plus_bias_fifo
// - Verifies AXI-stream FIFO correctness (order / hold under backpressure)
// - No FIFO init (FIFO is empty after reset, as it should)
//======================================================================

module tb_top_mac_plus_bias_fifo;

    // ---------------- Parameters ----------------
    localparam int TILE_SIZE  = 4;
    localparam int DATA_WIDTH = 16;
    localparam int ACC_WIDTH  = 32;
    localparam int FRAC_BITS  = 8;

    localparam int N_BANK     = 6;
    localparam int WDEPTH     = 683;
    localparam int WADDR_W    = $clog2(WDEPTH);
    localparam int DATA_W     = 256;
    localparam int XT_ADDR_W  = 6;

    localparam int D          = 256;
    localparam int PIPE_LAT   = 4;   // bias_add链路延迟（你测得）
    localparam int FIFO_LAT   = 2;   // 你的FIFO IP常见 fixed latency=2（如果不是2，可改成0只做顺序/hold验证）

    // ---------------- DUT ports ----------------
    logic clk, rst_n;
    logic s_axis_TVALID, s_axis_TREADY;

    logic                      fifo_out_valid;
    logic                      fifo_out_ready;
    logic signed [DATA_WIDTH-1:0] fifo_out_vec [TILE_SIZE-1:0];

    logic                      bias_raw_valid;
    logic signed [DATA_WIDTH-1:0] bias_raw_vec [TILE_SIZE-1:0];

    // ---------------- Clock ----------------
    initial begin
        clk = 0;
        forever #1 clk = ~clk;   // 500 MHz
    end

    // ---------------- Reset ----------------
    initial begin
        rst_n          = 0;
        s_axis_TVALID  = 0;
        fifo_out_ready = 1;
        #10;
        rst_n = 1;
    end

    // ---------------- DUT ----------------
    top_mac_plus_bias_fifo #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS),
        .N_BANK    (N_BANK),
        .WDEPTH    (WDEPTH),
        .WADDR_W   (WADDR_W),
        .DATA_W    (DATA_W),
        .XT_ADDR_W (XT_ADDR_W),
        .D         (D),
        .PIPE_LAT  (PIPE_LAT)
    ) u_top (
        .clk            (clk),
        .rst_n          (rst_n),

        .s_axis_TVALID  (s_axis_TVALID),
        .s_axis_TREADY  (s_axis_TREADY),

        .fifo_out_valid (fifo_out_valid),
        .fifo_out_ready (fifo_out_ready),
        .fifo_out_vec   (fifo_out_vec),

        .bias_raw_valid (bias_raw_valid),
        .bias_raw_vec   (bias_raw_vec)
    );

    // ==========================================================
    // 可选：初始化 WBUF/XT/bias_ROM（如果你希望链路有确定数值）
    // 你如果只想验证 FIFO 行为（顺序/hold），可以整段删掉。
    // ==========================================================
    integer b, addr, w;
    integer tile_id, element_id, value;
    logic [DATA_W-1:0] line;

    initial begin
        #5;

        // -------- WBUF init（需要 u_wbuf.mem_sim 存在）--------
        $display("[%0t] init WBUF ...", $time);
        for (b = 0; b < N_BANK; b = b + 1) begin
            for (addr = 0; addr < WDEPTH; addr = addr + 1) begin
                line = '0;
                tile_id = b + addr * N_BANK; // 0..4095
                for (w = 0; w < 16; w = w + 1) begin
                    element_id = tile_id * 16 + w;
                    value      = 1 + element_id;
                    line[w*DATA_WIDTH +: DATA_WIDTH] = value[DATA_WIDTH-1:0];
                end
                u_top.u_mac.u_wbuf.mem_sim[b][addr] = line;
            end
        end

        // -------- XT init（需要 u_xt.mem_sim 存在）--------
        $display("[%0t] init XT ...", $time);
        for (addr = 0; addr < 64; addr = addr + 1) begin
            u_top.u_mac.u_xt.mem_sim[addr] = {
                16'(4*addr + 4),
                16'(4*addr + 3),
                16'(4*addr + 2),
                16'(4*addr + 1)
            };
        end

        // -------- bias_ROM init：按你工程层级改这里（如用 COE，可不写）--------
        // integer a, base;
        // logic [63:0] word;
        // for (a=0; a<64; a=a+1) begin
        //     base = a*4;
        //     word = {
        //        16'(1000+base+3), 16'(1000+base+2), 16'(1000+base+1), 16'(1000+base+0)
        //     };
        //     u_top.u_bias_add.mem_sim[a] = word; // <- 按实际层级修改
        // end

        $display("[%0t] init done", $time);
    end

    // ==========================================================
    // Start-tile sender (controller start pulse)
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
    // FIFO Scoreboard
    // - 记录 FIFO 输入 fire 的向量
    // - 输出 fire 时按顺序比对
    // - backpressure 时检查数据保持
    // - 可选：检查“不会早于 input+FIFO_LAT”
    // ==========================================================

    // 这里直接用顶层暴露的 bias_raw_* 作为 FIFO 输入观测点：
    // FIFO 输入 fire = bias_raw_valid && fifo_in_ready
    wire fifo_in_fire  = bias_raw_valid && u_top.u_vec_fifo.in_ready;
    wire fifo_out_fire = fifo_out_valid && fifo_out_ready;

    integer cycle;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) cycle <= 0;
        else        cycle <= cycle + 1;
    end

    // 用并行队列存放期望的 due_cycle 和对应向量，避免用 struct
    int due_cycle_q[$];
    logic signed [DATA_WIDTH-1:0] v_q[$][TILE_SIZE-1:0];

    // backpressure hold check
    logic hold_seen;
    logic signed [DATA_WIDTH-1:0] hold_v [TILE_SIZE-1:0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            due_cycle_q.delete();
            v_q.delete();
            hold_seen <= 1'b0;
            hold_v    <= '{default:'0};
        end else begin
            // 1) push on FIFO in fire
            if (fifo_in_fire) begin
                logic signed [DATA_WIDTH-1:0] vec_tmp [TILE_SIZE-1:0];
                for (int i=0; i<TILE_SIZE; i++) vec_tmp[i] = bias_raw_vec[i];
                due_cycle_q.push_back(cycle + FIFO_LAT);
                v_q.push_back(vec_tmp);

                $display("[%0t] ▶ FIFO_IN fire @cycle=%0d (earliest_due=%0d) data=%0d,%0d,%0d,%0d  q=%0d",
                         $time, cycle, due_cycle_q[$],
                         bias_raw_vec[0], bias_raw_vec[1], bias_raw_vec[2], bias_raw_vec[3],
                         due_cycle_q.size());
            end

            // 2) hold check while out_valid=1 and out_ready=0
            if (fifo_out_valid && !fifo_out_ready) begin
                if (!hold_seen) begin
                    for (int i=0; i<TILE_SIZE; i++) hold_v[i] <= fifo_out_vec[i];
                    hold_seen <= 1'b1;
                end else begin
                    for (int i=0; i<TILE_SIZE; i++) begin
                        if (fifo_out_vec[i] !== hold_v[i]) begin
                            $error("[%0t] ❌ FIFO hold violated while ready=0: lane%0d old=%0d new=%0d",
                                   $time, i, hold_v[i], fifo_out_vec[i]);
                        end
                    end
                end
            end else begin
                hold_seen <= 1'b0;
            end

            // 3) pop/check on FIFO out fire
            if (fifo_out_fire) begin
                if (due_cycle_q.size() == 0) begin
                    $error("[%0t] ❌ FIFO_OUT fired but expected queue empty!", $time);
                end else begin
                    int head_due;
                    logic signed [DATA_WIDTH-1:0] head_v [TILE_SIZE-1:0];
                    head_due = due_cycle_q.pop_front();
                    head_v   = v_q.pop_front();

                    // not earlier than FIFO_LAT
                    if (FIFO_LAT > 0 && cycle < head_due) begin
                        $error("[%0t] ❌ FIFO latency too small: got_cycle=%0d earliest_due=%0d (FIFO_LAT=%0d)",
                               $time, cycle, head_due, FIFO_LAT);
                    end

                    for (int i=0; i<TILE_SIZE; i++) begin
                        if (fifo_out_vec[i] !== head_v[i]) begin
                            $error("[%0t] ❌ FIFO order/data mismatch lane%0d: got=%0d exp=%0d",
                                   $time, i, fifo_out_vec[i], head_v[i]);
                        end
                    end

                    $display("[%0t] ✅ FIFO_OUT fire @cycle=%0d OK data=%0d,%0d,%0d,%0d  q=%0d",
                             $time, cycle,
                             fifo_out_vec[0], fifo_out_vec[1], fifo_out_vec[2], fifo_out_vec[3],
                             due_cycle_q.size());
                end
            end
        end
    end

    // ==========================================================
    // Stimulus:
    //   - 发几次 tile（间隔足够）
    //   - 中途制造 backpressure
    // ==========================================================
    initial begin
        wait(rst_n);
        repeat (3) @(posedge clk);

        // tile 0
        send_tile();
        repeat (80) @(posedge clk);

        // tile 1
        send_tile();
        repeat (20) @(posedge clk);

        // backpressure window
        $display("[%0t] ⛔ Apply backpressure: fifo_out_ready=0", $time);
        fifo_out_ready = 0;
        repeat (12) @(posedge clk);
        fifo_out_ready = 1;
        $display("[%0t] ✅ Release backpressure: fifo_out_ready=1", $time);

        repeat (80) @(posedge clk);

        // tile 2
        send_tile();
        repeat (150) @(posedge clk);

        if (due_cycle_q.size() != 0) begin
            $error("[%0t] ❌ End but expected queue not empty: q=%0d", $time, due_cycle_q.size());
        end

        $display("[%0t] ✅ Simulation Finished", $time);
        $finish;
    end

endmodule
