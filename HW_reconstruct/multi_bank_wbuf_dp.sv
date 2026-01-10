// ====================================================================
//  File: multi_bank_wbuf_dp.sv
//  Function:
//      6-bank TRUE Dual-Port WBUF subsystem for Mamba SSM (MAC mode)
//      - Supports 4 parallel array reads via dual-ports
//      - Synthesis uses BRAM TDP IP (WBUF_bank_dp)
//      - Simulation uses internal mem_sim (1-cycle latency)
//
//  NOTE:
//      One address = one 4x4 block (256-bit)
// ====================================================================
module multi_bank_wbuf_dp #(
    parameter int N_BANK  = 6,
    parameter int DEPTH   = 11,               // 11 blocks per bank
    parameter int ADDR_W  = $clog2(DEPTH),    // = 4
    parameter int DATA_W  = 256
)(
    input  logic                       clk,
    input  logic                       rst_n,

    // -------- Controller Interface --------
    input  logic [3:0][$clog2(N_BANK)-1:0] bank_sel,  // A1..A4 bank select
    input  logic [3:0][ADDR_W-1:0]         addr_sel,  // A1..A4 addresses
    input  logic [3:0]                     en_sel,    // per-read enable
    input  logic [3:0]                     port_sel,  // 0:PortA, 1:PortB

    // -------- Data Output --------
    output logic [3:0][DATA_W-1:0]         dout_sel   // 4x 256-bit blocks
);
    logic [$clog2(N_BANK)-1:0] b;
    logic [ADDR_W-1:0]         a;

    // ====================================================================
    // Internal bank arrays
    // ====================================================================
    logic [N_BANK-1:0]           enA_bank, enB_bank;
    logic [ADDR_W-1:0]           addrA_bank [N_BANK];
    logic [ADDR_W-1:0]           addrB_bank [N_BANK];
    logic [DATA_W-1:0]           doutA_bank [N_BANK];
    logic [DATA_W-1:0]           doutB_bank [N_BANK];

    // ====================================================================
    // Safe address helper (no X/no OOB access)
    // ====================================================================
    function automatic [ADDR_W-1:0] safe_addr(input [ADDR_W-1:0] raw);
        if (raw < DEPTH)
            safe_addr = raw;
        else
            safe_addr = '0;
    endfunction

// ====================================================================
//  Synthesis Model — instantiate the real 256-bit dual-port BRAM
// ====================================================================
`ifdef SYNTHESIS

    generate
        for (genvar i = 0; i < N_BANK; i++) begin : WBUF_BANK
            WBUF_bank_dp u_bank (
                // ---- Port A ----
                .clka   (clk),
                .ena    (enA_bank[i]),
                .addra  (addrA_bank[i]),
                .douta  (doutA_bank[i]),

                // ---- Port B ----
                .clkb   (clk),
                .enb    (enB_bank[i]),
                .addrb  (addrB_bank[i]),
                .doutb  (doutB_bank[i])
            );
        end
    endgenerate

// ====================================================================
//  Simulation Model — internal arrays, 2-cycle latency (match BRAM reg)
// ====================================================================
`else
    logic [DATA_W-1:0] mem_sim [N_BANK][DEPTH];
    logic [DATA_W-1:0] doutA_r [N_BANK];
    logic [DATA_W-1:0] doutA_q [N_BANK];
    logic [DATA_W-1:0] doutB_r [N_BANK];
    logic [DATA_W-1:0] doutB_q [N_BANK];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int b = 0; b < N_BANK; b++) begin
                doutA_r[b] <= '0; doutA_q[b] <= '0;
                doutB_r[b] <= '0; doutB_q[b] <= '0;
            end
        end else begin
            for (int b = 0; b < N_BANK; b++) begin
                if (enA_bank[b])
                    doutA_r[b] <= mem_sim[b][addrA_bank[b]]; // stage 1
                if (enB_bank[b])
                    doutB_r[b] <= mem_sim[b][addrB_bank[b]]; // stage 1
                // stage 2
                doutA_q[b] <= doutA_r[b];
                doutB_q[b] <= doutB_r[b];
            end
        end
    end

    always_comb begin
        for (int b = 0; b < N_BANK; b++) begin
            doutA_bank[b] = doutA_q[b];
            doutB_bank[b] = doutB_q[b];
        end
    end
`endif

    // ====================================================================
    // Routing logic for Port A and Port B
    // ====================================================================
    always_comb begin
        enA_bank = '0;
        enB_bank = '0;

        for (int b = 0; b < N_BANK; b++) begin
            addrA_bank[b] = '0;
            addrB_bank[b] = '0;
        end

        // Assign 4 array reads to ports/banks
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

    // ====================================================================
    // BRAM read = 1 cycle → register selectors
    // ====================================================================
    logic [3:0][$clog2(N_BANK)-1:0] bank_sel_q;
    logic [3:0]                     port_sel_q;
    logic [3:0]                     en_sel_q;

    always_ff @(posedge clk or negedge rst_n) begin
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

    // ====================================================================
    // Output mux (Port A or Port B, depending on port_sel)
    // ====================================================================
    always_comb begin
        for (int j = 0; j < 4; j++) begin
            if (!en_sel_q[j]) begin
                dout_sel[j] = '0;
            end else begin
                dout_sel[j] = (port_sel_q[j] == 1'b0)
                             ? doutA_bank[ bank_sel_q[j] ]
                             : doutB_bank[ bank_sel_q[j] ];
            end
        end
    end

endmodule
