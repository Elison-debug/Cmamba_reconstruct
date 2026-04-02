from __future__ import annotations

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from common import case_dir, read_mem_packed_u16, read_mem_hex


def _read_bank_lines(path):
    lines = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        lines.append(int(line, 16))
    return lines


@cocotb.test()
async def test_reuse_mamba_block_top_inproj_partial(dut):
    clk = Clock(dut.clk, 2, units="ns")
    cocotb.start_soon(clk.start())

    dut.rst_n.value = 0
    dut.block_auto_mode.value = 1
    dut.block_start.value = 0
    dut.inproj_enable.value = 1
    dut.inproj_start.value = 0
    dut.s_axis_TVALID.value = 0
    dut.u_rd_en.value = 0
    dut.u_rd_addr.value = 0
    dut.z_rd_en.value = 0
    dut.z_rd_addr.value = 0
    dut.outproj_enable.value = 0
    dut.h_wr_en.value = 0
    dut.h_wr_addr.value = 0
    for lane in range(4):
        dut.h_wr_data[lane].value = 0
        dut.g_axis_TDATA[lane].value = 0
    dut.g_axis_TVALID.value = 1
    dut.y_axis_TREADY.value = 1
    for _ in range(10):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    stage_dir = case_dir() / "stages" / "reuse_mamba_block_top"
    h_addr = read_mem_hex(stage_dir / "h_wr_addr.mem", signed=False, bits=8)
    h_data = read_mem_packed_u16(stage_dir / "h_wr_data_q88.mem", signed=True)
    u_gold = read_mem_packed_u16(stage_dir / "u_golden_q88.mem", signed=True)
    z_gold = read_mem_packed_u16(stage_dir / "z_golden_q88.mem", signed=True)

    for b in range(6):
        bank_path = stage_dir / f"inproj_wbuf_bank{b}.mem"
        for addr, val in enumerate(_read_bank_lines(bank_path)):
            dut.u_in_proj.u_w_sram.u_weight.mem_sim[b][addr].value = val
    for b in range(6):
        bank_path = stage_dir / f"dt_wbuf_bank{b}.mem"
        for addr, val in enumerate(_read_bank_lines(bank_path)):
            dut.u_dt_sched.u_wbuf.mem_sim[b][addr].value = val

    for idx in range(len(h_addr)):
        await RisingEdge(dut.clk)
        dut.h_wr_en.value = 1
        dut.h_wr_addr.value = int(h_addr[idx])
        for lane in range(4):
            dut.h_wr_data[lane].value = int(h_data[idx, lane]) & 0xFFFF
    await RisingEdge(dut.clk)
    dut.h_wr_en.value = 0

    await RisingEdge(dut.clk)
    dut.block_start.value = 1
    await RisingEdge(dut.clk)
    dut.block_start.value = 0

    while int(dut.inproj_done.value) == 0:
        await RisingEdge(dut.clk)

    for addr in range(64):
        packed_u = int(dut.u_in_proj.u_u_sram.mem_sim[addr].value)
        packed_z = int(dut.u_in_proj.u_z_sram.mem_sim[addr].value)
        got_u = [((packed_u >> (16 * i)) & 0xFFFF) for i in range(4)]
        got_z = [((packed_z >> (16 * i)) & 0xFFFF) for i in range(4)]
        exp_u = [int(v) & 0xFFFF for v in u_gold[addr].tolist()]
        exp_z = [int(v) & 0xFFFF for v in z_gold[addr].tolist()]
        assert got_u == exp_u, f"u SRAM mismatch addr={addr}: got={got_u} exp={exp_u}"
        assert got_z == exp_z, f"z SRAM mismatch addr={addr}: got={got_z} exp={exp_z}"
