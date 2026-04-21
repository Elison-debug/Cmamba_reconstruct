`timescale 1ns/1ps
module reuse_mamba_axi_lite_regs #(
    parameter int ADDR_W = 12
) (
    input  logic         clk,
    input  logic         rst_n,

    input  logic [ADDR_W-1:0] s_axi_awaddr,
    input  logic              s_axi_awvalid,
    output logic              s_axi_awready,
    input  logic [31:0]       s_axi_wdata,
    input  logic [3:0]        s_axi_wstrb,
    input  logic              s_axi_wvalid,
    output logic              s_axi_wready,
    output logic [1:0]        s_axi_bresp,
    output logic              s_axi_bvalid,
    input  logic              s_axi_bready,

    input  logic [ADDR_W-1:0] s_axi_araddr,
    input  logic              s_axi_arvalid,
    output logic              s_axi_arready,
    output logic [31:0]       s_axi_rdata,
    output logic [1:0]        s_axi_rresp,
    output logic              s_axi_rvalid,
    input  logic              s_axi_rready,

    input  logic              block_busy,
    input  logic              block_done,
    input  logic              preload_h_busy,
    input  logic              preload_h_done,
    input  logic              dma_error,

    output logic              soft_reset_pulse,
    output logic              start_pulse,
    output logic              block_auto_mode,
    output logic              preload_h_start_pulse,
    output logic [15:0]       h_rows_cfg,
    output logic [15:0]       y_rows_cfg,
    output logic [31:0]       irq_enable,

    output logic [63:0]       h_src_addr,
    output logic [63:0]       g_src_addr,
    output logic [63:0]       y_dst_addr,
    output logic [63:0]       inproj_w_addr,
    output logic [63:0]       dt_w_addr,
    output logic [63:0]       outproj_w_addr
);
    localparam logic [ADDR_W-1:0] REG_CTRL            = 12'h000;
    localparam logic [ADDR_W-1:0] REG_STATUS          = 12'h004;
    localparam logic [ADDR_W-1:0] REG_H_SRC_L         = 12'h010;
    localparam logic [ADDR_W-1:0] REG_H_SRC_H         = 12'h014;
    localparam logic [ADDR_W-1:0] REG_G_SRC_L         = 12'h018;
    localparam logic [ADDR_W-1:0] REG_G_SRC_H         = 12'h01C;
    localparam logic [ADDR_W-1:0] REG_Y_DST_L         = 12'h020;
    localparam logic [ADDR_W-1:0] REG_Y_DST_H         = 12'h024;
    localparam logic [ADDR_W-1:0] REG_INPROJ_W_L      = 12'h028;
    localparam logic [ADDR_W-1:0] REG_INPROJ_W_H      = 12'h02C;
    localparam logic [ADDR_W-1:0] REG_DT_W_L          = 12'h030;
    localparam logic [ADDR_W-1:0] REG_DT_W_H          = 12'h034;
    localparam logic [ADDR_W-1:0] REG_OUTPROJ_W_L     = 12'h038;
    localparam logic [ADDR_W-1:0] REG_OUTPROJ_W_H     = 12'h03C;
    localparam logic [ADDR_W-1:0] REG_H_ROWS          = 12'h040;
    localparam logic [ADDR_W-1:0] REG_Y_ROWS          = 12'h044;
    localparam logic [ADDR_W-1:0] REG_IRQ_ENABLE      = 12'h048;
    localparam logic [ADDR_W-1:0] REG_VERSION         = 12'h0FC;

    logic [ADDR_W-1:0] awaddr_q;
    logic              awaddr_valid_q;
    logic [31:0]       wdata_q;
    logic [3:0]        wstrb_q;
    logic              wdata_valid_q;
    logic [ADDR_W-1:0] araddr_q;
    logic [31:0]       reg_tmp32;
    logic              wr_fire;
    logic              rd_fire;

    assign s_axi_bresp = 2'b00;
    assign s_axi_rresp = 2'b00;

    // Single-outstanding AXI4-Lite slave.
    // Accept AW and W independently, then commit write once both are captured.
    assign s_axi_awready = (~awaddr_valid_q) && (~s_axi_bvalid);
    assign s_axi_wready  = (~wdata_valid_q)  && (~s_axi_bvalid);
    assign s_axi_arready = (~s_axi_rvalid);

    assign wr_fire = awaddr_valid_q && wdata_valid_q && (~s_axi_bvalid);
    assign rd_fire = s_axi_arvalid && s_axi_arready;

    function automatic [31:0] apply_wstrb(
        input [31:0] oldv,
        input [31:0] newv,
        input [3:0]  wstrb
    );
        apply_wstrb = oldv;
        for (int i = 0; i < 4; i++) begin
            if (wstrb[i])
                apply_wstrb[i*8 +: 8] = newv[i*8 +: 8];
        end
    endfunction

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            s_axi_bvalid          <= 1'b0;
            s_axi_rvalid          <= 1'b0;
            s_axi_rdata           <= '0;
            awaddr_q              <= '0;
            awaddr_valid_q        <= 1'b0;
            wdata_q               <= '0;
            wstrb_q               <= '0;
            wdata_valid_q         <= 1'b0;
            araddr_q              <= '0;
            soft_reset_pulse      <= 1'b0;
            start_pulse           <= 1'b0;
            preload_h_start_pulse <= 1'b0;
            block_auto_mode       <= 1'b1;
            h_rows_cfg            <= 16'd32;
            y_rows_cfg            <= 16'd32;
            irq_enable            <= '0;
            h_src_addr            <= '0;
            g_src_addr            <= '0;
            y_dst_addr            <= '0;
            inproj_w_addr         <= '0;
            dt_w_addr             <= '0;
            outproj_w_addr        <= '0;
        end else begin
            soft_reset_pulse      <= 1'b0;
            start_pulse           <= 1'b0;
            preload_h_start_pulse <= 1'b0;

            // Capture write address/data independently.
            if (s_axi_awvalid && s_axi_awready) begin
                awaddr_q       <= s_axi_awaddr;
                awaddr_valid_q <= 1'b1;
            end
            if (s_axi_wvalid && s_axi_wready) begin
                wdata_q        <= s_axi_wdata;
                wstrb_q        <= s_axi_wstrb;
                wdata_valid_q  <= 1'b1;
            end

            if (wr_fire) begin
                unique case (awaddr_q)
                    REG_CTRL: begin
                        reg_tmp32 = apply_wstrb({30'd0, block_auto_mode,1'b0}, wdata_q, wstrb_q);
                        block_auto_mode <= !reg_tmp32[1];
                        if (wdata_q[0]) start_pulse <= 1'b1;
                        if (wdata_q[2]) preload_h_start_pulse <= 1'b1;
                        if (wdata_q[3]) soft_reset_pulse <= 1'b1;
                    end
                    REG_H_SRC_L:      h_src_addr[31:0]      <= apply_wstrb(h_src_addr[31:0],      wdata_q, wstrb_q);
                    REG_H_SRC_H:      h_src_addr[63:32]     <= apply_wstrb(h_src_addr[63:32],     wdata_q, wstrb_q);
                    REG_G_SRC_L:      g_src_addr[31:0]      <= apply_wstrb(g_src_addr[31:0],      wdata_q, wstrb_q);
                    REG_G_SRC_H:      g_src_addr[63:32]     <= apply_wstrb(g_src_addr[63:32],     wdata_q, wstrb_q);
                    REG_Y_DST_L:      y_dst_addr[31:0]      <= apply_wstrb(y_dst_addr[31:0],      wdata_q, wstrb_q);
                    REG_Y_DST_H:      y_dst_addr[63:32]     <= apply_wstrb(y_dst_addr[63:32],     wdata_q, wstrb_q);
                    REG_INPROJ_W_L:   inproj_w_addr[31:0]   <= apply_wstrb(inproj_w_addr[31:0],   wdata_q, wstrb_q);
                    REG_INPROJ_W_H:   inproj_w_addr[63:32]  <= apply_wstrb(inproj_w_addr[63:32],  wdata_q, wstrb_q);
                    REG_DT_W_L:       dt_w_addr[31:0]       <= apply_wstrb(dt_w_addr[31:0],       wdata_q, wstrb_q);
                    REG_DT_W_H:       dt_w_addr[63:32]      <= apply_wstrb(dt_w_addr[63:32],      wdata_q, wstrb_q);
                    REG_OUTPROJ_W_L:  outproj_w_addr[31:0]  <= apply_wstrb(outproj_w_addr[31:0],  wdata_q, wstrb_q);
                    REG_OUTPROJ_W_H:  outproj_w_addr[63:32] <= apply_wstrb(outproj_w_addr[63:32], wdata_q, wstrb_q);
                    REG_H_ROWS: begin
                        reg_tmp32 = apply_wstrb({16'd0, h_rows_cfg}, wdata_q, wstrb_q);
                        h_rows_cfg <= reg_tmp32[15:0];
                    end
                    REG_Y_ROWS: begin
                        reg_tmp32 = apply_wstrb({16'd0, y_rows_cfg}, wdata_q, wstrb_q);
                        y_rows_cfg <= reg_tmp32[15:0];
                    end
                    REG_IRQ_ENABLE:   irq_enable            <= apply_wstrb(irq_enable,             wdata_q, wstrb_q);
                    default: ;
                endcase
                s_axi_bvalid   <= 1'b1;
                awaddr_valid_q <= 1'b0;
                wdata_valid_q  <= 1'b0;
            end else if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end

            if (rd_fire) begin
                araddr_q <= s_axi_araddr;
                unique case (s_axi_araddr)
                    REG_CTRL:        s_axi_rdata <= {28'd0, 1'b0, 1'b0, block_auto_mode, 1'b0};
                    REG_STATUS:      s_axi_rdata <= {27'd0, dma_error, preload_h_done, preload_h_busy, block_done, block_busy};
                    REG_H_SRC_L:     s_axi_rdata <= h_src_addr[31:0];
                    REG_H_SRC_H:     s_axi_rdata <= h_src_addr[63:32];
                    REG_G_SRC_L:     s_axi_rdata <= g_src_addr[31:0];
                    REG_G_SRC_H:     s_axi_rdata <= g_src_addr[63:32];
                    REG_Y_DST_L:     s_axi_rdata <= y_dst_addr[31:0];
                    REG_Y_DST_H:     s_axi_rdata <= y_dst_addr[63:32];
                    REG_INPROJ_W_L:  s_axi_rdata <= inproj_w_addr[31:0];
                    REG_INPROJ_W_H:  s_axi_rdata <= inproj_w_addr[63:32];
                    REG_DT_W_L:      s_axi_rdata <= dt_w_addr[31:0];
                    REG_DT_W_H:      s_axi_rdata <= dt_w_addr[63:32];
                    REG_OUTPROJ_W_L: s_axi_rdata <= outproj_w_addr[31:0];
                    REG_OUTPROJ_W_H: s_axi_rdata <= outproj_w_addr[63:32];
                    REG_H_ROWS:      s_axi_rdata <= {16'd0, h_rows_cfg};
                    REG_Y_ROWS:      s_axi_rdata <= {16'd0, y_rows_cfg};
                    REG_IRQ_ENABLE:  s_axi_rdata <= irq_enable;
                    REG_VERSION:     s_axi_rdata <= 32'h4D414201; // "MAB" v1
                    default:         s_axi_rdata <= 32'h0;
                endcase
                s_axi_rvalid <= 1'b1;
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end
endmodule
