#ifndef PLATFORM_CFG_H
#define PLATFORM_CFG_H

#include "xparameters.h"
#include <stdint.h>

/* DDR buffer layout */
#define DDR_BUF_BASE             (XPAR_PSU_DDR_0_BASEADDRESS + 0x10000000ULL)

#define H_BUF_ADDR               (DDR_BUF_BASE + 0x00000000ULL)
#define Y_BUF_ADDR               (DDR_BUF_BASE + 0x00100000ULL)
#define GOLDEN_BUF_ADDR          (DDR_BUF_BASE + 0x00200000ULL)

#define H_BUF_MAX_BYTES          0x00100000U
#define Y_BUF_MAX_BYTES          0x00100000U
#define GOLDEN_BUF_MAX_BYTES     0x00100000U

/* mem file paths */
#define CASE_ROOT_DIR            "0:/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top"
#define H_MEM_FILE               CASE_ROOT_DIR "/h_wr_data_q88.mem"
#define Y_GOLDEN_MEM_FILE        CASE_ROOT_DIR "/y_golden_q88.mem"

/* dimensions from TB */
#define TILE_SIZE                4
#define DATA_WIDTH               16
#define H_DEPTH_EXPECT           32
#define Y_DEPTH_EXPECT           32
#define BYTES_PER_BEAT           ((TILE_SIZE * DATA_WIDTH) / 8)

/* AXI DMA base addresses */
#define DMA_GY_BASEADDR          XPAR_AXI_DMA_GY_BASEADDR
#define DMA_H_BASEADDR           XPAR_AXI_DMA_H_BASEADDR

/* Mamba AXI-Lite base */
#ifdef XPAR_REUSE_MAMBA_BOARD_SHELL_0_BASEADDR
#define MAMBA_BASEADDR           XPAR_REUSE_MAMBA_BOARD_SHELL_0_BASEADDR
#else
#define MAMBA_BASEADDR           XPAR_REUSE_MAMBA_BOARD_SH_0_BASEADDR
#endif

#endif
