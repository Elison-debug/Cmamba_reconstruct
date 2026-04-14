module tb_slim_probe;
  localparam int N_BANK=6; localparam int DEPTH=8; localparam int ADDR_W=$clog2(DEPTH); localparam int DATA_W=32;
  logic clk=0; always #5 clk=~clk; logic rst_n;
  logic [3:0][$clog2(N_BANK)-1:0] bank_sel; logic [3:0][ADDR_W-1:0] addr_sel; logic [3:0] en_sel, port_sel; logic [3:0][DATA_W-1:0] dout_sel;
  slim_multi_bank_wbuf_dp #(.N_BANK(N_BANK),.DEPTH(DEPTH),.ADDR_W(ADDR_W),.DATA_W(DATA_W),
    .BANK0_INIT_FILE("E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank0.mem"),
    .BANK1_INIT_FILE("E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank1.mem"),
    .BANK2_INIT_FILE("E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank2.mem"),
    .BANK3_INIT_FILE("E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank3.mem"),
    .BANK4_INIT_FILE("E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank4.mem"),
    .BANK5_INIT_FILE("E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank5.mem")) dut(
    .clk(clk),.rst_n(rst_n),.bank_sel(bank_sel),.addr_sel(addr_sel),.en_sel(en_sel),.port_sel(port_sel),.dout_sel(dout_sel));
  initial begin rst_n=0; bank_sel='{default:'0}; addr_sel='{default:'0}; en_sel='0; port_sel='0; repeat(4) @(posedge clk); rst_n=1; #1;
    $display("mem00=%h mem02=%h mem10=%h", dut.mem_sim[0][0], dut.mem_sim[0][2], dut.mem_sim[1][0]);
    repeat(2) @(posedge clk);
    bank_sel='{0,1,2,3}; addr_sel='{2,3,4,5}; en_sel=4'b1111; port_sel=4'b0000;
    repeat(3) begin @(posedge clk); #1; $display("t=%0t q=%p enA=%b addrA0=%0d mem02=%h doutA0=%h dout0=%h",$time,dut.bank_sel_q,dut.enA_bank,dut.addrA_bank[0],dut.mem_sim[0][2],dut.doutA_r[0],dout_sel[0]); end
    $finish; end
endmodule
