package slm_block_cfg_pkg;
    import slm_linear_cfg_pkg::*;

    typedef struct packed {
        slm_linear_desc_t inproj_desc;
        slm_linear_desc_t dt_desc;
        slm_linear_desc_t outproj_desc;
        logic                  use_scaled_state_scan;
        logic                  state_continuous_default;
    } slm_block_cfg_t;

    function automatic slm_block_cfg_t make_block_cfg(
        input slm_linear_desc_t inproj_desc,
        input slm_linear_desc_t dt_desc,
        input slm_linear_desc_t outproj_desc,
        input logic use_scaled_state_scan,
        input logic state_continuous_default
    );
        slm_block_cfg_t cfg;
        begin
            cfg.inproj_desc = inproj_desc;
            cfg.dt_desc = dt_desc;
            cfg.outproj_desc = outproj_desc;
            cfg.use_scaled_state_scan = use_scaled_state_scan;
            cfg.state_continuous_default = state_continuous_default;
            return cfg;
        end
    endfunction

    function automatic slm_block_cfg_t make_block_cfg_from_flags(
        input logic inproj_use_per_channel_scale,
        input logic dt_use_per_channel_scale,
        input logic outproj_use_per_channel_scale,
        input logic use_scaled_state_scan,
        input logic state_continuous_default
    );
        return make_block_cfg(
            make_linear_desc(SLM_LINEAR_INPROJ, 2'b00, 1'b1, inproj_use_per_channel_scale, 8'd128, 8'd8, 16'd1),
            make_linear_desc(SLM_LINEAR_DTPROJ, 2'b00, 1'b1, dt_use_per_channel_scale, 8'd64, 8'd16, 16'd2),
            make_linear_desc(SLM_LINEAR_OUTPROJ, 2'b00, 1'b1, outproj_use_per_channel_scale, 8'd32, 8'd16, 16'd3),
            use_scaled_state_scan,
            state_continuous_default
        );
    endfunction
endpackage

