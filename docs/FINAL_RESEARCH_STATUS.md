# Final Research Status

## Status as of the latest DE10-Standard validation

### Complete
- Healthy CNN baseline implemented and validated.
- T1 PE computation corruption implemented and physically detected/localized.
- T2 Conv2 weight/data-path corruption implemented and physically detected/localized.
- T3 interconnect data-path alteration implemented, compiled, programmed, and physically detected/localized.
- T4 selective interconnect routing alteration implemented, compiled, programmed, and physically detected/localized.
- T5 selected control-path stall implemented, compiled, programmed, and physically detected/localized.
- Quartus builds for all controlled variants complete without timing violations.
- Reproducible simulation and build scripts exist.
- Results/evidence ledger updated.
- Literature review satisfies the professor's four-category / 10-paper minimum at the documentation level.
- Submission checklist updated.

### Core measured result
At 50 MHz, the deterministic reference-image experiment reports:
- Healthy inference: 346,563 cycles.
- T1-T4 inference: 634,281 cycles.
- T5 inference: 634,282 cycles.
- T1-T4 detector latency: 149,136 cycles = 2.98272 ms.
- T5 detector latency: 149,135 cycles = 2.98270 ms.
- T1 localization: 01.
- T2 localization: 10.
- T3-T5 localization: 11.
- All T1-T5 predicted class 7 for the controlled reference image.
- T1-T5 physical detector/localization outputs have been observed on the DE10-Standard.

### Remaining scientific experiments

The remaining gap is **statistical/generalization evidence**, not FPGA implementation.

1. Collect repeated Trojan-free workloads/images.
2. Collect repeated T1-T5 runs on the same workload set.
3. Record each run in verification/results/runs.csv.
4. Compute TP/TN/FP/FN, TPR, FPR, precision, and F1.
5. Build a localization confusion matrix.
6. Measure latency distributions rather than one deterministic latency.
7. Collect switching/activity evidence.
8. Collect Quartus power estimates or board-level power measurements if available.
9. Run single-signature vs multi-signature ablation.
10. Run controlled stealthiness/signature-strength sweeps.
11. Run cross-workload validation.
12. If time permits, add a second CNN/accelerator configuration for cross-CNN validation.
13. Regenerate the final paper figures and tables from the measured dataset.

## Why these items cannot be filled automatically

The current repository contains one deterministic MNIST image and controlled T1-T5 experiments. It does not contain a measured multi-workload runtime dataset. Manufacturing statistically valid FPR/TPR/F1 values by duplicating the existing deterministic result would violate the professor's explicit instruction not to invent numerical results.

## Submission recommendation

The FPGA engineering portion is complete enough to freeze the RTL and preserve the validated SOFs/results. Do not modify T1-T5 payload logic while collecting the remaining evidence.

The final manuscript should distinguish:
- hardware-validated claims: healthy and T1-T5 board observations;
- simulation-derived timing/signature claims;
- statistical claims: only after repeated measured runs.
