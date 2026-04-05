# ZCU102 Board Input Architecture

## Goal

Provide a stable board-level path for:
- booting the design
- preloading weights and static tables
- moving runtime input/output through PS DDR
- leaving clear hooks for a later full front-end before `block0`

## Recommended Bring-Up Path

Use:
- `microSD` for boot image and large static model files
- `PS DDR4` as the runtime staging area
- `AXI DMA` between PS DDR and PL stream interfaces
- `AXI4-Lite` for control/status

Do not make PL talk directly to:
- USB mass storage
- SD card controller

Those are better handled by PS software. The PL should only see:
- AXI control
- AXI memory/stream traffic

## Why This Path

For ZCU102 bring-up, the lowest-risk chain is:

1. Boot Linux or bare-metal from SD.
2. Load weight/data files from SD or USB into PS DDR.
3. Use AXI DMA / AXI master to feed PL.
4. Read results back into DDR.

This avoids:
- custom PL file-system logic
- direct USB host debugging in PL
- direct SD controller integration into PL

## Relevant ZCU102 Interfaces

Based on the official board guide:
- PS DDR4 64-bit SODIMM
- PL DDR4 component (16-bit)
- configuration from SD card
- configuration from QSPI
- USB3 support on PS GTR
- PS MIO Ethernet
- PS MIO USB2 on the USB connector

Practical choice:
- use `PS DDR4` for all data staging
- use `microSD` for model/package preload
- optionally use `USB` only as a convenience path to copy files into Linux

## Throughput Assessment

Current `block0` data volume is small relative to DDR bandwidth.

For one block invocation:
- `h_t`: about `32 * 8 B = 256 B`
- `g` stream: same order as a few hundred bytes
- `y`: about `32 * 8 B = 256 B`
- weight banks for one block: roughly hundreds of KB, suitable for preload

So runtime throughput should use:
- `DDR -> AXI DMA MM2S -> PL`
- `PL -> AXI DMA S2MM -> DDR`

This is far more than enough for the present kernel size.

## Recommended Vivado IP

### PS Side
- `Zynq UltraScale+ MPSoC`
- enable `DDR4`
- enable one `AXI HPM` master from PS to PL for control
- enable one or more `HP/HPC` slave ports for DMA access to DDR

### PL Side
- `AXI SmartConnect`
- `AXI DMA`
- `Processor System Reset`
- `AXI Interrupt Controller` or `xlconcat` if needed
- current compute wrapper:
  - [reuse_mamba_board_shell.sv](/e:/course/master/mamba/Cmamba_reconstruct/HW_reconstruct/rtl_reuse_shared/reuse_mamba_board_shell.sv)

## DMA Topology

Recommended simple-mode layout:

- `DMA0 MM2S`
  - source: DDR buffer containing `h_t`
  - sink: `s_axis_h_*`
- `DMA1 MM2S`
  - source: DDR buffer containing `g`
  - sink: `s_axis_g_*`
- `DMA1 S2MM` or `DMA2 S2MM`
  - source: `m_axis_y_*`
  - sink: DDR result buffer

For first bring-up:
- weights stay preinitialized by `.mem`
- only `h/g/y` go through DMA

Later:
- add a dedicated weight loader path from DDR into bank memories

## Memory Map

### AXI4-Lite CSR Base

Suggested base:
- `0xA000_0000`

Registers:
- `0x0000 CTRL`
  - bit0: `start`
  - bit1: `block_auto_mode`
  - bit2: `preload_h_start`
  - bit3: `soft_reset`
- `0x0004 STATUS`
  - bit0: `block_busy`
  - bit1: `block_done`
  - bit2: `preload_h_busy`
  - bit3: `preload_h_done`
  - bit4: `dma_error`
- `0x0010/0x0014 H_SRC_ADDR`
- `0x0018/0x001C G_SRC_ADDR`
- `0x0020/0x0024 Y_DST_ADDR`
- `0x0028/0x002C INPROJ_W_ADDR`
- `0x0030/0x0034 DT_W_ADDR`
- `0x0038/0x003C OUTPROJ_W_ADDR`
- `0x0040 H_ROWS`
- `0x0044 Y_ROWS`
- `0x0048 IRQ_ENABLE`
- `0x00FC VERSION`

### DDR Buffer Layout

Suggested aligned layout:
- `0x1000_0000` `h_t` input buffer
- `0x1000_1000` `g` input buffer
- `0x1000_2000` `y` output buffer
- `0x1100_0000` inproj weight package
- `0x1110_0000` dt weight package
- `0x1120_0000` outproj weight package
- `0x1130_0000` scale tables / bias / LUT package

Use 4 KB alignment minimum.

## Software Bring-Up Flow

### Phase 1
- boot from SD
- bitstream includes preinitialized weight memories
- PS writes `h_t` and `g` into DDR
- PS starts DMA channels
- PS writes `preload_h_start`, waits done
- PS writes `start`
- PS waits interrupt or polls `block_done`
- PS reads `y` from DDR

### Phase 2
- same as phase 1, but static weights copied from SD/USB into DDR once at init
- a future weight-loader moves them from DDR into PL SRAM/BRAM banks

### Phase 3
- front-end kernels before `block0` generate `h_t/g` directly in PL or stream from DDR

## Current RTL Hooks

Implemented shell files:
- [reuse_mamba_axi_lite_regs.sv](/e:/course/master/mamba/Cmamba_reconstruct/HW_reconstruct/rtl_reuse_shared/reuse_mamba_axi_lite_regs.sv)
- [reuse_mamba_h_stream_loader.sv](/e:/course/master/mamba/Cmamba_reconstruct/HW_reconstruct/rtl_reuse_shared/reuse_mamba_h_stream_loader.sv)
- [reuse_mamba_board_shell.sv](/e:/course/master/mamba/Cmamba_reconstruct/HW_reconstruct/rtl_reuse_shared/reuse_mamba_board_shell.sv)

What is already wired:
- AXI4-Lite control/status
- AXIS preload path for `h_t`
- AXIS stream input for `g`
- AXIS stream output for `y`

What is intentionally left for the next step:
- DDR-to-bank weight loader
- DMA descriptor engine in PL
- full front-end before `block0`
- Linux/Vitis driver

## Interface Recommendation Summary

For ZCU102, the least risky path is:
- `microSD` for boot and file preload
- `PS DDR4` for staging
- `AXI DMA + AXI4-Lite` for runtime data movement

This is the path I recommend you implement first.
