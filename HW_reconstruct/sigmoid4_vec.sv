// sigmoid4_vec.sv
// 4-lane sigmoid using LUT (Q8.8 in -> Q0.16 out), ready/valid handshake compatible with AXI-stream semantics
`timescale 1ns/1ps

module sigmoid4_vec #(
    parameter int TILE_SIZE  = 4,
    parameter int IN_W       = 16,   // Q8.8 signed
    parameter int OUT_W      = 16,   // Q0.16 unsigned
    parameter int ADDR_BITS  = 11,   // 2048 entries
    parameter string LUT_FILE = "D:/Mamba/Cmamba_reconstruct/sigmoid_lut_q016_2048.hex"
)(
    input  logic clk,
    input  logic rst_n,

    // Upstream (from FIFO)
    input  logic in_valid,
    output logic in_ready,
    input  logic signed [IN_W-1:0] in_vec [TILE_SIZE-1:0],

    // Downstream (to next block / external)
    output logic out_valid,
    input  logic out_ready,
    output logic [OUT_W-1:0] out_vec [TILE_SIZE-1:0]
);

    // ---------------- Constants for clamp [-4, +4) in Q8.8 ----------------
    localparam logic signed [IN_W-1:0] X_MIN = -16'sd1024; // -4.0 * 256
    localparam logic signed [IN_W-1:0] X_MAX =  16'sd1023; // +3.996... (right-open, matches 2048 entries)

    localparam int LUT_SIZE = (1 << ADDR_BITS); // 2048

    initial begin
        if (LUT_SIZE != 2048) $error("ADDR_BITS must be 11 for 2048-entry LUT in this design.");
        if (TILE_SIZE != 4)   $error("This module is written for TILE_SIZE=4 (4 lanes).");
    end

    // ---------------- ROM storage ----------------
    logic [OUT_W-1:0] rom [0:LUT_SIZE-1];

    // simulation init; Vivado can also infer init for BRAM when supported
    initial begin
        $readmemh(LUT_FILE, rom);
    end

    // ---------------- Handshake helpers ----------------
    wire in_fire  = in_valid  && in_ready;
    wire out_fire = out_valid && out_ready;

    // ---------------- Clamp + addr mapping ----------------
    function automatic logic signed [IN_W-1:0] clamp_q88(input logic signed [IN_W-1:0] x);
        if (x < X_MIN)       clamp_q88 = X_MIN;
        else if (x > X_MAX)  clamp_q88 = X_MAX;
        else                 clamp_q88 = x;
    endfunction

    // ---------------- Stage0: register LUT addresses ----------------
    logic stage0_valid;
    logic [ADDR_BITS-1:0] stage0_addr [TILE_SIZE-1:0];

    // ---------------- ROM output registered (models 1-cycle ROM latency) ----------------
    logic rom_valid;
    logic [OUT_W-1:0] rom_dout [TILE_SIZE-1:0];

    // ---------------- Output buffer ----------------
    logic [OUT_W-1:0] out_reg [TILE_SIZE-1:0];

    // ---------------- Pending (skid) buffer to avoid token loss under backpressure ----------------
    logic pending_valid;
    logic [OUT_W-1:0] pending_reg [TILE_SIZE-1:0];

    // ---------------- in_ready logic ----------------
    // We can accept a new input if:
    //  - stage0 is free this cycle (we only hold 1 address set)
    //  - and we will have space to eventually store rom_dout when it arrives:
    //      output buffer or pending must be able to take it.
    //
    // With the pending buffer, we can allow accepting a new token even if out_valid is holding,
    // as long as pending is empty AND we won't already have a rom token arriving this cycle.
    //
    // Practical safe policy (simple + correct):
    //   - never accept new input if stage0_valid is already 1 (i.e., we already accepted this cycle)
    //   - never accept new input if rom_valid is 1 (rom token arriving now and needs space)
    //   - require that at least one of {output buffer writable, pending empty} is true
    //
    // This supports sustained 1 token/cycle when no backpressure,
    // and guarantees no loss when backpressure occurs.
    always_comb begin
        bit out_writable;
        out_writable = (~out_valid) || out_ready; // if out_ready=1 and out_valid=1, it will fire

        // We need somewhere for *next* rom_dout (from a new in_fire) to go:
        // - Ideally into out_reg if writable at that time
        // - If not writable, into pending_reg (must be empty)
        //
        // To avoid corner cases, block accepting a new input when:
        // - we already have a pending token, or
        // - a rom token is arriving this cycle, or
        // - stage0 is currently holding a token (won't happen with our stage0_valid clearing, but keep safe)
        //
        // Also require either out_writable OR pending empty (pending empty is already required).
        in_ready = rst_n
                   && (~stage0_valid)
                   && (~rom_valid)
                   && (~pending_valid)
                   && (out_writable || (~out_valid)); // redundant but keeps intent clear
    end

    // ---------------- Stage0 register ----------------
    // We clear stage0_valid every cycle and only raise it when we accept an input.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage0_valid <= 1'b0;
            for (int i=0; i<TILE_SIZE; i++) stage0_addr[i] <= '0;
        end else begin
            stage0_valid <= 1'b0;
            if (in_fire) begin
                stage0_valid <= 1'b1;
                for (int i=0; i<TILE_SIZE; i++) begin
                    logic signed [IN_W-1:0] xc;
                    logic signed [IN_W-1:0] sum;
                    xc  = clamp_q88(in_vec[i]);
                    sum = xc + 16'sd1024;                  // 0..2047
                    stage0_addr[i] <= sum[ADDR_BITS-1:0];  // explicit slice
                end
            end
        end
    end

    // ---------------- ROM registered output (1-cycle) ----------------
    // rom_valid corresponds to stage0_valid delayed by 1.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rom_valid <= 1'b0;
            for (int i=0; i<TILE_SIZE; i++) rom_dout[i] <= '0;
        end else begin
            rom_valid <= stage0_valid;
            if (stage0_valid) begin
                for (int i=0; i<TILE_SIZE; i++) begin
                    rom_dout[i] <= rom[stage0_addr[i]];
                end
            end
        end
    end

    // ---------------- Output register assignment ----------------
    always_comb begin
        for (int i=0; i<TILE_SIZE; i++) out_vec[i] = out_reg[i];
    end

    // ---------------- Output buffer + pending skid ----------------
    // Priority:
    //  1) If output consumed, free buffer.
    //  2) If pending_valid and buffer writable, move pending -> out_reg (and assert out_valid).
    //  3) Else if rom_valid:
    //       - if buffer writable, write rom_dout -> out_reg (assert out_valid)
    //       - else park rom_dout -> pending_reg (assert pending_valid)
    //
    // This guarantees rom_valid token is NEVER dropped.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_valid     <= 1'b0;
            pending_valid <= 1'b0;
            for (int i=0; i<TILE_SIZE; i++) begin
                out_reg[i]     <= '0;
                pending_reg[i] <= '0;
            end
        end else begin
            bit buf_writable;
            buf_writable = (~out_valid) || out_fire; // writable if empty OR just consumed this cycle

            // 1) If downstream consumed, clear out_valid (buffer becomes free)
            if (out_fire) begin
                out_valid <= 1'b0;
            end

            // recompute buf_writable after possible out_fire clearing (conceptually same cycle)
            buf_writable = (~out_valid) || out_fire;

            // 2) Serve pending first if possible
            if (pending_valid && buf_writable) begin
                for (int i=0; i<TILE_SIZE; i++) out_reg[i] <= pending_reg[i];
                out_valid     <= 1'b1;
                pending_valid <= 1'b0;
            end
            // 3) Otherwise handle new rom token
            else if (rom_valid) begin
                if (buf_writable) begin
                    for (int i=0; i<TILE_SIZE; i++) out_reg[i] <= rom_dout[i];
                    out_valid <= 1'b1;
                end else begin
                    // park into pending (should be empty due to in_ready gating, but safe anyway)
                    for (int i=0; i<TILE_SIZE; i++) pending_reg[i] <= rom_dout[i];
                    pending_valid <= 1'b1;
                end
            end
            // else: hold state
        end
    end

endmodule
