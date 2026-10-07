#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"
fail=0
check_file(){ [[ -f "$1" ]] || { echo "FAIL: missing $1"; fail=1; }; }
for f in verification/results/runs.csv verification/results/ablation_summary.csv verification/results/stealthiness_sensitivity.csv verification/results/ABLATION_STEALTHINESS_REPORT.md Hardware_Trojan_FPGA_CNN_Professor_Submission.zip verification/results/PHYSICAL_BOARD_RERUN_2026-10-08.md; do check_file "$f"; done
for t in T1 T2 T3 T4 T5; do check_file "verification/results/physical_${t}_program.log"; done
rows=$(tail -n +2 verification/results/runs.csv | wc -l)
[[ "${rows}" -eq 60 ]] || { echo "FAIL: canonical rows=${rows}"; fail=1; }
passrows=$(awk -F, 'NR>1 && $NF=="PASS"{n++} END{print n+0}' verification/results/runs.csv)
[[ "${passrows}" -eq 60 ]] || { echo "FAIL: canonical PASS rows=${passrows}"; fail=1; }
unzip -t Hardware_Trojan_FPGA_CNN_Professor_Submission.zip >/dev/null || { echo "FAIL: ZIP integrity"; fail=1; }
for qsf in cnn_full_small/cnn_full_small.qsf trojan_T1/cnn_full_small.qsf trojan_T2/cnn_full_small.qsf trojan_T3/cnn_full_small.qsf trojan_T4/cnn_full_small.qsf trojan_T5/cnn_full_small.qsf; do
  grep -q 'set_global_assignment -name DEVICE 5CSXFC6D6F31C6' "${qsf}" || { echo "FAIL: non-C6 target in ${qsf}"; fail=1; }
done
if [[ "${fail}" -eq 0 ]]; then echo "PASS: final evidence audit"; else exit 1; fi
