#include "mamba_test.h"
#include "platform_cfg.h"
#include "dma_helper.h"
#include "mem_assets.h"

#include "xaxidma.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xstatus.h"

#include <string.h>
#include <stdint.h>

static XAxiDma AxiDmaH;
static XAxiDma AxiDmaGY;

static int compare_y_q88_from_assets(const int16_t *got,
                                     const uint64_t *golden_packed,
                                     uint32_t y_depth,
                                     uint32_t tile_size,
                                     int *err_cnt)
{
    uint32_t i, lane;
    int err = 0;

    for (i = 0; i < y_depth; i++) {
        uint64_t exp_pack = golden_packed[i];

        for (lane = 0; lane < tile_size; lane++) {
            int16_t exp_v = (int16_t)((exp_pack >> (lane * 16)) & 0xFFFF);
            int16_t got_v = got[i * tile_size + lane];

            if (got_v != exp_v) {
                err++;
                xil_printf("Mismatch @ row=%lu lane=%lu : got=%d exp=%d\r\n",
                           (unsigned long)i,
                           (unsigned long)lane,
                           (int)got_v,
                           (int)exp_v);
            }
        }
    }

    *err_cnt = err;
    return 0;
}

int run_mamba_test(void)
{
    int Status;
    uint32_t h_words;
    uint32_t y_words;
    uint32_t h_bytes;
    uint32_t y_bytes;
    uint32_t frame_cnt;
    uint32_t frame;
    uint32_t h_words_per_frame = H_DEPTH_EXPECT;
    uint32_t y_words_per_frame = Y_DEPTH_EXPECT;
    uint32_t h_bytes_per_frame;
    uint32_t y_bytes_per_frame;
    int err_cnt = 0;

    uint64_t *h_buf      = (uint64_t *)(UINTPTR)H_BUF_ADDR;
    int16_t  *y_buf      = (int16_t  *)(UINTPTR)Y_BUF_ADDR;
    uint64_t *golden_buf = (uint64_t *)(UINTPTR)GOLDEN_BUF_ADDR;

    xil_printf("=== mamba_test start ===\r\n");

    Status = dma_init_baseaddr(&AxiDmaH, (UINTPTR)DMA_H_BASEADDR);
    if (Status != XST_SUCCESS) {
        xil_printf("dma_init H failed, base=0x%08lx\r\n",
                   (unsigned long)DMA_H_BASEADDR);
        return XST_FAILURE;
    }

    Status = dma_init_baseaddr(&AxiDmaGY, (UINTPTR)DMA_GY_BASEADDR);
    if (Status != XST_SUCCESS) {
        xil_printf("dma_init GY failed, base=0x%08lx\r\n",
                   (unsigned long)DMA_GY_BASEADDR);
        return XST_FAILURE;
    }

    if (h_wr_data_q88_mem_len == 0U || y_golden_q88_mem_len == 0U) {
        xil_printf("embedded mem assets are empty\r\n");
        return XST_FAILURE;
    }

    memcpy((void *)(UINTPTR)H_BUF_ADDR,
           (const void *)h_wr_data_q88_mem,
           h_wr_data_q88_mem_len * sizeof(uint64_t));

    memcpy((void *)(UINTPTR)GOLDEN_BUF_ADDR,
           (const void *)y_golden_q88_mem,
           y_golden_q88_mem_len * sizeof(uint64_t));

    h_words = h_wr_data_q88_mem_len;
    y_words = y_golden_q88_mem_len;

    xil_printf("H words=%lu, Y golden words=%lu\r\n",
               (unsigned long)h_words,
               (unsigned long)y_words);

    h_bytes = h_words * sizeof(uint64_t);
    y_bytes = y_words * sizeof(uint64_t);
    h_bytes_per_frame = h_words_per_frame * sizeof(uint64_t);
    y_bytes_per_frame = y_words_per_frame * sizeof(uint64_t);

    if ((h_words % h_words_per_frame) != 0U) {
        xil_printf("invalid H words=%lu, not divisible by frame=%lu\r\n",
                   (unsigned long)h_words, (unsigned long)h_words_per_frame);
        return XST_FAILURE;
    }
    frame_cnt = h_words / h_words_per_frame;

    if (y_words != frame_cnt * y_words_per_frame) {
        xil_printf("invalid Y words=%lu, expect frames(%lu)*%lu=%lu\r\n",
                   (unsigned long)y_words,
                   (unsigned long)frame_cnt,
                   (unsigned long)y_words_per_frame,
                   (unsigned long)(frame_cnt * y_words_per_frame));
        return XST_FAILURE;
    }

    xil_printf("stream frames=%lu, h/frame=%lu, y/frame=%lu\r\n",
               (unsigned long)frame_cnt,
               (unsigned long)h_words_per_frame,
               (unsigned long)y_words_per_frame);

    for (frame = 0; frame < frame_cnt; frame++) {
        UINTPTR h_frame_addr = (UINTPTR)H_BUF_ADDR + ((UINTPTR)frame * h_bytes_per_frame);
        UINTPTR y_frame_addr = (UINTPTR)Y_BUF_ADDR + ((UINTPTR)frame * y_bytes_per_frame);

        /* AXI4-Stream standard flow: arm output path first, then push input frame. */
        Status = dma_recv_start(&AxiDmaGY, y_frame_addr, y_bytes_per_frame);
        if (Status != XST_SUCCESS) {
            xil_printf("dma recv start failed @frame=%lu\r\n", (unsigned long)frame);
            return XST_FAILURE;
        }

        Status = dma_send_blocking(&AxiDmaH, h_frame_addr, h_bytes_per_frame);
        if (Status != XST_SUCCESS) {
            xil_printf("dma send H failed @frame=%lu\r\n", (unsigned long)frame);
            return XST_FAILURE;
        }

        Status = dma_wait_s2mm_done(&AxiDmaGY, 50000000U);
        if (Status != XST_SUCCESS) {
            xil_printf("wait y dma done timeout @frame=%lu\r\n", (unsigned long)frame);
            return XST_FAILURE;
        }

        Status = dma_wait_mm2s_done(&AxiDmaH, 50000000U);
        if (Status != XST_SUCCESS) {
            xil_printf("wait h dma done timeout @frame=%lu\r\n", (unsigned long)frame);
            return XST_FAILURE;
        }
    }

    Xil_DCacheInvalidateRange((UINTPTR)Y_BUF_ADDR, y_bytes);

    Status = compare_y_q88_from_assets(y_buf, golden_buf, y_words, TILE_SIZE, &err_cnt);
    if (Status != 0) {
        xil_printf("compare failed internal\r\n");
        return XST_FAILURE;
    }

    if (err_cnt != 0) {
        xil_printf("FAIL: y mismatch count = %d\r\n", err_cnt);
        return XST_FAILURE;
    }

    xil_printf("PASS: mamba_test ok\r\n");
    return XST_SUCCESS;
}
