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

    // ---------------- ROM Instance / SIM Model ----------------
`ifdef SYNTHESIS
    u_xt_rom X_T_ROM (
        .clka  (clk),
        .ena   (en),
        .addra (addr),
        .wea   (1'b0),          // 🔒 写使能固定为0
        .dina  ('0),            // 🔒 写数据固定为0
        .douta (rom_dout)
    );
    // rst_n 主要用于仿真模型，综合时保留一条“使用”路径以避免未用告警
    (* keep = "true" *) logic rst_n_keep;
    assign rst_n_keep = rst_n;
`else
    // 行为仿真模型：公开 mem_sim 供 TB 初始化，读出总延迟 2 拍（与 IP 对齐）
    localparam int XT_DEPTH = (1 << ADDR_W);
    logic [63:0] mem_sim [XT_DEPTH];
    logic [63:0] rom_dout_d1;
    // 初始化 mem，避免未写地址为 X；rom_dout 由 always_ff 唯一驱动
    initial begin
        for (int i = 0; i < XT_DEPTH; i++) mem_sim[i] = '0;
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rom_dout_d1 <= '0;
            rom_dout    <= '0;
        end else begin
            rom_dout    <= rom_dout_d1; // stage2
            if (en)
                rom_dout_d1 <= mem_sim[addr]; // stage1
        end
    end
`endif

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
