`timescale 1ns/1ps
//---------------------------------------------------------------
// File: reuse_ip_blackboxes.sv
// Function:
//   Behavioral stand-ins for vendor/generated IP blocks.
//   These models are used only for functional simulation so the
//   board-shell path does not propagate X from empty black boxes.
//---------------------------------------------------------------

module bias_ROM (
    input  logic        clka,
    input  logic        ena,
    input  logic [5:0]  addra,
    output logic [63:0] douta
);
    localparam int DEPTH = 64;
    logic [63:0] mem [0:DEPTH-1];
    logic [63:0] dout_d1;

    initial begin
        for (int i = 0; i < DEPTH; i++)
            mem[i] = '0;
    end

    always_ff @(posedge clka) begin
        if (ena)
            dout_d1 <= mem[addra];
        douta <= dout_d1;
    end
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
    logic        full;
    logic [63:0] data_reg;

    assign s_axis_tready = !full || (m_axis_tvalid && m_axis_tready);
    assign m_axis_tvalid = full;
    assign m_axis_tdata  = data_reg;

    always_ff @(posedge s_aclk) begin
        if (!s_aresetn) begin
            full     <= 1'b0;
            data_reg <= '0;
        end else begin
            if (m_axis_tvalid && m_axis_tready)
                full <= 1'b0;

            if (s_axis_tvalid && s_axis_tready) begin
                data_reg <= s_axis_tdata;
                full     <= 1'b1;
            end
        end
    end
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
    localparam int DEPTH = 64;
    logic [63:0] mem [0:DEPTH-1];
    logic [63:0] douta_r;
    logic [63:0] doutb_r;

    initial begin
        for (int i = 0; i < DEPTH; i++)
            mem[i] = '0;
    end

    always_ff @(posedge clka) begin
        if (ena) begin
            if (|wea)
                mem[addra] <= dina;
            douta_r <= mem[addra];
        end
    end

    always_ff @(posedge clkb) begin
        if (enb) begin
            if (web)
                mem[addrb] <= dinb;
            doutb_r <= mem[addrb];
        end
    end

    assign douta = douta_r;
    assign doutb = doutb_r;
endmodule

module u_xt_rom (
    input  logic        clka,
    input  logic        ena,
    input  logic [5:0]  addra,
    input  logic        wea,
    input  logic [63:0] dina,
    output logic [63:0] douta
);
    localparam int DEPTH = 64;
    logic [63:0] mem [0:DEPTH-1];

    initial begin
        for (int i = 0; i < DEPTH; i++)
            mem[i] = '0;
    end

    always_ff @(posedge clka) begin
        if (ena) begin
            if (wea)
                mem[addra] <= dina;
            douta <= mem[addra];
        end
    end
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
    localparam int DEPTH = 32;
    logic [63:0] mem [0:DEPTH-1];

    initial begin
        for (int i = 0; i < DEPTH; i++)
            mem[i] = '0;
    end

    always_ff @(posedge clka) begin
        if (ena) begin
            if (wea)
                mem[addra] <= dina;
            douta <= mem[addra];
        end
    end

    always_ff @(posedge clkb) begin
        if (enb) begin
            if (web)
                mem[addrb] <= dinb;
            doutb <= mem[addrb];
        end
    end
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
    localparam int DEPTH = 64;
    logic [63:0] mem [0:DEPTH-1];

    initial begin
        for (int i = 0; i < DEPTH; i++)
            mem[i] = '0;
    end

    always_ff @(posedge clka) begin
        if (ena) begin
            if (wea)
                mem[addra] <= dina;
            douta <= mem[addra];
        end
    end

    always_ff @(posedge clkb) begin
        if (enb) begin
            if (web)
                mem[addrb] <= dinb;
            doutb <= mem[addrb];
        end
    end
endmodule
