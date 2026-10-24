# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    dut._log.info("Test project behavior")

    threshold = 100
    window = [101] + [100] * 253 + [101, 101]

    for sample in window:
        dut.ui_in.value = sample
        dut.uio_in.value = threshold
        await ClockCycles(dut.clk, 1)

    assert dut.uo_out.value == 3
    assert dut.uio_out.value[1] == 0
