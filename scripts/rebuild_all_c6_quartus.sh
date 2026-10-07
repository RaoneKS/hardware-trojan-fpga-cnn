#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QUARTUS_SH="${QUARTUS_SH:-/home/raone/intelFPGA/25.1lite/quartus/bin/quartus_sh}"
[[ -x "${QUARTUS_SH}" ]] || { echo "ERROR: Quartus not found at ${QUARTUS_SH}"; exit 1; }

projects=("cnn_full_small/cnn_full_small" "trojan_T1/cnn_full_small" "trojan_T2/cnn_full_small" "trojan_T3/cnn_full_small" "trojan_T4/cnn_full_small" "trojan_T5/cnn_full_small")
for rel in "${projects[@]}"; do
  dir="${ROOT}/$(dirname "${rel}")"
  project="$(basename "${rel}")"
  echo "=== C6 rebuild: ${project} ==="
  cd "${dir}"
  "${QUARTUS_SH}" --flow compile "${project}"
done
echo "PASS: all six C6 Quartus compile flows completed."
echo "Archive exact fitter/timing values only from generated Quartus reports."
