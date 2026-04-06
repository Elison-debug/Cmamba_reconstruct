`timescale 1ns/1ps
//---------------------------------------------------------------
// Board-facing shell for ZCU102 bring-up.
// h is preloaded through AXIS into the existing H SRAM path.
// g is first captured from AXIS into a small local buffer, then
// replayed to the inner core so the core sees a deterministic
// stream aligned with block_start.
//---------------------------------------------------------------
module reuse_mamba_board_shell #(
    parameter integer TILE_SIZE   = 4,
    parameter integer DATA_WIDTH  = 16,
    parameter integer ACC_WIDTH   = 32,
    parameter integer FRAC_BITS   = 8,
    parameter integer N_BANK      = 6,
    parameter integer WDEPTH      = 1024,
    parameter integer WADDR_W     = $clog2(WDEPTH),
    parameter integer DATA_W      = 256,
    parameter integer XT_ADDR_W   = 6,
    parameter integer D           = 256,
    parameter integer PIPE_LAT    = 4,
    parameter integer ADDR_BITS   = 11,
    parameter LUT_FILE            = "sigmoid_lut_q016_2048.hex",
    parameter integer S_ADDR_W    = 6,
    parameter integer G_FRAC_BITS = 8,
    parameter integer AXIL_ADDR_W = 12,
    parameter integer G_DEPTH     = 64,
    parameter integer G_ADDR_W    = $clog2(G_DEPTH)
) (
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME sys_clk, ASSOCIATED_BUSIF s_axi:s_axis_h:s_axis_g:m_axis_y, ASSOCIATED_RESET ext_reset_n, FREQ_HZ 100000000" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 sys_clk CLK" *)
    input  wire                            sys_clk,

    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ext_reset_n, POLARITY ACTIVE_LOW" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ext_reset_n RST" *)
    input  wire                            ext_reset_n,
    output wire                            irq,

    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWADDR" *)
    input  wire [AXIL_ADDR_W-1:0]          s_axi_awaddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWVALID" *)
    input  wire                            s_axi_awvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWREADY" *)
    output wire                            s_axi_awready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WDATA" *)
    input  wire [31:0]                     s_axi_wdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WSTRB" *)
    input  wire [3:0]                      s_axi_wstrb,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WVALID" *)
    input  wire                            s_axi_wvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WREADY" *)
    output wire                            s_axi_wready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BRESP" *)
    output wire [1:0]                      s_axi_bresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BVALID" *)
    output wire                            s_axi_bvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BREADY" *)
    input  wire                            s_axi_bready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARADDR" *)
    input  wire [AXIL_ADDR_W-1:0]          s_axi_araddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARVALID" *)
    input  wire                            s_axi_arvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARREADY" *)
    output wire                            s_axi_arready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RDATA" *)
    output wire [31:0]                     s_axi_rdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RRESP" *)
    output wire [1:0]                      s_axi_rresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RVALID" *)
    output wire                            s_axi_rvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RREADY" *)
    input  wire                            s_axi_rready,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_h TVALID" *)
    input  wire                            s_axis_h_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_h TREADY" *)
    output wire                            s_axis_h_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_h TDATA" *)
    input  wire [TILE_SIZE*DATA_WIDTH-1:0] s_axis_h_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_h TLAST" *)
    input  wire                            s_axis_h_tlast,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_g TVALID" *)
    input  wire                            s_axis_g_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_g TREADY" *)
    output wire                            s_axis_g_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_g TDATA" *)
    input  wire [TILE_SIZE*DATA_WIDTH-1:0] s_axis_g_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_g TLAST" *)
    input  wire                            s_axis_g_tlast,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_y TVALID" *)
    output wire                            m_axis_y_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_y TREADY" *)
    input  wire                            m_axis_y_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_y TDATA" *)
    output wire [TILE_SIZE*DATA_WIDTH-1:0] m_axis_y_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_y TLAST" *)
    output wire                            m_axis_y_tlast
);
    wire                           core_rst_n_o;
    wire                           core_soft_reset_pulse;
    wire                           core_start_pulse;
    wire                           preload_h_start_pulse;
    wire                           block_auto_mode;
    wire [15:0]                    h_rows_cfg;
    wire [15:0]                    y_rows_cfg;
    wire [31:0]                    irq_enable;
    wire [63:0]                    h_src_addr;
    wire [63:0]                    g_src_addr;
    wire [63:0]                    y_dst_addr;
    wire [63:0]                    inproj_w_addr;
    wire [63:0]                    dt_w_addr;
    wire [63:0]                    outproj_w_addr;
    

    wire                           block_busy;
    wire                           block_done;
    wire                           inproj_busy;
    wire                           inproj_done;
    wire                           outproj_busy;
    wire                           preload_h_busy;
    wire                           preload_h_done;
    wire                           dma_error;

    wire                           h_wr_en;
    wire [4:0]                     h_wr_addr;
    wire signed [TILE_SIZE*DATA_WIDTH-1:0] h_wr_data_flat;
    wire signed [TILE_SIZE*DATA_WIDTH-1:0] u_rd_data_flat;
    wire signed [TILE_SIZE*DATA_WIDTH-1:0] z_rd_data_flat;

    wire                           rst_n_int;

    // g adapter signals
    reg                            g_load_start_pulse;
    reg                            g_play_start_pulse;
    reg                            core_block_start_pulse;
    reg                            run_pending;
    wire                           preload_g_busy;
    wire                           preload_g_done;
    wire                           g_play_busy;
    wire                           g_play_done;
    wire                           core_g_tvalid;
    wire                           core_g_tready;
    wire [TILE_SIZE*DATA_WIDTH-1:0] core_g_tdata;

    assign rst_n_int      = ext_reset_n & ~core_soft_reset_pulse;
    assign dma_error      = 1'b0;
    assign irq            = (irq_enable[0] & block_done) |
                            (irq_enable[1] & preload_h_done) |
                            (irq_enable[2] & dma_error);
    assign m_axis_y_tlast = m_axis_y_tvalid & m_axis_y_tready;

    reuse_mamba_axi_lite_regs #(
        .ADDR_W(AXIL_ADDR_W)
    ) u_regs (
        .clk                  (sys_clk),
        .rst_n                (rst_n_int),
        .s_axi_awaddr         (s_axi_awaddr),
        .s_axi_awvalid        (s_axi_awvalid),
        .s_axi_awready        (s_axi_awready),
        .s_axi_wdata          (s_axi_wdata),
        .s_axi_wstrb          (s_axi_wstrb),
        .s_axi_wvalid         (s_axi_wvalid),
        .s_axi_wready         (s_axi_wready),
        .s_axi_bresp          (s_axi_bresp),
        .s_axi_bvalid         (s_axi_bvalid),
        .s_axi_bready         (s_axi_bready),
        .s_axi_araddr         (s_axi_araddr),
        .s_axi_arvalid        (s_axi_arvalid),
        .s_axi_arready        (s_axi_arready),
        .s_axi_rdata          (s_axi_rdata),
        .s_axi_rresp          (s_axi_rresp),
        .s_axi_rvalid         (s_axi_rvalid),
        .s_axi_rready         (s_axi_rready),
        .block_busy           (block_busy),
        .block_done           (block_done),
        .preload_h_busy       (preload_h_busy),
        .preload_h_done       (preload_h_done),
        .dma_error            (dma_error),
        .soft_reset_pulse     (core_soft_reset_pulse),
        .start_pulse          (core_start_pulse),
        .block_auto_mode      (block_auto_mode),
        .preload_h_start_pulse(preload_h_start_pulse),
        .h_rows_cfg           (h_rows_cfg),
        .y_rows_cfg           (y_rows_cfg),
        .irq_enable           (irq_enable),
        .h_src_addr           (h_src_addr),
        .g_src_addr           (g_src_addr),
        .y_dst_addr           (y_dst_addr),
        .inproj_w_addr        (inproj_w_addr),
        .dt_w_addr            (dt_w_addr),
        .outproj_w_addr       (outproj_w_addr)
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
        .h_wr_data    (h_wr_data_flat)
    );

    //g load暂时有问题先直通core，后续调试好再打开上面的loader模块
    parameter G_COMPAT_MODE = 1;
    wire                           g_loader_axis_tvalid;
    wire                           g_loader_axis_tready;
    wire [TILE_SIZE*DATA_WIDTH-1:0] g_loader_axis_tdata;

    wire                           preload_g_busy_int;
    wire                           preload_g_done_int;
    wire                           g_play_busy_int;
    wire                           g_play_done_int;
    wire                           s_axis_g_tready_loader;

    reuse_mamba_g_stream_loader #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .G_DEPTH   (G_DEPTH),
        .G_ADDR_W  (G_ADDR_W)
    ) u_g_loader (
        .clk          (sys_clk),
        .rst_n        (rst_n_int),
        .load_start   (g_load_start_pulse),
        .rows_cfg     (y_rows_cfg),
        .load_busy    (preload_g_busy),
        .load_done    (preload_g_done),
        .s_axis_tvalid(s_axis_g_tvalid),
        .s_axis_tready(s_axis_g_tready),
        .s_axis_tdata (s_axis_g_tdata),
        .s_axis_tlast (s_axis_g_tlast),
        .play_start   (g_play_start_pulse),
        .play_busy    (g_play_busy),
        .play_done    (g_play_done),
        // .g_axis_tvalid(core_g_tvalid),
        // .g_axis_tready(core_g_tready),
        // .g_axis_tdata (core_g_tdata)
        .g_axis_tvalid (g_loader_axis_tvalid),//调试用，先不直接连 core
        .g_axis_tready (g_loader_axis_tready),
        .g_axis_tdata  (g_loader_axis_tdata)
    );


//调试用代码
    assign preload_g_busy = (G_COMPAT_MODE) ? 1'b0 : preload_g_busy_int;
    assign preload_g_done = (G_COMPAT_MODE) ? 1'b1 : preload_g_done_int;
    assign g_play_busy    = (G_COMPAT_MODE) ? 1'b0 : g_play_busy_int;
    assign g_play_done    = (G_COMPAT_MODE) ? 1'b1 : g_play_done_int;

    assign s_axis_g_tready = (G_COMPAT_MODE) ? 1'b0 : s_axis_g_tready_loader;

    assign core_g_tvalid = (G_COMPAT_MODE) ? 1'b1 : g_loader_axis_tvalid;
    assign core_g_tdata  = (G_COMPAT_MODE) ? {TILE_SIZE*DATA_WIDTH{1'b0}} : g_loader_axis_tdata;
    assign g_loader_axis_tready = (G_COMPAT_MODE) ? 1'b0 : core_g_tready;

//调试代码结束

    reg h_preloaded;
    reg g_preloaded;

    always @(posedge sys_clk) begin
        if (!rst_n_int) begin
            g_load_start_pulse     <= 1'b0;
            g_play_start_pulse     <= 1'b0;
            core_block_start_pulse <= 1'b0;
            run_pending            <= 1'b0;
            
            h_preloaded            <= 1'b0;
            g_preloaded            <= 1'b0;
        end else begin
            g_load_start_pulse     <= 1'b0;
            g_play_start_pulse     <= 1'b0;
            core_block_start_pulse <= 1'b0;

            // h preload完成后，锁存成状态
            if (preload_h_start_pulse)
                h_preloaded <= 1'b0;
            else if (preload_h_done)
                h_preloaded <= 1'b1;

            // g load完成后，锁存成状态
            // if (core_start_pulse)
            //     g_preloaded <= 1'b0;
            // else if (preload_g_done)
            //     g_preloaded <= 1'b1;

            // 先简化成 g 一开始就预取好了调试用
            if (!G_COMPAT_MODE) begin
                if (g_load_start_pulse)
                    g_preloaded <= 1'b0;
                else if (preload_g_done)
                    g_preloaded <= 1'b1;
            end else begin
                g_preloaded <= 1'b1;
            end//调试代码结束

            // 启动一轮运行：要求 h 已经 preload 完成
            if (core_start_pulse && h_preloaded && !run_pending && !preload_g_busy && !g_play_busy && !block_busy) begin
                run_pending        <= 1'b1;
                g_load_start_pulse <= 1'b1;
            end

            // g 预取完成后，再开始真正喂 core
            if (run_pending && g_preloaded) begin
                run_pending            <= 1'b0;
                g_play_start_pulse     <= 1'b1;
                core_block_start_pulse <= 1'b1;
            end
        end
    end

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
        .sys_clk         (sys_clk),
        .ext_reset_n     (rst_n_int),
        .core_rst_n_o    (core_rst_n_o),
        .block_auto_mode (block_auto_mode),
        .block_start     (core_block_start_pulse),
        .block_busy      (block_busy),
        .block_done      (block_done),
        .s_axis_tvalid   (core_block_start_pulse),
        .s_axis_tready   (),
        .g_axis_tvalid   (core_g_tvalid),
        .g_axis_tready   (core_g_tready),
        .g_axis_tdata    (core_g_tdata),
        .y_axis_tvalid   (m_axis_y_tvalid),
        .y_axis_tready   (m_axis_y_tready),
        .y_axis_tdata    (m_axis_y_tdata),
        .inproj_enable   (1'b1),
        .inproj_start    (core_block_start_pulse),
        .inproj_busy     (inproj_busy),
        .inproj_done     (inproj_done),
        .h_wr_en         (h_wr_en),
        .h_wr_addr       (h_wr_addr),
        .h_wr_data       (h_wr_data_flat),
        .u_rd_en         (1'b0),
        .u_rd_addr       (0),
        .u_rd_data       (u_rd_data_flat),
        .z_rd_en         (1'b0),
        .z_rd_addr       (0),
        .z_rd_data       (z_rd_data_flat),
        .outproj_enable  (1'b1),
        .outproj_busy    (outproj_busy)
    );
endmodule
