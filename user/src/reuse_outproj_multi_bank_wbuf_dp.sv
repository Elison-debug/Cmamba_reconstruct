`timescale 1ns/1ps
// ====================================================================
// File: reuse_outproj_multi_bank_wbuf_dp.sv
// Function:
//   6-bank dual-port WBUF subsystem for out_proj matrix tiles.
//   - Stores all 2048 (32x64) tiles of W_out
//   - Uses same bank mapping interface as slim_multi_bank_wbuf_dp
//   - Synthesis uses outproj_WBUF_bank_dp, simulation uses mem_sim
// ====================================================================
module reuse_outproj_multi_bank_wbuf_dp #(
    parameter int N_BANK  = 6,
    parameter int DEPTH   = 342,
    parameter int ADDR_W  = $clog2(DEPTH),
    parameter int DATA_W  = 256
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

    logic [N_BANK-1:0] enA_bank, enB_bank;
    logic [ADDR_W-1:0] addrA_bank [N_BANK];
    logic [ADDR_W-1:0] addrB_bank [N_BANK];
    logic [DATA_W-1:0] doutA_bank [N_BANK];
    logic [DATA_W-1:0] doutB_bank [N_BANK];

    function automatic [ADDR_W-1:0] safe_addr(input [ADDR_W-1:0] raw);
        if (raw < DEPTH) safe_addr = raw;
        else             safe_addr = '0;
    endfunction

`ifdef SYNTHESIS
    generate
        for (genvar i = 0; i < N_BANK; i++) begin : WBUF_BANK
            outproj_WBUF_bank_dp u_bank (
                .clka  (clk),
                .ena   (enA_bank[i]),
                .addra (addrA_bank[i]),
                .douta (doutA_bank[i]),
                .clkb  (clk),
                .enb   (enB_bank[i]),
                .addrb (addrB_bank[i]),
                .doutb (doutB_bank[i])
            );
        end
    endgenerate
`else
    logic [DATA_W-1:0] mem_sim [N_BANK][DEPTH];
    logic [DATA_W-1:0] doutA_r [N_BANK];
    logic [DATA_W-1:0] doutB_r [N_BANK];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int bi = 0; bi < N_BANK; bi++) begin
                doutA_r[bi] <= '0;
                doutB_r[bi] <= '0;
            end
        end else begin
            for (int bi = 0; bi < N_BANK; bi++) begin
                if (enA_bank[bi])
                    doutA_r[bi] <= mem_sim[bi][addrA_bank[bi]];
                if (enB_bank[bi])
                    doutB_r[bi] <= mem_sim[bi][addrB_bank[bi]];
            end
        end
    end

    always_comb begin
        for (int bi = 0; bi < N_BANK; bi++) begin
            doutA_bank[bi] = doutA_r[bi];
            doutB_bank[bi] = doutB_r[bi];
        end
    end
`endif

    always_comb begin
        enA_bank = '0;
        enB_bank = '0;

        for (int bi = 0; bi < N_BANK; bi++) begin
            addrA_bank[bi] = '0;
            addrB_bank[bi] = '0;
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

    always_comb begin
        dout_sel = '{default:'0};
        for (int j = 0; j < 4; j++) begin
            b = bank_sel[j];
            if (port_sel[j] == 1'b0)
                dout_sel[j] = doutA_bank[b];
            else
                dout_sel[j] = doutB_bank[b];
        end
    end
endmodule
