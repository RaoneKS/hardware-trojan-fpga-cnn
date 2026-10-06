# Lightweight Runtime Detection and Localization of Hardware Trojans in FPGA-CNNs

This repository contains the FPGA-CNN baseline and controlled Trojan experiments for the research project **“Lightweight Runtime Detection and Localization of Hardware Trojans in FPGA Based CNN Accelerators.”**

## Platform
- Terasic DE10-Standard
- Intel Cyclone V SoC FPGA: 5CSXFC6D6F31C6
- 50 MHz experiment clock
- Quartus Prime Lite 25.1

## CNN workload
MNIST -> Conv1 -> ReLU -> MaxPool -> Conv2 -> ReLU -> MaxPool -> FC -> Argmax

Healthy software accuracy: **98.41%**. The included reference image predicts digit **7**.

## Security experiments
- T1: Conv2 PE computation corruption
- T2: Conv2 weight/data-path corruption
- T3: Conv2 interconnect data-path alteration
- T4: Conv2 selective source-routing alteration
- T5: selected Conv2 control-path stall

## Current validated evidence
### Healthy
- Simulation: 346,563 cycles; predicted class 7.
- Physical DE10-Standard: class 7 observed on LEDR[2:0] = 111.

### T1
- Simulation: detected, localization 01, 634,281 cycles, 149,136-cycle detection latency.
- Physical DE10-Standard: detector assertion validated; localization 01.
- Fitter: 1,170 ALMs, 910 registers, 71 RAM blocks, 13 DSP blocks.

### T2
- Simulation: detected, localization 10, 634,281 cycles, 149,136-cycle detection latency.
- Physical DE10-Standard: class 7, detector ON, localization 10.
- Fitter: 1,192 ALMs, 919 registers, 71 RAM blocks, 15 DSP blocks.

### T3
- Simulation: detected, localization 11, 634,281 cycles, 149,136-cycle detection latency.
- Quartus full compile: 0 errors; SOF generated; no timing violations.
- Physical DE10-Standard: LEDR0–LEDR5 all ON, corresponding to class 7 + detector ON + localization 11.

### T4
- Simulation: detected, localization 11, 634,281 cycles, 149,136-cycle detection latency.
- Quartus full compile: 0 errors; SOF generated; no timing violations.
- Physical DE10-Standard: LEDR0–LEDR5 all ON, corresponding to class 7 + detector ON + localization 11.

### T5
- Simulation: detected, localization 11, 634,282 cycles, 149,135-cycle detection latency.
- Quartus full compile: 0 errors; SOF generated; no timing violations.
- Physical DE10-Standard: LEDR0–LEDR5 all ON, corresponding to class 7 + detector ON + localization 11.

**Therefore T1–T5 are now physically validated at the board-output level.**

## Evidence boundary
The deterministic reference-image experiment is **not** a statistical test set. Do not derive TPR/FPR/precision/F1, false-positive rate, cross-workload robustness, power overhead, or ablation conclusions from the single reference image.

Those quantities require repeated healthy/Trojan runs and multiple valid workloads. The repository keeps verification/results/runs.csv empty until such measurements are collected.

## Reproducible simulation
Run verification/run_all.sh.

The script resolves the repository root from its own location and verifies predicted class, detector assertion, localization code, inference cycles, and detection latency for T1–T5.

## Quartus builds
Run verification/build_quartus_t3_t5.sh.

The script builds T3–T5 with Quartus Prime Lite and verifies that an SOF is generated.

## Analysis
- docs/PAPER_RESULTS.md — manuscript evidence ledger
- docs/RELATED_WORK.md — literature review and positioning
- docs/EXPERIMENT_MATRIX.md — controlled experiment matrix
- docs/BOARD_VALIDATION.md — DE10 validation procedure
- docs/VIVA_QA.md — viva preparation
- verification/aggregate_metrics.py — TP/TN/FP/FN and derived statistics
- verification/results/runs.csv — repeated measured-run ledger

## Important scientific limitation
This project demonstrates controlled runtime detection/localization of the selected T1–T5 Trojan classes. It does **not** establish universal Trojan detection. The current statistical gap is repeated multi-workload measurement, not RTL construction.
