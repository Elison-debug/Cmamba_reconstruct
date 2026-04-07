//---------------------------------------------------------------
// Module: reuse_vec_out_sram_ip
// Function:
//   2-read-port vector SRAM wrapper built from 2 copied dual-port RAM IPs.
//   Both copies share the same write port; each copy serves one read port.
//---------------------------------------------------------------
module reuse_vec_out_sram_ip #(
    parameter int DATA_W = 64,
    parameter int ADDR_W = 6
)(
    input  logic              clk,
    input  logic              wr_en,
    input  logic [ADDR_W-1:0] wr_addr,
    input  logic [DATA_W-1:0] wr_data,
    input  logic              rd_en,
    input  logic [ADDR_W-1:0] rd_addr,
    output logic [DATA_W-1:0] rd_data,
    input  logic              rd2_en,
    input  logic [ADDR_W-1:0] rd2_addr,
    output logic [DATA_W-1:0] rd2_data
);
    inproj_vec_out_sram_ip u_copy0 (
        .clka (clk),
        .ena  (wr_en),
        .wea  (wr_en),
        .addra(wr_addr),
        .dina (wr_data),
        .douta(),
        .clkb (clk),
        .enb  (rd_en),
        .web  (1'b0),
        .addrb(rd_addr),
        .dinb ('0),
        .doutb(rd_data)
    );

    inproj_vec_out_sram_ip u_copy1 (
        .clka (clk),
        .ena  (wr_en),
        .wea  (wr_en),
        .addra(wr_addr),
        .dina (wr_data),
        .douta(),
        .clkb (clk),
        .enb  (rd2_en),
        .web  (1'b0),
        .addrb(rd2_addr),
        .dinb ('0),
        .doutb(rd2_data)
    );
endmodule
