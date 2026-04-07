from __future__ import annotations

import os

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from common import case_dir, load_stage_manifest, read_mem_packed_u16


@cocotb.test()
async def test_sigmoid4_vec_vectors(dut):
    clk = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clk.start())

    dut.rst_n.value = 0
    dut.in_valid.value = 0
    dut.out_ready.value = 1
    for _ in range(5):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    manifest = load_stage_manifest()
    stage_dir = case_dir() / "stages" / manifest["name"]
    inp = read_mem_packed_u16(stage_dir / "in_q88.mem", signed=True)
    golden = read_mem_packed_u16(stage_dir / "out_q016.mem", signed=False)
    max_vectors = int(os.environ.get("MAX_VECTORS", "0") or "0")
    if max_vectors > 0:
        inp = inp[:max_vectors]
        golden = golden[:max_vectors]

    got_rows = []
    token = 0
    while token < inp.shape[0]:
        while int(dut.in_ready.value) == 0:
            await RisingEdge(dut.clk)
        for lane in range(inp.shape[1]):
            dut.in_vec[lane].value = int(inp[token, lane]) & 0xFFFF
        dut.in_valid.value = 1
        await RisingEdge(dut.clk)
        dut.in_valid.value = 0
        token += 1

    idle_cycles = 0
    while len(got_rows) < golden.shape[0]:
        await RisingEdge(dut.clk)
        if int(dut.out_valid.value):
            got_rows.append([int(dut.out_vec[i].value) & 0xFFFF for i in range(golden.shape[1])])
            idle_cycles = 0
        else:
            idle_cycles += 1
            if idle_cycles > 5000:
                raise AssertionError(
                    f"timeout waiting for sigmoid outputs: got {len(got_rows)} / {golden.shape[0]} vectors"
                )

    for idx, row in enumerate(got_rows):
        exp = [int(v) & 0xFFFF for v in golden[idx].tolist()]
        assert row == exp, f"vector {idx}: got={row}, exp={exp}"
