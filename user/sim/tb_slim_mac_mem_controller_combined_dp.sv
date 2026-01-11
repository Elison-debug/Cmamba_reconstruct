// `timescale 1ns/1ps
// //---------------------------------------------------------------
// // Testbench for slim_mac_mem_controller_combined_dp
// // - Verifies 256×256 WBUF (6-bank dual-port) + XT synchronization
// // - Initializes WBUF & XT internal mem_sim arrays (SMALL RANGE [-3,3])
// //---------------------------------------------------------------
// module tb_slim_mac_mem_controller_combined_dp;

//     // ---------------- Parameters ----------------
//     localparam int TILE_SIZE  = 4;
//     localparam int DATA_WIDTH = 16;
//     localparam int ACC_WIDTH  = 32;
//     localparam int FRAC_BITS  = 8;
//     localparam int N_BANK     = 6;
//     localparam int ADDR_W     = 10;      // log2(683) ~ 10
//     localparam int DEPTH      = 683;     // *** FIXED ***
//     localparam int DATA_W     = 256;
//     localparam int XT_ADDR_W  = 6;       // 64 entries

//     // ---------------- DUT ports ----------------
//     logic clk, rst_n;
//     logic s_axis_TVALID, s_axis_TREADY;
//     logic m_axis_TVALID, m_axis_TREADY;
//     //logic signed [ACC_WIDTH-1:0] reduced_vec [TILE_SIZE-1:0];
//     logic signed [DATA_WIDTH-1:0] reduced_vec [TILE_SIZE-1:0];
//     // ---------------- Clock ----------------
//     initial begin
//         clk = 0;
//         forever #1 clk = ~clk;   // 500 MHz
//     end

//     // ---------------- Reset ----------------
//     initial begin
//         rst_n = 0;
//         s_axis_TVALID = 0;
//         m_axis_TREADY = 1;
//         #10;
//         rst_n = 1;
//     end

//     // ---------------- DUT ----------------
//     slim_mac_mem_controller_combined_dp #(
//         .TILE_SIZE (TILE_SIZE),
//         .DATA_WIDTH(DATA_WIDTH),
//         .ACC_WIDTH (ACC_WIDTH),
//         .FRAC_BITS (FRAC_BITS),
//         .N_BANK    (N_BANK),
//         .ADDR_W    (ADDR_W),
//         .DEPTH     (DEPTH),
//         .DATA_W    (DATA_W),
//         .XT_ADDR_W (XT_ADDR_W)
//     ) u_dut (
//         .clk(clk),
//         .rst_n(rst_n),
//         .s_axis_TVALID(s_axis_TVALID),
//         .s_axis_TREADY(s_axis_TREADY),
//         .m_axis_TVALID(m_axis_TVALID),
//         .m_axis_TREADY(m_axis_TREADY),
//         .reduced_trunc(reduced_vec)
//     );

//     // ==========================================================
//     // WBUF Initialization (all ones)
//     // ==========================================================
//     initial begin
//         for (int b = 0; b < N_BANK; b++) begin
//             for (int addr = 0; addr < DEPTH; addr++) begin
//                 automatic logic [DATA_W-1:0] line = '0;
//                 for (int w = 0; w < 16; w++)
//                     line[w*DATA_WIDTH +: DATA_WIDTH] = 16'sd1;
//                 u_dut.u_wbuf.mem_sim[b][addr] = line;
//             end
//         end
//     end

//     // ==========================================================
//     // XT ROM initialization
//     // ==========================================================
//     initial begin
//         $display("[%0t] 🔧 Initializing XT ROM ...", $time);
//         // for (int addr = 0; addr < 64; addr++) begin
//         //     u_dut.u_xt.mem_sim[addr][0] = 16'(4*addr + 1);
//         //     u_dut.u_xt.mem_sim[addr][1] = 16'(4*addr + 2);
//         //     u_dut.u_xt.mem_sim[addr][2] = 16'(4*addr + 3);
//         //     u_dut.u_xt.mem_sim[addr][3] = 16'(4*addr + 4);
//         // end
//         for (int addr = 0; addr < 64; addr++) begin
//             u_dut.u_xt.mem_sim[addr] = {
//                 16'(4*addr + 4),
//                 16'(4*addr + 3),
//                 16'(4*addr + 2),
//                 16'(4*addr + 1)
//             };
//         end
//     end


//     // ==========================================================
//     // AXIS tile sender
//     // ==========================================================
//     task send_tile;
//     begin
//         @(posedge clk);
//         s_axis_TVALID = 1;
//         wait (s_axis_TREADY);
//         @(posedge clk);
//         s_axis_TVALID = 0;
//         $display("[%0t] 🚀 Tile started", $time);
//     end
//     endtask

//     // ==========================================================
//     // Stimulus: send multiple tiles without long IDLE
//     // ==========================================================
//     initial begin
//         wait(rst_n);
//         @(posedge clk);

//         repeat (1) @(posedge clk);

//         // Send 3 tiles
//         for (int t = 0; t < 3; t++) begin
//             send_tile();
//             repeat (30) @(posedge clk);   // tile_len ≈20, leave some gap
//         end

