# Lightweight Runtime Detection and Localization of Hardware Trojans in FPGA-CNNs

This repository contains an INT8 FPGA-CNN baseline and five controlled Hardware Trojan variants for runtime detection and regional localization.

## Platform
- Terasic DE10-Standard
- Intel Cyclone V SoC FPGA: 5CSXFC6D6F31C6
- 50 MHz experiment clock
- Intel Quartus Prime

## CNN workload
MNIST -> Conv1 -> ReLU -> MaxPool -> Conv2 -> ReLU -> MaxPool -> FC -> Argmax

## Security experiments
- T1: Conv2 PE computation corruption
- T2: Conv2 weight/data-path corruption
- T3: Conv2 interconnect data-path alteration
- T4: Conv2 selective source-routing alteration
- T5: Conv2 control-path stall

## Current evidence status

### Simulation
The canonical reproducible regression is:
`verification/run_full_matrix.sh`

It generates ten distinct MNIST workloads (digits 0–9), evaluates Healthy + T1–T5, and writes the resulting 60-row ledger to `verification/results/runs.csv`.

The committed simulation ledger contains:
- 10 healthy cases
- 50 Trojan cases
- TP=50, TN=10, FP=0, FN=0
- TPR=100%, FPR=0%, Precision=100%, F1=1.000
- regional localization correct for all evaluated Trojan rows

These statistics are scoped to the committed simulation regression ledger. They are not claimed as universal Trojan-detection performance.

### FPGA implementation
Canonical archived resource values are:
- Healthy: 1,153 ALMs, 902 registers, 71 RAM blocks, 13 DSPs
- T1: 1,170 ALMs, 910 registers, 71 RAM blocks, 13 DSPs
- T2: 1,192 ALMs, 919 registers, 71 RAM blocks, 15 DSPs

Exact final fitter ALM/register/RAM/DSP counts for T3–T5 are not retained in the canonical resource ledger and are deliberately not invented. The Healthy/T1/T2 resource snapshots predate the final QSF target correction to C6 and should be refreshed on C6 before being treated as final-device resource measurements.

### Power
Quartus Power Analyzer values in the project are **tool estimates**, not physical rail/current measurements. VCD switching analysis is an activity proxy.

### Physical board validation
T3, T4, and T5 were programmed successfully on the DE10-Standard and observed at the board-output level. For each:
- LEDR0–LEDR5 were all ON
- `LEDR[2:0] = 111` → class 7
- `LEDR3 = 1` → detector asserted
- `LEDR[5:4] = 11` → regional localization code 11

The detailed record is in `docs/PHYSICAL_BOARD_VALIDATION.md`.

## Reproducibility

Run:

```bash
cd ~/hardware-trojan-fpga-cnn
chmod +x verification/run_full_matrix.sh
./verification/run_full_matrix.sh
```

CI runs the same canonical full matrix and archives the per-run logs as workflow artifacts.

## Key documents
- `docs/FINAL_COMPLETION_STATUS.md` — final project status
- `docs/PROFESSOR_REQUIREMENTS_AUDIT.md` — evidence status
- `docs/PHYSICAL_BOARD_VALIDATION.md` — DE10-Standard T3–T5 observations
- `docs/BASELINE_RECONCILIATION.md` — healthy latency history
- `docs/CROSS_WORKLOAD_RESULTS.md` — simulation-only cross-workload evidence
- `docs/ABLATION_RESULTS.md` — ablation status; no unsupported numerical ablation claims
- `paper/manuscript.md` — conservative paper draft
- `paper/tables/` — paper tables
- `verification/results/runs.csv` — canonical 60-row simulation ledger
- `verification/results/hardware_resources.csv` — canonical archived resource values

## Scientific boundary

This project demonstrates runtime detection/localization for the selected T1–T5 controlled Trojan implementations. It does not establish universal Hardware Trojan detection.

Do not describe:
- the 60 simulation rows as 60 physical measurements;
- Quartus power estimates as physical power measurements;
- localization code `11` as exact identification of T3, T4, and T5;
- classification invariance on the selected workloads as universal stealthiness.
