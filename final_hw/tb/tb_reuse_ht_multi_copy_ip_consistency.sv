`timescale 1ns/1ps

// Compare reuse_ht_multi_copy_ip (4 copied BRAMs) with a single-memory reference model.
// This directly checks whether copied-IP implementation matches the hand-written 4-read-port SRAM semantics.
module tb_reuse_ht_multi_copy_ip_consistency;
  localparam int DATA_W = 64;
  localparam int DEPTH  = 64;
  localparam int ADDR_W = $clog2(DEPTH);

  logic clk;
  logic rst_n;
  logic wr_en;
  logic [ADDR_W-1:0] wr_addr;
  logic [DATA_W-1:0] wr_data;
  logic rd_en;
  logic [ADDR_W-1:0] rd_addr0, rd_addr1, rd_addr2, rd_addr3;

  logic [DATA_W-1:0] rd_ref0, rd_ref1, rd_ref2, rd_ref3;
  logic [DATA_W-1:0] rd_ip0,  rd_ip1,  rd_ip2,  rd_ip3;
  logic [DATA_W-1:0] rd_ip0_safe, rd_ip1_safe, rd_ip2_safe, rd_ip3_safe;

  logic [DATA_W-1:0] mem_ref [DEPTH-1:0];

  initial clk = 1'b0;
  always #5 clk = ~clk;

  // Ref model: same semantics as reuse_ht_sram behavioral branch.
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      for (int i = 0; i < DEPTH; i++) mem_ref[i] <= '0;
      rd_ref0 <= '0;
      rd_ref1 <= '0;
      rd_ref2 <= '0;
      rd_ref3 <= '0;
    end else begin
      if (wr_en) mem_ref[wr_addr] <= wr_data;
      if (rd_en) begin
        rd_ref0 <= mem_ref[rd_addr0];
        rd_ref1 <= mem_ref[rd_addr1];
        rd_ref2 <= mem_ref[rd_addr2];
        rd_ref3 <= mem_ref[rd_addr3];
      end
    end
  end

  reuse_ht_multi_copy_ip #(
      .DATA_W(DATA_W),
      .ADDR_W(ADDR_W)
  ) dut (
      .clk(clk),
      .wr_en(wr_en),
      .wr_addr(wr_addr),
      .wr_data(wr_data),
      .rd_en(rd_en),
      .rd_addr0(rd_addr0),
      .rd_addr1(rd_addr1),
      .rd_addr2(rd_addr2),
      .rd_addr3(rd_addr3),
      .rd_data0(rd_ip0),
      .rd_data1(rd_ip1),
      .rd_data2(rd_ip2),
      .rd_data3(rd_ip3)
  );

  assign rd_ip0_safe = (^rd_ip0 === 1'bx) ? '0 : rd_ip0;
  assign rd_ip1_safe = (^rd_ip1 === 1'bx) ? '0 : rd_ip1;
  assign rd_ip2_safe = (^rd_ip2 === 1'bx) ? '0 : rd_ip2;
  assign rd_ip3_safe = (^rd_ip3 === 1'bx) ? '0 : rd_ip3;

  task automatic check_all(input string tag);
    begin
      if ((rd_ip0_safe !== rd_ref0) || (rd_ip1_safe !== rd_ref1) ||
          (rd_ip2_safe !== rd_ref2) || (rd_ip3_safe !== rd_ref3)) begin
        $display("[%0t] %s mismatch", $time, tag);
        $display("  ref={%h,%h,%h,%h}", rd_ref0, rd_ref1, rd_ref2, rd_ref3);
        $display("  ip ={%h,%h,%h,%h}", rd_ip0_safe, rd_ip1_safe, rd_ip2_safe, rd_ip3_safe);
        $display("  raw={%h,%h,%h,%h}", rd_ip0, rd_ip1, rd_ip2, rd_ip3);
        $fatal(1, "reuse_ht_multi_copy_ip semantic mismatch");
      end
    end
  endtask

  initial begin
    rst_n   = 1'b0;
    wr_en   = 1'b0;
    wr_addr = '0;
    wr_data = '0;
    rd_en   = 1'b0;
    rd_addr0 = '0;
    rd_addr1 = '0;
    rd_addr2 = '0;
    rd_addr3 = '0;

    repeat (4) @(posedge clk);
    rst_n <= 1'b1;
    @(posedge clk);
    #1 check_all("after reset release");

    // Fill several addresses
    for (int a = 0; a < 16; a++) begin
      wr_en   <= 1'b1;
      wr_addr <= a[ADDR_W-1:0];
      wr_data <= 64'h1111_0000_0000_0000 + a;
      rd_en   <= 1'b0;
      @(posedge clk);
    end
    wr_en <= 1'b0;
    @(posedge clk);

    // Multi-read
    rd_en   <= 1'b1;
    rd_addr0 <= 0;
    rd_addr1 <= 3;
    rd_addr2 <= 7;
    rd_addr3 <= 15;
    @(posedge clk); #1 check_all("multi-read #1");

    rd_addr0 <= 1;
    rd_addr1 <= 4;
    rd_addr2 <= 8;
    rd_addr3 <= 12;
    @(posedge clk); #1 check_all("multi-read #2");

    // Hold when rd_en=0
    rd_en <= 1'b0;
    @(posedge clk); #1 check_all("hold when rd_en=0");

    // Same-cycle write + read same address on all 4 ports (critical)
    wr_en   <= 1'b1;
    wr_addr <= 5;
    wr_data <= 64'hAAAA_BBBB_CCCC_DDDD;
    rd_en   <= 1'b1;
    rd_addr0 <= 5;
    rd_addr1 <= 5;
    rd_addr2 <= 5;
    rd_addr3 <= 5;
    @(posedge clk); #1 check_all("wr/rd same-addr collision");

    wr_en   <= 1'b0;
    rd_en   <= 1'b1;
    rd_addr0 <= 5;
    rd_addr1 <= 5;
    rd_addr2 <= 5;
    rd_addr3 <= 5;
    @(posedge clk); #1 check_all("read after overwrite");

    $display("[%0t] PASS tb_reuse_ht_multi_copy_ip_consistency", $time);
    #20;
    $finish;
  end
endmodule

