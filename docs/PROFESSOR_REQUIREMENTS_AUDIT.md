# Professor Requirements Audit — Final Evidence-Cleaned State

This audit is intentionally conservative. A requirement is DONE only when the repository contains reproducible implementation/evidence traceable to the claimed result.

| # | Requirement | Status | Evidence | Remaining action |
|---|---|---|---|---|
| 1 | Clean Trojan-free CNN baseline and golden reference | DONE | `cnn_baseline/`, `cnn_full_small/`, reports | None |
| 2 | INT8/quantized CNN | DONE | `cnn_baseline/data/`, quantization scripts | None |
| 3 | Verified CNN inference | DONE | `cnn_full_small/tb/`, golden simulation evidence | None |
| 4 | T1–T5 controlled Trojans | DONE | `trojan_T1/` … `trojan_T5/` | None |
| 5 | Healthy + T1–T5 matched evaluation | DONE (simulation scope) | `verification/results/runs.csv`: 10 workloads × 6 targets | None |
| 6 | Timing/latency evidence | DONE | Fresh C6 Healthy/T1/T2 snapshot plus canonical simulation ledger | Exact fresh C6 Fmax is not archived |
| 7 | Power/activity evidence | PARTIAL | Quartus Power Analyzer estimates; VCD activity proxy | Physical rail measurement is not included |
| 8 | Trojan detection | DONE | Simulation matrix plus physical T3–T5 board observations | None for selected T1–T5 scope |
| 9 | Trojan localization | DONE (regional scope) | Simulation matrix plus physical localization outputs | Do not describe code 11 as exact T3/T4/T5 identification |
| 10 | Multiple MNIST workloads | DONE | `verification/workloads/workload_manifest.csv`, `runs.csv` | None |
| 11 | TPR/FPR/Precision/F1 | DONE (simulation scope) | Metrics derived from committed 60-row ledger | Do not generalize beyond evaluated cases |
| 12 | Localization accuracy/confusion matrix | DONE (simulation scope) | Metrics derived from `runs.csv` | Do not generalize beyond evaluated cases |
| 13 | Cross-workload robustness | DONE (simulation scope) | Ten workload classes in canonical matrix | Broader datasets remain future work |
| 14 | Resource utilization | PARTIAL | `verification/results/hardware_resources.csv` | Exact T3–T5 fitter counts and fresh C6 Fmax are not archived |
| 15 | Paper-quality tables/figures | DONE for current evidence | `paper/tables/`, `paper/figures/` | Regenerate if new measurements are added |
| 16 | Healthy latency discrepancy | DONE | `docs/BASELINE_RECONCILIATION.md` | None |
| 17 | Final paper-ready evidence | DONE for defined scope | `paper/manuscript.md` plus physical validation record | Physical power remains a stated limitation |

## Canonical C6 resource evidence

| Target | ALMs | Registers | Block memory bits | RAM blocks | DSP blocks | Setup slack | Hold slack | Fmax |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| Healthy | 1153 | 912 | 455104 | 71 | 13 | +0.181 ns | +0.173 ns | not archived |
| T1 | 1170 | 918 | 455104 | 71 | 13 | +0.141 ns | +0.141 ns | not archived |
| T2 | 1192 | 919 | 455104 | 71 | 15 | +0.163 ns | +0.163 ns | not archived |

T3/T4/T5 exact final fitter counts are not archived and are not inferred.

## Statistical scope

The 60-row ledger is:
- 10 workloads × 6 architectures
- 10 healthy rows
- 50 Trojan rows
- TP=50, TN=10, FP=0, FN=0
- TPR=100%, FPR=0%, Precision=100%, Recall=100%, F1=1.000

These metrics are valid for the committed simulation regression only.

## Physical status

- T3: programmed successfully; all six LEDs ON; class 7; detector asserted; localization 11.
- T4: programmed successfully; all six LEDs ON; class 7; detector asserted; localization 11.
- T5: programmed successfully; all six LEDs ON; class 7; detector asserted; localization 11.
- Physical power/current measurement: not available.

## Submission gate

For the defined controlled-project scope, the project is ready for professor review. Remaining items are explicitly documented limitations/extensions:

1. physical rail/current power instrumentation;
2. exact unarchived T3–T5 fitter resource counts;
3. exact fresh C6 Fmax;
4. broader datasets and cross-CNN generalization;
5. executable numerical ablation study.
