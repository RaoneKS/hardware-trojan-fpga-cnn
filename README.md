# Lightweight Runtime Detection and Localization of Hardware Trojans in FPGA-CNNs

This repository contains the FPGA-CNN baseline and controlled Trojan experiments for the research project "Lightweight Runtime Detection and Localization of Hardware Trojans in FPGA Based CNN Accelerators."

## Platform
- Terasic DE10-Standard
- Intel Cyclone V SoC FPGA: 5CSXFC6D6F31C6
- 50 MHz experiment clock
- Quartus Prime Lite 25.1

## CNN workload
MNIST -> Conv1 -> ReLU -> MaxPool -> Conv2 -> ReLU -> MaxPool -> FC -> Argmax

The healthy reference workload predicts digit 7 for the included reference image.

## Security experiments
- T1: Conv2 PE computation corruption
- T2: Conv2 weight/data-path corruption
- T3: Conv2 interconnect data-path bit alteration
- T4: Conv2 selective source-routing alteration
- T5: selected Conv2 control-path stall

## Current evidence
Healthy, T1, and T2 have measured simulation/Quartus evidence. T1 and T2 have also been programmed on the physical DE10-Standard; T2 physically demonstrated class 7, detector assertion, and localization code 10.

T3/T4/T5 are controlled experiments but are not described as hardware-validated until their SOFs are programmed and observed.

## Reproducible simulation
Run verification/run_all.sh from the repository root. GitHub Actions runs the same Icarus-based smoke tests automatically.

## Paper-quality metrics
Do not invent TPR/FPR/F1, localization accuracy, power, or cross-workload robustness values. Those must come from measured runs. See docs/EXPERIMENT_MATRIX.md.
