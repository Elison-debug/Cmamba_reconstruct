package slm_chain_cfg_pkg;
    localparam int MM_EXACT_DEFAULT_N_BLOCKS = 4;
    localparam int MM_EXACT_DEFAULT_H_ROWS   = 32;

    typedef struct packed {
        logic        inter_block_pipeline;
        logic [7:0]  h_rows;
        logic [2:0]  n_blocks;
    } slm_chain_cfg_t;

    function automatic slm_chain_cfg_t make_chain_cfg(
        input logic inter_block_pipeline,
        input int unsigned h_rows,
        input int unsigned n_blocks
    );
        slm_chain_cfg_t cfg;
        begin
            cfg.inter_block_pipeline = inter_block_pipeline;
            cfg.h_rows               = h_rows[7:0];
            cfg.n_blocks             = n_blocks[2:0];
            return cfg;
        end
    endfunction
endpackage

