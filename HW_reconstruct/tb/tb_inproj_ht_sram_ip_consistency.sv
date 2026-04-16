`timescale 1ns/1ps

// Compare inproj_ht_sram_ip connection semantics against a reference SRAM model:
// - synchronous write
// - synchronous read, 1-cycle latency
// - rd_en=0 keeps previous q
// - reset drives q=0 and memory=0
module tb_inproj_ht_sram_ip_consistency;
  localparam int TILE_SIZE   = 4;
  localparam int DATA_WIDTH  = 16;
  localparam int DEPTH       = 32;
  localparam int ADDR_W      = $clog2(DEPTH);
  localparam int PACK_W      = TILE_SIZE * DATA_WIDTH;

  logic clk;
  logic rst_n;
  logic wr_en;
  logic [ADDR_W-1:0] wr_addr;
  logic signed [DATA_WIDTH-1:0] wr_data [TILE_SIZE-1:0];
  logic rd_en;
  logic [ADDR_W-1:0] rd_addr;

  logic [PACK_W-1:0] wr_pack;
  logic [PACK_W-1:0] q_ref_pack;
  logic [PACK_W-1:0] q_ip_pack;
  logic [PACK_W-1:0] q_ip_safe;

  logic signed [DATA_WIDTH-1:0] rd_ref [TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] rd_ip  [TILE_SIZE-1:0];

  logic [PACK_W-1:0] mem_ref [DEPTH-1:0];

  initial clk = 1'b0;
  always #5 clk = ~clk;

  always_comb begin
    for (int i = 0; i < TILE_SIZE; i++) begin
      wr_pack[i*DATA_WIDTH +: DATA_WIDTH] = wr_data[i];
      rd_ref[i] = q_ref_pack[i*DATA_WIDTH +: DATA_WIDTH];
      rd_ip[i]  = q_ip_safe[i*DATA_WIDTH +: DATA_WIDTH];
    end
  end

  // Reference model (matches previous hand-written semantics)
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      for (int i = 0; i < DEPTH; i++) mem_ref[i] <= '0;
      q_ref_pack <= '0;
    end else begin
      if (wr_en) mem_ref[wr_addr] <= wr_pack;
      if (rd_en) q_ref_pack <= mem_ref[rd_addr];
    end
  end

  // IP path (same wiring style as reuse_ht_sram_sp/reuse_ht_multi_copy_ip)
  inproj_ht_sram_ip u_ip (
      .clka (clk),
      .ena  (wr_en),
      .wea  (wr_en),
      .addra(wr_addr),
      .dina (wr_pack),
      .douta(),
      .clkb (clk),
      .enb  (rd_en),
      .web  (1'b0),
      .addrb(rd_addr),
      .dinb ('0),
      .doutb(q_ip_pack)
  );

  // Convert unknown/z from IP output to zero for diagnosis reporting.
  assign q_ip_safe = (^q_ip_pack === 1'bx) ? '0 : q_ip_pack;

  task automatic set_wr_data(input int seed);
    begin
      for (int i = 0; i < TILE_SIZE; i++) begin
        wr_data[i] = $signed((seed * 17 + i * 13) & 16'hFFFF);
      end
    end
  endtask

  task automatic check_eq(input string tag);
    begin
      if (q_ip_safe !== q_ref_pack) begin
        $display("[%0t] %s mismatch", $time, tag);
        $display("  ref=0x%016h ip=0x%016h raw_ip=0x%016h", q_ref_pack, q_ip_safe, q_ip_pack);
        $fatal(1, "inproj_ht_sram_ip semantic mismatch");
      end
    end
  endtask

  initial begin
    rst_n   = 1'b0;
    wr_en   = 1'b0;
    wr_addr = '0;
    rd_en   = 1'b0;
    rd_addr = '0;
    for (int i = 0; i < TILE_SIZE; i++) wr_data[i] = '0;

    repeat (4) @(posedge clk);
    rst_n <= 1'b1;
    @(posedge clk);
    #1 check_eq("after reset release (no read)");

    // Write several rows
    for (int a = 0; a < 8; a++) begin
      set_wr_data(a + 1);
      wr_en   <= 1'b1;
      wr_addr <= a[ADDR_W-1:0];
      rd_en   <= 1'b0;
      @(posedge clk);
    end
    wr_en <= 1'b0;
    @(posedge clk);

    // Read back
    for (int a = 0; a < 8; a++) begin
      rd_en   <= 1'b1;
      rd_addr <= a[ADDR_W-1:0];
      @(posedge clk);
      #1 check_eq($sformatf("read addr %0d", a));
    end

    // Hold check: rd_en=0 keeps q
    rd_en <= 1'b0;
    @(posedge clk);
    #1 check_eq("hold when rd_en=0");

    // Same-cycle write/read same addr stress (read-first expectation)
    set_wr_data(99);
    wr_en   <= 1'b1;
    wr_addr <= 3;
    rd_en   <= 1'b1;
    rd_addr <= 3;
    @(posedge clk);
    #1 check_eq("same-cycle wr/rd same addr");

    wr_en <= 1'b0;
    rd_en <= 1'b1;
    rd_addr <= 3;
    @(posedge clk);
    #1 check_eq("read addr 3 after overwrite");

    $display("[%0t] PASS tb_inproj_ht_sram_ip_consistency", $time);
    #20;
    $finish;
  end
endmodule

