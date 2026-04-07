from __future__ import annotations

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from common import case_dir, load_stage_manifest, read_mem_hex, read_mem_packed_u16


def _signed16(v) -> int:
    x = int(v.value) & 0xFFFF
    return x - 0x10000 if (x & 0x8000) else x


@cocotb.test()
async def test_ew_update_vec4_vectors(dut):
    clk = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clk.start())

    dut.rst_n.value = 0
    dut.in_valid.value = 0
    dut.out_ready.value = 1
    dut.s_addr.value = 0
    for lane in range(4):
        dut.lam_vec[lane].value = 0
        dut.u_vec[lane].value = 0
    for _ in range(5):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    stage_dir = case_dir() / "stages" / "ew_update_vec4"
    _ = load_stage_manifest()
    state_init = read_mem_packed_u16(stage_dir / "state_init_q88.mem", signed=False)
    lam = read_mem_packed_u16(stage_dir / "lam_q016.mem", signed=False)
    u = read_mem_packed_u16(stage_dir / "u_q88.mem", signed=True)
    s_addr = read_mem_hex(stage_dir / "s_addr.mem", signed=False, bits=8)
    golden = read_mem_packed_u16(stage_dir / "s_new_q88.mem", signed=True)

    for addr in range(state_init.shape[0]):
        dut.u_s_buffer.mem[addr].value = int.from_bytes(
            int(
                (int(state_init[addr, 0]) & 0xFFFF)
                | ((int(state_init[addr, 1]) & 0xFFFF) << 16)
                | ((int(state_init[addr, 2]) & 0xFFFF) << 32)
                | ((int(state_init[addr, 3]) & 0xFFFF) << 48)
            ).to_bytes(8, byteorder="little", signed=False),
            byteorder="little",
            signed=False,
        )

    got_rows = []
    token = 0
    while token < lam.shape[0]:
        while int(dut.in_ready.value) == 0:
            await RisingEdge(dut.clk)
        dut.s_addr.value = int(s_addr[token])
        for lane in range(4):
            dut.lam_vec[lane].value = int(lam[token, lane]) & 0xFFFF
            dut.u_vec[lane].value = int(u[token, lane]) & 0xFFFF
        dut.in_valid.value = 1
        await RisingEdge(dut.clk)
        dut.in_valid.value = 0
        token += 1

    while len(got_rows) < golden.shape[0]:
        await RisingEdge(dut.clk)
        if int(dut.out_valid.value):
            got_rows.append([_signed16(dut.s_new_vec[i]) for i in range(4)])

    for idx, row in enumerate(got_rows):
        exp = golden[idx].tolist()
        assert row == exp, f"token {idx}: got={row}, exp={exp}"
