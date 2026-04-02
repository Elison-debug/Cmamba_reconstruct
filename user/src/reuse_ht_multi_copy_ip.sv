//---------------------------------------------------------------
// Module: reuse_ht_multi_copy_ip
// Function:
//   4-read-port h_t SRAM wrapper built from 4 copied dual-port RAM IPs.
//   All copies share the same write port; each copy serves one read port.
//---------------------------------------------------------------
module reuse_ht_multi_copy_ip #(
    parameter int DATA_W = 64,
    parameter int ADDR_W = 5
)(
    input  logic                clk,
    input  logic                wr_en,
    input  logic [ADDR_W-1:0]   wr_addr,
    input  logic [DATA_W-1:0]   wr_data,
    input  logic                rd_en,
    input  logic [ADDR_W-1:0]   rd_addr0,
    input  logic [ADDR_W-1:0]   rd_addr1,
    input  logic [ADDR_W-1:0]   rd_addr2,
    input  logic [ADDR_W-1:0]   rd_addr3,
    output logic [DATA_W-1:0]   rd_data0,
    output logic [DATA_W-1:0]   rd_data1,
    output logic [DATA_W-1:0]   rd_data2,
    output logic [DATA_W-1:0]   rd_data3
);
    inproj_ht_sram_ip u_copy0 (
        .clka (clk),
        .ena  (wr_en),
        .wea  (wr_en),
        .addra(wr_addr),
        .dina (wr_data),
        .douta(),
        .clkb (clk),
        .enb  (rd_en),
        .web  (1'b0),
        .addrb(rd_addr0),
        .dinb ('0),
        .doutb(rd_data0)
    );

    inproj_ht_sram_ip u_copy1 (
        .clka (clk),
        .ena  (wr_en),
        .wea  (wr_en),
        .addra(wr_addr),
        .dina (wr_data),
        .douta(),
        .clkb (clk),
        .enb  (rd_en),
        .web  (1'b0),
        .addrb(rd_addr1),
        .dinb ('0),
        .doutb(rd_data1)
    );

    inproj_ht_sram_ip u_copy2 (
        .clka (clk),
        .ena  (wr_en),
        .wea  (wr_en),
        .addra(wr_addr),
        .dina (wr_data),
        .douta(),
        .clkb (clk),
        .enb  (rd_en),
        .web  (1'b0),
        .addrb(rd_addr2),
        .dinb ('0),
        .doutb(rd_data2)
    );

    inproj_ht_sram_ip u_copy3 (
        .clka (clk),
        .ena  (wr_en),
        .wea  (wr_en),
        .addra(wr_addr),
        .dina (wr_data),
        .douta(),
        .clkb (clk),
        .enb  (rd_en),
        .web  (1'b0),
        .addrb(rd_addr3),
        .dinb ('0),
        .doutb(rd_data3)
    );
endmodule
