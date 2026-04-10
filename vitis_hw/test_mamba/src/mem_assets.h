#ifndef MEM_ASSETS_H
#define MEM_ASSETS_H

#include <stdint.h>

typedef enum {
    MEM_ASSET_U64 = 0,
    MEM_ASSET_BYTES = 1
} mem_asset_kind_t;

typedef struct {
    const char *name;
    mem_asset_kind_t kind;
    const void *data;
    uint32_t count;          /* u64元素个数或byte个数 */
    uint32_t line_count;
    uint32_t max_hex_len;
    uint32_t bytes_per_line; /* 仅对BYTES模式有意义，0表示不固定 */
} mem_asset_t;

extern const uint64_t dt_golden_q88_mem[];
extern const uint32_t dt_golden_q88_mem_len;

extern const uint64_t dt_hw_golden_q88_mem[];
extern const uint32_t dt_hw_golden_q88_mem_len;

extern const uint64_t dt_scale_q15_mem[];
extern const uint32_t dt_scale_q15_mem_len;

extern const uint8_t dt_wbuf_bank0_mem[];
extern const uint32_t dt_wbuf_bank0_mem_len;

extern const uint8_t dt_wbuf_bank1_mem[];
extern const uint32_t dt_wbuf_bank1_mem_len;

extern const uint8_t dt_wbuf_bank2_mem[];
extern const uint32_t dt_wbuf_bank2_mem_len;

extern const uint8_t dt_wbuf_bank3_mem[];
extern const uint32_t dt_wbuf_bank3_mem_len;

extern const uint8_t dt_wbuf_bank4_mem[];
extern const uint32_t dt_wbuf_bank4_mem_len;

extern const uint8_t dt_wbuf_bank5_mem[];
extern const uint32_t dt_wbuf_bank5_mem_len;

extern const uint64_t gate_y_golden_q88_mem[];
extern const uint32_t gate_y_golden_q88_mem_len;

extern const uint64_t gate_y_hw_golden_q88_mem[];
extern const uint32_t gate_y_hw_golden_q88_mem_len;

extern const uint64_t h_wr_addr_mem[];
extern const uint32_t h_wr_addr_mem_len;

extern const uint64_t h_wr_data_q88_mem[];
extern const uint32_t h_wr_data_q88_mem_len;

extern const uint64_t inproj_scale_q15_mem[];
extern const uint32_t inproj_scale_q15_mem_len;

extern const uint8_t inproj_wbuf_bank0_mem[];
extern const uint32_t inproj_wbuf_bank0_mem_len;

extern const uint8_t inproj_wbuf_bank1_mem[];
extern const uint32_t inproj_wbuf_bank1_mem_len;

extern const uint8_t inproj_wbuf_bank2_mem[];
extern const uint32_t inproj_wbuf_bank2_mem_len;

extern const uint8_t inproj_wbuf_bank3_mem[];
extern const uint32_t inproj_wbuf_bank3_mem_len;

extern const uint8_t inproj_wbuf_bank4_mem[];
extern const uint32_t inproj_wbuf_bank4_mem_len;

extern const uint8_t inproj_wbuf_bank5_mem[];
extern const uint32_t inproj_wbuf_bank5_mem_len;

extern const uint64_t lam_golden_q016_mem[];
extern const uint32_t lam_golden_q016_mem_len;

extern const uint64_t lam_hw_golden_q016_mem[];
extern const uint32_t lam_hw_golden_q016_mem_len;

extern const uint64_t outproj_scale_q15_mem[];
extern const uint32_t outproj_scale_q15_mem_len;

extern const uint8_t outproj_wbuf_bank0_mem[];
extern const uint32_t outproj_wbuf_bank0_mem_len;

extern const uint8_t outproj_wbuf_bank1_mem[];
extern const uint32_t outproj_wbuf_bank1_mem_len;

extern const uint8_t outproj_wbuf_bank2_mem[];
extern const uint32_t outproj_wbuf_bank2_mem_len;

extern const uint8_t outproj_wbuf_bank3_mem[];
extern const uint32_t outproj_wbuf_bank3_mem_len;

extern const uint8_t outproj_wbuf_bank4_mem[];
extern const uint32_t outproj_wbuf_bank4_mem_len;

extern const uint8_t outproj_wbuf_bank5_mem[];
extern const uint32_t outproj_wbuf_bank5_mem_len;

extern const uint64_t ssm_golden_q88_mem[];
extern const uint32_t ssm_golden_q88_mem_len;

extern const uint64_t ssm_hw_golden_q88_mem[];
extern const uint32_t ssm_hw_golden_q88_mem_len;

extern const uint64_t u_act_golden_q88_mem[];
extern const uint32_t u_act_golden_q88_mem_len;

extern const uint64_t u_golden_q88_mem[];
extern const uint32_t u_golden_q88_mem_len;

extern const uint64_t xt_hw_golden_q88_mem[];
extern const uint32_t xt_hw_golden_q88_mem_len;

extern const uint64_t y_golden_q88_mem[];
extern const uint32_t y_golden_q88_mem_len;

extern const uint64_t y_hw_golden_q88_mem[];
extern const uint32_t y_hw_golden_q88_mem_len;

extern const uint64_t z_golden_q88_mem[];
extern const uint32_t z_golden_q88_mem_len;

extern const uint64_t z_silu_golden_q88_mem[];
extern const uint32_t z_silu_golden_q88_mem_len;

extern const mem_asset_t g_mem_assets[];
extern const uint32_t g_mem_assets_count;

#endif
