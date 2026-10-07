# Ablation and Architectural Evaluation

## Evidence status

The repository contains an architectural discussion of possible ablations, but it does **not** contain independently reproducible RTL builds and raw logs for output-only, PE-only, memory-only, and proposed-monitor variants as separate experiments. Therefore the numerical ablation table that previously appeared here has been removed from the scientific evidence set. The claims below are design rationale, not measured ablation results.

## Supported design rationale

- A PE-only monitor can directly cover T1 but does not, by construction, cover memory, interconnect, routing, or control Trojans.
- A memory-only monitor directly covers T2 but does not cover the other Trojan regions.
- The proposed multi-region monitor exposes a 1-bit detection flag plus a 2-bit regional code.
- T3, T4 and T5 intentionally share regional code `2'b11`; this is regional localization rather than exact Trojan identity.

## Stealthiness scope

The ten-workload simulation ledger records unchanged top-1 classification for the selected workloads. That is evidence of classification invariance for those cases, not a universal stealthiness proof.

## What is still required for a true ablation study

1. Build a no-monitor/output-only reference.
2. Build a PE-only monitor.
3. Build a memory-only monitor.
4. Build the full multi-region monitor.
5. Record fitted resources and detection outcomes for the same workload/Trojan matrix.
6. Archive raw logs and regenerate the comparison table from those logs.
