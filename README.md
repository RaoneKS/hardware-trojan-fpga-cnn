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

## Current evidence
Healthy, T1, and T2 have measured simulation/Quartus evidence. T1 and T2 have also been programmed on the physical DE10-Standard; T2 physically demonstrated class 7, detector assertion, and localization code 10.

T3/T4/T5 are controlled experiments but are **not described as hardware-validated** until their SOFs are programmed and observed.

## Non-hardware research package
- `docs/PAPER_RESULTS.md` — evidence ledger
- `docs/PAPER_RESULTS_AND_CLAIMS.md` — validated vs pending claims boundary
- `docs/VIVA_QA.md` — professor/viva preparation
- `docs/SUBMISSION_CHECKLIST.md` — submission status
- `docs/BOARD_VALIDATION.md` — exact DE10 hardware validation procedure
- `verification/aggregate_metrics.py` — statistical metric calculation
- `verification/results/runs.csv` — repeatable experiment ledger

## Reproducible simulation
Run `verification/run_all.sh` from any working directory; the script resolves the repository root from its own location. GitHub Actions runs the same Icarus-based smoke tests automatically.

## Paper-quality metrics
Do **not** invent TPR/FPR/F1, localization accuracy, power, or cross-workload robustness values. Those must come from measured runs.

## Hardware-validation boundary
T3/T4/T5 still require local Quartus implementation and DE10-Standard programming before they can be claimed as physically validated. Statistical security metrics such as TPR/FPR/F1 require measured healthy and Trojan runs across multiple workloads; deterministic single-image simulations are not used as substitutes.
