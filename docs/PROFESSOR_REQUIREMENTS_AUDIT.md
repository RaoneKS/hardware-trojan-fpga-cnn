# Professor Requirements Audit — Final Evidence-Cleaned State

This audit is intentionally conservative. A requirement is **DONE** only when the repository contains a reproducible implementation and evidence traceable to the claimed result.

| # | Requirement | Status | Evidence | Remaining action |
|---|---|---|---|---|
| 1 | Clean Trojan-free CNN baseline and golden reference | DONE | `cnn_baseline/`, `cnn_full_small/`, reports | None |
| 2 | INT8/quantized CNN | DONE | `cnn_baseline/data/`, quantization scripts | None |
| 3 | Verified CNN inference | DONE | `cnn_full_small/tb/`, golden simulation evidence | None |
| 4 | T1–T5 controlled Trojans | DONE | `trojan_T1/` … `trojan_T5/` | None |
| 5 | Healthy + T1–T5 matched evaluation | DONE (simulation scope) | `verification/results/runs.csv`: 10 workloads × 6 targets | Raw logs are archived by CI; the committed ledger itself remains the canonical summary |
| 6 | Timing/latency evidence | DONE | Quartus logs, baseline reconciliation, simulation ledger | None for defined scope |
| 7 | Power/activity evidence | PARTIAL | Quartus Power Analyzer estimates; VCD activity proxy | Physical rail measurement is not included |
| 8 | Trojan detection | DONE | Simulation matrix plus physical T3–T5 board observations | None for selected T1–T5 scope |
| 9 | Trojan localization | DONE (regional scope) | Simulation matrix plus physical localization outputs | Do not describe code 11 as exact T3/T4/T5 identification |
| 10 | Multiple MNIST workloads | DONE | `verification/workloads/workload_manifest.csv`, `runs.csv` | None |
| 11 | TPR/FPR/Precision/F1 | DONE (simulation scope) | Metrics derived from the committed 60-row ledger | Do not generalize beyond evaluated cases |
| 12 | Localization accuracy/confusion matrix | DONE (simulation scope) | Metrics derived from `runs.csv` | Do not generalize beyond evaluated cases |
| 13 | Cross-workload robustness | DONE (simulation scope) | Ten workload classes in the canonical matrix | Broader datasets remain future work |
| 14 | Resource utilization | PARTIAL | `verification/results/hardware_resources.csv` and Quartus logs | T3–T5 exact final fitter ALM/register counts are not archived; Healthy/T1/T2 archived snapshots should be refreshed on C6 after the device-target correction |
| 15 | Paper-quality tables/figures | DONE for current evidence | `paper/tables/`, `paper/figures/` | Regenerate if new measurements are added |
| 16 | Healthy latency discrepancy | DONE | `docs/BASELINE_RECONCILIATION.md` | None |
| 17 | Final paper-ready evidence | DONE for defined scope | `paper/manuscript.md` plus physical validation record | Physical power remains a stated limitation |

## Canonical numeric policy

The canonical resource file is:

`verification/results/hardware_resources.csv`

It records:

- Healthy: 1153 ALMs, 902 registers, 71 RAM blocks, 13 DSPs
- T1: 1170 ALMs, 910 registers, 71 RAM blocks, 13 DSPs
- T2: 1192 ALMs, 919 registers, 71 RAM blocks, 15 DSPs
- T3/T4/T5: exact final ALM/register counts are **not archived in the canonical CSV**

No unsupported T3–T5 fitter numbers are to be inferred.

## Statistical scope

The 60-row ledger is:

- 10 workloads × 6 architectures
- 10 healthy rows
- 50 Trojan rows

Its metrics are valid for the committed simulation regression. They must not be presented as universal detector performance or as 60 physical measurements.

## Physical status

- Healthy/T1/T2: documented physical validation.
- T3: programmed successfully; LEDR0–LEDR5 all observed ON; class 7, detector asserted, localization 11.
- T4: programmed successfully; LEDR0–LEDR5 all observed ON; class 7, detector asserted, localization 11.
- T5: programmed successfully; LEDR0–LEDR5 all observed ON; class 7, detector asserted, localization 11.
- Physical power/current measurement: not available.

## Submission gate

For the defined controlled-project scope, the physical-board gate is now closed. Remaining items are limitations/extensions rather than blockers:

1. physical rail/current power instrumentation;
2. exact unarchived T3–T5 fitter resource counts;
3. broader datasets and cross-CNN generalization;
4. executable numerical ablation study.
