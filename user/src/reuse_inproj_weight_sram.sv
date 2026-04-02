//---------------------------------------------------------------
// Module: reuse_inproj_weight_sram
// Function:
//   Dedicated read-only weight SRAM wrapper for in_proj.
//   Stores 4x4 tiles of W_in (512x128 => 4096 tiles), with the same
//   6-bank dual-port organization style used by the SSM dt path.
//---------------------------------------------------------------
module reuse_inproj_weight_sram #(
    parameter int N_BANK  = 6,
    parameter int DEPTH   = 683,
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
    slim_multi_bank_wbuf_dp #(
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
