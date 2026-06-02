package mm_gemv_job_pkg;
    typedef enum logic [1:0] {
        MM_OP_INPROJ  = 2'd0,
        MM_OP_DTPROJ  = 2'd1,
        MM_OP_OUTPROJ = 2'd2
    } mm_op_t;

    typedef struct packed {
        mm_op_t      op_type;
        logic [7:0]  row_tiles;
        logic [7:0]  k_groups;
        logic [1:0]  mode;
        logic        reduce_rows;
        logic        use_per_channel_scale;
        logic [15:0] job_id;
    } mm_gemv_job_t;
endpackage


