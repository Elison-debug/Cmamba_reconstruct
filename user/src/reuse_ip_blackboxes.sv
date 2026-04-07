//---------------------------------------------------------------
// File: reuse_ip_blackboxes.sv
// Function:
//   Placeholder declarations for vendor/generated IP blocks that
//   are referenced by the reuse-oriented RTL but do not have local
//   synthesizable RTL sources in this repository.
//---------------------------------------------------------------

module bias_ROM (
    input  logic        clka,
    input  logic        ena,
    input  logic [5:0]  addra,
    output logic [63:0] douta
);
endmodule

module bias2sigmoid_fifo (
    input  logic        s_aclk,
    input  logic        s_aresetn,
    input  logic        s_axis_tvalid,
    output logic        s_axis_tready,
    input  logic [63:0] s_axis_tdata,
    output logic        m_axis_tvalid,
    input  logic        m_axis_tready,
    output logic [63:0] m_axis_tdata
);
endmodule

module s_buffer (
    input  logic        clka,
    input  logic        ena,
    input  logic [7:0]  wea,
    input  logic [5:0]  addra,
    input  logic [63:0] dina,
    output logic [63:0] douta,
    input  logic        clkb,
    input  logic        enb,
    input  logic        web,
    input  logic [5:0]  addrb,
    input  logic [63:0] dinb,
    output logic [63:0] doutb
);
endmodule

module slim_WBUF_bank_dp (
    input  logic         clka,
    input  logic         ena,
    input  logic [9:0]   addra,
    output logic [255:0] douta,
    input  logic         clkb,
    input  logic         enb,
    input  logic [9:0]   addrb,
    output logic [255:0] doutb
);
endmodule

module u_xt_rom (
    input  logic        clka,
    input  logic        ena,
    input  logic [5:0]  addra,
    input  logic        wea,
    input  logic [63:0] dina,
    output logic [63:0] douta
);
endmodule

module inproj_ht_sram_ip (
    input  logic        clka,
    input  logic        ena,
    input  logic        wea,
    input  logic [4:0]  addra,
    input  logic [63:0] dina,
    output logic [63:0] douta,
    input  logic        clkb,
    input  logic        enb,
    input  logic        web,
    input  logic [4:0]  addrb,
    input  logic [63:0] dinb,
    output logic [63:0] doutb
);
endmodule

module inproj_vec_out_sram_ip (
    input  logic        clka,
    input  logic        ena,
    input  logic        wea,
    input  logic [5:0]  addra,
    input  logic [63:0] dina,
    output logic [63:0] douta,
    input  logic        clkb,
    input  logic        enb,
    input  logic        web,
    input  logic [5:0]  addrb,
    input  logic [63:0] dinb,
    output logic [63:0] doutb
);
endmodule
