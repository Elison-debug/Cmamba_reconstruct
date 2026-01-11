// ============================================================
// pulse_to_stream_adapter.sv
// Function:
//   Convert a 1-cycle "event pulse" + data (pulse_valid/pulse_vec)
//   into a standard ready/valid stream (out_valid/out_ready/out_vec).
//
// Key properties (streaming compliant):
//   - Once out_valid=1, out_vec stays constant until out_ready=1
//   - If pulse_valid arrives while buffer full and not being freed,
//     the new pulse is NOT accepted (would be dropped). In your case
//     pulses are sparse, so this is OK.
//   - If a pulse arrives in the same cycle the previous output is
//     being consumed (fire), it will be accepted (no bubble).
// ============================================================
module pulse_to_stream_adapter #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16
)(
    input  logic clk,
    input  logic rst_n,

    // Input: 1-cycle event pulse + data
    input  logic                             pulse_valid,
    input  logic signed [DATA_WIDTH-1:0]      pulse_vec [TILE_SIZE-1:0],

    // Output: standard ready/valid stream
    output logic                             out_valid,
    input  logic                             out_ready,
    output logic signed [DATA_WIDTH-1:0]      out_vec [TILE_SIZE-1:0]
);

    logic hold_valid;
    wire  fire = hold_valid && out_ready; // output is consumed this cycle

    assign out_valid = hold_valid;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hold_valid <= 1'b0;
            out_vec    <= '{default:'0};
        end else begin
            // 1) If downstream consumed the held item, clear the flag
            if (fire) begin
                hold_valid <= 1'b0;
            end

            // 2) Capture a new pulse if buffer is free OR being freed this cycle
            if (pulse_valid && (!hold_valid || fire)) begin
                hold_valid <= 1'b1;
                out_vec    <= pulse_vec;
            end
        end
    end

endmodule
