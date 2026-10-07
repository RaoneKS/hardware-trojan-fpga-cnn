# Professor Submission — Hardware Trojan Detection in FPGA-CNNs

## Scope
Controlled INT8 CNN Hardware Trojan detection/localization study on a Terasic DE10-Standard using Intel Cyclone V SoC FPGA 5CSXFC6D6F31C6 at a 50 MHz experiment clock.

## Experimental design
10 deterministic MNIST workloads (digits 0–9) × 6 targets:
Healthy, T1, T2, T3, T4, T5.

Total canonical simulation rows: 60.

## Trojan variants
- T1 — Conv2 PE computation corruption
- T2 — Conv2 weight/data-path corruption
- T3 — Conv2 interconnect alteration
- T4 — Conv2 selective source-routing alteration
- T5 — Conv2 control-path stall

## Simulation results
- Healthy: 10/10 PASS
- Trojan: 50/50 PASS
- TP=50
- TN=10
- FP=0
- FN=0
- TPR=100%
- FPR=0%
- Precision=100%
- Recall=100%
- F1=1.000
- Regional localization: correct for all evaluated Trojan rows

These are simulation-regression metrics for the committed workload set, not 60 physical measurements and not a universal security guarantee.

## Canonical timing
At 50 MHz:
- Healthy/T1/T2/T3/T4: 634,281 cycles = 12.68562 ms
- T5: 634,282 cycles = 12.68564 ms
- T1–T4 detection latency: 149,136 cycles = 2.98272 ms
- T5 detection latency: 149,135 cycles = 2.98270 ms

## Fresh C6 implementation evidence
| Target | ALMs | Registers | Block memory bits | RAM blocks | DSP blocks | Setup slack | Hold slack | Fmax |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| Healthy | 1153 | 912 | 455104 | 71 | 13 | +0.181 ns | +0.173 ns | not archived |
| T1 | 1170 | 918 | 455104 | 71 | 13 | +0.141 ns | +0.141 ns | not archived |
| T2 | 1192 | 919 | 455104 | 71 | 15 | +0.163 ns | +0.163 ns | not archived |

Exact final fitter resource counts for T3–T5 are not archived and are not inferred.

## Physical validation
T3, T4 and T5 were successfully programmed on the DE10-Standard through the USB-Blaster/JTAG chain. Each had 0 programming errors and 0 warnings. All six LEDs were observed ON:
- class = 7
- detector = asserted
- localization = regional code 11

Code 11 is shared by T3/T4/T5 and does not distinguish those three variants.

## Power
Quartus Power Analyzer estimates are documented separately. They are tool estimates, not physical rail/current measurements.

## Evidence boundaries
The project does not claim:
- universal Hardware Trojan detection;
- physical power overhead;
- exact T3/T4/T5 fitter counts when not archived;
- exact fresh C6 Fmax when not archived;
- universal stealthiness/classification invariance.

## Primary evidence
- `verification/results/runs.csv`
- `verification/results/hardware_resources.csv`
- `docs/PHYSICAL_BOARD_VALIDATION.md`
- `docs/PAPER_RESULTS.md`
- `docs/FINAL_COMPLETION_STATUS.md`
- `docs/PROFESSOR_REQUIREMENTS_AUDIT.md`