//         repeat (20) @(posedge clk);
//         $display("[%0t] ✅ Simulation Finished", $time);
//         $finish;
//     end

//     // ==========================================================
//     // Output monitor
//     // ==========================================================
//     always_ff @(posedge clk) begin
//         if (m_axis_TVALID && m_axis_TREADY) begin
//             $display("[%0t] 📤 Output ready:", $time);
//             for (int i = 0; i < TILE_SIZE; i++)
//                 $display("  reduced_vec[%0d] = %0d", i, reduced_vec[i]);
//         end
//     end

// endmodule

`timescale 1ns/1ps
//---------------------------------------------------------------
// Testbench for slim_mac_mem_controller_combined_dp
// - Verifies 256×256 WBUF (6-bank dual-port) + XT synchronization
// - Initializes WBUF & XT internal mem_sim arrays
//---------------------------------------------------------------
module tb_slim_mac_mem_controller_combined_dp;

    // ---------------- Parameters ----------------
    localparam int TILE_SIZE  = 4;
    localparam int DATA_WIDTH = 16;
    localparam int ACC_WIDTH  = 32;
    localparam int FRAC_BITS  = 8;
    localparam int N_BANK     = 6;
    localparam int ADDR_W     = 10;      // log2(683)=9.4 → 10 bits
    localparam int DEPTH      = 683;     // *** FIXED ***
    localparam int DATA_W     = 256;
    localparam int XT_ADDR_W  = 6;       // 64 entries

    // ---------------- DUT ports ----------------
    logic clk, rst_n;
    logic s_axis_TVALID, s_axis_TREADY;
    logic m_axis_TVALID, m_axis_TREADY;
    logic signed [DATA_WIDTH-1:0] reduced_vec [TILE_SIZE-1:0];

    // ---------------- Clock ----------------
    initial begin
        clk = 0;
        forever #1 clk = ~clk;   // 500 MHz
    end

    // ---------------- Reset ----------------
    initial begin
        rst_n = 0;
        s_axis_TVALID = 0;
        m_axis_TREADY = 1;
        #10;
        rst_n = 1;
    end

    // ---------------- DUT ----------------
    slim_mac_mem_controller_combined_dp #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS),
        .N_BANK    (N_BANK),
        .ADDR_W    (ADDR_W),
        .DEPTH     (DEPTH),   // *** FIXED ***
        .DATA_W    (DATA_W),
        .XT_ADDR_W (XT_ADDR_W)
    ) u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_axis_TVALID(s_axis_TVALID),
        .s_axis_TREADY(s_axis_TREADY),
        .m_axis_TVALID(m_axis_TVALID),
        .m_axis_TREADY(m_axis_TREADY),
        .reduced_trunc(reduced_vec)
    );

    // ==========================================================
    //   WBUF Initialization (DEPTH = 683)
    // ==========================================================
    initial begin
        #5;

        $display("[%0t] 🔧 Initializing 6-bank WBUF (DEPTH=683, non-zero data)...", $time);

        for (int b = 0; b < N_BANK; b++) begin
            for (int addr = 0; addr < DEPTH; addr++) begin
                
                logic [DATA_W-1:0] line = '0;
                int tile_id = b + addr * N_BANK;   // 0~4095

                for (int w = 0; w < 16; w++) begin
                    int element_id = tile_id * 16 + w;
                    int value = 1 + element_id;   // always > 1, unique
                    line[w*DATA_WIDTH +: DATA_WIDTH] = value[DATA_WIDTH-1:0];
                end

                u_dut.u_wbuf.mem_sim[b][addr] = line;
            end
        end

        // ==========================================================
        // XT ROM initialization
        // ==========================================================
        $display("[%0t] 🔧 Initializing XT ROM (64 entries)...", $time);

        for (int addr = 0; addr < 64; addr++) begin
            u_dut.u_xt.mem_sim[addr] = {
                16'(4*addr + 4),
                16'(4*addr + 3),
                16'(4*addr + 2),
                16'(4*addr + 1)
                // 16'd1,
                // 16'd1,
                // 16'd1,
                // 16'd1
            };
        end
    end

    // ==========================================================
    // AXIS tile sender
    // ==========================================================
    task send_tile;
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
    // Stimulus: send multiple tiles without long IDLE
    // ==========================================================
    initial begin
        wait(rst_n);
        @(posedge clk);

        repeat (1) @(posedge clk);

        // Send 3 tiles
        for (int t = 0; t < 3; t++) begin
            send_tile();
            repeat (30) @(posedge clk);   // tile_len ≈20, leave some gap
        end

        repeat (20) @(posedge clk);
        $display("[%0t] ✅ Simulation Finished", $time);
        $finish;
    end

    // ==========================================================
    // Output monitor
    // ==========================================================
    always_ff @(posedge clk) begin
        if (m_axis_TVALID && m_axis_TREADY) begin
            $display("[%0t] 📤 Output ready:", $time);
            for (int i = 0; i < TILE_SIZE; i++)
                $display("  reduced_vec[%0d] = %0d", i, reduced_vec[i]);
        end
    end

endmodule
