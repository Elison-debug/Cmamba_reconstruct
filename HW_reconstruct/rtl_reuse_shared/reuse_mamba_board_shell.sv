`timescale 1ns/1ps
//---------------------------------------------------------------
// Board-facing shell for ZCU102 bring-up.
//
// Intended Vivado block design around this shell:
// - Zynq UltraScale+ MPSoC PS
// - AXI SmartConnect
// - AXI GPIO / interrupt concat (optional)
// - AXI DMA #0 MM2S : preload h_t rows from DDR
// - AXI DMA #1 MM2S : stream g input rows from DDR
// - AXI DMA #1 S2MM : capture y output rows back to DDR
//
// Current scope:
// - Provides AXI4-Lite control/status registers
// - Provides AXIS hooks for h preload, g input, and y output
// - Instantiates the existing reuse_mamba_block_wrapper
// - Keeps weight DDR addresses as software-visible descriptors for a later
//   bank-loader path; initial board bring-up can keep weights preinitialized
//   from .mem/bitstream.
//---------------------------------------------------------------
module reuse_mamba_board_shell #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8,
    parameter int N_BANK     = 6,
    parameter int WDEPTH     = 1024,
    parameter int WADDR_W    = $clog2(WDEPTH),
    parameter int DATA_W     = 256,
    parameter int XT_ADDR_W  = 6,
    parameter int D          = 256,
    parameter int PIPE_LAT   = 4,
    parameter int ADDR_BITS  = 11,
    parameter string LUT_FILE = "sigmoid_lut_q016_2048.hex",
    parameter int S_ADDR_W   = 6,
    parameter int G_FRAC_BITS = 8,
    parameter int AXIL_ADDR_W = 12
) (
    input  logic sys_clk,
    input  logic ext_reset_n,
    output logic irq,

    input  logic [AXIL_ADDR_W-1:0] s_axi_awaddr,
    input  logic                   s_axi_awvalid,
    output logic                   s_axi_awready,
    input  logic [31:0]            s_axi_wdata,
    input  logic [3:0]             s_axi_wstrb,
    input  logic                   s_axi_wvalid,
    output logic                   s_axi_wready,
    output logic [1:0]             s_axi_bresp,
    output logic                   s_axi_bvalid,
    input  logic                   s_axi_bready,
    input  logic [AXIL_ADDR_W-1:0] s_axi_araddr,
    input  logic                   s_axi_arvalid,
    output logic                   s_axi_arready,
    output logic [31:0]            s_axi_rdata,
    output logic [1:0]             s_axi_rresp,
    output logic                   s_axi_rvalid,
    input  logic                   s_axi_rready,

    input  logic                         s_axis_h_tvalid,
    output logic                         s_axis_h_tready,
    input  logic [TILE_SIZE*DATA_WIDTH-1:0] s_axis_h_tdata,
    input  logic                         s_axis_h_tlast,

    input  logic                         s_axis_g_tvalid,
    output logic                         s_axis_g_tready,
    input  logic [TILE_SIZE*DATA_WIDTH-1:0] s_axis_g_tdata,
    input  logic                         s_axis_g_tlast,

    output logic                         m_axis_y_tvalid,
    input  logic                         m_axis_y_tready,
    output logic [TILE_SIZE*DATA_WIDTH-1:0] m_axis_y_tdata,
    output logic                         m_axis_y_tlast
);
    logic core_rst_n_o;
    logic core_soft_reset_pulse;
    logic core_start_pulse;
    logic preload_h_start_pulse;
    logic block_auto_mode;
    logic [15:0] h_rows_cfg, y_rows_cfg;
    logic [31:0] irq_enable;
    logic [63:0] h_src_addr, g_src_addr, y_dst_addr;
    logic [63:0] inproj_w_addr, dt_w_addr, outproj_w_addr;

    logic block_busy, block_done;
    logic inproj_busy, inproj_done, outproj_busy;
    logic preload_h_busy, preload_h_done;
    logic dma_error;

    logic h_wr_en;
    logic [4:0] h_wr_addr;
    logic signed [TILE_SIZE*DATA_WIDTH-1:0] h_wr_data_flat;
    logic signed [DATA_WIDTH-1:0] h_wr_data_arr [TILE_SIZE-1:0];
    logic signed [TILE_SIZE*DATA_WIDTH-1:0] u_rd_data_flat;
    logic signed [TILE_SIZE*DATA_WIDTH-1:0] z_rd_data_flat;

    logic block_start_mux;
    logic rst_n_int;

    assign rst_n_int = ext_reset_n & ~core_soft_reset_pulse;
    assign block_start_mux = core_start_pulse & preload_h_done;
    assign dma_error = 1'b0;
    assign irq = (irq_enable[0] & block_done) | (irq_enable[1] & preload_h_done) | (irq_enable[2] & dma_error);
    assign m_axis_y_tlast = m_axis_y_tvalid & m_axis_y_tready;

    reuse_mamba_axi_lite_regs #(
        .ADDR_W(AXIL_ADDR_W)
    ) u_regs (
        .clk                 (sys_clk),
        .rst_n               (rst_n_int),
        .s_axi_awaddr        (s_axi_awaddr),
        .s_axi_awvalid       (s_axi_awvalid),
        .s_axi_awready       (s_axi_awready),
        .s_axi_wdata         (s_axi_wdata),
        .s_axi_wstrb         (s_axi_wstrb),
        .s_axi_wvalid        (s_axi_wvalid),
        .s_axi_wready        (s_axi_wready),
        .s_axi_bresp         (s_axi_bresp),
        .s_axi_bvalid        (s_axi_bvalid),
        .s_axi_bready        (s_axi_bready),
        .s_axi_araddr        (s_axi_araddr),
        .s_axi_arvalid       (s_axi_arvalid),
        .s_axi_arready       (s_axi_arready),
        .s_axi_rdata         (s_axi_rdata),
        .s_axi_rresp         (s_axi_rresp),
        .s_axi_rvalid        (s_axi_rvalid),
        .s_axi_rready        (s_axi_rready),
        .block_busy          (block_busy),
        .block_done          (block_done),
        .preload_h_busy      (preload_h_busy),
        .preload_h_done      (preload_h_done),
        .dma_error           (dma_error),
        .soft_reset_pulse    (core_soft_reset_pulse),
        .start_pulse         (core_start_pulse),
        .block_auto_mode     (block_auto_mode),
        .preload_h_start_pulse(preload_h_start_pulse),
        .h_rows_cfg          (h_rows_cfg),
        .y_rows_cfg          (y_rows_cfg),
        .irq_enable          (irq_enable),
        .h_src_addr          (h_src_addr),
        .g_src_addr          (g_src_addr),
        .y_dst_addr          (y_dst_addr),
        .inproj_w_addr       (inproj_w_addr),
        .dt_w_addr           (dt_w_addr),
        .outproj_w_addr      (outproj_w_addr)
    );

    reuse_mamba_h_stream_loader #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .H_ADDR_W  (5)
    ) u_h_loader (
        .clk          (sys_clk),
        .rst_n        (rst_n_int),
        .start        (preload_h_start_pulse),
        .rows_cfg     (h_rows_cfg),
        .busy         (preload_h_busy),
        .done         (preload_h_done),
        .s_axis_tvalid(s_axis_h_tvalid),
        .s_axis_tready(s_axis_h_tready),
        .s_axis_tdata (s_axis_h_tdata),
        .s_axis_tlast (s_axis_h_tlast),
        .h_wr_en      (h_wr_en),
        .h_wr_addr    (h_wr_addr),
        .h_wr_data    (h_wr_data_arr)
    );

    genvar gi;
    generate
        for (gi = 0; gi < TILE_SIZE; gi++) begin : g_h_flat
            assign h_wr_data_flat[gi*DATA_WIDTH +: DATA_WIDTH] = h_wr_data_arr[gi];
        end
    endgenerate

    reuse_mamba_block_wrapper #(
        .TILE_SIZE   (TILE_SIZE),
        .DATA_WIDTH  (DATA_WIDTH),
        .ACC_WIDTH   (ACC_WIDTH),
        .FRAC_BITS   (FRAC_BITS),
        .N_BANK      (N_BANK),
        .WDEPTH      (WDEPTH),
        .WADDR_W     (WADDR_W),
        .DATA_W      (DATA_W),
        .XT_ADDR_W   (XT_ADDR_W),
        .D           (D),
        .PIPE_LAT    (PIPE_LAT),
        .ADDR_BITS   (ADDR_BITS),
        .LUT_FILE    (LUT_FILE),
        .S_ADDR_W    (S_ADDR_W),
        .G_FRAC_BITS (G_FRAC_BITS)
    ) u_core (
        .sys_clk        (sys_clk),
        .ext_reset_n    (rst_n_int),
        .core_rst_n_o   (core_rst_n_o),
        .block_auto_mode(block_auto_mode),
        .block_start    (block_start_mux),
        .block_busy     (block_busy),
        .block_done     (block_done),
        .s_axis_tvalid  (block_start_mux),
        .s_axis_tready  (),
        .g_axis_tvalid  (s_axis_g_tvalid),
        .g_axis_tready  (s_axis_g_tready),
        .g_axis_tdata   (s_axis_g_tdata),
        .y_axis_tvalid  (m_axis_y_tvalid),
        .y_axis_tready  (m_axis_y_tready),
        .y_axis_tdata   (m_axis_y_tdata),
        .inproj_enable  (1'b1),
        .inproj_start   (block_start_mux),
        .inproj_busy    (inproj_busy),
        .inproj_done    (inproj_done),
        .h_wr_en        (h_wr_en),
        .h_wr_addr      (h_wr_addr),
        .h_wr_data      (h_wr_data_flat),
        .u_rd_en        (1'b0),
        .u_rd_addr      ('0),
        .u_rd_data      (u_rd_data_flat),
        .z_rd_en        (1'b0),
        .z_rd_addr      ('0),
        .z_rd_data      (z_rd_data_flat),
        .outproj_enable (1'b1),
        .outproj_busy   (outproj_busy)
    );

endmodule
