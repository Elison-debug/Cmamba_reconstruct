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
    parameter int PIPE_LAT   = 2,                        // match your IP summary
    parameter string BIAS_INIT_FILE = ""
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
    localparam bit USE_LOCAL_BIAS_ROM = (BIAS_INIT_FILE != "");

    // Scheme A: upstream is allowed when output slot is empty
    // or will be freed this cycle.
    logic bias_primed;
    assign in_ready = (USE_LOCAL_BIAS_ROM ? 1'b1 : bias_primed) && ((!hold_valid) || fire_out);

    wire accept_in = in_valid && in_ready;

    // ------------------------------------------------------------
    // 1) Bias tile pointer: 0..63, advances per accepted beat
    // ------------------------------------------------------------
    logic [ADDR_W-1:0] tile_idx;

    always_ff @(posedge clk) begin
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
    logic [63:0]       bias64_ip;

    generate
        if (BIAS_INIT_FILE != "") begin : g_bias_param_rom
            (* rom_style = "block" *) logic [63:0] bias_mem [0:TILE_DEPTH-1];
            initial begin
                for (int i = 0; i < TILE_DEPTH; i++) bias_mem[i] = '0;
                $readmemh(BIAS_INIT_FILE, bias_mem);
            end
            always_ff @(posedge clk) begin
                if (bias_en)
                    bias64_ip <= bias_mem[bias_addr];
            end
        end else begin : g_bias_ip
            // Use the generated Vivado IP model in both RTL sim and synthesis.
            // Keep bias data directly from the IP output to avoid an extra local
            // register stage that would shift bias by one beat.
            bias_ROM u_bias_rom (
                .clka  (clk),
                .ena   (bias_en),
                .addra (bias_addr),
                .douta (bias64_ip)
            );
        end
    endgenerate

    // Bias ROM timing in this IP configuration is effectively one-beat ahead
    // of accepted payload tracking, so keep one-word look-ahead address and
    // prefetch addr0 before first payload beat.
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            bias_primed <= 1'b0;
        end else if (sof) begin
            bias_primed <= 1'b0;
        end else if (USE_LOCAL_BIAS_ROM) begin
            bias_primed <= 1'b1;
        end else if (!bias_primed) begin
            bias_primed <= 1'b1;
        end
    end

    always_comb begin
        if (USE_LOCAL_BIAS_ROM) begin
            // Local ROM path: use straightforward synchronous BRAM timing.
            bias_en   = accept_in;
            bias_addr = tile_idx;
        end else if (!bias_primed) begin
            // Vivado IP path: keep prefetch + look-ahead alignment.
            bias_en   = 1'b1;
            bias_addr = '0;
        end else begin
            bias_en = accept_in;
            if (tile_idx == TILE_DEPTH-1)
                bias_addr = '0;
            else
                bias_addr = tile_idx + 1'b1;
        end
    end

    // Unpack bias64 into 4 lanes (lane0 lowest)
    logic signed [DATA_WIDTH-1:0] bias_vec [TILE_SIZE-1:0];
    always_comb begin
        bias_vec[0] = bias64_ip[15:0];
        bias_vec[1] = bias64_ip[31:16];
        bias_vec[2] = bias64_ip[47:32];
        bias_vec[3] = bias64_ip[63:48];
    end

    // ------------------------------------------------------------
    // 3) Valid alignment pipeline for ROM latency
    // vpipe[k]==1 means: "the accepted input is now k cycles old"
    // vpipe[PIPE_LAT]==1 means: "bias64 corresponds to that accepted input this cycle"
    // ------------------------------------------------------------
    logic [PIPE_LAT:0] vpipe;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            vpipe <= '0;
        end else begin
            vpipe <= {vpipe[PIPE_LAT-1:0], accept_in};
        end
    end

    // ------------------------------------------------------------
    // 4) Align input vector with ROM latency (PIPE_LAT cycles)
    // ------------------------------------------------------------
    logic signed [DATA_WIDTH-1:0] z_pipe [0:PIPE_LAT][TILE_SIZE-1:0];

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            for (int st = 0; st <= PIPE_LAT; st++) begin
                z_pipe[st] <= '{default:'0};
            end
        end else begin
            if (accept_in) begin
                z_pipe[0] <= in_vec;
            end
            for (int st = 1; st <= PIPE_LAT; st++) begin
                if (vpipe[st-1]) begin
                    z_pipe[st] <= z_pipe[st-1];
                end
            end
        end
    end

    logic signed [DATA_WIDTH-1:0] z_aligned [TILE_SIZE-1:0];
    always_comb begin
        z_aligned = z_pipe[PIPE_LAT];
    end

    // ------------------------------------------------------------
    // 5) Produce output when ROM data is aligned
    // Backpressure-safe holding: out_vec stable while hold_valid=1 and out_ready=0
    // ------------------------------------------------------------
    always_ff @(posedge clk) begin
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
