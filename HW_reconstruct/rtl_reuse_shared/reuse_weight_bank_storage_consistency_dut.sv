`timescale 1ns/1ps

module reuse_weight_bank_storage_consistency_dut #(
    parameter int ROM_DEPTH = 8,
    parameter int ROM_ADDR_W = $clog2(ROM_DEPTH),
    parameter int ROM_DATA_W = 32,
    parameter string ROM_INIT_FILE = "E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank0.mem",
    parameter int N_BANK = 6,
    parameter int WBUF_DEPTH = 8,
    parameter int WBUF_ADDR_W = $clog2(WBUF_DEPTH),
    parameter int WBUF_DATA_W = 32,
    parameter string BANK0_INIT_FILE = "E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank0.mem",
    parameter string BANK1_INIT_FILE = "E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank1.mem",
    parameter string BANK2_INIT_FILE = "E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank2.mem",
    parameter string BANK3_INIT_FILE = "E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank3.mem",
    parameter string BANK4_INIT_FILE = "E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank4.mem",
    parameter string BANK5_INIT_FILE = "E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank5.mem"
)(
    input  logic clk,
    input  logic rst_n,
    input  logic                     rom_en_a,
    input  logic [ROM_ADDR_W-1:0]    rom_addr_a,
    output logic [ROM_DATA_W-1:0]    rom_dout_a,
    input  logic                     rom_en_b,
    input  logic [ROM_ADDR_W-1:0]    rom_addr_b,
    output logic [ROM_DATA_W-1:0]    rom_dout_b,
    input  logic [3:0][$clog2(N_BANK)-1:0] slim_bank_sel,
    input  logic [3:0][WBUF_ADDR_W-1:0]    slim_addr_sel,
    input  logic [3:0]                     slim_en_sel,
    input  logic [3:0]                     slim_port_sel,
    output logic [3:0][WBUF_DATA_W-1:0]    slim_dout_sel
);
    reuse_weight_bank_rom #(
        .DEPTH     (ROM_DEPTH),
        .ADDR_W    (ROM_ADDR_W),
        .DATA_W    (ROM_DATA_W),
        .INIT_FILE (ROM_INIT_FILE)
    ) u_rom (
        .clk    (clk),
        .en_a   (rom_en_a),
        .addr_a (rom_addr_a),
        .dout_a (rom_dout_a),
        .en_b   (rom_en_b),
        .addr_b (rom_addr_b),
        .dout_b (rom_dout_b)
    );

    slim_multi_bank_wbuf_dp #(
        .N_BANK          (N_BANK),
        .DEPTH           (WBUF_DEPTH),
        .ADDR_W          (WBUF_ADDR_W),
        .DATA_W          (WBUF_DATA_W),
        .BANK0_INIT_FILE (BANK0_INIT_FILE),
        .BANK1_INIT_FILE (BANK1_INIT_FILE),
        .BANK2_INIT_FILE (BANK2_INIT_FILE),
        .BANK3_INIT_FILE (BANK3_INIT_FILE),
        .BANK4_INIT_FILE (BANK4_INIT_FILE),
        .BANK5_INIT_FILE (BANK5_INIT_FILE)
    ) u_wbuf (
        .clk      (clk),
        .rst_n    (rst_n),
        .bank_sel (slim_bank_sel),
        .addr_sel (slim_addr_sel),
        .en_sel   (slim_en_sel),
        .port_sel (slim_port_sel),
        .dout_sel (slim_dout_sel)
    );
endmodule
