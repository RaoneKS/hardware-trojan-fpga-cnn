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

At the 50 MHz experiment clock:
- T1-T4 detection latency = 149,136 cycles = 2.98272 ms.
- T5 detection latency = 149,135 cycles = 2.98270 ms.
- T5 has the intended one-cycle inference-cycle difference caused by the selected control-path stall.

## Physical-board validation status

### T1 — PE computation corruption
- Physical DE10-Standard validation completed.
- Detector assertion observed.
- Localization code 01 observed.
- Detector-enabled fitter: 1,170 ALMs, 910 registers, 455,104 block memory bits, 71 RAM blocks, 13 DSP blocks.
- Detector-enabled worst setup slack: +1.078 ns.
- Detector-enabled worst hold slack: +0.145 ns.
- No timing violations.

Note: the ALM change is a post-fit implementation result and should not be described as the exact gate count of the detector.

### T2 — Weight/data-path corruption
- Physical board validation completed.
- Class 7 observed.
- Detector asserted.
- Localization code 10 observed.
- Fitter: 1,192 ALMs, 919 registers, 455,104 block memory bits, 71 RAM blocks, 15 DSP blocks.
- Worst setup slack: +2.634 ns.
- Worst hold slack: +0.140 ns.
- No timing violations.
- Relative to healthy: ALMs +39 (+3.38%), registers +17 (+1.88%), RAM 0%, DSP +2 (+15.38%).

### T3 — Interconnect data-path alteration
- Simulation validated: class 7, detector = 1, localization = 11.
- Quartus full compile completed with 0 errors; SOF generated; no timing violations.
- Physical DE10-Standard validation completed.
- Observed board state: LEDR0–LEDR5 all ON.
- Interpretation: class 7, detector asserted, localization 11.
- Exact final fitter ALM/register counts are not recorded in the repository evidence ledger and must not be invented.

### T4 — Selective interconnect routing alteration
- Simulation validated: class 7, detector = 1, localization = 11.
- Quartus full compile completed with 0 errors; SOF generated; no timing violations.
- Physical DE10-Standard validation completed.
- Observed board state: LEDR0–LEDR5 all ON.
- Interpretation: class 7, detector asserted, localization 11.
- Quartus synthesis evidence: 2,335 logic cells, 160 RAM segments, 13 DSP elements.
- Timing: worst setup +5.581 ns; worst hold +0.105 ns.
- Exact final fitter ALM/register counts are not recorded in the repository evidence ledger and must not be invented.

### T5 — Control-path anomaly
- Simulation validated: class 7, detector = 1, localization = 11.
- Quartus full compile completed with 0 errors; SOF generated; no timing violations.
- Physical DE10-Standard validation completed.
- Observed board state: LEDR0–LEDR5 all ON.
- Interpretation: class 7, detector asserted, localization 11.
- Quartus synthesis evidence: 2,229 logic cells, 160 RAM segments, 13 DSP elements.
- Timing: worst setup +4.648 ns; worst hold +0.134 ns.
- Exact final fitter ALM/register counts are not recorded in the repository evidence ledger and must not be invented.

## What is scientifically established

The controlled T1-T5 set demonstrates:
1. The healthy CNN completes correctly on the target FPGA.
2. Each selected Trojan variant can be activated in the controlled experiment.
3. The runtime detector asserts for each selected variant.
4. The current monitor exports region codes for the selected experiment regions.
5. T1-T5 all reach the physical DE10 board-output validation stage.
6. Detection latency is approximately 2.983 ms at 50 MHz for the deterministic reference input.

## What is not yet statistically established

Do not derive the following from the single deterministic reference input:
- TPR/recall
- FPR
- precision/F1
- localization accuracy over a test set
- cross-workload robustness
- false-positive stress-test rate
- stealthiness detection-probability curve
- power/activity overhead
- single-vs-multi-signature ablation
- cross-CNN generalization

A valid statistical evaluation requires repeated healthy and Trojan runs over multiple valid inputs/workloads.

## Repeated-run ledger

verification/results/runs.csv is intentionally empty until measured runs are collected. Execute:

python3 verification/aggregate_metrics.py

after populating it with real measurements.

## Hardware validation boundary

T1-T5 are now physically validated at the board-output level. Statistical security and generalization claims remain pending because the repository does not contain the required repeated multi-workload measurement dataset.
