`timescale 1ns/1ps

module tb_reuse_weight_bank_storage_consistency;
  localparam int ROM_DEPTH   = 8;
  localparam int ROM_ADDR_W  = $clog2(ROM_DEPTH);
  localparam int ROM_DATA_W  = 32;
  localparam int N_BANK      = 6;
  localparam int WBUF_DEPTH  = 8;
  localparam int WBUF_ADDR_W = $clog2(WBUF_DEPTH);
  localparam int WBUF_DATA_W = 32;

  logic clk;
  logic rst_n;
  logic                  rom_en_a;
  logic [ROM_ADDR_W-1:0] rom_addr_a;
  logic [ROM_DATA_W-1:0] rom_dout_a;
  logic                  rom_en_b;
  logic [ROM_ADDR_W-1:0] rom_addr_b;
  logic [ROM_DATA_W-1:0] rom_dout_b;
  logic [3:0][$clog2(N_BANK)-1:0] slim_bank_sel;
  logic [3:0][WBUF_ADDR_W-1:0]    slim_addr_sel;
  logic [3:0]                     slim_en_sel;
  logic [3:0]                     slim_port_sel;
  logic [3:0][WBUF_DATA_W-1:0]    slim_dout_sel;

  initial clk = 1'b0;
  always #5 clk = ~clk;

  function automatic logic [31:0] bank_word(input int bank, input int addr);
    bank_word = (32'h1000_0000 * bank) + addr;
  endfunction

  task automatic drive_rom(
      input logic ena,
      input logic [ROM_ADDR_W-1:0] addra,
      input logic enb,
      input logic [ROM_ADDR_W-1:0] addrb
  );
    begin
      rom_en_a   = ena;
      rom_addr_a = addra;
      rom_en_b   = enb;
      rom_addr_b = addrb;
    end
  endtask

  task automatic drive_slim(
      input logic [3:0][$clog2(N_BANK)-1:0] bank_sel_i,
      input logic [3:0][WBUF_ADDR_W-1:0]    addr_sel_i,
      input logic [3:0]                     en_sel_i,
      input logic [3:0]                     port_sel_i
  );
    begin
      slim_bank_sel = bank_sel_i;
      slim_addr_sel = addr_sel_i;
      slim_en_sel   = en_sel_i;
      slim_port_sel = port_sel_i;
    end
  endtask

  task automatic check_rom(
      input logic [31:0] exp_a,
      input logic [31:0] exp_b,
      input string tag
  );
    begin
      if (rom_dout_a !== exp_a || rom_dout_b !== exp_b) begin
        $fatal(1, "[%0t] %s ROM mismatch got_a=0x%08h exp_a=0x%08h got_b=0x%08h exp_b=0x%08h",
               $time, tag, rom_dout_a, exp_a, rom_dout_b, exp_b);
      end
    end
  endtask

  task automatic check_slim_all(
      input logic [31:0] exp0,
      input logic [31:0] exp1,
      input logic [31:0] exp2,
      input logic [31:0] exp3,
      input string tag
  );
    begin
      if ((slim_dout_sel[0] !== exp0) || (slim_dout_sel[1] !== exp1) ||
          (slim_dout_sel[2] !== exp2) || (slim_dout_sel[3] !== exp3)) begin
        $fatal(1, "[%0t] %s slim mismatch got={0x%08h,0x%08h,0x%08h,0x%08h} exp={0x%08h,0x%08h,0x%08h,0x%08h}",
               $time, tag,
               slim_dout_sel[0], slim_dout_sel[1], slim_dout_sel[2], slim_dout_sel[3],
               exp0, exp1, exp2, exp3);
      end
    end
  endtask

  reuse_weight_bank_storage_consistency_dut dut (
      .clk          (clk),
      .rst_n        (rst_n),
      .rom_en_a     (rom_en_a),
      .rom_addr_a   (rom_addr_a),
      .rom_dout_a   (rom_dout_a),
      .rom_en_b     (rom_en_b),
      .rom_addr_b   (rom_addr_b),
      .rom_dout_b   (rom_dout_b),
      .slim_bank_sel(slim_bank_sel),
      .slim_addr_sel(slim_addr_sel),
      .slim_en_sel  (slim_en_sel),
      .slim_port_sel(slim_port_sel),
      .slim_dout_sel(slim_dout_sel)
  );

  initial begin
    rst_n         = 1'b0;
    rom_en_a      = 1'b0;
    rom_addr_a    = '0;
    rom_en_b      = 1'b0;
    rom_addr_b    = '0;
    slim_bank_sel = '{default:'0};
    slim_addr_sel = '{default:'0};
    slim_en_sel   = '0;
    slim_port_sel = '0;

    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    repeat (2) @(posedge clk);

    // reuse_weight_bank_rom: 1-cycle synchronous read, holds previous output when en=0.
    drive_rom(1'b1, 3, 1'b1, 5);
    @(posedge clk); #1;
    check_rom(bank_word(0, 3), bank_word(0, 5), "rom first read");

    drive_rom(1'b0, 0, 1'b0, 0);
    @(posedge clk); #1;
    check_rom(bank_word(0, 3), bank_word(0, 5), "rom hold");

    drive_rom(1'b1, 7, 1'b1, 1);
    @(posedge clk); #1;
    check_rom(bank_word(0, 7), bank_word(0, 1), "rom second read");

    // slim_multi_bank_wbuf_dp: registered selectors + registered bank outputs.
    drive_slim('{0:0,1:1,2:2,3:3}, '{0:2,1:3,2:4,3:5}, 4'b1111, 4'b0000);
    @(posedge clk); #1;
    $display("[%0t] slim portA observe1 {0x%08h,0x%08h,0x%08h,0x%08h}", $time,
             slim_dout_sel[0], slim_dout_sel[1], slim_dout_sel[2], slim_dout_sel[3]);
    @(posedge clk); #1;
    check_slim_all(bank_word(0, 2), bank_word(1, 3), bank_word(2, 4), bank_word(3, 5), "slim portA");

    drive_slim('{0:1,1:2,2:4,3:5}, '{0:6,1:1,2:7,3:2}, 4'b1111, 4'b1111);
    @(posedge clk); #1;
    $display("[%0t] slim portB observe1 {0x%08h,0x%08h,0x%08h,0x%08h}", $time,
             slim_dout_sel[0], slim_dout_sel[1], slim_dout_sel[2], slim_dout_sel[3]);
    @(posedge clk); #1;
    check_slim_all(bank_word(1, 6), bank_word(2, 1), bank_word(4, 7), bank_word(5, 2), "slim portB");

    drive_slim('{default:'0}, '{default:'0}, 4'b0000, 4'b0000);
    @(posedge clk); #1;
    @(posedge clk); #1;
    check_slim_all(32'h0000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000, "slim disabled");

    $display("[%0t] PASS weight-bank storage consistency semantics", $time);
    #20;
    $finish;
  end
endmodule

