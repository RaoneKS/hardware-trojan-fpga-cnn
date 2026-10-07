# Paper Results Ledger

This file is the single source of truth for manuscript numbers. Only enter values backed by simulation, Quartus reports, or physical-board observations.

## Healthy baseline

### Functional
- MNIST reference image: predicted class 7.
- Software reference accuracy: 98.41%.
- Verified synchronous-M10K FPGA reference: 634,281 cycles.
- Healthy physical board: class 7 observed on LEDR[2:0] = 111.

Historical latency values are retained and reconciled in `docs/BASELINE_RECONCILIATION.md`; the 346,563-cycle intermediate value is not the canonical current hardware reference.

### Quartus
- Device: 5CSXFC6D6F31C6.
- ALMs: 1,153.
- Registers: 902.
- Block memory bits: 455,104.
- RAM blocks: 71.
- DSP blocks: 13.
- Worst reported setup slack: +2.933 ns.
- Worst reported hold slack: +0.116 ns.
- Worst-case reported Fmax: 58.59 MHz.
- No timing violations.

## Trojan simulation evidence

The canonical `verification/results/runs.csv` contains 60 simulation regression rows: 10 workloads × Healthy/T1–T5.

For the deterministic reference image:

| ID | Behavior | Predicted class | Detected | Localization | Inference cycles | Detection cycle | Detection latency |
|---|---|---:|---:|---:|---:|---:|---:|
| T1 | Conv2 PE MAC product sign inversion | 7 | 1 | 01 | 634,281 | 149,144 | 149,136 |
| T2 | Conv2 weight bit flip | 7 | 1 | 10 | 634,281 | 149,144 | 149,136 |
| T3 | Conv2 feature interconnect bit alteration | 7 | 1 | 11 | 634,281 | 149,144 | 149,136 |
| T4 | Conv2 selective source-routing alteration | 7 | 1 | 11 | 634,281 | 149,144 | 149,136 |
| T5 | Conv2 selected control-path stall | 7 | 1 | 11 | 634,282 | 149,143 | 149,135 |

At 50 MHz:
- T1–T4 detection latency = 149,136 cycles = 2.98272 ms.
- T5 detection latency = 149,135 cycles = 2.98270 ms.

## Simulation metrics

For the committed 60-row simulation regression:
- Healthy = 10
- Trojan = 50
- TP = 50
- TN = 10
- FP = 0
- FN = 0
- TPR = 100%
- FPR = 0%
- Precision = 100%
- F1 = 1.000

These are simulation-regression metrics for the evaluated workload set, not universal security guarantees.

## Physical-board validation

### T1
- Physical DE10-Standard validation completed.
- Detector asserted.
- Localization code 01 observed.

### T2
- Physical DE10-Standard validation completed.
- Class 7 observed.
- Detector asserted.
- Localization code 10 observed.

### T3
- Physical DE10-Standard validation completed.
- SOF checksum: `0x022CD4EE`.
- Configuration succeeded with 0 errors and 0 warnings.
- LEDR0–LEDR5 all ON.
- Interpretation: class 7, detector asserted, localization 11.

### T4
- Physical DE10-Standard validation completed.
- SOF checksum: `0x022B88DC`.
- Configuration succeeded with 0 errors and 0 warnings.
- LEDR0–LEDR5 all ON.
- Interpretation: class 7, detector asserted, localization 11.

### T5
- Physical DE10-Standard validation completed.
- SOF checksum: `0x022990E2`.
- Configuration succeeded with 0 errors and 0 warnings.
- LEDR0–LEDR5 all ON.
- Interpretation: class 7, detector asserted, localization 11.

Full programming/observation details are in `docs/PHYSICAL_BOARD_VALIDATION.md`.

## Resource and power evidence

Canonical exact fitted counts are retained for Healthy, T1, and T2:
- Healthy: 1,153 ALMs, 902 registers, 71 RAM blocks, 13 DSPs.
- T1: 1,170 ALMs, 910 registers, 71 RAM blocks, 13 DSPs.
- T2: 1,192 ALMs, 919 registers, 71 RAM blocks, 15 DSPs.

Exact final fitter ALM/register/RAM/DSP counts for T3–T5 are not retained in the canonical resource ledger and are intentionally not invented.

Quartus Power Analyzer estimates:
- Healthy: 463.79 mW
- T1: 465.51 mW
- T2: 466.28 mW
- T3: 467.17 mW
- T4: 464.75 mW
- T5: 464.27 mW

These are tool estimates, not physical rail/current measurements.

## Scientific boundary

The project establishes runtime detection and regional localization for the selected controlled T1–T5 implementations within the evaluated simulation matrix and physical board-output demonstrations. It does not establish universal Hardware Trojan detection, exact identification among T3/T4/T5 from localization code 11, or physical power overhead.
