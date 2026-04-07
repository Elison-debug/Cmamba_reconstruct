module reuse_outproj_weight_sram #(
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
    reuse_outproj_multi_bank_wbuf_dp #(
        .N_BANK (N_BANK),
        .DEPTH  (DEPTH),
        .ADDR_W (ADDR_W),
        .DATA_W (DATA_W)
    ) u_weight (
        .clk      (clk),
        .rst_n    (rst_n),
        .bank_sel (bank_sel),
        .addr_sel (addr_sel),
        .en_sel   (en_sel),
        .port_sel (port_sel),
        .dout_sel (dout_sel)
    );
endmodule
