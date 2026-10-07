# Professor Requirements Audit — Final Evidence-Cleaned State

This audit is intentionally conservative. A requirement is **DONE** only when the repository contains a reproducible implementation and evidence that can be traced to the claimed result. Aggregate simulation ledgers are not treated as equivalent to archived raw logs.

| # | Requirement | Status | Evidence | Remaining action |
|---|---|---|---|---|
| 1 | Clean Trojan-free CNN baseline and golden reference | DONE | `cnn_baseline/`, `cnn_full_small/`, `cnn_full_small/reports/` | None |
| 2 | INT8/quantized CNN | DONE | `cnn_baseline/data/`, quantization scripts | None |
| 3 | Verified CNN inference | DONE | `cnn_full_small/tb/`, golden simulation evidence | None |
| 4 | T1–T5 controlled Trojans | DONE | `trojan_T1/` … `trojan_T5/` | None |
| 5 | Healthy + T1–T5 matched evaluation | PARTIAL | `verification/results/runs.csv` contains a 60-row regression ledger | Preserve/re-generate raw per-run logs before submission |
| 6 | Timing/latency evidence | PARTIAL | `verification/results/runs.csv`, Quartus logs, baseline reconciliation | Canonicalize all timing sources and archive raw reports used for paper tables |
| 7 | Power/activity evidence | PARTIAL | Quartus Power Analyzer summary table; VCD activity proxy | Physical rail measurement is still absent; archive raw .pow reports if available |
| 8 | Trojan detection | DONE (simulation scope) | `runs.csv`, Trojan RTL/TBs | Physical T3–T5 observation remains separate |
| 9 | Trojan localization | DONE (regional simulation scope) | `runs.csv` | Do not describe 2'b11 as exact T3/T4/T5 identification |
| 10 | Multiple MNIST workloads | DONE (10-class simulation matrix) | `verification/workloads/workload_manifest.csv`, `runs.csv` | Keep generator/manifest synchronized for future reruns |
| 11 | TPR/FPR/Precision/F1 | PARTIAL | Metrics derived from the 60-row ledger | Treat as results of the committed simulation ledger; archive raw logs before calling them fully auditable empirical statistics |
| 12 | Localization accuracy/confusion matrix | PARTIAL | Metrics derived from `runs.csv` | Same provenance limitation as #11 |
| 13 | Cross-workload robustness | PARTIAL | 10-class rows in `runs.csv` | Re-run and archive raw logs; current result is simulation-only |
| 14 | Resource utilization | PARTIAL | `verification/results/hardware_resources.csv` and Quartus logs | Canonical source is now the CSV; T3–T5 exact ALM/register values are not archived in that CSV and must not be invented |
| 15 | Paper-quality tables/figures | PARTIAL | `paper/tables/`, `paper/figures/` | Regenerate tables after final raw-evidence freeze |
| 16 | Healthy latency discrepancy | DONE | `docs/BASELINE_RECONCILIATION.md` | None |
| 17 | Final paper-ready evidence | PARTIAL | `paper/manuscript.md` | Paper is a strong draft, not final submission-ready until evidence provenance and physical T3–T5 validation are closed |

## Canonical numeric policy

The repository contains conflicting historical resource snapshots. The canonical resource file for the current audit is:

`verification/results/hardware_resources.csv`

It records:

- Healthy: 1153 ALMs, 902 registers, 71 RAM blocks, 13 DSPs
- T1: 1170 ALMs, 910 registers, 71 RAM blocks, 13 DSPs
- T2: 1192 ALMs, 919 registers, 71 RAM blocks, 15 DSPs
- T3/T4/T5: exact final ALM/register counts are **not archived in the canonical CSV**

Therefore the paper must not publish the older 1145/889 baseline or unsupported T3–T5 ALM/register numbers as if they were the canonical current measurements.

## Statistical scope

The 60-row ledger is:

- 10 workloads × 6 architectures
- 10 healthy rows
- 50 Trojan rows

Its calculated metrics are mathematically valid **conditional on those recorded simulation runs**, but raw per-run simulator logs are not all archived. The paper therefore uses the narrower phrase **"simulation regression ledger"** rather than claiming 60 independently archived physical measurements.

## Physical status

- T1/T2: documented physical validation.
- T3/T4/T5: build/JTAG readiness exists, but repository evidence does not establish human-observed board LED validation.
- Physical power/current measurement: not available.

## Submission gate

The project is **engineering-complete and simulation-evaluation-complete**, but the repository is not declared fully submission-ready until:
1. raw logs for the final 60-run matrix are archived or regenerated and archived;
2. one canonical Quartus resource/timing/power evidence set is frozen;
3. T3/T4/T5 are physically observed if the professor requires board validation for every Trojan;
4. paper claims are regenerated from that frozen evidence set.
