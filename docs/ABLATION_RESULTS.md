# Ablation and Architectural Evaluation

## Evidence status

The repository contains an **evidence-bounded evaluation-layer channel-masking ablation** derived from the committed 60-row simulation ledger. It is reproducible from `verification/analyze_ablation_stealthiness.py` and the archived CSV outputs. It is **not** a set of independently synthesized no-monitor, PE-only, memory-only, and full-monitor hardware builds, so no build-level resource overhead is claimed.

## Supported design rationale

- A PE-only monitor can directly cover T1 but does not, by construction, cover memory, interconnect, routing, or control Trojans.
- A memory-only monitor directly covers T2 but does not cover the other Trojan regions.
- The proposed multi-region monitor exposes a 1-bit detection flag plus a 2-bit regional code.
- T3, T4 and T5 intentionally share regional code `2'b11`; this is regional localization rather than exact Trojan identity.

## Stealthiness scope

The ten-workload simulation ledger records unchanged top-1 classification for the selected workloads. That is evidence of classification invariance for those cases, not a universal stealthiness proof.

## Current numerical coverage result

The committed ledger yields TPR values of 0% for functional-only classification, 20% for timing-only, 20% for code-01-only, 20% for code-10-only, 60% for code-11-only, and 100% for the full non-zero regional code. FPR is 0% for each masking configuration. These values are derived metrics, not independent hardware builds.

## What is still required for a true build-level ablation study

1. Create independently synthesized monitor variants (output-only, PE-only, memory-only, full regional).
2. Record fitted resources and detection outcomes from each build.
3. Archive raw build/simulation logs and regenerate the comparison table.
4. Add a graded trigger-probability/payload-severity sweep only after a controlled RTL parameter is available.
