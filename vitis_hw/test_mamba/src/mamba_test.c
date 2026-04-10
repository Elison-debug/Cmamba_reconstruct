#include "mamba_test.h"
#include "platform_cfg.h"
#include "mamba_regs.h"
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

static int wait_status_set(uint32_t mask, uint32_t timeout_cycles)
{
    volatile uint32_t t = 0;
    while ((mamba_read(REG_STATUS) & mask) == 0U) {
        if (++t > timeout_cycles) {
            return XST_FAILURE;
        }
    }
    return XST_SUCCESS;
}

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

    if (h_words != H_DEPTH_EXPECT) {
        xil_printf("unexpected H depth: %lu (expect %u)\r\n",
                   (unsigned long)h_words, H_DEPTH_EXPECT);
        return XST_FAILURE;
    }

    if (y_words != Y_DEPTH_EXPECT) {
        xil_printf("unexpected Y depth: %lu (expect %u)\r\n",
                   (unsigned long)y_words, Y_DEPTH_EXPECT);
        return XST_FAILURE;
    }

    h_bytes = h_words * sizeof(uint64_t);
    y_bytes = y_words * sizeof(uint64_t);

    mamba_write(REG_IRQ_ENABLE, 0U);
    mamba_write(REG_H_ROWS, h_words);
    mamba_write(REG_Y_ROWS, y_words);

    mamba_write(REG_CTRL, CTRL_SOFT_RESET);

    xil_printf("REG_STATUS before = 0x%08lx\r\n", (unsigned long)mamba_read(REG_STATUS));

    Status = dma_recv_start(&AxiDmaGY, (UINTPTR)Y_BUF_ADDR, y_bytes);
    if (Status != XST_SUCCESS) {
        xil_printf("dma recv start failed\r\n");
        return XST_FAILURE;
    }

    mamba_write(REG_CTRL, CTRL_PRELOAD_H);

    Status = dma_send_blocking(&AxiDmaH, (UINTPTR)H_BUF_ADDR, h_bytes);
    if (Status != XST_SUCCESS) {
        xil_printf("dma send H failed\r\n");
        return XST_FAILURE;
    }

    Status = wait_status_set(STATUS_PRELOAD_H_DONE, 1000000U);
    if (Status != XST_SUCCESS) {
        xil_printf("wait preload_h_done timeout, status=0x%08lx\r\n",
                   (unsigned long)mamba_read(REG_STATUS));
        return XST_FAILURE;
    }

    xil_printf("preload_h done, status=0x%08lx\r\n",
               (unsigned long)mamba_read(REG_STATUS));

    mamba_write(REG_CTRL, CTRL_START);

    Status = wait_status_set(STATUS_BLOCK_DONE, 50000000U);
    if (Status != XST_SUCCESS) {
        xil_printf("wait block_done timeout, status=0x%08lx\r\n",
                   (unsigned long)mamba_read(REG_STATUS));
        return XST_FAILURE;
    }

    xil_printf("block done, status=0x%08lx\r\n",
               (unsigned long)mamba_read(REG_STATUS));

    Status = dma_wait_s2mm_done(&AxiDmaGY, 50000000U);
    if (Status != XST_SUCCESS) {
        xil_printf("wait y dma done timeout\r\n");
        return XST_FAILURE;
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
