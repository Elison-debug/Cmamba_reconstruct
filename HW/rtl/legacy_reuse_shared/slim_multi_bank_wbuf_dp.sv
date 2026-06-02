// ====================================================================
//  File: slim_multi_bank_wbuf_dp.sv
//  Function:
//      6-bank TRUE Dual-Port WBUF subsystem for FULL 256?256 matrix
//      - Stores all 4096 (64?64) tiles of W
//      - Uses same bank mapping formula as old design
//      - Fully compatible with existing controller (no modification)
//
//  NOTE:
//      One address = one 4x4 block (256-bit) = 16 elements
//      New DEPTH = ceil(4096 / 6) = 683
// ====================================================================
module slim_multi_bank_wbuf_dp #(
    parameter int N_BANK  = 6,
    parameter int DEPTH   = 683,
    parameter int ADDR_W  = $clog2(DEPTH),
    parameter int DATA_W  = 256,
    parameter string BANK0_INIT_FILE = "",
    parameter string BANK1_INIT_FILE = "",
    parameter string BANK2_INIT_FILE = "",
    parameter string BANK3_INIT_FILE = "",
    parameter string BANK4_INIT_FILE = "",
    parameter string BANK5_INIT_FILE = ""
)(
    input  logic                       clk,
    input  logic                       rst_n,
    input  logic [3:0][$clog2(N_BANK)-1:0] bank_sel,
    input  logic [3:0][ADDR_W-1:0]         addr_sel,
    input  logic [3:0]                     en_sel,
    input  logic [3:0]                     port_sel,
    output logic [3:0][DATA_W-1:0]         dout_sel
);

    logic [$clog2(N_BANK)-1:0] b;
    logic [ADDR_W-1:0]         a;

    logic [N_BANK-1:0]           enA_bank, enB_bank;
    logic [ADDR_W-1:0]           addrA_bank [N_BANK];
    logic [ADDR_W-1:0]           addrB_bank [N_BANK];
    logic [DATA_W-1:0]           doutA_bank [N_BANK];
    logic [DATA_W-1:0]           doutB_bank [N_BANK];

    function automatic [ADDR_W-1:0] safe_addr(input [ADDR_W-1:0] raw);
        if (raw < DEPTH)
            safe_addr = raw;
        else
            safe_addr = '0;
    endfunction

