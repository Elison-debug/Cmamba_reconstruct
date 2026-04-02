// ===============================================================
//  File: multi_bank_wbuf.sv
//  Function: 12-bank read-only WBUF subsystem for Mamba SSM (MAC mode)
//             支持同时访问4个bank，controller通过bank_sel控制
// ===============================================================
module multi_bank_wbuf #(
    parameter int N_BANK  = 12,   // bank数量
    parameter int ADDR_W  = 10,   // 每个bank地址宽度
    parameter int DATA_W  = 256   // 每个bank数据宽度
)(
    input  logic                       clk,
    input  logic                       rst_n,

    // -------- Controller Interface --------
    input  logic [3:0][$clog2(N_BANK)-1:0] bank_sel,       // 当前周期需要访问的4个bank_id
    input  logic [3:0][ADDR_W-1:0]         addr_sel,       // 对应bank的读地址
    input  logic [3:0]                     en_sel,         // 每个bank的使能信号

    // -------- Data Output (4个有效bank输出) --------
    output logic [3:0][DATA_W-1:0]         dout_sel        // 4个有效bank的数据输出
);

    // ===========================================================
    // Internal ROM Bank Array
    // ===========================================================
    logic [N_BANK-1:0]           en_bank;
    logic [ADDR_W-1:0]           addr_bank [N_BANK];
    logic [DATA_W-1:0]           dout_bank [N_BANK];
    // Align select/enable with sync ROM read (1-cycle latency)
    logic [3:0][$clog2(N_BANK)-1:0] bank_sel_q;
    logic [3:0]                     en_sel_q;

    // 生成12个ROM bank实例
`ifdef SYNTHESIS
    generate
        for (genvar i = 0; i < N_BANK; i++) begin : WBUF_BANK
            WBUF_Xproj_bank u_bank (
                .clka  (clk),
                .ena   (en_bank[i]),
                .addra (addr_bank[i]),
                .wea   (1'b0),          // 🔒 写使能固定为0
                .dina  ('0),            // 🔒 写数据固定为0
                .douta (dout_bank[i])
            );
        end
    endgenerate
`else
    // 仿真行为模型：内部可写mem_sim，时序与同步ROM一致（读出打一拍）
    localparam int DEPTH = (1 << ADDR_W);
    logic [DATA_W-1:0] mem_sim   [N_BANK][DEPTH];
    logic [DATA_W-1:0] dout_bank_r [N_BANK];

    // 保持接口一致：dout_bank 从寄存器读出
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < N_BANK; i++) begin
                dout_bank_r[i] <= '0; // avoid X at startup in sim
            end
        end else begin
            for (int i = 0; i < N_BANK; i++) begin
                if (en_bank[i]) begin
                    dout_bank_r[i] <= mem_sim[i][addr_bank[i]];
                end
            end
        end
    end

    // 将寄存器输出映射到原有信号名
    always_comb begin
        for (int i = 0; i < N_BANK; i++) begin
            dout_bank[i] = dout_bank_r[i];
        end
    end
`endif

    // ===========================================================
    // 控制信号展开：将4个bank_sel映射到各自的ROM输入
    // ===========================================================
    always_comb begin
        // 默认所有bank关闭
        en_bank  = '0;
        for (int i = 0; i < N_BANK; i++)
            addr_bank[i] = '0;

        // 激活被选中的bank
        for (int j = 0; j < 4; j++) begin
            if (en_sel[j]) begin
                en_bank[ bank_sel[j] ]  = 1'b1;
                addr_bank[ bank_sel[j] ]= addr_sel[j];
            end
        end
    end

    // 打拍选择/使能，与同步ROM读出对齐
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bank_sel_q <= '0;
            en_sel_q   <= '0;
        end else begin
            bank_sel_q <= bank_sel;
            en_sel_q   <= en_sel;
        end
    end

    // ===========================================================
    // 数据选择：每个 dout_sel[j] 对应 bank_sel[j] 的输出
    // ===========================================================
    always_comb begin
        for (int j = 0; j < 4; j++) begin
            dout_sel[j] = en_sel_q[j] ? dout_bank[ bank_sel_q[j] ] : '0;
        end
    end

endmodule
