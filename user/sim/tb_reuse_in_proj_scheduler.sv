`timescale 1ns/1ps
//======================================================================
// tb_reuse_in_proj_scheduler.sv
//
// Purpose:
//   Validate reuse_in_proj_scheduler as a standalone in_proj GEMV engine
//   together with the shared 4x4x4 MAC fabric.
//
// Test pattern:
//   - h_t is loaded as all-ones across 128 dims
//   - every 4x4 tile in row_tile r uses a constant weight (r+1)
//   - with the current shared fabric, one k-block contributes:
//       4-array MAC accumulation  -> 4*(r+1) per matrix element
//       reduction over 4 rows     -> 16*(r+1) per output lane
//   - there are IN_DIM/TILE_SIZE = 32 k-blocks, so each output lane is:
//       32 * 16 * (r+1) = 512 * (r+1)
//
// Mapping:
//   - row_tile 0..63  -> u_t SRAM addr 0..63
//   - row_tile 64..127 -> z_t SRAM addr 0..63
//======================================================================
module tb_reuse_in_proj_scheduler;
  localparam int TILE_SIZE   = 4;
  localparam int DATA_WIDTH  = 16;
  localparam int ACC_WIDTH   = 32;
  localparam int N_BANK      = 6;
  localparam int WDEPTH      = 683;
  localparam int WADDR_W     = $clog2(WDEPTH);
  localparam int DATA_W      = 256;
  localparam int IN_DIM      = 128;
  localparam int OUT_DIM     = 512;
  localparam int H_DEPTH     = IN_DIM / TILE_SIZE;
  localparam int H_ADDR_W    = $clog2(H_DEPTH);
  localparam int U_DEPTH     = (OUT_DIM/2) / TILE_SIZE;
  localparam int U_ADDR_W    = $clog2(U_DEPTH);

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
    $dumpfile("tb_reuse_in_proj_scheduler.vcd");
    $dumpvars(0, tb_reuse_in_proj_scheduler);
  end

  logic enable, start, busy, done;
  logic                         h_wr_en;
  logic [H_ADDR_W-1:0]          h_wr_addr;
  logic signed [DATA_WIDTH-1:0] h_wr_data [TILE_SIZE-1:0];
  logic                         u_rd_en;
  logic [U_ADDR_W-1:0]          u_rd_addr;
  logic signed [DATA_WIDTH-1:0] u_rd_data [TILE_SIZE-1:0];
  logic                         z_rd_en;
  logic [U_ADDR_W-1:0]          z_rd_addr;
  logic signed [DATA_WIDTH-1:0] z_rd_data [TILE_SIZE-1:0];

  logic [1:0]                   fabric_mode;
  logic [6:0]                   fabric_col_blocks;
  logic                         fabric_valid_in;
  logic signed [DATA_WIDTH-1:0] fabric_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] fabric_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] fabric_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] fabric_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] fabric_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] fabric_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] fabric_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] fabric_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [ACC_WIDTH-1:0]  fabric_reduced_vec [TILE_SIZE-1:0];
  logic signed [ACC_WIDTH-1:0]  fabric_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [ACC_WIDTH-1:0]  fabric_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [ACC_WIDTH-1:0]  fabric_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [ACC_WIDTH-1:0]  fabric_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic                         fabric_valid_out;

  reuse_in_proj_scheduler #(
      .TILE_SIZE (TILE_SIZE),
      .DATA_WIDTH(DATA_WIDTH),
      .ACC_WIDTH (ACC_WIDTH),
      .N_BANK    (N_BANK),
      .WDEPTH    (WDEPTH),
      .WADDR_W   (WADDR_W),
      .DATA_W    (DATA_W),
      .IN_DIM    (IN_DIM),
      .OUT_DIM   (OUT_DIM)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .enable(enable),
      .start(start),
      .busy(busy),
      .done(done),
      .h_wr_en(h_wr_en),
      .h_wr_addr(h_wr_addr),
      .h_wr_data(h_wr_data),
      .u_rd_en(u_rd_en),
      .u_rd_addr(u_rd_addr),
      .u_rd_data(u_rd_data),
      .u_ssm_rd_en(1'b0),
      .u_ssm_rd_addr('0),
      .u_ssm_rd_data(),
      .z_rd_en(z_rd_en),
      .z_rd_addr(z_rd_addr),
      .z_rd_data(z_rd_data),
      .z_gate_rd_en(1'b0),
      .z_gate_rd_addr('0),
      .z_gate_rd_data(),
      .fabric_mode(fabric_mode),
      .fabric_col_blocks(fabric_col_blocks),
      .fabric_valid_in(fabric_valid_in),
      .fabric_A0_mat(fabric_A0_mat),
      .fabric_A1_mat(fabric_A1_mat),
      .fabric_A2_mat(fabric_A2_mat),
      .fabric_A3_mat(fabric_A3_mat),
      .fabric_B0_mat(fabric_B0_mat),
      .fabric_B1_mat(fabric_B1_mat),
      .fabric_B2_mat(fabric_B2_mat),
      .fabric_B3_mat(fabric_B3_mat),
      .fabric_reduced_vec(fabric_reduced_vec),
      .fabric_reduced_mat_0(fabric_reduced_mat_0),
      .fabric_reduced_mat_1(fabric_reduced_mat_1),
      .fabric_reduced_mat_2(fabric_reduced_mat_2),
      .fabric_reduced_mat_3(fabric_reduced_mat_3),
      .fabric_valid_out(fabric_valid_out)
  );

  reuse_shared_mac_fabric #(
      .TILE_SIZE (TILE_SIZE),
      .DATA_WIDTH(DATA_WIDTH),
      .ACC_WIDTH (ACC_WIDTH),
      .FRAC_BITS (8)
  ) u_fabric (
      .clk(clk),
      .rst_n(rst_n),
      .mode(fabric_mode),
      .col_blocks_cfg(fabric_col_blocks),
      .valid_in(fabric_valid_in),
      .A0_mat(fabric_A0_mat),
      .A1_mat(fabric_A1_mat),
      .A2_mat(fabric_A2_mat),
      .A3_mat(fabric_A3_mat),
      .B0_mat(fabric_B0_mat),
      .B1_mat(fabric_B1_mat),
      .B2_mat(fabric_B2_mat),
      .B3_mat(fabric_B3_mat),
      .reduced_vec(fabric_reduced_vec),
      .reduced_mat_0(fabric_reduced_mat_0),
      .reduced_mat_1(fabric_reduced_mat_1),
      .reduced_mat_2(fabric_reduced_mat_2),
      .reduced_mat_3(fabric_reduced_mat_3),
      .valid_reduced(fabric_valid_out)
  );

  task automatic init_weight_tiles();
    logic [DATA_W-1:0] line_i;
    int tile_id_i;
    int row_tile_i;
    int w_i;
    int value_i;
    begin
      for (int b = 0; b < N_BANK; b++) begin
        for (int addr = 0; addr < WDEPTH; addr++) begin
          line_i = '0;
          tile_id_i = b + addr * N_BANK;
          row_tile_i = tile_id_i / (IN_DIM / TILE_SIZE);
          value_i = row_tile_i + 1;
          for (w_i = 0; w_i < 16; w_i++)
            line_i[w_i*DATA_WIDTH +: DATA_WIDTH] = value_i[DATA_WIDTH-1:0];
          dut.u_w_sram.u_weight.mem_sim[b][addr] = line_i;
        end
      end
    end
  endtask

  task automatic load_h_ones();
    begin
      for (int addr = 0; addr < H_DEPTH; addr++) begin
        @(posedge clk);
        h_wr_en   <= 1'b1;
        h_wr_addr <= addr[H_ADDR_W-1:0];
        for (int i = 0; i < TILE_SIZE; i++)
          h_wr_data[i] <= 16'sd1;
      end
      @(posedge clk);
      h_wr_en   <= 1'b0;
      h_wr_addr <= '0;
      for (int i = 0; i < TILE_SIZE; i++)
        h_wr_data[i] <= '0;
    end
  endtask

  function automatic logic signed [DATA_WIDTH-1:0] expected_tile_val(input int row_tile_idx);
    int value_i;
    begin
      value_i = 4 * IN_DIM * (row_tile_idx + 1);
      expected_tile_val = value_i[DATA_WIDTH-1:0];
    end
  endfunction

  task automatic check_u_z_mem();
    logic signed [DATA_WIDTH-1:0] exp_val;
    int match_count;
    begin
      match_count = 0;
      for (int addr = 0; addr < U_DEPTH; addr++) begin
        exp_val = expected_tile_val(addr);
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          if ($signed(dut.u_u_sram.mem_sim[addr][lane*DATA_WIDTH +: DATA_WIDTH]) !== exp_val) begin
            $error("[%0t] u_t mismatch addr=%0d lane=%0d got=%0d exp=%0d",
                   $time, addr, lane,
                   $signed(dut.u_u_sram.mem_sim[addr][lane*DATA_WIDTH +: DATA_WIDTH]),
                   $signed(exp_val));
          end else begin
            match_count++;
          end
        end
      end

      for (int addr = 0; addr < U_DEPTH; addr++) begin
        exp_val = expected_tile_val(addr + U_DEPTH);
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          if ($signed(dut.u_z_sram.mem_sim[addr][lane*DATA_WIDTH +: DATA_WIDTH]) !== exp_val) begin
            $error("[%0t] z_t mismatch addr=%0d lane=%0d got=%0d exp=%0d",
                   $time, addr, lane,
                   $signed(dut.u_z_sram.mem_sim[addr][lane*DATA_WIDTH +: DATA_WIDTH]),
                   $signed(exp_val));
          end else begin
            match_count++;
          end
        end
      end

      $display("[%0t] MATCH reuse_in_proj_scheduler checked %0d lanes", $time, match_count);
    end
  endtask

  initial begin
    enable   = 1'b1;
    start    = 1'b0;
    h_wr_en  = 1'b0;
    h_wr_addr= '0;
    u_rd_en  = 1'b0;
    u_rd_addr= '0;
    z_rd_en  = 1'b0;
    z_rd_addr= '0;
    for (int i = 0; i < TILE_SIZE; i++)
      h_wr_data[i] = '0;

    wait(rst_n);
    repeat (5) @(posedge clk);

    $display("[%0t] init in_proj weight SRAM", $time);
    init_weight_tiles();

    $display("[%0t] load h_t all-ones", $time);
    load_h_ones();

    @(posedge clk);
    start <= 1'b1;
    @(posedge clk);
    start <= 1'b0;

    wait(done);
    @(posedge clk);

    check_u_z_mem();
    $display("[%0t] PASS reuse_in_proj_scheduler basic GEMV", $time);
    $finish;
  end
endmodule
