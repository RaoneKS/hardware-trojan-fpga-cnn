# Paper Results and Claims Boundary

## Validated
- Healthy CNN software accuracy: 98.41%.
- Healthy resources: 1,153 ALMs, 902 registers, 71 RAM blocks, 13 DSP.
- T1/T2 detection cycle: 149144.
- T1/T2 detection latency: 149136 cycles = 2.98272 ms at 50 MHz.
- T1 localization: 01.
- T2 localization: 10.
- T2 physical class 7 + detector assertion + localization 10.
- T1 detector/localization build: 1,170 ALMs, 910 registers, 71 RAM, 13 DSP.
- T2 build: 1,192 ALMs, 919 registers, 71 RAM, 15 DSP.

## Pending
- T3/T4/T5 physical validation.
- Repeated healthy/Trojan workload dataset.
- TPR/FPR/precision/F1.
- Localization confusion matrix.
- Power/switching measurement.
- Cross-workload/cross-CNN robustness.
- Single-vs-multi-signature ablation.

**Rule:** Never convert a planned metric into a result and never call T3/T4/T5 hardware-validated before physical observation.
