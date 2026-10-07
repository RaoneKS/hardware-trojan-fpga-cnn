#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
OUT="Hardware_Trojan_FPGA_CNN_Professor_Submission.zip"
rm -f "$OUT"
zip -r "$OUT"   professor_submission   paper/manuscript.md   paper/ieee_paper.tex   paper/references/references.bib   paper/tables   paper/figures   docs/FINAL_REPORT.md   docs/PAPER_RESULTS.md   docs/RESULTS_AND_METRICS.md   docs/CONFUSION_MATRIX.csv   docs/REPRODUCIBILITY.md   docs/RESEARCH_CLAIMS.md   docs/PHYSICAL_BOARD_VALIDATION.md   docs/FINAL_COMPLETION_STATUS.md   docs/PROFESSOR_REQUIREMENTS_AUDIT.md   docs/CROSS_WORKLOAD_RESULTS.md   docs/POWER_MEASUREMENT_PROTOCOL.md   docs/ABLATION_RESULTS.md   docs/VIVA_QA.md   verification/results/runs.csv   verification/results/hardware_resources.csv verification/results/physical_T1_program.log verification/results/physical_T2_program.log verification/results/physical_T3_program.log verification/results/physical_T4_program.log verification/results/physical_T5_program.log verification/results/PHYSICAL_BOARD_RERUN_2026-10-08.md   CITATION.cff >/dev/null
unzip -t "$OUT" >/dev/null
echo "Created and verified: $ROOT/$OUT"
