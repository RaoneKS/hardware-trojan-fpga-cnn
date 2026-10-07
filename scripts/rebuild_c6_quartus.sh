#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QUARTUS_SH="${QUARTUS_SH:-/home/raone/intelFPGA/25.1lite/quartus/bin/quartus_sh}"

if [[ ! -x "${QUARTUS_SH}" ]]; then
  echo "ERROR: Quartus not found at ${QUARTUS_SH}"
  echo "Set QUARTUS_SH to your Quartus 25.1 Lite quartus_sh executable."
  exit 1
fi

projects=(
  "${ROOT}/cnn_full_small/cnn_full_small.qpf"
  "${ROOT}/trojan_T1/cnn_full_small.qpf"
  "${ROOT}/trojan_T2/cnn_full_small.qpf"
)

for qpf in "${projects[@]}"; do
  dir="$(dirname "${qpf}")"
  project="$(basename "${qpf}" .qpf)"
  echo "=== C6 rebuild: ${project} ==="
  cd "${dir}"
  "${QUARTUS_SH}" --flow compile "${project}"
done

echo
echo "C6 Quartus rebuilds completed."
echo "Review the generated .fit.summary / .sta.summary files before updating"
echo "verification/results/hardware_resources.csv."
