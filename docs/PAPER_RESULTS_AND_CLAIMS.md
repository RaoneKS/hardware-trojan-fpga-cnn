# Paper Results and Claims Boundary

## Current hardware-validated evidence

The DE10-Standard board-output validation has now been completed for the healthy baseline and controlled T1-T5 variants.

| Case | Simulation | Quartus | Physical board | Detector | Localization |
|---|---|---|---|---:|---|
| Healthy | Validated | Validated | Validated | 0 | 00 |
| T1 | Validated | Validated | Validated | 1 | 01 |
| T2 | Validated | Validated | Validated | 1 | 10 |
| T3 | Validated | Validated | Validated | 1 | 11 |
| T4 | Validated | Validated | Validated | 1 | 11 |
| T5 | Validated | Validated | Validated | 1 | 11 |

### Deterministic reference-image measurements

- Healthy FPGA inference: 346,563 cycles.
- T1-T4 inference: 634,281 cycles.
- T5 inference: 634,282 cycles.
- T1-T4 detection latency: 149,136 cycles = 2.98272 ms at 50 MHz.
- T5 detection latency: 149,135 cycles = 2.98270 ms at 50 MHz.
- T1 localization: 01.
- T2 localization: 10.
- T3-T5 localization: 11.
- All T1-T5 predicted class 7 for the controlled reference image.
- T1-T5 detector/localization outputs were observed on the physical DE10-Standard.

### Hardware resource evidence currently recorded

Healthy:
- 1,153 ALMs
- 902 registers
- 71 RAM blocks
- 13 DSP blocks
- 455,104 block memory bits

T1 detector-enabled:
- 1,170 ALMs
- 910 registers
- 71 RAM blocks
- 13 DSP blocks
- 455,104 block memory bits

T2:
- 1,192 ALMs
- 919 registers
- 71 RAM blocks
- 15 DSP blocks
- 455,104 block memory bits

Exact final fitter ALM/register counts for T3-T5 are not recorded in the repository evidence ledger and must not be invented.

## Scientific claims that remain pending

The following cannot be inferred from the single deterministic reference image:

- TPR / recall
- FPR
- precision / F1
- localization accuracy over repeated cases
- localization confusion matrix
- false-positive stress-test rate
- cross-workload robustness
- stealthiness detection-probability curve
- switching/activity overhead
- power overhead
- single-vs-multi-signature ablation
- cross-CNN generalization
- multi-workload CNN accuracy degradation

These require real repeated measurements.

## Claim rule

Never convert a planned metric into a result. The manuscript must distinguish:

1. **Physical hardware evidence:** board-level observations for healthy and T1-T5.
2. **Simulation evidence:** deterministic runtime signatures and latency for the reference image.
3. **Statistical evidence:** only values calculated from the measured repeated-run ledger.
4. **Literature evidence:** published values from verified sources, never mixed with project measurements.

The project does not claim universal Hardware Trojan detection.
