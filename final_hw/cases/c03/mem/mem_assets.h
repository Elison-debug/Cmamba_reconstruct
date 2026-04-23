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

extern const uint64_t stream_h_input_stateless_q88_mem[];
extern const uint32_t stream_h_input_stateless_q88_mem_len;

extern const uint64_t stream_y_golden_stateless_q88_mem[];
extern const uint32_t stream_y_golden_stateless_q88_mem_len;

extern const mem_asset_t g_mem_assets[];
extern const uint32_t g_mem_assets_count;

#endif
