# Final Completion Status

## Repository state

The evidence-cleanup baseline was merged at:
`eb61c55bbbeb2af1ebce8e39c644efa0d0913e92`

The repository now also contains the canonical reproducible full-matrix runner and synchronized documentation on `main`.

## What is complete

- INT8 CNN baseline and golden/reference flow
- T1–T5 controlled Trojan RTL and testbenches
- Workload-aware Trojan testbenches
- Ten deterministic MNIST workloads covering digits 0–9
- Canonical 10 workloads × 6 targets regression runner
- Canonical `verification/results/runs.csv` 60-row simulation ledger
- Automated TP/TN/FP/FN and derived metric generation
- CI execution of the canonical matrix
- CI artifact archiving of the per-run simulation logs
- Canonical resource/timing evidence policy
- Conservative power/activity evidence wording
- Paper manuscript and tables
- Professor requirements audit
- Submission checklist

## Current committed simulation result

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
- F1 = 1.000
- Regional localization is correct for all committed Trojan rows

These statistics describe the committed simulation regression cases only.

## Remaining physical gate

The only work that cannot be completed truthfully from repository access alone is physical DE10-Standard observation.

Current evidence does not independently establish human-observed T3/T4/T5 LED outputs. If the professor requires physical demonstration of every Trojan, program and run T3, T4, and T5 on the DE10-Standard and record the LED/output observations.

Physical rail/current power measurement is also not present. Quartus Power Analyzer results remain tool estimates.

## Final claim boundary

The project may be described as:

**Engineering-complete and simulation-evaluation-complete, with remaining physical-board validation required only for the final hardware-validation gate.**

Do not claim universal Trojan detection, physical power measurement, exact T3/T4/T5 identification from regional code 11, or 60 physical measurements.
