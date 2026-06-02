//---------------------------------------------------------------
// Module: reuse_in_proj_scheduler
// Function:
//   in_proj scheduler using the shared 4x4x4 MAC fabric.
//   This version follows the dt-style controller skeleton:
//   - IDLE / RUN_PIPELINE / WAIT_DONE / WRITE / DONE
//   - A-path updates are staggered by en_sel/en_sel_reg windows
//   - B-path uses curr/next group registers with gradual stage switching
//---------------------------------------------------------------
module reuse_in_proj_scheduler #(
    parameter int TILE_SIZE   = 4,
    parameter int DATA_WIDTH  = 16,
    parameter int ACC_WIDTH   = 32,
    parameter int FRAC_BITS   = 8,
    parameter int N_BANK      = 6,
    parameter int WDEPTH      = 1024,
    parameter int WADDR_W     = $clog2(WDEPTH),
    parameter int DATA_W      = 256,
    parameter int IN_DIM      = 128,
    parameter int OUT_DIM     = 512,
    parameter int H_DEPTH     = IN_DIM / TILE_SIZE,
    parameter int H_ADDR_W    = $clog2(H_DEPTH),
    parameter int U_DEPTH     = (OUT_DIM/2) / TILE_SIZE,
    parameter int U_ADDR_W    = $clog2(U_DEPTH),
    parameter int SCALE_W            = 16,
    parameter int SCALE_FRAC_BITS    = 15,
    parameter bit USE_PER_CHANNEL_SCALE = 0,
    parameter string INPROJ_BANK0_INIT_FILE = "",
    parameter string INPROJ_BANK1_INIT_FILE = "",
    parameter string INPROJ_BANK2_INIT_FILE = "",
    parameter string INPROJ_BANK3_INIT_FILE = "",
    parameter string INPROJ_BANK4_INIT_FILE = "",
    parameter string INPROJ_BANK5_INIT_FILE = "",
    parameter string INPROJ_SCALE_INIT_FILE = "",
    parameter int REQUANT_ROUND_MODE = 1,
    parameter int REQUANT_SAT_MODE   = 1
)(
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    input  logic start,
    output logic busy,
    output logic done,

    input  logic                          h_wr_en,
    input  logic [H_ADDR_W-1:0]           h_wr_addr,
    input  logic signed [DATA_WIDTH-1:0]  h_wr_data [TILE_SIZE-1:0],

    input  logic                          u_rd_en,
    input  logic [U_ADDR_W-1:0]           u_rd_addr,
    output logic signed [DATA_WIDTH-1:0]  u_rd_data [TILE_SIZE-1:0],
    input  logic                          u_ssm_rd_en,
    input  logic [U_ADDR_W-1:0]           u_ssm_rd_addr,
    output logic signed [DATA_WIDTH-1:0]  u_ssm_rd_data [TILE_SIZE-1:0],
    input  logic                          z_rd_en,
    input  logic [U_ADDR_W-1:0]           z_rd_addr,
    output logic signed [DATA_WIDTH-1:0]  z_rd_data [TILE_SIZE-1:0],
    input  logic                          z_gate_rd_en,
    input  logic [U_ADDR_W-1:0]           z_gate_rd_addr,
    output logic signed [DATA_WIDTH-1:0]  z_gate_rd_data [TILE_SIZE-1:0],

    output logic [1:0]                    fabric_mode,
    output logic [6:0]                    fabric_col_blocks,
    output logic                          fabric_valid_in,
    output logic signed [DATA_WIDTH-1:0]  fabric_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_vec [TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic                          fabric_valid_out
);
    localparam int ROW_GROUPS    = OUT_DIM / (TILE_SIZE * 4); // 32 groups, each covers 16 rows
    localparam int ROWS_PER_GRP  = 4;                         // 4 output tiles per group
    localparam int ROW_TILES     = OUT_DIM / TILE_SIZE;       // 128 4-row tiles
    localparam int K_GROUPS      = IN_DIM / (TILE_SIZE * 4);  // 8 groups, each covers 16 input dims
    localparam int PHYS_K_BLOCKS = IN_DIM / TILE_SIZE;        // 32 physical 4-dim tiles
    localparam int TILE_CYCLE    = K_GROUPS + 3;             // 8 valid + 3 stagger drain
    localparam int OUT_PHASE_LAST = K_GROUPS + 2;            // 0..10 then clear on next beat
    localparam int SCALE_DEPTH   = ROW_TILES;
    localparam int SCALE_ADDR_W  = $clog2(SCALE_DEPTH);

    typedef enum logic [2:0] { IDLE, RUN_PIPELINE, WAIT_DONE, WRITE, DONE_S } state_t;
    state_t state, next_state;

    logic [$clog2(ROW_GROUPS)-1:0] row_group_idx;
    logic [1:0]                    row_subtile_idx;
    logic [$clog2(ROW_TILES)-1:0]  row_tile_linear;
    logic [$clog2(ROW_GROUPS)-1:0] write_row_group_idx;
    logic [1:0]                    write_row_subtile_idx;
    logic [$clog2(ROW_TILES)-1:0]  write_row_tile_linear;
    logic [$clog2(K_GROUPS+1)-1:0] data_cnt;
    logic [$clog2(TILE_CYCLE+2)-1:0] tile_cnt, tile_cnt_d;
    logic [1:0]                    drain_cnt;

    logic                          h_rd_en;
    logic [H_ADDR_W-1:0]           h_rd_addr0, h_rd_addr1, h_rd_addr2, h_rd_addr3;
    logic signed [DATA_WIDTH-1:0]  h_rd_data0 [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  h_rd_data1 [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  h_rd_data2 [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  h_rd_data3 [TILE_SIZE-1:0];
    logic                          fetch_fire_d1, fetch_fire_d2, fetch_fire_d3;

    logic [3:0][$clog2(N_BANK)-1:0] w_bank_sel;
    logic [3:0][WADDR_W-1:0]        w_addr_sel;
    logic [3:0]                     w_en_sel;
    logic [3:0]                     w_port_sel;
    logic [3:0][DATA_W-1:0]         w_dout_sel;
    logic                           scale_rd_en;
    logic [SCALE_ADDR_W-1:0]        scale_rd_addr;
    logic [63:0]                    scale_rd_data;

    logic [3:0]                    en_sel, en_sel_reg, out_sel;
    logic [$clog2(K_GROUPS+5)-1:0] out_phase_cnt;
    logic                          out_phase_active;
    logic [1:0]                    phase_reg;

    logic signed [DATA_WIDTH-1:0] cur_A0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] cur_A1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] cur_A2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] cur_A3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A0_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A1_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A2_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A3_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A2_hold1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A3_hold1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A3_hold2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A0_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A1_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A2_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A3_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];

    logic signed [DATA_WIDTH-1:0] cur_B0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] cur_B1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] cur_B2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] cur_B3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B0_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B1_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B2_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B3_hold [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B2_hold1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B3_hold1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B3_hold2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B0_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B1_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B2_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B3_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic                         valid_in_d1, valid_in_d2;

    logic                         seen_valid;
    logic signed [ACC_WIDTH-1:0]  final_vec [TILE_SIZE-1:0];
    logic                         u_wr_en, z_wr_en;
    logic [U_ADDR_W-1:0]          out_wr_addr;
    logic signed [DATA_WIDTH-1:0] out_wr_data [TILE_SIZE-1:0];
    logic [DATA_WIDTH-1:0]        out_wr_data_u [TILE_SIZE-1:0];
    logic [ACC_WIDTH-1:0]         final_vec_u [TILE_SIZE-1:0];
    logic [SCALE_W-1:0]           out_scale_vec [TILE_SIZE-1:0];
    logic                         valid_in;

    assign row_tile_linear       = row_group_idx * ROWS_PER_GRP + row_subtile_idx;
    assign write_row_tile_linear = write_row_group_idx * ROWS_PER_GRP + write_row_subtile_idx;

    reuse_inproj_weight_sram #(
        .N_BANK (N_BANK),
        .DEPTH  (WDEPTH),
        .ADDR_W (WADDR_W),
        .DATA_W (DATA_W),
        .BANK0_INIT_FILE (INPROJ_BANK0_INIT_FILE),
        .BANK1_INIT_FILE (INPROJ_BANK1_INIT_FILE),
        .BANK2_INIT_FILE (INPROJ_BANK2_INIT_FILE),
        .BANK3_INIT_FILE (INPROJ_BANK3_INIT_FILE),
        .BANK4_INIT_FILE (INPROJ_BANK4_INIT_FILE),
        .BANK5_INIT_FILE (INPROJ_BANK5_INIT_FILE)
    ) u_w_sram (
        .clk(clk),
        .rst_n(rst_n),
        .bank_sel(w_bank_sel),
        .addr_sel(w_addr_sel),
        .en_sel(w_en_sel),
        .port_sel(w_port_sel),
        .dout_sel(w_dout_sel)
    );

    reuse_ht_sram #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (H_DEPTH),
        .ADDR_W    (H_ADDR_W)
    ) u_h_sram (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(h_wr_en),
        .wr_addr(h_wr_addr),
        .wr_data(h_wr_data),
        .rd_en(h_rd_en),
        .rd_addr0(h_rd_addr0),
        .rd_addr1(h_rd_addr1),
        .rd_addr2(h_rd_addr2),
        .rd_addr3(h_rd_addr3),
        .rd_data0(h_rd_data0),
        .rd_data1(h_rd_data1),
        .rd_data2(h_rd_data2),
        .rd_data3(h_rd_data3)
    );

    reuse_vec_out_sram #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (U_DEPTH),
        .ADDR_W    (U_ADDR_W)
    ) u_u_sram (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(u_wr_en),
        .wr_addr(out_wr_addr),
        .wr_data(out_wr_data),
        .rd_en(u_rd_en),
        .rd_addr(u_rd_addr),
        .rd_data(u_rd_data),
        .rd2_en(u_ssm_rd_en),
        .rd2_addr(u_ssm_rd_addr),
        .rd2_data(u_ssm_rd_data)
    );

    reuse_vec_out_sram #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (U_DEPTH),
        .ADDR_W    (U_ADDR_W)
    ) u_z_sram (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(z_wr_en),
        .wr_addr(out_wr_addr),
        .wr_data(out_wr_data),
        .rd_en(z_rd_en),
        .rd_addr(z_rd_addr),
        .rd_data(z_rd_data),
        .rd2_en(z_gate_rd_en),
        .rd2_addr(z_gate_rd_addr),
        .rd2_data(z_gate_rd_data)
    );

    assign fabric_mode       = 2'b00;
    assign fabric_col_blocks = K_GROUPS;
    assign busy              = (state != IDLE && state != DONE_S);
    assign done              = (state == DONE_S);
    assign valid_in          = (state == RUN_PIPELINE) && (data_cnt < K_GROUPS);
    assign h_rd_en           = enable && valid_in;
    assign fabric_valid_in   = valid_in_d2;
    assign scale_rd_en       = enable && (state == RUN_PIPELINE) && (data_cnt == '0);
    assign scale_rd_addr     = row_tile_linear[SCALE_ADDR_W-1:0];

    reuse_packed_scale_mem #(
        .DEPTH     (SCALE_DEPTH),
        .ADDR_W    (SCALE_ADDR_W),
        .DATA_W    (64),
        .INIT_FILE (INPROJ_SCALE_INIT_FILE)
    ) u_scale_mem (
        .clk  (clk),
        .en   (scale_rd_en),
        .addr (scale_rd_addr),
        .dout (scale_rd_data)
    );

    always_comb begin
        int aligned_addr;

        h_rd_addr0 = '0;
        h_rd_addr1 = '0;
        h_rd_addr2 = '0;
        h_rd_addr3 = '0;
        w_bank_sel = '0;
        w_addr_sel = '0;
        w_en_sel   = '0;
        w_port_sel = '0;

        if (valid_in) begin
            h_rd_addr0 = data_cnt * 4 + 0;
            h_rd_addr1 = data_cnt * 4 + 1;
            h_rd_addr2 = data_cnt * 4 + 2;
            h_rd_addr3 = data_cnt * 4 + 3;

            aligned_addr = row_tile_linear * K_GROUPS + data_cnt;
            w_bank_sel[0] = 0;
            w_bank_sel[1] = 1;
            w_bank_sel[2] = 2;
            w_bank_sel[3] = 3;
            w_addr_sel[0] = aligned_addr[WADDR_W-1:0];
            w_addr_sel[1] = aligned_addr[WADDR_W-1:0];
            w_addr_sel[2] = aligned_addr[WADDR_W-1:0];
            w_addr_sel[3] = aligned_addr[WADDR_W-1:0];
            w_en_sel      = 4'b1111;
            w_port_sel    = '0;
        end
    end

    always_comb begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
            out_scale_vec[lane] = scale_rd_data[lane*SCALE_W +: SCALE_W];
        end
    end

    always_comb begin
        cur_A0 = '{default:'0};
        cur_A1 = '{default:'0};
        cur_A2 = '{default:'0};
        cur_A3 = '{default:'0};
        cur_B0 = '{default:'0};
        cur_B1 = '{default:'0};
        cur_B2 = '{default:'0};
        cur_B3 = '{default:'0};

        for (int i = 0; i < TILE_SIZE; i++) begin
            cur_A0[i][0] = w_dout_sel[0][(i*TILE_SIZE+0)*DATA_WIDTH +: DATA_WIDTH];
            cur_A0[i][1] = w_dout_sel[0][(i*TILE_SIZE+1)*DATA_WIDTH +: DATA_WIDTH];
            cur_A0[i][2] = w_dout_sel[0][(i*TILE_SIZE+2)*DATA_WIDTH +: DATA_WIDTH];
            cur_A0[i][3] = w_dout_sel[0][(i*TILE_SIZE+3)*DATA_WIDTH +: DATA_WIDTH];

            cur_A1[i][0] = w_dout_sel[1][(i*TILE_SIZE+0)*DATA_WIDTH +: DATA_WIDTH];
            cur_A1[i][1] = w_dout_sel[1][(i*TILE_SIZE+1)*DATA_WIDTH +: DATA_WIDTH];
            cur_A1[i][2] = w_dout_sel[1][(i*TILE_SIZE+2)*DATA_WIDTH +: DATA_WIDTH];
            cur_A1[i][3] = w_dout_sel[1][(i*TILE_SIZE+3)*DATA_WIDTH +: DATA_WIDTH];

            cur_A2[i][0] = w_dout_sel[2][(i*TILE_SIZE+0)*DATA_WIDTH +: DATA_WIDTH];
            cur_A2[i][1] = w_dout_sel[2][(i*TILE_SIZE+1)*DATA_WIDTH +: DATA_WIDTH];
            cur_A2[i][2] = w_dout_sel[2][(i*TILE_SIZE+2)*DATA_WIDTH +: DATA_WIDTH];
            cur_A2[i][3] = w_dout_sel[2][(i*TILE_SIZE+3)*DATA_WIDTH +: DATA_WIDTH];

            cur_A3[i][0] = w_dout_sel[3][(i*TILE_SIZE+0)*DATA_WIDTH +: DATA_WIDTH];
            cur_A3[i][1] = w_dout_sel[3][(i*TILE_SIZE+1)*DATA_WIDTH +: DATA_WIDTH];
            cur_A3[i][2] = w_dout_sel[3][(i*TILE_SIZE+2)*DATA_WIDTH +: DATA_WIDTH];
            cur_A3[i][3] = w_dout_sel[3][(i*TILE_SIZE+3)*DATA_WIDTH +: DATA_WIDTH];

            for (int j = 0; j < TILE_SIZE; j++) begin
                cur_B0[i][j] = h_rd_data0[j];
                cur_B1[i][j] = h_rd_data1[j];
                cur_B2[i][j] = h_rd_data2[j];
                cur_B3[i][j] = h_rd_data3[j];
            end
        end
    end

    always_comb begin
        en_sel[0] = (state == RUN_PIPELINE) && (tile_cnt >= 0) && (tile_cnt < K_GROUPS);
        en_sel[1] = (state == RUN_PIPELINE) && (tile_cnt >= 1) && (tile_cnt < K_GROUPS + 1);
        en_sel[2] = (state == RUN_PIPELINE) && (tile_cnt >= 2) && (tile_cnt < K_GROUPS + 2);
        en_sel[3] = (state == RUN_PIPELINE) && (tile_cnt >= 3) && (tile_cnt < K_GROUPS + 3);
    end

    always_comb begin
        out_sel[0] = out_phase_active && (out_phase_cnt >= 0) && (out_phase_cnt < K_GROUPS);
        out_sel[1] = out_phase_active && (out_phase_cnt >= 1) && (out_phase_cnt < K_GROUPS + 1);
        out_sel[2] = out_phase_active && (out_phase_cnt >= 2) && (out_phase_cnt < K_GROUPS + 2);
        out_sel[3] = out_phase_active && (out_phase_cnt >= 3) && (out_phase_cnt < K_GROUPS + 3);
    end

    for (genvar g = 0; g < TILE_SIZE; g++) begin : gen_final_vec_cast
        assign final_vec_u[g] = final_vec[g];
    end

    requant_round_sat_engine #(
        .TILE_SIZE  (TILE_SIZE),
        .IN_W       (ACC_WIDTH),
        .OUT_W      (DATA_WIDTH),
        .SHIFT      (FRAC_BITS),
        .SCALE_W    (SCALE_W),
        .SCALE_FRAC_BITS(SCALE_FRAC_BITS),
        .SIGNED_IN  (1),
        .SIGNED_OUT (1),
        .USE_SCALE  (USE_PER_CHANNEL_SCALE),
        .ROUND_MODE (REQUANT_ROUND_MODE),
        .SAT_MODE   (REQUANT_SAT_MODE)
    ) u_out_requant (
        .in_vec  (final_vec_u),
        .scale_vec(out_scale_vec),
        .out_vec (out_wr_data_u)
    );

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            out_wr_data[i] = $signed(out_wr_data_u[i]);
        end

        if (write_row_tile_linear >= U_DEPTH)
            out_wr_addr = write_row_tile_linear - U_DEPTH;
        else
            out_wr_addr = write_row_tile_linear[U_ADDR_W-1:0];
    end

    assign u_wr_en = (state == WRITE) && (write_row_tile_linear < U_DEPTH);
    assign z_wr_en = (state == WRITE) && (write_row_tile_linear >= U_DEPTH);

    always_comb begin
        fabric_A0_mat = A0_mat_reg;
        fabric_A1_mat = A1_mat_reg;
        fabric_A2_mat = A2_mat_reg;
        fabric_A3_mat = A3_mat_reg;
        fabric_B0_mat = B0_mat_reg;
        fabric_B1_mat = B1_mat_reg;
        fabric_B2_mat = B2_mat_reg;
        fabric_B3_mat = B3_mat_reg;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (enable && start)
                    next_state = RUN_PIPELINE;
            end
            RUN_PIPELINE: begin
                if (data_cnt >= K_GROUPS) begin
                    if (drain_cnt == 0)
                        next_state = WAIT_DONE;
                    else
                        next_state = RUN_PIPELINE;
                end
            end
            WAIT_DONE: begin
                if (seen_valid && !fabric_valid_out)
                    next_state = WRITE;
            end
            WRITE: begin
                if (row_group_idx == ROW_GROUPS-1 && row_subtile_idx == ROWS_PER_GRP-1)
                    next_state = DONE_S;
                else
                    next_state = RUN_PIPELINE;
            end
            DONE_S: begin
                if (!start)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state         <= IDLE;
            row_group_idx <= '0;
            row_subtile_idx <= '0;
            write_row_group_idx <= '0;
            write_row_subtile_idx <= '0;
            data_cnt      <= '0;
            tile_cnt      <= '0;
            tile_cnt_d    <= '0;
            drain_cnt     <= '0;
            fetch_fire_d1 <= 1'b0;
            fetch_fire_d2 <= 1'b0;
            fetch_fire_d3 <= 1'b0;
            en_sel_reg    <= '0;
            phase_reg     <= '0;
            seen_valid    <= 1'b0;
            final_vec     <= '{default:'0};
            A0_hold       <= '{default:'0};
            A1_hold       <= '{default:'0};
            A2_hold       <= '{default:'0};
            A3_hold       <= '{default:'0};
            A2_hold1      <= '{default:'0};
            A3_hold1      <= '{default:'0};
            A3_hold2      <= '{default:'0};
            A0_mat_reg    <= '{default:'0};
            A1_mat_reg    <= '{default:'0};
            A2_mat_reg    <= '{default:'0};
            A3_mat_reg    <= '{default:'0};
            B0_mat_reg    <= '{default:'0};
            B1_mat_reg    <= '{default:'0};
            B2_mat_reg    <= '{default:'0};
            B3_mat_reg    <= '{default:'0};
            B0_hold       <= '{default:'0};
            B1_hold       <= '{default:'0};
            B2_hold       <= '{default:'0};
            B3_hold       <= '{default:'0};
            B2_hold1      <= '{default:'0};
            B3_hold1      <= '{default:'0};
            B3_hold2      <= '{default:'0};
            valid_in_d1   <= 1'b0;
            valid_in_d2   <= 1'b0;
            out_phase_cnt <= '0;
            out_phase_active <= 1'b0;
        end else begin
            state         <= next_state;
            fetch_fire_d1 <= valid_in;
            fetch_fire_d2 <= fetch_fire_d1;
            fetch_fire_d3 <= fetch_fire_d2;
            valid_in_d1   <= valid_in;
            valid_in_d2   <= valid_in_d1;
            en_sel_reg    <= en_sel;
            tile_cnt_d    <= tile_cnt;

            if (fabric_valid_out) begin
                seen_valid <= 1'b1;
                for (int i = 0; i < TILE_SIZE; i++) begin
                    final_vec[i] <= fabric_reduced_vec[i];
                end
            end

            if (state == IDLE) begin
                data_cnt       <= '0;
                tile_cnt       <= '0;
                drain_cnt      <= 2'd3;
                row_group_idx  <= '0;
                row_subtile_idx <= '0;
                write_row_group_idx <= '0;
                write_row_subtile_idx <= '0;
                seen_valid     <= 1'b0;
                en_sel_reg     <= '0;
                phase_reg      <= '0;
                A0_mat_reg     <= '{default:'0};
                A1_mat_reg     <= '{default:'0};
                A2_mat_reg     <= '{default:'0};
                A3_mat_reg     <= '{default:'0};
                B0_mat_reg     <= '{default:'0};
                B1_mat_reg     <= '{default:'0};
                B2_mat_reg     <= '{default:'0};
                B3_mat_reg     <= '{default:'0};
                B0_hold       <= '{default:'0};
                B1_hold       <= '{default:'0};
                B2_hold       <= '{default:'0};
                B3_hold       <= '{default:'0};
                B2_hold1      <= '{default:'0};
                B3_hold1      <= '{default:'0};
                B3_hold2      <= '{default:'0};
                out_phase_cnt  <= '0;
                out_phase_active <= 1'b0;
                A2_hold1      <= '{default:'0};
                A3_hold1      <= '{default:'0};
                A3_hold2      <= '{default:'0};
            end

            if (state == RUN_PIPELINE) begin
                if (valid_in) begin
                    data_cnt <= data_cnt + 1'b1;
                end else if (drain_cnt != 0) begin
                    drain_cnt <= drain_cnt - 1'b1;
                end

                if (tile_cnt < TILE_CYCLE)
                    tile_cnt <= tile_cnt + 1'b1;

                if (phase_reg == 2'd2)
                    phase_reg <= 2'd0;
                else
                    phase_reg <= phase_reg + 2'd1;

                if (out_phase_active) begin
                    if (out_phase_cnt >= OUT_PHASE_LAST) begin
                        out_phase_active <= 1'b0;
                        out_phase_cnt    <= '0;
                        A0_hold          <= '{default:'0};
                        A1_hold          <= '{default:'0};
                        A2_hold          <= '{default:'0};
                        A3_hold          <= '{default:'0};
                        A2_hold1         <= '{default:'0};
                        A3_hold1         <= '{default:'0};
                        A3_hold2         <= '{default:'0};
                        A0_mat_reg       <= '{default:'0};
                        A1_mat_reg       <= '{default:'0};
                        A2_mat_reg       <= '{default:'0};
                        A3_mat_reg       <= '{default:'0};
                        B0_mat_reg       <= '{default:'0};
                        B1_mat_reg       <= '{default:'0};
                        B2_mat_reg       <= '{default:'0};
                        B3_mat_reg       <= '{default:'0};
                    end else begin
                        out_phase_cnt <= out_phase_cnt + 1'b1;
                    end
                end
            end

            if (state == WAIT_DONE && next_state == WRITE) begin
                write_row_group_idx   <= row_group_idx;
                write_row_subtile_idx <= row_subtile_idx;
            end

            if (fetch_fire_d1) begin
                A0_hold <= cur_A0;
                A1_hold <= cur_A1;
                A2_hold <= cur_A2;
                A3_hold <= cur_A3;
                B0_hold <= cur_B0;
                B1_hold <= cur_B1;
                B2_hold <= cur_B2;
                B3_hold <= cur_B3;
            end

            if (fetch_fire_d2) begin
                A2_hold1 <= A2_hold;
                A3_hold1 <= A3_hold;
                B2_hold1 <= B2_hold;
                B3_hold1 <= B3_hold;
            end

            if (fetch_fire_d3) begin
                A3_hold2 <= A3_hold1;
                B3_hold2 <= B3_hold1;
            end

            if (fetch_fire_d1) begin
                out_phase_active <= 1'b1;
                out_phase_cnt    <= '0;
                B0_mat_reg       <= cur_B0;
            end

            if (out_phase_active && out_phase_cnt == K_GROUPS-1)
                A0_mat_reg <= '{default:'0};
            else if (en_sel_reg[0])
                A0_mat_reg <= cur_A0;

            if (out_phase_active && out_phase_cnt == K_GROUPS)
                A1_mat_reg <= '{default:'0};
            else if (en_sel_reg[1])
                A1_mat_reg <= A1_hold;

            if (out_phase_active && out_phase_cnt == K_GROUPS+1)
                A2_mat_reg <= '{default:'0};
            else if (en_sel_reg[2])
                A2_mat_reg <= A2_hold1;

            if (out_phase_active && out_phase_cnt == K_GROUPS+2)
                A3_mat_reg <= '{default:'0};
            else if (en_sel_reg[3])
                A3_mat_reg <= A3_hold2;

            if (out_phase_active && out_phase_cnt == K_GROUPS-1)
                B0_mat_reg <= '{default:'0};
            else if (en_sel_reg[0])
                B0_mat_reg <= cur_B0;

            if (out_phase_active && out_phase_cnt == K_GROUPS)
                B1_mat_reg <= '{default:'0};
            else if (en_sel_reg[1])
                B1_mat_reg <= B1_hold;

            if (out_phase_active && out_phase_cnt == K_GROUPS+1)
                B2_mat_reg <= '{default:'0};
            else if (en_sel_reg[2])
                B2_mat_reg <= B2_hold1;

            if (out_phase_active && out_phase_cnt == K_GROUPS+2)
                B3_mat_reg <= '{default:'0};
            else if (en_sel_reg[3])
                B3_mat_reg <= B3_hold2;

            if (state == WRITE) begin
                seen_valid <= 1'b0;
                data_cnt   <= '0;
                tile_cnt   <= '0;
                drain_cnt  <= 2'd3;
                out_phase_active <= 1'b0;
                out_phase_cnt    <= '0;
                if (row_subtile_idx == ROWS_PER_GRP-1) begin
                    row_subtile_idx <= '0;
                    if (row_group_idx != ROW_GROUPS-1)
                        row_group_idx <= row_group_idx + 1'b1;
                end else begin
                    row_subtile_idx <= row_subtile_idx + 1'b1;
                end
            end
        end
    end
endmodule
