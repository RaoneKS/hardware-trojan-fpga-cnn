# Lightweight Runtime Detection and Localization of Hardware Trojans in FPGA-CNNs

This repository contains an INT8 FPGA-CNN baseline and five controlled Hardware Trojan variants for runtime detection and regional localization.

## Platform
- Terasic DE10-Standard
- Intel Cyclone V SoC FPGA: 5CSXFC6D6F31C6
- 50 MHz experiment clock
- Intel Quartus Prime Lite 25.1

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
The canonical reproducible regression is `verification/run_full_matrix.sh`.

The committed `verification/results/runs.csv` contains 60 PASS rows:
- 10 healthy cases
- 50 Trojan cases
- TP=50, TN=10, FP=0, FN=0
- TPR=100%, FPR=0%, Precision=100%, F1=1.000
- regional localization correct for all evaluated Trojan rows

These statistics are scoped to the committed simulation regression ledger and are not universal Trojan-detection performance.

### Fresh C6 FPGA implementation evidence
The canonical resource ledger was refreshed after rebuilding the Healthy/T1/T2 Quartus projects for device `5CSXFC6D6F31C6`:

| Target | ALMs | Registers | Block memory bits | RAM blocks | DSP blocks | Worst setup slack (ns) | Worst hold slack (ns) | Fmax |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| Healthy | 1153 | 912 | 455104 | 71 | 13 | +0.181 | +0.173 | not archived |
| T1 | 1170 | 918 | 455104 | 71 | 13 | +0.141 | +0.141 | not archived |
| T2 | 1192 | 919 | 455104 | 71 | 15 | +0.163 | +0.163 | not archived |
| T3 | — | — | — | — | — | historical evidence only | historical evidence only | — |
| T4 | — | — | — | — | — | historical evidence only | historical evidence only | — |
| T5 | — | — | — | — | — | historical evidence only | historical evidence only | — |

The Healthy/T1/T2 values above are the fresh C6 evidence currently archived in `verification/results/hardware_resources.csv`. Exact final fitter counts for T3–T5 are not archived and are deliberately not inferred.

Fmax is left blank because an exact fresh C6 Fmax value is not archived in the repository evidence. No Fmax number is fabricated.

### Canonical latency
At 50 MHz:
- Healthy/T1/T2/T3/T4: 634,281 cycles = 12.68562 ms
- T5: 634,282 cycles = 12.68564 ms
- T1–T4 detection latency: 149,136 cycles = 2.98272 ms
- T5 detection latency: 149,135 cycles = 2.98270 ms

### Power
Quartus Power Analyzer values are **tool estimates**, not physical rail/current measurements. VCD switching analysis is an activity proxy.

### Physical board validation
T3, T4, and T5 were programmed successfully on the DE10-Standard and observed at board-output level. For each:
- LEDR0–LEDR5 were all ON
- `LEDR[2:0] = 111` -> class 7
- `LEDR3 = 1` -> detector asserted
- `LEDR[5:4] = 11` -> regional localization code 11

The detailed record is in `docs/PHYSICAL_BOARD_VALIDATION.md`.

## Reproducibility

```bash
cd ~/hardware-trojan-fpga-cnn
chmod +x verification/run_full_matrix.sh
./verification/run_full_matrix.sh
```

For the fresh C6 Healthy/T1/T2 rebuild:

```bash
bash scripts/rebuild_c6_quartus.sh
```

## Key documents
- `docs/FINAL_COMPLETION_STATUS.md`
- `docs/PROFESSOR_REQUIREMENTS_AUDIT.md`
- `docs/PHYSICAL_BOARD_VALIDATION.md`
- `docs/BASELINE_RECONCILIATION.md`
- `docs/CROSS_WORKLOAD_RESULTS.md`
- `docs/ABLATION_RESULTS.md`
- `paper/manuscript.md`
- `verification/results/runs.csv`
- `verification/results/hardware_resources.csv`

## Scientific boundary

This project demonstrates runtime detection/localization for the selected T1–T5 controlled Trojan implementations.

Do not describe:
- the 60 simulation rows as 60 physical measurements;
- Quartus power estimates as physical power measurements;
- localization code `11` as exact identification of T3, T4, and T5;
- classification invariance on the selected workloads as universal stealthiness;
- missing T3–T5 fitter values as measured numbers.
