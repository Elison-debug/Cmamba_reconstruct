//---------------------------------------------------------------
// Module: reuse_inproj_weight_sram
// Function:
//   in_proj binding layer for the shared banked weight store.
//   The module fixes the in_proj initialization files and preserves the
//   existing port contract used by the in_proj scheduler.
//---------------------------------------------------------------
module reuse_inproj_weight_sram #(
    parameter int N_BANK  = 6,
    parameter int DEPTH   = 683,
    parameter int ADDR_W  = $clog2(DEPTH),
    parameter int DATA_W  = 256,
    parameter string BANK0_INIT_FILE = "E:/course/smamba/HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top/inproj_wbuf_bank0.mem",
    parameter string BANK1_INIT_FILE = "E:/course/smamba/HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top/inproj_wbuf_bank1.mem",
    parameter string BANK2_INIT_FILE = "E:/course/smamba/HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top/inproj_wbuf_bank2.mem",
    parameter string BANK3_INIT_FILE = "E:/course/smamba/HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top/inproj_wbuf_bank3.mem",
    parameter string BANK4_INIT_FILE = "E:/course/smamba/HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top/inproj_wbuf_bank4.mem",
    parameter string BANK5_INIT_FILE = "E:/course/smamba/HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top/inproj_wbuf_bank5.mem"
)(
    input  logic                       clk,
    input  logic                       rst_n,
    input  logic [3:0][$clog2(N_BANK)-1:0] bank_sel,
    input  logic [3:0][ADDR_W-1:0]         addr_sel,
    input  logic [3:0]                     en_sel,
    input  logic [3:0]                     port_sel,
    output logic [3:0][DATA_W-1:0]         dout_sel
);
    slm_weight_bank_store #(
        .N_BANK          (N_BANK),
        .DEPTH           (DEPTH),
        .ADDR_W          (ADDR_W),
        .DATA_W          (DATA_W),
        .BANK0_INIT_FILE (BANK0_INIT_FILE),
        .BANK1_INIT_FILE (BANK1_INIT_FILE),
        .BANK2_INIT_FILE (BANK2_INIT_FILE),
        .BANK3_INIT_FILE (BANK3_INIT_FILE),
        .BANK4_INIT_FILE (BANK4_INIT_FILE),
        .BANK5_INIT_FILE (BANK5_INIT_FILE)
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
