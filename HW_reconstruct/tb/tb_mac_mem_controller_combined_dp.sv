`timescale 1ns/1ps
//---------------------------------------------------------------
// Testbench for mac_mem_controller_combined (Dual-Port Version)
// - Verifies WBUF (dual-port) + XT synchronization
// - Initializes WBUF & XT internal mem_sim arrays
//---------------------------------------------------------------
module tb_mac_mem_controller_combined_dp;

    // ---------------- Parameters ----------------
    localparam int TILE_SIZE  = 4;
    localparam int DATA_WIDTH = 16;
    localparam int ACC_WIDTH  = 32;
    localparam int FRAC_BITS  = 8;
    localparam int N_BANK     = 6;
    localparam int ADDR_W     = 4;
    localparam int DEPTH      = 11;
    localparam int DATA_W     = 256;

    // ---------------- DUT ports ----------------
    logic clk, rst_n;
    logic s_axis_TVALID, s_axis_TREADY;
    logic m_axis_TVALID, m_axis_TREADY;
    logic signed [ACC_WIDTH-1:0] reduced_vec [TILE_SIZE-1:0];

    // ---------------- Clock generation ----------------
    initial begin
        clk = 0;
        forever #1 clk = ~clk;   // 2ns clock → 500 MHz
    end

    // ---------------- Reset + AXIS defaults ----------------
    initial begin
        rst_n = 0;
        s_axis_TVALID = 0;
        m_axis_TREADY = 1;
        #10;
        rst_n = 1;
    end

    // ---------------- DUT Instance ----------------
    mac_mem_controller_combined_dp #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS),
        .N_BANK    (N_BANK),
        .ADDR_W    (ADDR_W),
        .DEPTH     (DEPTH),
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
    //   WBUF & XT ROM Initialization
    // ==========================================================
    initial begin
        #5; // wait for DUT hierarchy to exist

        // ----------------------
        // Initialize WBUF banks
        // ----------------------
        $display("[%0t] 🔧 Initializing 6-bank dual-port WBUF ...", $time);

        for (int b = 0; b < N_BANK; b++) begin
            for (int addr = 0; addr < DEPTH; addr++) begin
                logic [DATA_W-1:0] line = '0;
                logic [15:0] block_id = 16'(b + 6*addr);

                // Each block stores its block_id across the 16 words for easier tracking
                for (int w = 0; w < 16; w++) begin
                    line[w*DATA_WIDTH +: DATA_WIDTH] = block_id;
                end

                // ---- Correct dual-port WBUF simulation memory path ----
                u_dut.u_wbuf.mem_sim[b][addr] = line;
            end
        end

        // ----------------------
        // Initialize XT ROM
        // ----------------------
        $display("[%0t] 🔧 Initializing XT ROM ...", $time);

        for (int addr = 0; addr < 16; addr++) begin
            u_dut.u_xt.mem_sim[addr] = {
                16'(4*addr + 4),
                16'(4*addr + 3),
                16'(4*addr + 2),
                16'(4*addr + 1)
            };
        end
    end

    // ==========================================================
    //  AXIS stimulus — send two tiles
    // ==========================================================
    initial begin
        wait(rst_n == 1);
        @(posedge clk);

        // ---- Tile 1 ----
        $display("[%0t] 🚀 Start Tile 1", $time);
        s_axis_TVALID = 1;
        wait (s_axis_TREADY);
        @(posedge clk);
        s_axis_TVALID = 0;

        repeat (70) @(posedge clk);

        // ---- Tile 2 ----
        $display("[%0t] 🚀 Start Tile 2", $time);
        s_axis_TVALID = 1;
        wait (s_axis_TREADY);
        @(posedge clk);
        s_axis_TVALID = 0;

        repeat (70) @(posedge clk);

        $display("[%0t] ✅ Finished sending 2 tiles", $time);
        repeat (20) @(posedge clk);
        $finish;
    end

    // ==========================================================
    // Output monitor
    // ==========================================================
    always_ff @(posedge clk) begin
        if (m_axis_TVALID && m_axis_TREADY) begin
            $display("[%0t] ✅ Output valid:", $time);
            for (int i = 0; i < TILE_SIZE; i++)
                $display("  reduced_vec[%0d] = %0d", i, reduced_vec[i]);
        end
    end

endmodule