`ifdef SYNTHESIS
    generate
        for (genvar i = 0; i < N_BANK; i++) begin : WBUF_BANK
            if (i == 0) begin : g_bank0
                reuse_weight_bank_rom #(.DEPTH(DEPTH), .ADDR_W(ADDR_W), .DATA_W(DATA_W), .INIT_FILE(BANK0_INIT_FILE)) u_bank (
                    .clk(clk), .en_a(enA_bank[i]), .addr_a(addrA_bank[i]), .dout_a(doutA_bank[i]),
                    .en_b(enB_bank[i]), .addr_b(addrB_bank[i]), .dout_b(doutB_bank[i]));
            end else if (i == 1) begin : g_bank1
                reuse_weight_bank_rom #(.DEPTH(DEPTH), .ADDR_W(ADDR_W), .DATA_W(DATA_W), .INIT_FILE(BANK1_INIT_FILE)) u_bank (
                    .clk(clk), .en_a(enA_bank[i]), .addr_a(addrA_bank[i]), .dout_a(doutA_bank[i]),
                    .en_b(enB_bank[i]), .addr_b(addrB_bank[i]), .dout_b(doutB_bank[i]));
            end else if (i == 2) begin : g_bank2
                reuse_weight_bank_rom #(.DEPTH(DEPTH), .ADDR_W(ADDR_W), .DATA_W(DATA_W), .INIT_FILE(BANK2_INIT_FILE)) u_bank (
                    .clk(clk), .en_a(enA_bank[i]), .addr_a(addrA_bank[i]), .dout_a(doutA_bank[i]),
                    .en_b(enB_bank[i]), .addr_b(addrB_bank[i]), .dout_b(doutB_bank[i]));
            end else if (i == 3) begin : g_bank3
                reuse_weight_bank_rom #(.DEPTH(DEPTH), .ADDR_W(ADDR_W), .DATA_W(DATA_W), .INIT_FILE(BANK3_INIT_FILE)) u_bank (
                    .clk(clk), .en_a(enA_bank[i]), .addr_a(addrA_bank[i]), .dout_a(doutA_bank[i]),
                    .en_b(enB_bank[i]), .addr_b(addrB_bank[i]), .dout_b(doutB_bank[i]));
            end else if (i == 4) begin : g_bank4
                reuse_weight_bank_rom #(.DEPTH(DEPTH), .ADDR_W(ADDR_W), .DATA_W(DATA_W), .INIT_FILE(BANK4_INIT_FILE)) u_bank (
                    .clk(clk), .en_a(enA_bank[i]), .addr_a(addrA_bank[i]), .dout_a(doutA_bank[i]),
                    .en_b(enB_bank[i]), .addr_b(addrB_bank[i]), .dout_b(doutB_bank[i]));
            end else begin : g_bank5
                reuse_weight_bank_rom #(.DEPTH(DEPTH), .ADDR_W(ADDR_W), .DATA_W(DATA_W), .INIT_FILE(BANK5_INIT_FILE)) u_bank (
                    .clk(clk), .en_a(enA_bank[i]), .addr_a(addrA_bank[i]), .dout_a(doutA_bank[i]),
                    .en_b(enB_bank[i]), .addr_b(addrB_bank[i]), .dout_b(doutB_bank[i]));
            end
        end
    endgenerate
`else
    logic [DATA_W-1:0] mem_sim0 [0:DEPTH-1];
    logic [DATA_W-1:0] mem_sim1 [0:DEPTH-1];
    logic [DATA_W-1:0] mem_sim2 [0:DEPTH-1];
    logic [DATA_W-1:0] mem_sim3 [0:DEPTH-1];
    logic [DATA_W-1:0] mem_sim4 [0:DEPTH-1];
    logic [DATA_W-1:0] mem_sim5 [0:DEPTH-1];
    logic [DATA_W-1:0] doutA_r [N_BANK];
    logic [DATA_W-1:0] doutB_r [N_BANK];

    initial begin : init_mem_sim
        for (int addr = 0; addr < DEPTH; addr++) begin
            mem_sim0[addr] = '0;
            mem_sim1[addr] = '0;
            mem_sim2[addr] = '0;
            mem_sim3[addr] = '0;
            mem_sim4[addr] = '0;
            mem_sim5[addr] = '0;
        end
        if (BANK0_INIT_FILE != "") $readmemh(BANK0_INIT_FILE, mem_sim0);
        if (BANK1_INIT_FILE != "") $readmemh(BANK1_INIT_FILE, mem_sim1);
        if (BANK2_INIT_FILE != "") $readmemh(BANK2_INIT_FILE, mem_sim2);
        if (BANK3_INIT_FILE != "") $readmemh(BANK3_INIT_FILE, mem_sim3);
        if (BANK4_INIT_FILE != "") $readmemh(BANK4_INIT_FILE, mem_sim4);
        if (BANK5_INIT_FILE != "") $readmemh(BANK5_INIT_FILE, mem_sim5);
    end

    function automatic [DATA_W-1:0] mem_read_sim(input int bank_idx, input [ADDR_W-1:0] addr_idx);
        case (bank_idx)
            0: mem_read_sim = mem_sim0[addr_idx];
            1: mem_read_sim = mem_sim1[addr_idx];
            2: mem_read_sim = mem_sim2[addr_idx];
            3: mem_read_sim = mem_sim3[addr_idx];
            4: mem_read_sim = mem_sim4[addr_idx];
            5: mem_read_sim = mem_sim5[addr_idx];
            default: mem_read_sim = '0;
        endcase
    endfunction

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            for (int bank = 0; bank < N_BANK; bank++) begin
                doutA_r[bank] <= '0;
                doutB_r[bank] <= '0;
            end
        end else begin
            for (int bank = 0; bank < N_BANK; bank++) begin
                if (enA_bank[bank])
                    doutA_r[bank] <= mem_read_sim(bank, addrA_bank[bank]);
                if (enB_bank[bank])
                    doutB_r[bank] <= mem_read_sim(bank, addrB_bank[bank]);
            end
        end
    end

    always_comb begin
        for (int bank = 0; bank < N_BANK; bank++) begin
            doutA_bank[bank] = doutA_r[bank];
            doutB_bank[bank] = doutB_r[bank];
        end
    end
`endif

    always_comb begin
        enA_bank = '0;
        enB_bank = '0;
        for (int bank = 0; bank < N_BANK; bank++) begin
            addrA_bank[bank] = '0;
            addrB_bank[bank] = '0;
        end
        for (int j = 0; j < 4; j++) begin
            if (en_sel[j]) begin
                b = bank_sel[j];
                a = safe_addr(addr_sel[j]);
                if (port_sel[j] == 1'b0) begin
                    enA_bank[b]   = 1'b1;
                    addrA_bank[b] = a;
                end else begin
                    enB_bank[b]   = 1'b1;
                    addrB_bank[b] = a;
                end
            end
        end
    end

    logic [3:0][$clog2(N_BANK)-1:0] bank_sel_q;
    logic [3:0]                     port_sel_q;
    logic [3:0]                     en_sel_q;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            bank_sel_q <= '0;
            port_sel_q <= '0;
            en_sel_q   <= '0;
        end else begin
            bank_sel_q <= bank_sel;
            port_sel_q <= port_sel;
            en_sel_q   <= en_sel;
        end
    end

    always_comb begin
        for (int j = 0; j < 4; j++) begin
            if (!en_sel_q[j]) begin
                dout_sel[j] = '0;
            end else begin
                dout_sel[j] = (port_sel_q[j] == 1'b0) ? doutA_bank[bank_sel_q[j]] : doutB_bank[bank_sel_q[j]];
            end
        end
    end
endmodule
