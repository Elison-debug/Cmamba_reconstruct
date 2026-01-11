module vec_fifo_axis_ip #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16
)(
    input  logic clk,
    input  logic rst_n,

    // Upstream (from bias)
    input  logic in_valid,
    output logic in_ready,
    input  logic signed [DATA_WIDTH-1:0] in_vec [TILE_SIZE-1:0],

    // Downstream (to sigmoid)
    output logic out_valid,
    input  logic out_ready,
    output logic signed [DATA_WIDTH-1:0] out_vec [TILE_SIZE-1:0]
);

    // ---------------- Pack / Unpack ----------------
    logic [63:0] s_tdata;
    logic [63:0] m_tdata;

    always_comb begin
        s_tdata[15:0]   = in_vec[0];
        s_tdata[31:16]  = in_vec[1];
        s_tdata[47:32]  = in_vec[2];
        s_tdata[63:48]  = in_vec[3];
    end

    always_comb begin
        out_vec[0] = m_tdata[15:0];
        out_vec[1] = m_tdata[31:16];
        out_vec[2] = m_tdata[47:32];
        out_vec[3] = m_tdata[63:48];
    end

    // ---------------- AXI Stream ----------------
    // assign in_ready  = s_axis_tready;
    // assign s_axis_tvalid = in_valid;

    // assign out_valid = m_axis_tvalid;
    // assign m_axis_tready = out_ready;

    // ---------------- FIFO IP ----------------
    bias2sigmoid_fifo u_fifo (
        .s_aclk        (clk),
        .s_aresetn     (rst_n),

        .s_axis_tvalid (in_valid),
        .s_axis_tready (in_ready),
        .s_axis_tdata  (s_tdata),

        .m_axis_tvalid (out_valid),
        .m_axis_tready (out_ready),
        .m_axis_tdata  (m_tdata)
    );

endmodule
