// ============================================================
// bias_add_regslice_ip_A.sv   (Scheme A: no inflight, keep vpipe+hold)
// Function:
//   - Accept sparse 4-lane vectors with in_valid/in_ready
//   - Read 64-bit bias word from bias_ROM (depth=64) per accepted beat
//   - Align ROM latency using vpipe (PIPE_LAT cycles)
//   - Add bias to input vector and present output with out_valid/out_ready
//   - Backpressure-safe: output data stays stable while out_valid=1 and out_ready=0
//
// Assumptions:
//   - TILE_SIZE = 4
//   - bias_ROM: width=64, depth=64, total read latency = PIPE_LAT (default 2)
//   - Inputs are sparse enough that a new input won't arrive before previous output is accepted
//     (If that assumption breaks, add inflight/backpressure to upstream or use the conservative version.)
// ============================================================
module bias_add_regslice_ip_A #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int D          = 256,                      // total biases
    parameter int TILE_DEPTH = D / TILE_SIZE,            // 64
    parameter int ADDR_W     = $clog2(TILE_DEPTH),       // 6
    parameter int PIPE_LAT   = 2                         // match your IP summary
)(
    input  logic clk,
    input  logic rst_n,

    // Upstream
    input  logic in_valid,
    output logic in_ready,
    input  logic signed [DATA_WIDTH-1:0] in_vec  [TILE_SIZE-1:0],

    // optional: start-of-frame pulse to reset bias pointer
    input  logic sof,

    // Downstream
    output logic out_valid,
    input  logic out_ready,
    output logic signed [DATA_WIDTH-1:0] out_vec [TILE_SIZE-1:0]
);

    // ------------------------------------------------------------
    // 0) Output holding register (reg-slice)
    // ------------------------------------------------------------
    logic hold_valid;
    wire  fire_out = hold_valid && out_ready;

    // Scheme A: upstream is allowed when output slot is empty
    // or will be freed this cycle.
    assign in_ready = (!hold_valid) || fire_out;

    wire accept_in = in_valid && in_ready;

    // ------------------------------------------------------------
    // 1) Bias tile pointer: 0..63, advances per accepted beat
    // ------------------------------------------------------------
    logic [ADDR_W-1:0] tile_idx;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tile_idx <= '0;
        end else begin
            if (sof) begin
                tile_idx <= '0;
            end else if (accept_in) begin
                if (tile_idx == TILE_DEPTH-1) tile_idx <= '0;
                else                          tile_idx <= tile_idx + 1'b1;
            end
        end
    end

    // ------------------------------------------------------------
    // 2) bias_ROM IP read (64-bit packed bias)
    // ------------------------------------------------------------
    logic              bias_en;
    logic [ADDR_W-1:0] bias_addr;
    logic [63:0]       bias64;

`ifdef SYNTHESIS
    // NOTE: If your generated IP has different port names, edit here.
    bias_ROM u_bias_rom (
        .clka  (clk),
        .ena   (bias_en),
        .addra (bias_addr),
        .douta (bias64)
    );
`else
    // 仿真行为版 ROM：公开 mem_sim 供 TB 初始化，读出总延迟 2 拍（与 IP 一致）
    logic [63:0] mem_sim [TILE_DEPTH];
    logic [63:0] bias64_d1;
    initial begin
        for (int i = 0; i < TILE_DEPTH; i++) mem_sim[i] = '0;
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bias64_d1 <= '0;
        else if (bias_en)
            bias64_d1 <= mem_sim[bias_addr];
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bias64 <= '0;
        else
            bias64 <= bias64_d1; // 再打一拍，总延迟=2
    end
`endif

    // Read request on accept_in
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bias_en   <= 1'b0;
            bias_addr <= '0;
        end else begin
            bias_en   <= accept_in;
            bias_addr <= tile_idx;
        end
    end

    // Unpack bias64 into 4 lanes (lane0 lowest)
    logic signed [DATA_WIDTH-1:0] bias_vec [TILE_SIZE-1:0];
    always_comb begin
        bias_vec[0] = bias64[15:0];
        bias_vec[1] = bias64[31:16];
        bias_vec[2] = bias64[47:32];
        bias_vec[3] = bias64[63:48];
    end

    // ------------------------------------------------------------
    // 3) Valid alignment pipeline for ROM latency
    // vpipe[k]==1 means: "the accepted input is now k cycles old"
    // vpipe[PIPE_LAT]==1 means: "bias64 corresponds to that accepted input this cycle"
    // ------------------------------------------------------------
    logic [PIPE_LAT:0] vpipe;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vpipe <= '0;
        end else begin
            vpipe <= {vpipe[PIPE_LAT-1:0], accept_in};
        end
    end

    // ------------------------------------------------------------
    // 4) Align input vector with ROM latency (PIPE_LAT cycles)
    // For PIPE_LAT=2:
    //   accept_in -> z_q0
    //   +1 cycle  -> z_q1
    //   +2 cycle  -> z_q2  (aligned with bias64)
    // ------------------------------------------------------------
    logic signed [DATA_WIDTH-1:0] z_q0 [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] z_q1 [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] z_q2 [TILE_SIZE-1:0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            z_q0 <= '{default:'0};
            z_q1 <= '{default:'0};
            z_q2 <= '{default:'0};
        end else begin
            if (accept_in) begin
                z_q0 <= in_vec;
            end
            // shift stages driven by vpipe taps (keeps behavior clean for sparse inputs)
            if (vpipe[0]) begin
                z_q1 <= z_q0;
            end
            if (PIPE_LAT >= 2) begin
                if (vpipe[1]) begin
                    z_q2 <= z_q1;
                end
            end
        end
    end

    logic signed [DATA_WIDTH-1:0] z_aligned [TILE_SIZE-1:0];
    always_comb begin
        if (PIPE_LAT == 1) z_aligned = z_q1;
        else               z_aligned = z_q2; // default PIPE_LAT=2
    end

    // ------------------------------------------------------------
    // 5) Produce output when ROM data is aligned
    // Backpressure-safe holding: out_vec stable while hold_valid=1 and out_ready=0
    // ------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hold_valid <= 1'b0;
            out_vec    <= '{default:'0};
        end else begin
            // consume (clear) when downstream takes it
            if (fire_out) begin
                hold_valid <= 1'b0;
            end

            // produce new output when bias is ready and output slot is free (or just freed)
            if (vpipe[PIPE_LAT] && (!hold_valid || fire_out)) begin
                hold_valid <= 1'b1;
                for (int i=0; i<TILE_SIZE; i++) begin
                    out_vec[i] <= z_aligned[i] + bias_vec[i];
                end
            end
        end
    end

    assign out_valid = hold_valid;

endmodule
