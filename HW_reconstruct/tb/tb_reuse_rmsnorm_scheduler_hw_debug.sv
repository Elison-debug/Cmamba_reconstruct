`timescale 1ns/1ps
module tb_reuse_rmsnorm_scheduler_hw_debug;
  `include "tb_hw_debug_case_path.svh"

  `ifndef HW_DEBUG_CASE_DIR
    `define HW_DEBUG_CASE_DIR ""
  `endif

  localparam int TILE_SIZE  = 4;
  localparam int DATA_WIDTH = 16;
  localparam int H_DEPTH    = 32;
  localparam int H_ADDR_W   = 5;

  reg clk;
  reg rst_n;
  reg enable;
  reg start;
  wire busy;
  wire done;
  reg                         h_wr_en;
  reg [H_ADDR_W-1:0]          h_wr_addr;
  reg signed [DATA_WIDTH-1:0] h_wr_data [TILE_SIZE-1:0];
  reg                         gamma_wr_en;
  reg [H_ADDR_W-1:0]          gamma_wr_addr;
  reg signed [DATA_WIDTH-1:0] gamma_wr_data [TILE_SIZE-1:0];
  wire                        norm_wr_en;
  wire [H_ADDR_W-1:0]         norm_wr_addr;
  wire signed [DATA_WIDTH-1:0] norm_wr_data [TILE_SIZE-1:0];

  reg [7:0]  h_addr_mem [0:H_DEPTH-1];
  reg [63:0] h_raw_mem [0:H_DEPTH-1];
  reg [63:0] gamma_mem [0:H_DEPTH-1];
  reg [63:0] h_norm_mem [0:H_DEPTH-1];
  reg [63:0] golden_calc_mem [0:H_DEPTH-1];
  reg [63:0] got_mem [0:H_DEPTH-1];
  integer i;
  integer idx;
  integer addr;
  integer lane;

  string case_dir;
  string stage_dir;

  reuse_rmsnorm_scheduler #(
      .TILE_SIZE (TILE_SIZE),
      .DATA_WIDTH(DATA_WIDTH),
      .H_DEPTH   (H_DEPTH),
      .H_ADDR_W  (H_ADDR_W)
  ) dut (
      .clk        (clk),
      .rst_n      (rst_n),
      .enable     (enable),
      .start      (start),
      .busy       (busy),
      .done       (done),
      .h_wr_en    (h_wr_en),
      .h_wr_addr  (h_wr_addr),
      .h_wr_data  (h_wr_data),
      .gamma_wr_en(gamma_wr_en),
      .gamma_wr_addr(gamma_wr_addr),
      .gamma_wr_data(gamma_wr_data),
      .norm_wr_en (norm_wr_en),
      .norm_wr_addr(norm_wr_addr),
      .norm_wr_data(norm_wr_data)
  );

  initial begin
    clk = 1'b0;
    forever #1 clk = ~clk;
  end

  function automatic string join_path(input string a, input string b);
    begin
      join_path = {a, "/", b};
    end
  endfunction

  function automatic signed [15:0] unpack_lane64(input [63:0] packed_word, input integer lane);
    begin
      unpack_lane64 = $signed(packed_word[lane*16 +: 16]);
    end
  endfunction

  function automatic [63:0] pack4x16(
      input signed [15:0] v0,
      input signed [15:0] v1,
      input signed [15:0] v2,
      input signed [15:0] v3
  );
    begin
      pack4x16 = {v3[15:0], v2[15:0], v1[15:0], v0[15:0]};
    end
  endfunction

  function automatic [63:0] isqrt_u64(input [63:0] x_in);
    reg [63:0] x;
    reg [63:0] res;
    reg [63:0] step;
    begin
      x = x_in;
      res = 0;
      step = 64'h4000_0000_0000_0000;
      while (step > x)
        step = step >> 2;
      while (step != 0) begin
        if (x >= (res + step)) begin
          x = x - (res + step);
          res = (res >> 1) + step;
        end else begin
          res = res >> 1;
        end
        step = step >> 2;
      end
      isqrt_u64 = res;
    end
  endfunction

  function automatic signed [15:0] clamp_s16(input signed [63:0] x);
    begin
      if (x > 32767)
        clamp_s16 = 16'sd32767;
      else if (x < -32768)
        clamp_s16 = -16'sd32768;
      else
        clamp_s16 = x[15:0];
    end
  endfunction

  function automatic signed [63:0] div_round_nearest_signed(
      input signed [63:0] num,
      input [31:0] den
  );
    reg [63:0] abs_num;
    begin
      if (den == 0)
        div_round_nearest_signed = 0;
      else if (num >= 0)
        div_round_nearest_signed = (num + $signed({32'd0, (den >> 1)})) / $signed({32'd0, den});
      else begin
        abs_num = -num;
        div_round_nearest_signed = -$signed((abs_num + (den >> 1)) / den);
      end
    end
  endfunction

  task automatic load_case_files();
    string case_dir_macro;
    begin
      case_dir_macro = `HW_DEBUG_CASE_DIR;
      if (!$value$plusargs("CASE_DIR=%s", case_dir))
        case_dir = case_dir_macro;
      if (case_dir == "") begin
        $fatal(1, "CASE_DIR not provided and HW_DEBUG_CASE_DIR empty");
      end
      stage_dir = join_path(join_path(case_dir, "stages"), "reuse_rmsnorm_scheduler");
      $display("[TB] stage_dir=%0s", stage_dir);
      $readmemh(join_path(stage_dir, "h_wr_addr.mem"), h_addr_mem);
      $readmemh(join_path(stage_dir, "h_raw_wr_data_q88.mem"), h_raw_mem);
      $readmemh(join_path(stage_dir, "norm_weight_q88.mem"), gamma_mem);
      $readmemh(join_path(stage_dir, "h_norm_golden_q88.mem"), h_norm_mem);
    end
  endtask

  task automatic compute_golden();
    reg [63:0] sum_sq;
    reg [63:0] mean_sq_q16;
    reg [63:0] rms_q88;
    reg signed [63:0] lane_sq;
    reg signed [15:0] x_lane;
    reg signed [15:0] g_lane;
    reg signed [15:0] y_lane [0:TILE_SIZE-1];
    begin
      sum_sq = 0;
      for (addr = 0; addr < H_DEPTH; addr = addr + 1) begin
        for (lane = 0; lane < TILE_SIZE; lane = lane + 1) begin
          x_lane = unpack_lane64(h_raw_mem[addr], lane);
          lane_sq = x_lane;
          sum_sq = sum_sq + (lane_sq * lane_sq);
        end
      end
      mean_sq_q16 = (sum_sq + ((H_DEPTH * TILE_SIZE) / 2)) / (H_DEPTH * TILE_SIZE);
      rms_q88 = isqrt_u64(mean_sq_q16 + 1);
      if (rms_q88 == 0)
        rms_q88 = 1;
      $display("[TB] computed rms_q88=%0d", rms_q88);
      for (addr = 0; addr < H_DEPTH; addr = addr + 1) begin
        for (lane = 0; lane < TILE_SIZE; lane = lane + 1) begin
          x_lane = unpack_lane64(h_raw_mem[addr], lane);
          g_lane = unpack_lane64(gamma_mem[addr], lane);
          y_lane[lane] = clamp_s16(div_round_nearest_signed($signed(x_lane) * $signed(g_lane), rms_q88[31:0]));
        end
        golden_calc_mem[addr] = pack4x16(y_lane[0], y_lane[1], y_lane[2], y_lane[3]);
      end
    end
  endtask

  initial begin
    rst_n = 1'b0;
    enable = 1'b1;
    start = 1'b0;
    h_wr_en = 1'b0;
    h_wr_addr = '0;
    gamma_wr_en = 1'b0;
    gamma_wr_addr = '0;
    for (i = 0; i < TILE_SIZE; i = i + 1)
      h_wr_data[i] = '0;
    for (i = 0; i < TILE_SIZE; i = i + 1)
      gamma_wr_data[i] = '0;
    for (i = 0; i < H_DEPTH; i = i + 1)
      got_mem[i] = '0;

    load_case_files();
    compute_golden();

    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    for (idx = 0; idx < H_DEPTH; idx = idx + 1) begin
      @(posedge clk);
      gamma_wr_en <= 1'b1;
      gamma_wr_addr <= idx[H_ADDR_W-1:0];
      for (lane = 0; lane < TILE_SIZE; lane = lane + 1)
        gamma_wr_data[lane] <= unpack_lane64(gamma_mem[idx], lane);
    end
    @(posedge clk);
    gamma_wr_en <= 1'b0;

    for (idx = 0; idx < H_DEPTH; idx = idx + 1) begin
      @(posedge clk);
      h_wr_en <= 1'b1;
      h_wr_addr <= h_addr_mem[idx][H_ADDR_W-1:0];
      for (lane = 0; lane < TILE_SIZE; lane = lane + 1)
        h_wr_data[lane] <= unpack_lane64(h_raw_mem[idx], lane);
    end
    @(posedge clk);
    h_wr_en <= 1'b0;

    @(posedge clk);
    start <= 1'b1;
    @(posedge clk);
    start <= 1'b0;

    while (!done) begin
      @(posedge clk);
      if (norm_wr_en) begin
        got_mem[norm_wr_addr] = pack4x16(norm_wr_data[0], norm_wr_data[1], norm_wr_data[2], norm_wr_data[3]);
      end
    end

    for (addr = 0; addr < H_DEPTH; addr = addr + 1) begin
      if (golden_calc_mem[addr] !== h_norm_mem[addr]) begin
        $fatal(1, "golden mem mismatch addr=%0d calc=%h file=%h", addr, golden_calc_mem[addr], h_norm_mem[addr]);
      end
      if (got_mem[addr] !== golden_calc_mem[addr]) begin
        $fatal(1, "RTL mismatch addr=%0d got=%h exp=%h", addr, got_mem[addr], golden_calc_mem[addr]);
      end
    end

    $display("[TB] reuse_rmsnorm_scheduler pass");
    #20;
    $finish;
  end
endmodule
