#ifndef DMA_HELPER_H
#define DMA_HELPER_H

#include "xaxidma.h"
#include <stdint.h>

int dma_init(XAxiDma *InstancePtr, uint32_t DevId);
int dma_init_baseaddr(XAxiDma *InstancePtr, UINTPTR BaseAddr);
int dma_send_blocking(XAxiDma *InstancePtr, UINTPTR BufAddr, uint32_t LenBytes);
int dma_recv_start(XAxiDma *InstancePtr, UINTPTR BufAddr, uint32_t LenBytes);
int dma_wait_mm2s_done(XAxiDma *InstancePtr, uint32_t timeout_cycles);
int dma_wait_s2mm_done(XAxiDma *InstancePtr, uint32_t timeout_cycles);

#endif
