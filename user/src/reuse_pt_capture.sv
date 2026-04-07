`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: reuse_pt_capture
// Function:
//   Capture the current SSM core output stream (treated as p_t)
//   into a tile SRAM for later out_proj GEMV.
//---------------------------------------------------------------
module reuse_pt_capture #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int DEPTH      = 64,
    parameter int ADDR_W     = $clog2(DEPTH)
)(
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    input  logic start,
    output logic busy,
    output logic done,

    input  logic                         s_axis_TVALID,
    output logic                         s_axis_TREADY,
    input  logic signed [DATA_WIDTH-1:0] s_axis_TDATA [TILE_SIZE-1:0],
    output logic                         p_wr_en,
    output logic [ADDR_W-1:0]            p_wr_addr,
    output logic signed [DATA_WIDTH-1:0] p_wr_data [TILE_SIZE-1:0]
);
    typedef enum logic [1:0] {ST_IDLE, ST_CAP, ST_DONE} st_t;
    st_t st;
    logic [ADDR_W-1:0] wr_addr;
    assign busy = (st != ST_IDLE && st != ST_DONE);
    assign done = (st == ST_DONE);
    assign s_axis_TREADY = enable && (st == ST_CAP);
    assign p_wr_en   = s_axis_TVALID && s_axis_TREADY;
    assign p_wr_addr = wr_addr;
    assign p_wr_data = s_axis_TDATA;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            st <= ST_IDLE;
            wr_addr <= '0;
        end else begin
            case (st)
                ST_IDLE: begin
                    wr_addr <= '0;
                    if (enable && start)
                        st <= ST_CAP;
                end
                ST_CAP: begin
                    if (p_wr_en) begin
                        if (wr_addr == DEPTH-1)
                            st <= ST_DONE;
                        wr_addr <= wr_addr + 1'b1;
                    end
                end
                ST_DONE: begin
                    if (!start)
                        st <= ST_IDLE;
                end
                default: st <= ST_IDLE;
            endcase
        end
    end
endmodule
