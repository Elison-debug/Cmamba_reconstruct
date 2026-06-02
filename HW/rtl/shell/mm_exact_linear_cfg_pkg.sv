package slm_linear_cfg_pkg;
    typedef enum logic [1:0] {
        SLM_LINEAR_INPROJ  = 2'd0,
        SLM_LINEAR_DTPROJ  = 2'd1,
        SLM_LINEAR_OUTPROJ = 2'd2
    } slm_linear_role_t;

    typedef struct packed {
        slm_linear_role_t role;
        logic [1:0]            mode;
        logic                  reduce_rows;
        logic                  use_per_channel_scale;
        logic [7:0]            row_tiles;
        logic [7:0]            k_groups;
        logic [15:0]           stage_id;
    } slm_linear_desc_t;

    function automatic slm_linear_desc_t make_linear_desc(
        input slm_linear_role_t role,
        input logic [1:0] mode,
        input logic reduce_rows,
        input logic use_per_channel_scale,
        input logic [7:0] row_tiles,
        input logic [7:0] k_groups,
        input logic [15:0] stage_id
    );
        slm_linear_desc_t desc;
        begin
            desc.role = role;
            desc.mode = mode;
            desc.reduce_rows = reduce_rows;
            desc.use_per_channel_scale = use_per_channel_scale;
            desc.row_tiles = row_tiles;
            desc.k_groups = k_groups;
            desc.stage_id = stage_id;
            return desc;
        end
    endfunction
endpackage

