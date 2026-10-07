# Hardware Trojan Detection in FPGA-CNNs

<p align="center"><strong>Runtime detection and regional localization of controlled Hardware Trojans in an INT8 FPGA-CNN</strong></p>

<p align="center"><a href="https://github.com/RaoneKS/hardware-trojan-fpga-cnn/actions/workflows/hardware-trojan-sim.yml"><img src="https://github.com/RaoneKS/hardware-trojan-fpga-cnn/actions/workflows/hardware-trojan-sim.yml/badge.svg" alt="Simulation CI"></a> <img src="https://img.shields.io/badge/FPGA-Cyclone%20V-blue" alt="FPGA"> <img src="https://img.shields.io/badge/Board-DE10--Standard-informational" alt="Board"> <img src="https://img.shields.io/badge/CNN-INT8-success" alt="INT8"> <img src="https://img.shields.io/badge/Workloads-MNIST-orange" alt="MNIST"> <img src="https://img.shields.io/badge/Status-Research%20Prototype-purple" alt="Status"></p>

## Overview

This repository presents a reproducible study of **runtime detection and regional localization of controlled Hardware Trojans in an FPGA-based CNN**.

The project combines an INT8 CNN, five controlled Trojan variants, ten deterministic MNIST workloads, RTL simulation, Quartus implementation evidence, and physical DE10-Standard board validation.

> **Research scope:** the reported 100% detection / 0% false-positive result applies to the committed 60-case controlled simulation matrix. It is not a claim of universal Hardware Trojan detection.

## Research question

> Can lightweight runtime signatures identify and regionally localize controlled Hardware Trojan perturbations in an FPGA-CNN while preserving the intended CNN classification output?

## System architecture

~~~text
MNIST → INT8 CNN → Runtime detector → CNN class + Trojan status + regional code
             │
             ├─ Conv1 → ReLU → Pool
             ├─ Conv2 → ReLU → Pool
             └─ FC → Argmax
~~~

### Localization map

| Code | Region | Interpretation |
|---|---|---|
| 00 | Healthy | No Trojan detected |
| 01 | Conv2 PE | T1 region |
| 10 | Conv2 weight/data path | T2 region |
| 11 | Shared routing/control | T3/T4/T5 region |

Code 11 is a shared regional code and does not uniquely distinguish T3, T4, and T5.

## Platform

| Item | Configuration |
|---|---|
| Board | Terasic DE10-Standard |
| FPGA | Intel Cyclone V SoC |
| Device | <code>5CSXFC6D6F31C6</code> |
| Clock | 50 MHz |
| Toolchain | Intel Quartus Prime Lite 25.1 |
| RTL simulation | Icarus Verilog 12.0 |
| Dataset | MNIST |
| CNN precision | INT8 |

## Trojan campaign

| ID | Target region | Controlled perturbation |
|---|---|---|
| T1 | Conv2 PE | Computation corruption |
| T2 | Conv2 weight/data path | Weight/data corruption |
| T3 | Conv2 interconnect | Feature-interconnect alteration |
| T4 | Conv2 routing | Selective source-routing alteration |
| T5 | Conv2 control | One-cycle control-path stall |

## Results

### 60-case simulation matrix

10 MNIST workloads × 6 targets = **60 controlled simulation cases**.

| Metric | Result |
|---|---:|
| True positives | 50 |
| True negatives | 10 |
| False positives | 0 |
| False negatives | 0 |
| TPR / Recall | **100%** |
| FPR | **0%** |
| Precision | **100%** |
| F1 | **1.000** |

Regional localization was correct for all 50 evaluated Trojan rows at the defined regional-code level.

### Latency

| Target | Inference | Detection latency |
|---|---:|---:|
| Healthy / T1 / T2 / T3 / T4 | 634,281 cycles / 12.68562 ms | T1–T4: 149,136 cycles / 2.98272 ms |
| T5 | 634,282 cycles / 12.68564 ms | 149,135 cycles / 2.98270 ms |

### Fresh C6 implementation evidence

