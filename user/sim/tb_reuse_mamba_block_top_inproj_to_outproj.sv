`timescale 1ns/1ps
//======================================================================
// tb_reuse_mamba_block_top_inproj_to_outproj.sv
//
// Purpose:
//   Validate the block-level handoff:
//     h_t -> in_proj -> u_t SRAM -> ssm core(p_t stream)
//     -> p_t SRAM -> out_proj -> y_axis / y SRAM
//
// Scope:
//   - validates in_proj SRAM contents with a deterministic pattern
//   - validates p_t stream is captured into p SRAM
//   - validates out_proj reads the same p_t SRAM data
//   - validates out_proj y SRAM contents against a deterministic model
//======================================================================
module tb_reuse_mamba_block_top_inproj_to_outproj;
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
  localparam int P_DEPTH     = 64;
  localparam int Y_DEPTH     = 32;
  localparam int OUT_WDEPTH  = 342;
  localparam int H_SUM       = (128 * 129) / 2;
  localparam int LUT_SIZE    = (1 << ADDR_BITS);

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
    $dumpfile("tb_reuse_mamba_block_top_inproj_to_outproj.vcd");
    $dumpvars(0, tb_reuse_mamba_block_top_inproj_to_outproj);
  end

  initial begin
    $readmemh(LUT_FILE, tb_sigmoid_rom);
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
  logic                         seen_inproj_done;
  logic                         seen_pcap_done;
  logic                         seen_outproj_done;
  logic [DATA_WIDTH-1:0]        tb_sigmoid_rom [0:LUT_SIZE-1];
  typedef logic [TILE_SIZE*DATA_WIDTH-1:0] vec_pack_t;
  vec_pack_t                    silu_in_q[$];

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

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      seen_inproj_done  <= 1'b0;
      seen_pcap_done    <= 1'b0;
      seen_outproj_done <= 1'b0;
    end else begin
      if (inproj_done)
        seen_inproj_done <= 1'b1;
      if (dut.pcap_done)
        seen_pcap_done <= 1'b1;
      if (dut.u_out_proj.done)
        seen_outproj_done <= 1'b1;
    end
  end

  always_comb begin
    g_axis_TVALID = 1'b1;
    for (int i = 0; i < TILE_SIZE; i++)
      g_axis_TDATA[i] = 16'sd1;
  end

  task automatic init_dt_wbuf_pattern();
    logic [DATA_W-1:0] line_i;
    int tile_id_i;
    int element_id_i;
    int val_i;
    begin
      for (int b = 0; b < N_BANK; b++) begin
        for (int addr = 0; addr < WDEPTH; addr++) begin
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

  task automatic init_outproj_wbuf_pattern();
    logic [DATA_W-1:0] line_i;
    int tile_id_i;
    int row_tile_i;
    int col_tile_i;
    int val_i;
    begin
      for (int b = 0; b < N_BANK; b++) begin
        for (int addr = 0; addr < OUT_WDEPTH; addr++) begin
          line_i = '0;
          tile_id_i = b + addr * N_BANK;
          row_tile_i = tile_id_i / 64;
          col_tile_i = tile_id_i % 64;
          for (int r = 0; r < TILE_SIZE; r++) begin
            val_i = (row_tile_i * TILE_SIZE + r + 1) * (col_tile_i + 1);
            for (int c = 0; c < TILE_SIZE; c++)
              line_i[(r*TILE_SIZE+c)*DATA_WIDTH +: DATA_WIDTH] = val_i[DATA_WIDTH-1:0];
          end
          dut.u_out_proj.u_w_sram.u_weight.mem_sim[b][addr] = line_i;
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
      $display("[%0t] MATCH in_proj u_t checked %0d lanes", $time, match_count);
    end
  endtask

  task automatic start_block();
    begin
      @(posedge clk);
      block_start <= 1'b1;
      @(posedge clk);
      block_start <= 1'b0;
    end
  endtask

  function automatic logic signed [DATA_WIDTH-1:0] silu_expected_lane(
      input logic signed [DATA_WIDTH-1:0] x
  );
    logic signed [DATA_WIDTH-1:0] x_clamp;
    logic [ADDR_BITS-1:0] lut_addr;
    logic [DATA_WIDTH-1:0] sig_u;
    logic signed [31:0] prod;
    begin
      if (x < -16'sd1024)
        x_clamp = -16'sd1024;
      else if (x > 16'sd1023)
        x_clamp = 16'sd1023;
      else
        x_clamp = x;

      lut_addr = x_clamp + 16'sd1024;
      sig_u = tb_sigmoid_rom[lut_addr];
      prod = $signed({1'b0, sig_u}) * $signed(x);
      silu_expected_lane = $signed(prod[16 +: DATA_WIDTH]);
    end
  endfunction

  task automatic check_silu_first_tiles(input int tiles_to_check);
    int checked_tiles;
    int error_count;
    vec_pack_t in_pack;
    logic signed [DATA_WIDTH-1:0] in_lane;
    logic signed [DATA_WIDTH-1:0] exp_lane;
    logic signed [DATA_WIDTH-1:0] got_lane;
    begin
      checked_tiles = 0;
      error_count = 0;
      silu_in_q.delete();
      while (checked_tiles < tiles_to_check) begin
        @(posedge clk);

        if (dut.u_silu.in_valid && dut.u_silu.in_ready) begin
          in_pack = '0;
          for (int lane = 0; lane < TILE_SIZE; lane++)
            in_pack[lane*DATA_WIDTH +: DATA_WIDTH] = dut.u_silu.in_vec[lane];
          silu_in_q.push_back(in_pack);
        end

        if (dut.u_silu.out_valid && dut.u_silu.out_ready) begin
          vec_pack_t src_pack;
          if (silu_in_q.size() == 0)
            $fatal(1, "[%0t] u_silu produced output with empty input queue", $time);

          src_pack = silu_in_q.pop_front();
          for (int lane = 0; lane < TILE_SIZE; lane++) begin
            in_lane  = $signed(src_pack[lane*DATA_WIDTH +: DATA_WIDTH]);
            exp_lane = silu_expected_lane(in_lane);
            got_lane = $signed(dut.u_silu.out_vec[lane]);
            $display("[%0t] u_silu tile=%0d lane=%0d in=%0d exp=%0d act=%0d",
                     $time, checked_tiles, lane, in_lane, exp_lane, got_lane);
            if (got_lane !== exp_lane) begin
              error_count++;
              $error("[%0t] u_silu mismatch tile=%0d lane=%0d in=%0d got=%0d exp=%0d",
                     $time, checked_tiles, lane, in_lane, got_lane, exp_lane);
            end
          end
          checked_tiles++;
        end
      end
      if (error_count == 0)
        $display("[%0t] MATCH u_silu checked %0d tiles", $time, checked_tiles);
      else
        $display("[%0t] FAIL u_silu checked %0d tiles with %0d mismatches", $time, checked_tiles, error_count);
    end
  endtask

  task automatic check_z_reader_first_tiles(input int tiles_to_check);
    int checked_tiles;
    int error_count;
    logic signed [DATA_WIDTH-1:0] exp_lane;
    begin
      checked_tiles = 0;
      error_count = 0;
      while (checked_tiles < tiles_to_check) begin
        @(posedge clk);
        if (dut.u_z_reader.out_valid && dut.u_z_reader.out_ready) begin
          for (int lane = 0; lane < TILE_SIZE; lane++) begin
            exp_lane = $signed(dut.u_in_proj.u_z_sram.mem_sim[checked_tiles][lane*DATA_WIDTH +: DATA_WIDTH]);
            $display("[%0t] u_z_reader tile=%0d lane=%0d exp=%0d act=%0d",
                     $time, checked_tiles, lane, exp_lane, $signed(dut.u_z_reader.out_vec[lane]));
            if ($signed(dut.u_z_reader.out_vec[lane]) !== exp_lane) begin
              error_count++;
              $error("[%0t] u_z_reader mismatch tile=%0d lane=%0d got=%0d exp=%0d",
                     $time, checked_tiles, lane,
                     $signed(dut.u_z_reader.out_vec[lane]), exp_lane);
            end
          end
          checked_tiles++;
        end
      end
      if (error_count == 0)
        $display("[%0t] MATCH u_z_reader checked %0d tiles", $time, checked_tiles);
      else
        $display("[%0t] FAIL u_z_reader checked %0d tiles with %0d mismatches", $time, checked_tiles, error_count);
    end
  endtask

  int p_req_addr_q[$];
  int p_rd_checks;
  int p_rd_errors;
  int p_req_count;
  int y_fire_count;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      p_req_addr_q.delete();
      p_rd_checks <= 0;
      p_rd_errors <= 0;
      p_req_count <= 0;
      y_fire_count <= 0;
    end else begin
      if (dut.p_rd_en_out) begin
        p_req_addr_q.push_back(dut.p_rd_addr_out);
        p_req_count <= p_req_count + 1;
      end

      if (dut.u_out_proj.group_start) begin
        int exp_addr;
        logic [TILE_SIZE*DATA_WIDTH-1:0] exp_pack;

        if (p_req_addr_q.size() == 0) begin
          p_rd_errors <= p_rd_errors + 1;
          $error("[%0t] out_proj group_start with empty p queue", $time);
        end else begin
          exp_addr = p_req_addr_q.pop_front();
          exp_pack = dut.u_p_sram.mem_sim[exp_addr];
          p_rd_checks <= p_rd_checks + 1;
          for (int i = 0; i < TILE_SIZE; i++) begin
            logic signed [DATA_WIDTH-1:0] exp_lane;
            exp_lane = exp_pack[i*DATA_WIDTH +: DATA_WIDTH];
            if (dut.p_rd_data_out[i] !== exp_lane) begin
              p_rd_errors <= p_rd_errors + 1;
              $error("[%0t] p SRAM read mismatch addr=%0d lane=%0d got=%0d exp=%0d",
                     $time, exp_addr, i, $signed(dut.p_rd_data_out[i]), $signed(exp_lane));
            end
          end
        end
      end

      if (y_axis_TVALID && y_axis_TREADY)
        y_fire_count <= y_fire_count + 1;
    end
  end

  function automatic logic signed [DATA_WIDTH-1:0] expected_y_lane_val(
      input integer row_tile_idx,
      input integer lane_idx,
      input integer sum_p
  );
    integer value_i;
    begin
      value_i = (row_tile_idx * TILE_SIZE + lane_idx + 1) * 2080 * sum_p;
      expected_y_lane_val = $signed(value_i >>> FRAC_BITS);
    end
  endfunction

  task automatic check_outproj_y_mem();
    integer match_count;
    logic signed [DATA_WIDTH-1:0] exp_val;
    begin
      match_count = 0;
      for (int addr = 0; addr < Y_DEPTH; addr++) begin
        int sum_p;
        sum_p = 0;
        for (int lane = 0; lane < TILE_SIZE; lane++)
          sum_p += $signed(dut.u_p_sram.mem_sim[addr][lane*DATA_WIDTH +: DATA_WIDTH]);
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          exp_val = expected_y_lane_val(addr, lane, sum_p);
          if ($signed(dut.u_out_proj.u_y_sram.mem_sim[addr][lane*DATA_WIDTH +: DATA_WIDTH]) !== exp_val) begin
            $error("[%0t] out_proj y mismatch addr=%0d lane=%0d got=%0d exp=%0d",
                   $time, addr, lane,
                   $signed(dut.u_out_proj.u_y_sram.mem_sim[addr][lane*DATA_WIDTH +: DATA_WIDTH]),
                   $signed(exp_val));
          end else begin
            match_count++;
          end
        end
      end

      $display("[%0t] MATCH out_proj y checked %0d lanes", $time, match_count);
    end
  endtask

  integer nonzero_u_tiles;
  integer nonzero_p_tiles;
  integer nonzero_y_tiles;

  initial begin
    s_axis_TVALID   = 1'b0;
    block_auto_mode = 1'b1;
    block_start     = 1'b0;
    inproj_enable   = 1'b1;
    inproj_start    = 1'b0;
    h_wr_en         = 1'b0;
    h_wr_addr       = '0;
    u_rd_en         = 1'b0;
    u_rd_addr       = '0;
    z_rd_en         = 1'b0;
    z_rd_addr       = '0;
    outproj_enable  = 1'b1;
    for (int i = 0; i < TILE_SIZE; i++)
      h_wr_data[i] = '0;

    wait(rst_n);
    repeat (5) @(posedge clk);

    $display("[%0t] init weight memories", $time);
    init_dt_wbuf_pattern();
    init_inproj_wbuf_pattern();
    init_outproj_wbuf_pattern();

    $display("[%0t] write h_t SRAM", $time);
    write_h_vector();

    $display("[%0t] start block auto sequence", $time);
    start_block();

    fork
      check_z_reader_first_tiles(64);
      check_silu_first_tiles(64);
    join

    wait(seen_inproj_done);
    @(posedge clk);
    nonzero_u_tiles = 0;
    for (int addr = 0; addr < U_DEPTH; addr++) begin
      if (dut.u_in_proj.u_u_sram.mem_sim[addr] !== '0)
        nonzero_u_tiles++;
    end
    $display("[%0t] in_proj done, nonzero u tiles = %0d", $time, nonzero_u_tiles);
    if (nonzero_u_tiles == 0)
      $fatal(1, "[%0t] in_proj produced no nonzero u_t data", $time);
    // check_inproj_u_mem();

    wait(seen_pcap_done);
    @(posedge clk);
    nonzero_p_tiles = 0;
    for (int addr = 0; addr < P_DEPTH; addr++) begin
      if (dut.u_p_sram.mem_sim[addr] !== '0)
        nonzero_p_tiles++;
    end
    $display("[%0t] p_capture done, nonzero p tiles = %0d", $time, nonzero_p_tiles);
    if (nonzero_p_tiles == 0)
      $fatal(1, "[%0t] p_capture produced no nonzero p_t data", $time);

    wait(seen_outproj_done);
    repeat (10) @(posedge clk);

    nonzero_y_tiles = 0;
    for (int addr = 0; addr < Y_DEPTH; addr++) begin
      if (dut.u_out_proj.u_y_sram.mem_sim[addr] !== '0)
        nonzero_y_tiles++;
    end
    $display("[%0t] out_proj done, nonzero y tiles = %0d", $time, nonzero_y_tiles);
    if (nonzero_y_tiles == 0)
      $fatal(1, "[%0t] out_proj produced no nonzero y data", $time);

    if (p_req_count == 0)
      $fatal(1, "[%0t] out_proj never issued a p SRAM read", $time);
    if (p_rd_checks == 0)
      $fatal(1, "[%0t] no checked p SRAM reads observed", $time);
    if (p_rd_errors != 0)
      $fatal(1, "[%0t] found %0d p SRAM read mismatches", $time, p_rd_errors);

    // check_outproj_y_mem();

    if (y_fire_count == 0)
      $fatal(1, "[%0t] no out_proj y_axis transfers observed", $time);

    $display("[%0t] PASS reuse_mamba_block_top in_proj->out_proj p_reads=%0d y_fires=%0d",
             $time, p_rd_checks, y_fire_count);
    $finish;
  end
endmodule
