module vec_fifo_axis_ip #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16
)(
    input  logic clk,
    input  logic rst_n,
    input  logic in_valid,
    output logic in_ready,
    input  logic signed [DATA_WIDTH-1:0] in_vec [TILE_SIZE-1:0],
    output logic out_valid,
    input  logic out_ready,
    output logic signed [DATA_WIDTH-1:0] out_vec [TILE_SIZE-1:0]
);
    logic v0, v1;
    logic signed [DATA_WIDTH-1:0] d0 [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] d1 [TILE_SIZE-1:0];

    wire pop0 = v0 && out_ready;
    assign in_ready = ~v1;
    wire push = in_valid && in_ready;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            v0 <= 1'b0;
            v1 <= 1'b0;
            for (int i = 0; i < TILE_SIZE; i++) begin
                d0[i] <= '0;
                d1[i] <= '0;
            end
        end else begin
            if (pop0) begin
                if (v1) begin
                    d0 <= d1;
                    v0 <= 1'b1;
                    v1 <= 1'b0;
                end else begin
                    v0 <= 1'b0;
                end
            end

            if (push) begin
                if (!v0 || (pop0 && !v1)) begin
                    d0 <= in_vec;
                    v0 <= 1'b1;
                end else begin
                    d1 <= in_vec;
                    v1 <= 1'b1;
                end
            end
        end
    end

    assign out_valid = v0;
    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            out_vec[i] = d0[i];
        end
    end
endmodule

