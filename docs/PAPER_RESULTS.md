# Paper Results Ledger

This file is the single source of truth for manuscript numbers. Only enter values backed by simulation, Quartus reports, or physical-board observations.

## Healthy baseline

### Functional
- MNIST reference image: predicted class 7.
- Software reference accuracy: 98.41%.
- Healthy FPGA simulation: 346,563 cycles.
- Healthy physical board: class 7 observed on LEDR[2:0] = 111.

### Quartus
- Device: 5CSXFC6D6F31C6.
- ALMs: 1,153.
- Registers: 902.
- Block memory bits: 455,104.
- RAM blocks: 71.
- DSP blocks: 13.
- Worst reported setup slack: +2.933 ns (Slow 1100 mV, -40 C).
- Worst reported hold slack: +0.116 ns (Fast 1100 mV, -40 C).
- Worst-case reported Fmax: 58.59 MHz (Slow 1100 mV, -40 C).
- No timing violations.

## Trojan simulation evidence

All values below are for the included deterministic MNIST reference image and are simulation evidence only.

| ID | Behavior | Predicted class | Detected | Localization | Inference cycles | Detection cycle | Detection latency |
|---|---|---:|---:|---:|---:|---:|---:|
| T1 | Conv2 PE MAC product sign inversion | 7 | 1 | 01 | 634,281 | 149,144 | 149,136 |
| T2 | Conv2 weight bit flip | 7 | 1 | 10 | 634,281 | 149,144 | 149,136 |
| T3 | Conv2 feature interconnect bit alteration | 7 | 1 | 11 | 634,281 | 149,144 | 149,136 |
| T4 | Conv2 selective source-routing alteration | 7 | 1 | 11 | 634,281 | 149,144 | 149,136 |
| T5 | Conv2 selected control-path stall | 7 | 1 | 11 | 634,282 | 149,143 | 149,135 |

At the 50 MHz experiment clock, the T1-T4 detection latency is approximately 2.98272 ms and the T5 detection latency is approximately 2.98270 ms. The small T5 cycle difference is the intended one-cycle control-path stall.

## T1 — PE computation corruption

Measured:
- Triggered selected Conv2 MAC product sign inversion.
- Detector asserted.
- Localization code 01.
- Physical detector validation completed on DE10-Standard.
- Detector-enabled fitter result: 1,170 ALMs, 910 registers, 455,104 block memory bits, 71 RAM blocks, 13 DSP blocks.
- Detector-enabled worst setup slack: +1.078 ns.
- Detector-enabled worst hold slack: +0.145 ns.
- No timing violations.

Note: the ALM change is a post-fit implementation result and should not be described as the exact gate count of the detector.

## T2 — Weight/data-path corruption

Measured:
- Selected Conv2 weight bit flip: 5 -> 4.
- Detector asserted.
- Localization code 10.
- Physical board validation completed: class 7, detector LED asserted, localization code 10 observed.
- Fitter result: 1,192 ALMs, 919 registers, 455,104 block memory bits, 71 RAM blocks, 15 DSP blocks.
- Worst setup slack: +2.634 ns.
- Worst hold slack: +0.140 ns.
- No timing violations.

Relative to the healthy baseline:
- ALMs: +39 (+3.38%).
- Registers: +17 (+1.88%).
- Block memory bits/RAM blocks: 0%.
- DSP blocks: +2 (+15.38%).

## T3 — Interconnect data-path alteration

Simulation validated:
- predicted class 7
- detector assertion = 1
- localization code = 11
- detection cycle = 149,144
- detection latency = 149,136 cycles

Quartus implementation and physical-board validation are still pending.

## T4 — Selective interconnect routing alteration

Simulation validated:
- selected Conv2 source address is redirected to an adjacent spatial element
- predicted class 7
- detector assertion = 1
- localization code = 11
- detection cycle = 149,144
- detection latency = 149,136 cycles

Quartus implementation and physical-board validation are still pending.

## T5 — Control-path anomaly

Simulation validated:
- one-cycle selected Conv2 control-path stall
- no direct feature-data or weight operand corruption
- predicted class 7
- detector assertion = 1
- localization code = 11
- detection cycle = 149,143
- detection latency = 149,135 cycles

Quartus implementation and physical-board validation are still pending.

## Statistical evaluation

Do not derive TPR/FPR/precision/F1 from the deterministic T1-T5 smoke-test set. A valid statistical evaluation requires multiple healthy and Trojan runs across multiple workload/input instances.

Populate `verification/results/runs.csv` with measured runs and then execute:

`python3 verification/aggregate_metrics.py`

Required final measurements:
- TP, TN, FP, FN
- TPR, FPR, precision, F1
- localization accuracy and confusion matrix
- cross-workload false-positive rate
- detection latency distribution
- CNN functional degradation
- power/activity overhead
- FPGA resource/timing overhead
- ablation and robustness results

## Hardware validation boundary

Do not label T3/T4/T5 as physically validated until their SOFs are built, programmed on the DE10-Standard, and the detector/localization outputs are observed.

Do not claim statistical security metrics, cross-workload robustness, power, or final overhead values until those measurements are actually collected.
