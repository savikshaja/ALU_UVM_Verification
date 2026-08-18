# ALU Verification Project

## Overview

This project implements and verifies an **Arithmetic Logic Unit (ALU)** using **SystemVerilog and UVM**.

The verification environment generates different ALU operations, drives them to the DUT, monitors the inputs and outputs, and compares the DUT output with a reference model in the scoreboard.

The testbench also verifies **invalid command handling**, **operand-capture timing** (including the DUT's multi-cycle result latency), and the ALU's **16-clock-cycle wait/timeout behavior**.

## Features

* Arithmetic operations
* Logical operations
* Comparison operations
* Shift/rotate operations
* Multi-cycle multiply operations
* Input validation using `INP_VALID`
* Clock enable control using `CE`
* Mode-based command selection
* Invalid command detection
* `ERR` output verification
* 16-clock wait/timeout for incomplete operand capture
* Latest-value-wins operand overwrite behavior
* Reference-model-based scoreboard with pipeline latency modeling
* Functional coverage
* Code coverage
* Assertion-based verification
* UVM-based reusable verification environment

## ALU Interface

| Signal      | Direction | Description                             |
| ----------- | --------- | ---------------------------------------- |
| `CLK`       | Input     | System clock                             |
| `RST`       | Input     | Asynchronous reset (active high)         |
| `CE`        | Input     | Clock enable                             |
| `MODE`      | Input     | Selects arithmetic or logical operation  |
| `CMD`       | Input     | Operation command                        |
| `INP_VALID` | Input     | Indicates which operand(s) are valid     |
| `OA`        | Input     | Operand A                                |
| `OB`        | Input     | Operand B                                |
| `CIN`       | Input     | Carry input                              |
| `RES`       | Output    | ALU result                               |
| `COUT`      | Output    | Carry output                             |
| `OFLOW`     | Output    | Overflow/underflow indication            |
| `G`         | Output    | Greater-than flag                        |
| `E`         | Output    | Equal flag                               |
| `L`         | Output    | Less-than flag                           |
| `ERR`       | Output    | Invalid/incomplete operation indication  |

## Verification Environment

The testbench follows a standard UVM architecture:

```text
                        +------------------+
                        |   Test / Config  |
                        +---------+--------+
                                  |
                                  v
                        +------------------+
                        |       Env        |
                        +---------+--------+
                                  |
              +-------------------+-------------------+
              |                                        |
              v                                        v
     +------------------+                     +------------------+
     |   Input Agent     |                     |   Output Agent   |
     |   (active)        |                     |   (passive)      |
     +---------+---------+                     +---------+--------+
               |                                          |
     +---------+---------+                                |
     |                   |                                |
     v                   v                                v
+---------+       +--------------+                +----------------+
|Sequencer|       |Input Monitor |                |Output Monitor  |
+----+----+       +------+-------+                +--------+-------+
     |                    |                                 |
     v                    |                                 |
+---------+                |                                 |
| Driver  |                |                                 |
+----+----+                |                                 |
     |                     |                                 |
     v                     |                                 |
+---------+                |                                 |
|   DUT   |----------------+                                 |
|   ALU   |------------------------------------------------->+
+---------+
                           |                                 |
                           v                                 v
                     +---------------------------------------+
                     |              Scoreboard                |
                     |                                         |
                     |  - Reference model (per-operation math) |
                     |  - Latency-aware pending/queue tracking |
                     |  - Compare expected vs. actual           |
                     +-----------------------------------------+
```

## Operand Capture and Result Latency

The ALU captures operands based on `INP_VALID` on the clock edge, then produces a result after an internal processing delay rather than in the same cycle:

* Standard operations (ADD, SUB, logical, shift, rotate, etc.) take a small fixed number of cycles between operand capture and a valid `RES`.
* Multiply operations (`MUL_INC`, `MUL_SHL`) take longer, matching the spec's multi-cycle multiply behavior.

The scoreboard's reference model accounts for this by computing the expected result at capture time, then holding it until the correct number of cycles have elapsed before comparing it against the DUT's actual output — rather than comparing immediately, which would produce false mismatches due to the timing offset.

If a new operand capture arrives before a previous operation's result is due, the DUT overwrites its internal state and the earlier operation is abandoned; the reference model mirrors this by discarding an in-flight expected result when a genuinely new capture is observed.

## 16-Clock Wait/Timeout

The scoreboard handles cases where the ALU is waiting for the required second operand.

When one operand is received but the second is not, the scoreboard starts a wait counter.

```text
Operand received
       |
       v
Wait for required operand
       |
       +----> Operand received
       |            |
       |            v
       |         Execute
       |
       +----> 16 clock cycles reached
                    |
                    v
               ERR = 1
```

If the required operand is not received within **16 clock cycles**, the transaction is treated as an error condition.

Expected output:

```text
RES   = 0
COUT  = 0
OFLOW = 0
G     = 0
E     = 0
L     = 0
ERR   = 1
```

The scoreboard tracks this using a `wait_count` counter and generates the expected error transaction when the count reaches the timeout threshold.

Repeated captures of an already-held operand value do not reset the wait counter; only a genuinely different value restarts the wait window, consistent with the spec's "latest operand takes priority" rule.

## Invalid Command Verification

The error sequence generates commands that are invalid according to the ALU specification (e.g., undefined `CMD` values for a given `MODE`).

For invalid commands, the expected result from the reference model is:

```text
ERR = 1
```

The scoreboard compares this expected error indication against the DUT output.

```text
MODE = 1
CMD  = invalid command
       |
       v
Reference Model
       |
       v
ERR = 1
       |
       v
Compare with DUT
```

## Reference Model

The scoreboard's reference model computes the expected ALU output based on:

* `MODE`
* `CMD`
* `CIN`
* `OA`
* `OB`

producing expected values for:

```text
RES
COUT
OFLOW
G
E
L
ERR
```

Computation happens independently of the DUT's own outputs, using the spec's operation definitions directly — the reference model never derives an expected value from what the DUT itself reports, so it can catch genuine DUT bugs rather than echoing them back as correct.

## Scoreboard Checking

The scoreboard reports:

```text
TOTAL
PASS
FAIL
```

Example:

```text
EXPECTED : RES=00 COUT=0 OFLOW=0 G=0 E=0 L=0 ERR=1
ACTUAL   : RES=00 COUT=0 OFLOW=0 G=0 E=0 L=0 ERR=1

MATCH
```

## Coverage

The verification environment collects:

* Functional coverage
* Code coverage
* Assertion coverage
* Command coverage
* Mode coverage
* Input-valid combinations
* Error scenarios

Run:

```bash
vsim -vopt work.top \
  -voptargs="+acc=npr" \
  -assertdebug \
  -l alu_log.log \
  -coverage \
  -c \
  -do "coverage save -onexit -assert -directive -cvg -codeAll alu_veri.ucdb; run -all; exit" \
  "+UVM_TESTNAME=test_arithmetic" \
  "+UVM_VERBOSITY=UVM_MEDIUM"
```

## Available Tests

| Test name             | Purpose                                                  |
| ---------------------- | --------------------------------------------------------- |
| `test_arithmetic`      | Directed arithmetic-mode command sweep                    |
| `test_logic`           | Directed logical-mode command sweep                       |
| `test_mul_seq`         | MUL_INC multiply operation verification                   |
| `test_mul_shift_seq`   | MUL_SHL (shift-multiply) operation verification            |
| `test_rol_seq`         | Rotate-left (ROL_A_B) operation verification               |
| `test_ror_seq`         | Rotate-right (ROR_A_B) operation verification              |
| `test_err_seq`         | Invalid-command / error-response verification              |
| `test_wait_2_seq`      | Split-operand capture with a short (2-cycle) wait window   |
| `test_wait_16_seq`     | 16-clock wait/timeout boundary verification                |

Each test extends a common base test (`my_test`) that configures the interface, agent activity, and environment; individual tests only override `run_phase` to start their own directed sequence.


## Project Structure

```text
ALU/
│
├── alu_rtl.sv
├── interface.sv
├── seq_item.sv
├── alu_config.sv
├── alu_pkg.sv
│
├── sequence.sv
├── driver.sv
├── input_monitor.sv
├── output_monitor.sv
│
├── scoreboard.sv
├── input_agent.sv
├── output_agent.sv
├── env.sv
│
├── test.sv
└── top.sv
```

## Tools Used

* SystemVerilog
* UVM
* QuestaSim
* Functional Coverage
* Code Coverage
* SystemVerilog Assertions

## Verification Goals

1. Verify all arithmetic-mode operations (`test_arithmetic`) across ADD, SUB, ADD_CIN, SUB_CIN, INC/DEC, and CMP.
2. Verify all logical-mode operations (`test_logic`) across AND, NAND, OR, NOR, XOR, XNOR, NOT, and shifts.
3. Verify multiply operations, including 3-cycle result latency, for both MUL_INC (`test_mul_seq`) and MUL_SHL (`test_mul_shift_seq`).
4. Verify rotate-left (`test_rol_seq`) and rotate-right (`test_ror_seq`) operations, including the rotate-amount error condition when the upper operand bits are set.
5. Verify invalid/undefined command handling and `ERR` generation (`test_err_seq`).
6. Verify split-operand capture and short wait-window completion (`test_wait_2_seq`).
7. Verify the 16-clock wait-cycle timeout boundary for incomplete operand capture (`test_wait_16_seq`).
8. Verify operand-valid (`INP_VALID`) capture behavior, including split and combined capture, across all directed tests.
9. Verify `CE` gating behavior.
10. Verify latest-value-wins operand overwrite behavior.
11. Verify multi-cycle result latency for standard and multiply operations.
12. Verify output flags (`COUT`, `OFLOW`, `G`, `E`, `L`) across all relevant operations.
13. Achieve good functional and code coverage across all directed and random tests.
