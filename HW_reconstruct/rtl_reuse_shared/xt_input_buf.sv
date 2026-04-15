//---------------------------------------------------------------
// Module: xt_input_buf
// Function: Read-only ROM for x_t vector (controller-driven)
//            Each address outputs 4×16-bit vector (total 64-bit)
//            ✅ 输出为 unpacked + signed，直接对接顶层 xt_vec
//---------------------------------------------------------------
module xt_input_buf #(
    parameter int ADDR_W = 6,    // e.g., 64-depth → 6-bit address
    parameter int DATA_W = 16,   // Each element 16-bit signed
    parameter int TILE_SIZE = 4  // Each read outputs 4 elements
)(
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     en,        // Enable from controller
    input  logic [ADDR_W-1:0]        addr,      // Address from controller
    output logic signed [DATA_W-1:0] dout_vec [TILE_SIZE-1:0] // ✅ 4×16-bit signed unpacked output
);

    // 64-bit packed ROM data (4 × 16-bit)
    logic [63:0] rom_dout;

    // ---------------- ROM Instance ----------------
    // Use the generated Vivado ROM in both RTL sim and synthesis.
    // The IP provides 1-cycle latency; keep one explicit register here so
    // the total observed latency remains 2 cycles as assumed by the buffer
    // contract used elsewhere in the design.
    logic [63:0] rom_dout_ip;
    logic [63:0] rom_dout_d1;

    u_xt_rom X_T_ROM (
        .clka  (clk),
        .ena   (en),
        .addra (addr),
        .wea   (1'b0),
        .dina  ('0),
        .douta (rom_dout_ip)
    );

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            rom_dout_d1 <= '0;
            rom_dout    <= '0;
        end else begin
            rom_dout_d1 <= rom_dout_ip;
            rom_dout    <= rom_dout_d1;
        end
    end

    // ---------------- Split 64-bit → 4 × 16-bit ----------------
    always_comb begin
        // Little-endian layout (lowest word first)
        // 当 en 为 0 时输出 0，避免非 RUN 阶段 X 传播（综合 ROM 也等效保持/无效）
        if (!en) begin
            dout_vec[0] = '0;
            dout_vec[1] = '0;
            dout_vec[2] = '0;
            dout_vec[3] = '0;
        end else begin
            dout_vec[0] = $signed(rom_dout[15:0]);
            dout_vec[1] = $signed(rom_dout[31:16]);
            dout_vec[2] = $signed(rom_dout[47:32]);
            dout_vec[3] = $signed(rom_dout[63:48]);
        end
    end

endmodule

