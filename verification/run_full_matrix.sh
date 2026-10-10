#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUT="${ROOT}/verification/results/full_matrix"
RUNS="${ROOT}/verification/results/runs.csv"
MANIFEST="${ROOT}/verification/workloads/workload_manifest.csv"

rm -rf "${OUT}"
mkdir -p "${OUT}"

printf '%s\n' 'workload_id,trojan_id,trojan_present,trigger_location,predicted_class,expected_class,detected,expected_localization,localization_code,inference_cycles,detection_cycle,detection_latency_cycles,status' > "${RUNS}"

while IFS=, read -r workload_id mnist_index expected mem_path; do
  [[ "${workload_id}" == "workload_id" ]] && continue

  W="${ROOT}/${mem_path}"
  if [[ ! -f "${W}" ]]; then
    echo "FAIL: missing workload file: ${W}" >&2
    exit 1
  fi

  base=$(basename "${W}" .mem)

  for T in Healthy T1 T2 T3 T4 T5; do
    RUN="${OUT}/workload_${workload_id}/${T}"
    mkdir -p "${RUN}/data"
    cp -a "${ROOT}/cnn_baseline/data/." "${RUN}/data/"
    rm -f "${RUN}/data/mnist_image0_int8.mem"
    ln -s "${W}" "${RUN}/data/mnist_image0_int8.mem"

    if [[ "${T}" == "Healthy" ]]; then
      # Canonical healthy reference is the verified synchronous-M10K implementation.
      RTL="${ROOT}/cnn_full_small/rtl/cnn_small_core_m10k.v"
      TB="${ROOT}/cnn_full_small/tb/tb_cnn_small_core.v"
      loc_expected="00"
      present=0
      trigger="NONE"
    else
      RTL="${ROOT}/trojan_${T}/rtl/cnn_small_core_m10k.v"
      TB="${ROOT}/trojan_${T}/tb/tb_cnn_small_core.v"
      present=1
      case "${T}" in
        T1) loc_expected="01"; trigger="Conv2_PE";;
        T2) loc_expected="10"; trigger="Conv2_Weight";;
        T3) loc_expected="11"; trigger="Conv2_Interconnect";;
        T4) loc_expected="11"; trigger="Conv2_Routing";;
        T5) loc_expected="11"; trigger="Conv2_Control";;
      esac
    fi

    iverilog -g2012 -o "${RUN}/sim.out" "${TB}" "${RTL}"
    LOG="${RUN}/simulation.log"
    (cd "${RUN}" && timeout 45s vvp sim.out +EXPECTED="${expected}" +WORKLOAD="${workload_id}" +NAME="${base}") > "${LOG}" 2>&1
    # VCDs are not part of the canonical CSV evidence; discard them per run to keep CI disk use bounded.
    rm -f "${RUN}/cnn_full.vcd"

    pred=$(grep "Predicted class" "${LOG}" | tail -1 | awk '{print $NF}')
    cyc=$(grep "Cycle count" "${LOG}" | tail -1 | awk '{print $NF}')

    if [[ "${T}" == "Healthy" ]]; then
      detected=0; loc="00"; dcycle=0; latency=0
      if grep -q "PASS: CNN predicted expected digit" "${LOG}" && [[ "${pred}" == "${expected}" ]]; then
        status=PASS
      else
        status=FAIL
      fi
    else
      detected=$(grep "DETECTED" "${LOG}" | tail -1 | awk '{print $NF}' || true)
      [[ "${detected}" == "1" ]] || detected=0
      loc=$(grep "LOCALIZATION_OUTPUT" "${LOG}" | tail -1 | sed "s/.*2'b//" || true)
      dcycle=$(grep "DETECTION_CYCLE" "${LOG}" | tail -1 | awk '{print $NF}' || true)
      latency=$(grep "DETECTION_LATENCY" "${LOG}" | tail -1 | awk '{print $NF}' || true)
      if grep -q "PASS:" "${LOG}" && [[ "${pred}" == "${expected}" && "${detected}" == "1" && "${loc}" == "${loc_expected}" ]]; then
        status=PASS
      else
        status=FAIL
      fi
    fi

    printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' "${workload_id}" "${T}" "${present}" "${trigger}" "${pred}" "${expected}" "${detected}" "${loc_expected}" "${loc}" "${cyc}" "${dcycle}" "${latency}" "${status}" >> "${RUNS}"

    if [[ "${status}" != "PASS" ]]; then
      echo "FAIL: workload=${workload_id} target=${T}" >&2
      cat "${LOG}" >&2
      exit 1
    fi
  done
done < "${MANIFEST}"

python3 "${ROOT}/verification/generate_metrics_report.py"
python3 "${ROOT}/verification/validate_results.py"

python3 - "${RUNS}" <<'PY'
import csv,sys
from pathlib import Path
p=Path(sys.argv[1])
rows=list(csv.DictReader(p.open()))
assert len(rows)==60, len(rows)
assert all(r["status"]=="PASS" for r in rows)
assert sum(r["trojan_present"]=="0" for r in rows)==10
assert sum(r["trojan_present"]=="1" for r in rows)==50
print(f"PASS: archived 60/60 simulation rows in {p}")
PY
