# Table 5. Ablation and stealthiness sensitivity

## A. Evidence-bounded numerical ablation

| Configuration | TPR | FPR | Precision | F1 |
|---|---:|---:|---:|---:|
| Functional-only | 0.0% | 0.0% | — | — |
| Timing-only | 20.0% | 0.0% | 100.0% | 33.3% |
| PE-region-only (code 01) | 20.0% | 0.0% | 100.0% | 33.3% |
| Weight-memory-region-only (code 10) | 20.0% | 0.0% | 100.0% | 33.3% |
| Interconnect/control-region-only (code 11) | 60.0% | 0.0% | 100.0% | 75.0% |
| Full regional monitor | 100.0% | 0.0% | 100.0% | 100.0% |

Scope: derived deterministically from the committed 60-row simulation ledger. This is an evaluation-layer channel-masking/coverage ablation, not a claim of separately synthesized monitor variants or overhead deltas.

## B. Output-stealthiness / observability sensitivity

| Trojan | Output-stealthiness | Detection rate | Timing-visible rate | Mean cycle delta |
|---|---:|---:|---:|---:|
| T1 | 100.0% | 100.0% | 0.0% | 0.0 cycles |
| T2 | 100.0% | 100.0% | 0.0% | 0.0 cycles |
| T3 | 100.0% | 100.0% | 0.0% | 0.0 cycles |
| T4 | 100.0% | 100.0% | 0.0% | 0.0 cycles |
| T5 | 100.0% | 100.0% | 100.0% | 1.0 cycle |

Scope: output-stealthiness means the expected top-1 class is retained. This is a cross-variant observability comparison, not a continuous payload-severity sweep.
