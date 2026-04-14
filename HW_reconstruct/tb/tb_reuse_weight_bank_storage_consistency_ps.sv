`timescale 1ns/1ps

module tb_reuse_weight_bank_storage_consistency_ps;
  logic clk;
  logic rst_n;
  logic rom_en_a;
  logic [2:0] rom_addr_a;
  logic [31:0] rom_dout_a;
  logic rom_en_b;
  logic [2:0] rom_addr_b;
  logic [31:0] rom_dout_b;

  logic [2:0] slim_bank_sel_0, slim_bank_sel_1, slim_bank_sel_2, slim_bank_sel_3;
  logic [2:0] slim_addr_sel_0, slim_addr_sel_1, slim_addr_sel_2, slim_addr_sel_3;
  logic [3:0] slim_en_sel;
  logic [3:0] slim_port_sel;
  logic [31:0] slim_dout_sel_0, slim_dout_sel_1, slim_dout_sel_2, slim_dout_sel_3;

  initial clk = 1'b0;
  always #5 clk = ~clk;

  function automatic logic [31:0] bank_word(input int bank, input int addr);
    bank_word = (32'h1000_0000 * bank) + addr;
  endfunction

  task automatic drive_rom(input logic ena, input logic [2:0] addra, input logic enb, input logic [2:0] addrb);
    begin
      rom_en_a = ena;
      rom_addr_a = addra;
      rom_en_b = enb;
      rom_addr_b = addrb;
    end
  endtask

  task automatic drive_slim(
      input logic [2:0] b0, input logic [2:0] b1, input logic [2:0] b2, input logic [2:0] b3,
      input logic [2:0] a0, input logic [2:0] a1, input logic [2:0] a2, input logic [2:0] a3,
      input logic [3:0] en_i, input logic [3:0] port_i
  );
    begin
      slim_bank_sel_0 = b0; slim_bank_sel_1 = b1; slim_bank_sel_2 = b2; slim_bank_sel_3 = b3;
      slim_addr_sel_0 = a0; slim_addr_sel_1 = a1; slim_addr_sel_2 = a2; slim_addr_sel_3 = a3;
      slim_en_sel = en_i; slim_port_sel = port_i;
    end
  endtask

  task automatic check_rom(input logic [31:0] exp_a, input logic [31:0] exp_b, input string tag);
    begin
      if (rom_dout_a !== exp_a || rom_dout_b !== exp_b)
        $fatal(1, "[%0t] %s ROM mismatch got_a=0x%08h exp_a=0x%08h got_b=0x%08h exp_b=0x%08h", $time, tag, rom_dout_a, exp_a, rom_dout_b, exp_b);
    end
  endtask

  task automatic check_slim(input logic [31:0] exp0, input logic [31:0] exp1, input logic [31:0] exp2, input logic [31:0] exp3, input string tag);
    begin
      if ((slim_dout_sel_0 !== exp0) || (slim_dout_sel_1 !== exp1) || (slim_dout_sel_2 !== exp2) || (slim_dout_sel_3 !== exp3))
        $fatal(1, "[%0t] %s slim mismatch got={0x%08h,0x%08h,0x%08h,0x%08h} exp={0x%08h,0x%08h,0x%08h,0x%08h}",
               $time, tag, slim_dout_sel_0, slim_dout_sel_1, slim_dout_sel_2, slim_dout_sel_3, exp0, exp1, exp2, exp3);
    end
  endtask

  reuse_weight_bank_storage_consistency_dut dut (
    .clk(clk), .rst_n(rst_n), .rom_en_a(rom_en_a), .rom_addr_a(rom_addr_a), .rom_dout_a(rom_dout_a),
    .rom_en_b(rom_en_b), .rom_addr_b(rom_addr_b), .rom_dout_b(rom_dout_b),
    .\slim_bank_sel[0] (slim_bank_sel_0), .\slim_bank_sel[1] (slim_bank_sel_1), .\slim_bank_sel[2] (slim_bank_sel_2), .\slim_bank_sel[3] (slim_bank_sel_3),
    .\slim_addr_sel[0] (slim_addr_sel_0), .\slim_addr_sel[1] (slim_addr_sel_1), .\slim_addr_sel[2] (slim_addr_sel_2), .\slim_addr_sel[3] (slim_addr_sel_3),
    .slim_en_sel(slim_en_sel), .slim_port_sel(slim_port_sel),
    .\slim_dout_sel[0] (slim_dout_sel_0), .\slim_dout_sel[1] (slim_dout_sel_1), .\slim_dout_sel[2] (slim_dout_sel_2), .\slim_dout_sel[3] (slim_dout_sel_3)
  );

  initial begin
    rst_n = 1'b0;
    rom_en_a = 1'b0; rom_addr_a = '0; rom_en_b = 1'b0; rom_addr_b = '0;
    slim_bank_sel_0 = '0; slim_bank_sel_1 = '0; slim_bank_sel_2 = '0; slim_bank_sel_3 = '0;
    slim_addr_sel_0 = '0; slim_addr_sel_1 = '0; slim_addr_sel_2 = '0; slim_addr_sel_3 = '0;
    slim_en_sel = '0; slim_port_sel = '0;

    // Post-synth netlist includes glbl/GSR startup. Wait it out before checking semantics.
    #150;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    repeat (2) @(posedge clk);

    drive_rom(1'b1, 3, 1'b1, 5);
    @(posedge clk); #1;
    check_rom(bank_word(0, 3), bank_word(0, 5), "rom first read");

    drive_rom(1'b0, 0, 1'b0, 0);
    @(posedge clk); #1;
    check_rom(bank_word(0, 3), bank_word(0, 5), "rom hold");

    drive_rom(1'b1, 7, 1'b1, 1);
    @(posedge clk); #1;
    check_rom(bank_word(0, 7), bank_word(0, 1), "rom second read");

    drive_slim(0,1,2,3, 2,3,4,5, 4'b1111, 4'b0000);
    @(posedge clk); #1;
    @(posedge clk); #1;
    check_slim(bank_word(0, 2), bank_word(1, 3), bank_word(2, 4), bank_word(3, 5), "slim portA");

    drive_slim(1,2,4,5, 6,1,7,2, 4'b1111, 4'b1111);
    @(posedge clk); #1;
    @(posedge clk); #1;
    check_slim(bank_word(1, 6), bank_word(2, 1), bank_word(4, 7), bank_word(5, 2), "slim portB");

    drive_slim(0,0,0,0, 0,0,0,0, 4'b0000, 4'b0000);
    @(posedge clk); #1;
    @(posedge clk); #1;
    check_slim(32'h0, 32'h0, 32'h0, 32'h0, "slim disabled");

    $display("[%0t] PASS weight-bank storage consistency post-synth semantics", $time);
    #20;
    $finish;
  end
endmodule
