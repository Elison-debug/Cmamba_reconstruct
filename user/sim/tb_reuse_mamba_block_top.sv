`timescale 1ns/1ps
//======================================================================
// tb_reuse_mamba_block_top.sv
//
// Purpose:
//   Validate the reuse path:
//     h_t -> in_proj -> u_t SRAM -> dt scheduler read path
//
// Scope:
//   - validates in_proj SRAM contents with a deterministic pattern
//   - validates dt scheduler later fetches the same u_t values through the
//     shared SRAM path
//======================================================================
module tb_reuse_mamba_block_top;
  localparam int TILE_SIZE   = 4;
  localparam int DATA_WIDTH  = 16;
  localparam int ACC_WIDTH   = 32;
  localparam int FRAC_BITS   = 8;
  localparam int N_BANK      = 6;
  localparam int WDEPTH      = 683;
  localparam int WADDR_W     = $clog2(WDEPTH);
  localparam int DATA_W      = 256;
  localparam int XT_ADDR_W   = 6;
  localparam int D           = 256;
  localparam int PIPE_LAT    = 4;
  localparam int ADDR_BITS   = 11;
  localparam string LUT_FILE = "D:/Mamba/Cmamba_reconstruct/sigmoid_lut_q016_2048.hex";
  localparam int S_ADDR_W    = 6;
  localparam int G_FRAC_BITS = 8;
  localparam int H_DEPTH     = 32;
  localparam int U_DEPTH     = 64;
  localparam int H_SUM       = (128 * 129) / 2;

  logic clk, rst_n;
  initial begin
    clk = 1'b0;
    forever #1 clk = ~clk;
  end

  initial begin
    rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
  end

  initial begin
    $dumpfile("tb_reuse_mamba_block_top.vcd");
    $dumpvars(0, tb_reuse_mamba_block_top);
  end

  logic                         s_axis_TVALID;
  logic                         s_axis_TREADY;
  logic                         block_auto_mode;
  logic                         block_start;
  logic                         block_busy;
  logic                         block_done;
  logic                         g_axis_TVALID;
  logic                         g_axis_TREADY;
  logic signed [DATA_WIDTH-1:0] g_axis_TDATA [TILE_SIZE-1:0];
  logic                         y_axis_TVALID;
  logic                         y_axis_TREADY;
  logic signed [DATA_WIDTH-1:0] y_axis_TDATA [TILE_SIZE-1:0];

  logic                         inproj_enable;
  logic                         inproj_start;
  logic                         inproj_busy;
  logic                         inproj_done;
  logic                         h_wr_en;
  logic [4:0]                   h_wr_addr;
  logic signed [DATA_WIDTH-1:0] h_wr_data [TILE_SIZE-1:0];
  logic                         u_rd_en;
  logic [5:0]                   u_rd_addr;
  logic signed [DATA_WIDTH-1:0] u_rd_data [TILE_SIZE-1:0];
  logic                         z_rd_en;
  logic [5:0]                   z_rd_addr;
  logic signed [DATA_WIDTH-1:0] z_rd_data [TILE_SIZE-1:0];
  logic                         outproj_enable;
  logic                         outproj_busy;
  logic [TILE_SIZE*DATA_WIDTH-1:0] dbg_dt_u_rd_data;
  logic [TILE_SIZE*DATA_WIDTH-1:0] dbg_xt_axis_tdata;
  logic [TILE_SIZE*DATA_WIDTH-1:0] dbg_xt_fifo_in_vec;

  reuse_mamba_block_top #(
      .TILE_SIZE  (TILE_SIZE),
      .DATA_WIDTH (DATA_WIDTH),
      .ACC_WIDTH  (ACC_WIDTH),
      .FRAC_BITS  (FRAC_BITS),
      .N_BANK     (N_BANK),
      .WDEPTH     (WDEPTH),
      .WADDR_W    (WADDR_W),
      .DATA_W     (DATA_W),
      .XT_ADDR_W  (XT_ADDR_W),
      .D          (D),
      .PIPE_LAT   (PIPE_LAT),
      .ADDR_BITS  (ADDR_BITS),
      .LUT_FILE   (LUT_FILE),
      .S_ADDR_W   (S_ADDR_W),
      .G_FRAC_BITS(G_FRAC_BITS)
  ) dut (
      .clk           (clk),
      .rst_n         (rst_n),
      .block_auto_mode(block_auto_mode),
      .block_start   (block_start),
      .block_busy    (block_busy),
      .block_done    (block_done),
      .s_axis_TVALID (s_axis_TVALID),
      .s_axis_TREADY (s_axis_TREADY),
      .g_axis_TVALID (g_axis_TVALID),
      .g_axis_TREADY (g_axis_TREADY),
      .g_axis_TDATA  (g_axis_TDATA),
      .y_axis_TVALID (y_axis_TVALID),
      .y_axis_TREADY (y_axis_TREADY),
      .y_axis_TDATA  (y_axis_TDATA),
      .inproj_enable (inproj_enable),
      .inproj_start  (inproj_start),
      .inproj_busy   (inproj_busy),
      .inproj_done   (inproj_done),
      .h_wr_en       (h_wr_en),
      .h_wr_addr     (h_wr_addr),
      .h_wr_data     (h_wr_data),
      .u_rd_en       (u_rd_en),
      .u_rd_addr     (u_rd_addr),
      .u_rd_data     (u_rd_data),
      .z_rd_en       (z_rd_en),
      .z_rd_addr     (z_rd_addr),
      .z_rd_data     (z_rd_data),
      .outproj_enable(outproj_enable),
      .outproj_busy  (outproj_busy)
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      y_axis_TREADY <= 1'b1;
    else
      y_axis_TREADY <= 1'b1;
  end

  always_comb begin
    for (int i = 0; i < TILE_SIZE; i++) begin
      dbg_dt_u_rd_data[i*DATA_WIDTH +: DATA_WIDTH] = dut.dt_u_rd_data[i];
      dbg_xt_axis_tdata[i*DATA_WIDTH +: DATA_WIDTH] = dut.xt_d[i];
      dbg_xt_fifo_in_vec[i*DATA_WIDTH +: DATA_WIDTH] = dut.u_dt_sched.xt_fifo_in_vec[i];
    end
  end

  always_comb begin
    g_axis_TVALID = 1'b1;
    for (int i = 0; i < TILE_SIZE; i++)
      g_axis_TDATA[i] = '0;
  end

  task automatic init_dt_wbuf_pattern();
    logic [DATA_W-1:0] line_i;
    int tile_id_i;
    int element_id_i;
    int val_i;
    begin
      for (int b = 0; b < N_BANK; b++) begin
        for (int addr = 0; addr < WDEPTH; addr++)
        begin
          line_i = '0;
          tile_id_i = b + addr * N_BANK;
          for (int w = 0; w < 16; w++) begin
            element_id_i = tile_id_i * 16 + w;
            val_i = 1 + element_id_i;
            line_i[w*DATA_WIDTH +: DATA_WIDTH] = val_i[DATA_WIDTH-1:0];
          end
          dut.u_dt_sched.u_wbuf.mem_sim[b][addr] = line_i;
        end
      end
    end
  endtask

  task automatic init_inproj_wbuf_pattern();
    logic [DATA_W-1:0] line_i;
    int tile_id_i;
    int row_tile_i;
    int col_tile_i;
    int val_i;
    begin
      for (int b = 0; b < N_BANK; b++) begin
        for (int addr = 0; addr < WDEPTH; addr++) begin
          line_i = '0;
          tile_id_i = b + addr * N_BANK;
          row_tile_i = tile_id_i / 32;
          col_tile_i = tile_id_i % 32;
          for (int r = 0; r < TILE_SIZE; r++) begin
            val_i = (row_tile_i * TILE_SIZE + r + 1) * (col_tile_i + 1);
            for (int c = 0; c < TILE_SIZE; c++)
              line_i[(r*TILE_SIZE+c)*DATA_WIDTH +: DATA_WIDTH] = val_i[DATA_WIDTH-1:0];
          end
          dut.u_in_proj.u_w_sram.u_weight.mem_sim[b][addr] = line_i;
        end
      end
    end
  endtask

  task automatic write_h_vector();
    begin
      for (int addr = 0; addr < H_DEPTH; addr++) begin
        @(posedge clk);
        h_wr_en   <= 1'b1;
        h_wr_addr <= addr[4:0];
        for (int lane = 0; lane < TILE_SIZE; lane++)
          h_wr_data[lane] <= (addr * TILE_SIZE + lane + 1);
      end
      @(posedge clk);
      h_wr_en <= 1'b0;
      h_wr_addr <= '0;
      for (int lane = 0; lane < TILE_SIZE; lane++)
        h_wr_data[lane] <= '0;
    end
  endtask

  function automatic logic signed [DATA_WIDTH-1:0] expected_u_lane_val(
      input int row_tile_idx,
      input int lane_idx
  );
    int value_i;
    int base_i;
    int h_tile_idx;
    int h_sum_i;
    begin
      base_i = row_tile_idx * TILE_SIZE + lane_idx + 1;
      h_tile_idx = row_tile_idx % H_DEPTH;
      h_sum_i = 16 * h_tile_idx + 10;
      value_i = base_i * h_sum_i * 528;
      expected_u_lane_val = $signed(value_i >>> FRAC_BITS);
    end
  endfunction

  task automatic check_inproj_u_mem();
    logic signed [DATA_WIDTH-1:0] exp_val;
    int match_count;
    begin
      match_count = 0;
      for (int addr = 0; addr < U_DEPTH; addr++) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          exp_val = expected_u_lane_val(addr, lane);
          if ($signed(dut.u_in_proj.u_u_sram.mem_sim[addr][lane*DATA_WIDTH +: DATA_WIDTH]) !== exp_val) begin
            $error("[%0t] block_top u_t mismatch addr=%0d lane=%0d got=%0d exp=%0d",
                   $time, addr, lane,
                   $signed(dut.u_in_proj.u_u_sram.mem_sim[addr][lane*DATA_WIDTH +: DATA_WIDTH]),
                   $signed(exp_val));
          end else begin
            match_count++;
          end
        end
      end
      $display("[%0t] MATCH reuse_mamba_block_top in_proj u_t checked %0d lanes", $time, match_count);
    end
  endtask

  task automatic start_block();
    begin
      @(posedge clk);
      block_start  <= 1'b1;
      @(posedge clk);
      block_start  <= 1'b0;
    end
  endtask

  int req_addr_q[$];
  int rd_checks;
  int rd_errors;
  int req_count;
  logic [TILE_SIZE*DATA_WIDTH-1:0] xt_cmp_q[$];
  int xt_cmp_checks;
  int xt_cmp_errors;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      req_addr_q.delete();
      rd_checks <= 0;
      rd_errors <= 0;
      req_count <= 0;
      xt_cmp_q.delete();
      xt_cmp_checks <= 0;
      xt_cmp_errors <= 0;
    end else begin
      if (dut.dt_u_rd_en) begin
        req_addr_q.push_back(dut.dt_u_rd_addr);
        req_count <= req_count + 1;
        $display("[%0t] dt requests u SRAM addr %0d", $time, dut.dt_u_rd_addr);
      end

      if (dut.u_dt_sched.xt_en_reg_d1) begin
        int exp_addr;
        logic [TILE_SIZE*DATA_WIDTH-1:0] exp_pack;

        if (req_addr_q.size() == 0) begin
          rd_errors <= rd_errors + 1;
          $error("[%0t] xt_en_reg_d1 fired with empty read queue", $time);
        end else begin
          exp_addr = req_addr_q.pop_front();
          exp_pack = dut.u_in_proj.u_u_sram.mem_sim[exp_addr];
          rd_checks <= rd_checks + 1;
          for (int i = 0; i < TILE_SIZE; i++) begin
            logic signed [DATA_WIDTH-1:0] exp_lane;
            exp_lane = exp_pack[i*DATA_WIDTH +: DATA_WIDTH];
            if (dut.dt_u_rd_data[i] !== exp_lane) begin
              rd_errors <= rd_errors + 1;
              $error("[%0t] u SRAM read mismatch addr=%0d lane=%0d got=%0d exp=%0d",
                     $time, exp_addr, i, $signed(dut.dt_u_rd_data[i]), $signed(exp_lane));
            end
          end
        end
      end

      if (dut.u_dt_sched.xt_fifo_in_valid)
        xt_cmp_q.push_back(dbg_xt_fifo_in_vec);

      if (dut.xt_v && dut.xt_r_int) begin
        logic [TILE_SIZE*DATA_WIDTH-1:0] exp_xt_pack;
        xt_cmp_checks <= xt_cmp_checks + 1;
        if (xt_cmp_q.size() == 0) begin
          xt_cmp_errors <= xt_cmp_errors + 1;
          $error("[%0t] xt stream fired with empty expected queue", $time);
        end else begin
          exp_xt_pack = xt_cmp_q.pop_front();
          if (dbg_xt_axis_tdata !== exp_xt_pack) begin
            xt_cmp_errors <= xt_cmp_errors + 1;
            $error("[%0t] xt stream mismatch got=%h exp=%h",
                   $time, dbg_xt_axis_tdata, exp_xt_pack);
          end
        end
      end
    end
  end

  integer nonzero_u_tiles;
  initial begin
    s_axis_TVALID  = 1'b0;
    block_auto_mode = 1'b1;
    block_start    = 1'b0;
    inproj_enable  = 1'b1;
    inproj_start   = 1'b0;
    h_wr_en        = 1'b0;
    h_wr_addr      = '0;
    u_rd_en        = 1'b0;
    u_rd_addr      = '0;
    z_rd_en        = 1'b0;
    z_rd_addr      = '0;
    outproj_enable = 1'b0;
    for (int i = 0; i < TILE_SIZE; i++)
      h_wr_data[i] = '0;

    wait(rst_n);
    repeat (5) @(posedge clk);

    $display("[%0t] init weight memories", $time);
    init_dt_wbuf_pattern();
    init_inproj_wbuf_pattern();

    $display("[%0t] write h_t SRAM", $time);
    write_h_vector();

    $display("[%0t] start block auto sequence", $time);
    start_block();
    wait(inproj_done);
    @(posedge clk);

    nonzero_u_tiles = 0;
    for (int addr = 0; addr < U_DEPTH; addr++) begin
      if (dut.u_in_proj.u_u_sram.mem_sim[addr] !== '0)
        nonzero_u_tiles++;
    end
    $display("[%0t] in_proj done, nonzero u tiles = %0d", $time, nonzero_u_tiles);
    if (nonzero_u_tiles == 0)
      $fatal(1, "[%0t] in_proj produced no nonzero u_t data", $time);
    check_inproj_u_mem();

    wait(block_done);
    repeat (40) @(posedge clk);

    if (req_count == 0)
      $fatal(1, "[%0t] dt scheduler never issued a u_t SRAM read", $time);
    if (rd_checks == 0)
      $fatal(1, "[%0t] no checked u_t SRAM reads observed", $time);
    if (rd_errors != 0)
      $fatal(1, "[%0t] found %0d u_t SRAM read mismatches", $time, rd_errors);
    if (xt_cmp_checks == 0)
      $fatal(1, "[%0t] no xt stream comparisons observed", $time);
    if (xt_cmp_errors != 0)
      $fatal(1, "[%0t] found %0d xt stream mismatches", $time, xt_cmp_errors);

    $display("[%0t] PASS reuse_mamba_block_top u_t handoff checks=%0d requests=%0d xt_checks=%0d",
             $time, rd_checks, req_count, xt_cmp_checks);
    $finish;
  end
endmodule