| Target | ALMs | Registers | RAM blocks | DSPs | Setup slack | Hold slack |
|---|---:|---:|---:|---:|---:|---:|
| Healthy | 1,153 | 912 | 71 | 13 | +0.181 ns | +0.173 ns |
| T1 | 1,170 | 918 | 71 | 13 | +0.141 ns | +0.141 ns |
| T2 | 1,192 | 919 | 71 | 15 | +0.163 ns | +0.163 ns |

Block memory bits for Healthy/T1/T2: **455,104**.

Exact fresh C6 Fmax is not archived, so it is intentionally not reported. Exact final fitter resource counts for T3/T4/T5 are also not inferred.

## Physical DE10-Standard validation

T3, T4 and T5 were physically programmed through the DE10-Standard USB-Blaster/JTAG chain.

- 0 programming errors / 0 warnings
- LEDR0–LEDR5 observed ON
- <code>LEDR[2:0] = 111</code> → class 7
- <code>LEDR3 = 1</code> → detector asserted
- <code>LEDR[5:4] = 11</code> → regional code 11

[Detailed physical validation](docs/PHYSICAL_BOARD_VALIDATION.md)

## Power evidence

Quartus Power Analyzer values and VCD activity evidence are **tool/activity estimates**. No physical rail/current power measurement is claimed.

## Reproducibility

### Canonical simulation

~~~bash
cd ~/hardware-trojan-fpga-cnn
chmod +x verification/run_full_matrix.sh
./verification/run_full_matrix.sh
~~~

### Fresh C6 rebuild

~~~bash
cd ~/hardware-trojan-fpga-cnn
bash scripts/rebuild_c6_quartus.sh
~~~

### Professor package

~~~bash
cd ~/hardware-trojan-fpga-cnn
bash professor_submission/build_submission_zip.sh
~~~

## Repository structure

~~~text
hardware-trojan-fpga-cnn/
├── cnn_baseline/                  # Clean/reference CNN
├── cnn_full_small/                # Main CNN implementation
├── trojan_T1/ … trojan_T5/        # Controlled Trojan variants
├── verification/                  # Canonical regression + evidence
├── scripts/                       # Build/programming utilities
├── docs/                          # Methodology and validation
├── paper/                         # Manuscript, tables and figures
├── professor_submission/          # Professor-facing evidence package
└── .github/workflows/             # Automated RTL regression
~~~

## Documentation

- [Final completion status](docs/FINAL_COMPLETION_STATUS.md)
- [Professor requirements audit](docs/PROFESSOR_REQUIREMENTS_AUDIT.md)
- [Physical board validation](docs/PHYSICAL_BOARD_VALIDATION.md)
- [Paper results ledger](docs/PAPER_RESULTS.md)
- [Experiment matrix](docs/EXPERIMENT_MATRIX.md)
- [Baseline reconciliation](docs/BASELINE_RECONCILIATION.md)
- [Cross-workload results](docs/CROSS_WORKLOAD_RESULTS.md)
- [Ablation results](docs/ABLATION_RESULTS.md)
- [Power measurement protocol](docs/POWER_MEASUREMENT_PROTOCOL.md)
- [Paper manuscript](paper/manuscript.md)
- [Final evidence summary](professor_submission/FINAL_EVIDENCE_SUMMARY.txt)

## Scientific limitations

1. The 60-row experiment is a controlled simulation regression, not 60 physical measurements.
2. Physical rail/current power measurement is not included.
3. Quartus Power Analyzer values are tool estimates.
4. T3/T4/T5 share localization code 11.
5. Exact fresh C6 Fmax is not archived.
6. Exact final fitter resource counts for T3/T4/T5 are not archived.
7. Broader datasets and cross-CNN generalization remain future work.
8. Numerical ablation is not claimed unless independently reproducible.

## Project status

**Research prototype — complete for the defined controlled course/research scope.**

## Author

**Jeevan K S**  
B.Tech — Electronics and Communication Engineering  
IIIT Dharwad