module bias2sigmoid_fifo (
  input  wire        s_aclk,
  input  wire        s_aresetn,
  input  wire        s_axis_tvalid,
  output wire        s_axis_tready,
  input  wire [63:0] s_axis_tdata,
  output wire        m_axis_tvalid,
  input  wire        m_axis_tready,
  output wire [63:0] m_axis_tdata
);
  localparam integer DEPTH = 16;
  localparam integer PTR_W = 4;

  reg [63:0] mem [0:DEPTH-1];
  reg [PTR_W-1:0] wr_ptr;
  reg [PTR_W-1:0] rd_ptr;
  reg [PTR_W:0] count;

  wire push = s_axis_tvalid && s_axis_tready;
  wire pop  = m_axis_tvalid && m_axis_tready;

  assign s_axis_tready = (count < DEPTH);
  assign m_axis_tvalid = (count != 0);
  assign m_axis_tdata  = mem[rd_ptr];

  always @(posedge s_aclk) begin
    if (!s_aresetn) begin
      wr_ptr <= {PTR_W{1'b0}};
      rd_ptr <= {PTR_W{1'b0}};
      count  <= {(PTR_W+1){1'b0}};
    end else begin
      if (push)
        mem[wr_ptr] <= s_axis_tdata;

      case ({push, pop})
        2'b10: begin
          wr_ptr <= wr_ptr + 1'b1;
          count  <= count + 1'b1;
        end
        2'b01: begin
          rd_ptr <= rd_ptr + 1'b1;
          count  <= count - 1'b1;
        end
        2'b11: begin
          wr_ptr <= wr_ptr + 1'b1;
          rd_ptr <= rd_ptr + 1'b1;
        end
        default: begin
        end
      endcase
    end
  end
endmodule
