`timescale 1ns/1ps
//---------------------------------------------------------------
// Stream-first shell (no legacy g/debug path).
// Flow: load one H frame -> run core -> stream Y -> repeat.
//---------------------------------------------------------------
module reuse_mamba_board_shell_stream #(
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
    parameter integer S_ADDR_W    = 6,
    parameter integer G_FRAC_BITS = 8,
    parameter         INTER_BLOCK_PIPELINE = 1'b1,
    parameter integer H_ROWS      = 32
) (
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME sys_clk, ASSOCIATED_BUSIF s_axis_h:m_axis_y, ASSOCIATED_RESET ext_reset_n, FREQ_HZ 99990005" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 sys_clk CLK" *)
    input  wire                           sys_clk,
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ext_reset_n, POLARITY ACTIVE_LOW" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ext_reset_n RST" *)
    input  wire                           ext_reset_n,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_h TVALID" *)
    input  wire                           s_axis_h_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_h TREADY" *)
    output wire                           s_axis_h_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_h TDATA" *)
    input  wire [TILE_SIZE*DATA_WIDTH-1:0] s_axis_h_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_h TLAST" *)
    input  wire                           s_axis_h_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_y TVALID" *)
    output wire                           m_axis_y_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_y TREADY" *)
    input  wire                           m_axis_y_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_y TDATA" *)
    output wire [TILE_SIZE*DATA_WIDTH-1:0] m_axis_y_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_y TLAST" *)
    output wire                           m_axis_y_tlast,
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME frame_busy, SENSITIVITY LEVEL_HIGH" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 frame_busy INTERRUPT" *)
    output wire                           frame_busy
);
    localparam integer H_ADDR_W = 5;
    localparam [15:0] H_ROWS_CFG = H_ROWS[15:0];

    reg  [1:0]                     rst_sync_ff;
    wire                           rst_n_int;
    wire                           preload_h_busy;
    wire                           preload_h_done;
    wire                           h_wr_en;
    wire [H_ADDR_W-1:0]            h_wr_addr;
    wire signed [TILE_SIZE*DATA_WIDTH-1:0] h_wr_data_flat;

    reg                            preload_h_start_pulse;
    reg                            core_start_pulse;
    reg [15:0]                     y_row_cnt;
    reg                            frame_loaded;
    reg                            core_started;
    reg [1:0]                      ctrl_state;
    wire                           core_busy;
    wire                           core_done;
    wire                           core_rst_n_o;
    wire                           y_fire;
    wire                           y_last_int;
    wire [15:0]                    h_rows_safe;

    always @(posedge sys_clk) begin
        if (!ext_reset_n)
            rst_sync_ff <= 2'b00;
        else
            rst_sync_ff <= {rst_sync_ff[0], 1'b1};
    end

    assign rst_n_int    = rst_sync_ff[1];
    assign frame_busy   = preload_h_busy | core_busy;
    assign h_rows_safe  = (H_ROWS_CFG == 16'd0) ? 16'd1 : H_ROWS_CFG;
    assign y_fire       = m_axis_y_tvalid & m_axis_y_tready;
    assign y_last_int   = m_axis_y_tvalid && (y_row_cnt == (h_rows_safe - 16'd1));
    assign m_axis_y_tlast = y_last_int;

    reuse_mamba_h_stream_loader #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .H_ADDR_W  (H_ADDR_W)
    ) u_h_loader (
        .clk          (sys_clk),
        .rst_n        (rst_n_int),
        .start        (preload_h_start_pulse),
        .rows_cfg     (H_ROWS_CFG),
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

    localparam [1:0] ST_LOAD_REQ   = 2'd0;
    localparam [1:0] ST_LOAD_WAIT  = 2'd1;
    localparam [1:0] ST_RUN_REQ    = 2'd2;
    localparam [1:0] ST_RUN_WAIT   = 2'd3;

    always @(posedge sys_clk) begin
        if (!rst_n_int) begin
            preload_h_start_pulse <= 1'b0;
            core_start_pulse      <= 1'b0;
            y_row_cnt             <= 16'd0;
            frame_loaded          <= 1'b0;
            core_started          <= 1'b0;
            ctrl_state            <= ST_LOAD_REQ;
        end else begin
            preload_h_start_pulse <= 1'b0;
            core_start_pulse      <= 1'b0;

            case (ctrl_state)
                ST_LOAD_REQ: begin
                    if (!preload_h_busy && !core_busy) begin
                        preload_h_start_pulse <= 1'b1;
                        ctrl_state <= ST_LOAD_WAIT;
                    end
                end

                ST_LOAD_WAIT: begin
                    if (preload_h_done) begin
                        frame_loaded <= 1'b1;
                        ctrl_state <= ST_RUN_REQ;
                    end
                end

                ST_RUN_REQ: begin
                    // Intentional 1-cycle separation from LOAD done event.
                    if (frame_loaded && !core_busy) begin
                        core_start_pulse <= 1'b1;
                        frame_loaded <= 1'b0;
                        core_started <= 1'b1;
                        y_row_cnt <= 16'd0;
                        ctrl_state <= ST_RUN_WAIT;
                    end
                end

                ST_RUN_WAIT: begin
                    if (y_fire) begin
                        if (y_row_cnt == (h_rows_safe - 16'd1))
                            y_row_cnt <= 16'd0;
                        else
                            y_row_cnt <= y_row_cnt + 16'd1;
                    end

                    if (core_started && core_done) begin
                        core_started <= 1'b0;
                        ctrl_state <= ST_LOAD_REQ;
                    end
                end

                default: begin
                    ctrl_state <= ST_LOAD_REQ;
                end
            endcase
        end
    end

    reuse_mamba_chain4_core_adapter #(
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
        .S_ADDR_W    (S_ADDR_W),
        .G_FRAC_BITS (G_FRAC_BITS)
        ,.INTER_BLOCK_PIPELINE(INTER_BLOCK_PIPELINE)
    ) u_core (
        .sys_clk       (sys_clk),
        .ext_reset_n   (rst_n_int),
        .core_rst_n_o  (core_rst_n_o),
        .start         (core_start_pulse),
        .busy          (core_busy),
        .done          (core_done),
        .h_wr_en       (h_wr_en),
        .h_wr_addr     (h_wr_addr),
        .h_wr_data     (h_wr_data_flat),
        .y_axis_tvalid (m_axis_y_tvalid),
        .y_axis_tready (m_axis_y_tready),
        .y_axis_tdata  (m_axis_y_tdata)
    );
endmodule
