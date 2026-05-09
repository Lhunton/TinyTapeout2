# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    
# --- Test 1 ---
    dut.ui_in.value = 20
    dut.uio_in.value = 30
    await ClockCycles(dut.clk, 1)

    result = (int(dut.uio_out.value) << 8) | int(dut.uo_out.value)
    assert result == (20 * 30) & 0xFFFF

    # --- Test 2 ---
    dut.ui_in.value = 3
    dut.uio_in.value = 4
    await ClockCycles(dut.clk, 1)

    result = (int(dut.uio_out.value) << 8) | int(dut.uo_out.value)
    assert result == (3 * 4)

    # --- Test 3 (signed) ---
    dut.ui_in.value = (-8) & 0xFF
    dut.uio_in.value = 4
    await ClockCycles(dut.clk, 1)

    result = (int(dut.uio_out.value) << 8) | int(dut.uo_out.value)
    expected = ((-8 * 4) & 0xFFFF)
    assert result == expected
