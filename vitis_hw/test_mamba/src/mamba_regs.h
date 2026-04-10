#ifndef MAMBA_REGS_H
#define MAMBA_REGS_H

#include "xil_io.h"
#include "platform_cfg.h"
#include <stdint.h>

#define REG_CTRL                 0x000
#define REG_STATUS               0x004
#define REG_H_ROWS               0x040
#define REG_Y_ROWS               0x044
#define REG_IRQ_ENABLE           0x048

#define CTRL_START               0x00000001U
#define CTRL_BLOCK_AUTO          0x00000002U
#define CTRL_PRELOAD_H           0x00000004U
#define CTRL_SOFT_RESET          0x00000008U

#define STATUS_BLOCK_BUSY        0x01U
#define STATUS_BLOCK_DONE        0x02U
#define STATUS_PRELOAD_H_BUSY    0x04U
#define STATUS_PRELOAD_H_DONE    0x08U
#define STATUS_DMA_ERROR         0x10U

static inline void mamba_write(uint32_t off, uint32_t val)
{
    Xil_Out32((UINTPTR)(MAMBA_BASEADDR + off), val);
}

static inline uint32_t mamba_read(uint32_t off)
{
    return Xil_In32((UINTPTR)(MAMBA_BASEADDR + off));
}

#endif