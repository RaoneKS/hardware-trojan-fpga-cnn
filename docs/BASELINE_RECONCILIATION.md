# Healthy Baseline Latency Reconciliation

## Purpose & Problem Statement
Historical project documentation and golden simulation text logs reported healthy inference latencies of:
- **346,563 cycles** (recorded in `golden_simulation.txt`, `README.md`, `docs/PAPER_RESULTS.md`, and legacy notes)
- **301,854 cycles** (recorded in `cnn_small_core.v` distributed RAM regression)
- **634,281 cycles** (observed in current reproducible synthesizable M10K RTL regression across all 10 workloads)

The research project mandates investigating the Git history and source code configurations to reconcile these three figures without fabricating or silently discarding data. Before using healthy latency as a quantitative comparison in the final manuscript, we identify the exact healthy RTL/top-level and Cyclone V implementation for each figure.

---

## Detailed Root-Cause Analysis

### 1. The 301,854 Cycles Artifact (Distributed RAM Core)
- **Source RTL**: `cnn_full_small/rtl/cnn_small_core.v` (and `cnn_small_core_before_ram_fix.v`).
- **Architecture**: In this initial architecture, image and feature map buffers are declared as distributed asynchronous registers/RAM arrays:
  ```verilog
  reg signed [7:0] image [0:783];
  reg signed [7:0] conv1_out [0:6271];
  ```
- **Access Latency**: Memory reads are entirely combinational (0 additional clock cycles). Reads occur on the same clock cycle that addresses are computed.
- **Empirical Execution**: When compiled and simulated with `iverilog -g2012 tb/tb_cnn_small_core.v rtl/cnn_fpga_top.v rtl/cnn_small_core.v`, the exact execution time is:
  ```
  Inference complete.
  Cycle count = 301854
  Predicted class = 7
  ```
- **Quartus Synthesizability Limitation**: Synthesizing 6,272 bytes of distributed register arrays exhausts Cyclone V ALMs or creates enormous routing congestion. It was not synthesizable as a compact block RAM accelerator.

---

### 2. The 346,563 Cycles Artifact (Intermediate M10K with Pipelining Bug)
- **Source RTL**: `cnn_full_small/rtl/cnn_small_core_m10k_backup.v` and historical `reports/golden_simulation.txt`.
- **Architecture**: The architecture was refactored to use synchronous Cyclone V M10K block RAM (`cnn_sp_ram`), which introduces a mandatory 1-cycle read synchronous latency (`rdata <= mem[raddr]`).
- **The Defect**: In `cnn_small_core_m10k_backup.v`, the state machine attempted to issue read addresses and immediately multiply/accumulate within the next cycle without sufficient multi-cycle wait states for pipeline settling across all convolutional and maxpool layers.
- **Empirical Execution**: Running this intermediate RTL produces:
  ```
  Inference complete.
  Cycle count = 346563
  Predicted class = 1  <-- INCORRECT (Expected 7)
  ```
- **Conclusion**: The historical figure of 346,563 cycles was captured during the initial migration to M10K blocks before memory read latency hazards were resolved. Although `golden_simulation.txt` showed digit 7 (due to hardcoded display in early testbenches or an earlier intermediate state), the actual RTL in that configuration mispredicts due to memory pipeline data hazards.

---

### 3. The 634,281 Cycles Artifact (Validated Synthesizable M10K Core)
- **Source RTL**: `cnn_full_small/rtl/cnn_small_core_m10k.v` and `trojan_T*/rtl/cnn_small_core_m10k.v`.
- **Architecture**: To guarantee full timing closure and correct synchronous memory fetching from M10K blocks across Cyclone V, dedicated wait and handshake states were introduced for each layer (`C1W`, `P1W1`-`P1W3`, `C2W`, `P2W1`-`P2W3`, `FCW`).
- **Empirical Execution**:
  ```
  Inference complete.
  Cycle count = 634281
  Predicted class = 7  (and correct across 10/10 MNIST digits)
  ```
- **Quartus Implementation**: This design synthesizes cleanly with 1,153 ALMs, 902 registers, 71 M10K RAM blocks, and 13 DSP blocks on the DE10-Standard (5CSXFC6D6F31), meeting timing at 50 MHz with positive slack.

---

## Reconciliation Summary Table

| Latency Metric | Implementation Variant | Memory Primitive | Prediction Status | FPGA Synthesizability | Role in Manuscript |
|---|---|---|---|---|---|
| **301,854 cycles** | `cnn_small_core.v` | Distributed async registers | Correct (Digit 7) | High ALM pressure / Routing congestion | Architectural baseline (ideal 0-wait-state memory) |
| **346,563 cycles** | `cnn_small_core_m10k_backup.v` | M10K synchronous RAM | Incorrect (Digit 1 data hazard) | Intermediate development stage | **HISTORICAL ARTIFACT** (Documented, not used for comparative claims) |
| **634,281 cycles** | `cnn_small_core_m10k.v` | M10K synchronous RAM | Correct (10/10 Digits) | **Clean FPGA Fit** (71 M10Ks, 1,153 ALMs, +2.933 ns setup slack) | **CURRENT REPRODUCIBLE GOLDEN RTL** |

## Scientific Protocol Rule
For all subsequent comparisons, overhead evaluations, and manuscript tables:
1. Label **346,563 cycles** explicitly as a **historical intermediate development milestone**.
2. Use **634,281 cycles** as the verified, reproducible reference baseline for the synthesizable M10K FPGA accelerator.



## Final-device note
The DE10-Standard physical target is Cyclone V SoC 5CSXFC6D6F31C6. Some legacy Quartus project files target the I7 variant; those legacy targets must not be presented as the final physical board device.
