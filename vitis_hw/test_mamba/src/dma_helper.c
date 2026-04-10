#include "dma_helper.h"
#include "xil_cache.h"
#include "xstatus.h"

int dma_init(XAxiDma *InstancePtr, uint32_t DevId)
{
    XAxiDma_Config *Cfg;
    int Status;

    Cfg = XAxiDma_LookupConfig(DevId);
    if (!Cfg) {
        return XST_FAILURE;
    }

    Status = XAxiDma_CfgInitialize(InstancePtr, Cfg);
    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    if (XAxiDma_HasSg(InstancePtr)) {
        return XST_FAILURE;
    }

    XAxiDma_Reset(InstancePtr);
    while (!XAxiDma_ResetIsDone(InstancePtr)) {
        ;
    }

    return XST_SUCCESS;
}

int dma_init_baseaddr(XAxiDma *InstancePtr, UINTPTR BaseAddr)
{
    XAxiDma_Config *Cfg;
    int Status;

    Cfg = XAxiDma_LookupConfigBaseAddr(BaseAddr);
    if (!Cfg) {
        return XST_FAILURE;
    }

    Status = XAxiDma_CfgInitialize(InstancePtr, Cfg);
    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    if (XAxiDma_HasSg(InstancePtr)) {
        return XST_FAILURE;
    }

    XAxiDma_Reset(InstancePtr);
    while (!XAxiDma_ResetIsDone(InstancePtr)) {
        ;
    }

    return XST_SUCCESS;
}

int dma_send_blocking(XAxiDma *InstancePtr, UINTPTR BufAddr, uint32_t LenBytes)
{
    int Status;

    Xil_DCacheFlushRange(BufAddr, LenBytes);

    Status = XAxiDma_SimpleTransfer(InstancePtr, BufAddr, LenBytes, XAXIDMA_DMA_TO_DEVICE);
    if (Status != XST_SUCCESS) {
        return Status;
    }

    while (XAxiDma_Busy(InstancePtr, XAXIDMA_DMA_TO_DEVICE)) {
        ;
    }

    return XST_SUCCESS;
}

int dma_recv_start(XAxiDma *InstancePtr, UINTPTR BufAddr, uint32_t LenBytes)
{
    Xil_DCacheInvalidateRange(BufAddr, LenBytes);
    return XAxiDma_SimpleTransfer(InstancePtr, BufAddr, LenBytes, XAXIDMA_DEVICE_TO_DMA);
}

int dma_wait_mm2s_done(XAxiDma *InstancePtr, uint32_t timeout_cycles)
{
    volatile uint32_t t = 0;
    while (XAxiDma_Busy(InstancePtr, XAXIDMA_DMA_TO_DEVICE)) {
        if (++t > timeout_cycles) {
            return XST_FAILURE;
        }
    }
    return XST_SUCCESS;
}

int dma_wait_s2mm_done(XAxiDma *InstancePtr, uint32_t timeout_cycles)
{
    volatile uint32_t t = 0;
    while (XAxiDma_Busy(InstancePtr, XAXIDMA_DEVICE_TO_DMA)) {
        if (++t > timeout_cycles) {
            return XST_FAILURE;
        }
    }
    return XST_SUCCESS;
}
