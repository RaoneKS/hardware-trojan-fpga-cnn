#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
OUT="Hardware_Trojan_FPGA_CNN_Professor_Submission.zip"
rm -f "$OUT"
zip -r "$OUT" professor_submission \
  verification/results/runs.csv \
  verification/results/hardware_resources.csv \
  docs/PHYSICAL_BOARD_VALIDATION.md \
  docs/FINAL_COMPLETION_STATUS.md \
  docs/PROFESSOR_REQUIREMENTS_AUDIT.md \
  docs/PAPER_RESULTS.md \
  docs/CROSS_WORKLOAD_RESULTS.md \
  docs/POWER_MEASUREMENT_PROTOCOL.md \
  docs/ABLATION_RESULTS.md \
  paper/manuscript.md >/dev/null
unzip -t "$OUT" >/dev/null
echo "Created and verified: $ROOT/$OUT"
