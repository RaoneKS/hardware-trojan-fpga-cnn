# Final Completion Status

## Repository state

The repository contains the reproducibility pipeline, evidence-cleanup changes, fresh C6 Healthy/T1/T2 resource snapshot, and physical DE10-Standard observations for T1, T2, T3, T4, and T5.

## Complete evidence

- INT8 CNN baseline and golden/reference flow
- T1–T5 controlled Trojan RTL and testbenches
- Workload-aware Trojan testbenches
- Ten deterministic MNIST workloads covering digits 0–9
- Canonical 10 workloads × 6 targets regression ledger
- Automated TP/TN/FP/FN and derived metrics
- CI execution of the canonical matrix
- Conservative power/activity evidence wording
- Paper manuscript and tables
- Professor requirements audit
- Submission checklist
- Fresh C6 resource/timing snapshot for Healthy/T1/T2
- Physical DE10-Standard board-output validation for T1/T2/T3/T4/T5

## Committed simulation result

The committed ledger contains 60 PASS rows:
- Healthy: 10
- T1–T5: 50
- TP = 50
- TN = 10
- FP = 0
- FN = 0
- TPR = 100%
- FPR = 0%
- Precision = 100%
- Recall = 100%
- F1 = 1.000
- Regional localization is correct for all committed Trojan rows

These statistics describe the committed simulation regression cases only. The ledger is not presented as 60 independent physical measurements.

## Fresh C6 resource snapshot

The currently archived fresh C6 evidence is:

| Target | ALMs | Registers | Block memory bits | RAM blocks | DSP blocks | Worst setup slack | Worst hold slack | Fmax |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| Healthy | 1,153 | 912 | 455,104 | 71 | 13 | +0.181 ns | +0.173 ns | not archived |
| T1 | 1,170 | 918 | 455,104 | 71 | 13 | +0.141 ns | +0.141 ns | not archived |
| T2 | 1,192 | 919 | 455,104 | 71 | 15 | +0.163 ns | +0.163 ns | not archived |

Exact final fitter resource counts for T3/T4/T5 are not archived and are not inferred.

## Canonical timing

At 50 MHz:
- Healthy/T1/T2/T3/T4: 634,281 cycles = 12.68562 ms
- T5: 634,282 cycles = 12.68564 ms
- T1–T4 detection latency: 149,136 cycles = 2.98272 ms
- T5 detection latency: 149,135 cycles = 2.98270 ms

## Physical DE10-Standard validation

T1, T2, T3, T4, and T5 were programmed successfully through the DE10-Standard USB-Blaster/JTAG chain at FPGA device index 2 (JTAG ID `02D020DD`), with 0 programming errors and 0 warnings.

For each of T1/T2/T3/T4/T5:
- LEDR0–LEDR5 = ON
- `LEDR[2:0] = 111` -> class 7
- `LEDR3 = 1` -> detector asserted
- `LEDR[5:4] = 11` -> regional localization code 11

## Limitations

1. Physical rail/current power measurement is not present.
2. Quartus Power Analyzer values are tool estimates.
3. Exact final fitter ALM/register/RAM/DSP counts for T3–T5 are not archived.
4. Exact fresh C6 Fmax is not archived.
5. Broader datasets/cross-CNN generalization are future work.
6. Executable numerical ablation is not claimed.
7. The 100%/0% detection metrics are scoped to the committed 60-row simulation regression.
8. Localization code 11 does not distinguish T3/T4/T5.

## Final status

**PROJECT COMPLETE for the defined controlled course/research implementation and validation scope.**

These limitations are evidence boundaries or research extensions, not blockers for the completed controlled project scope.
