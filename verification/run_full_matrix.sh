#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUT="${ROOT}/verification/results/full_matrix"
WORK="${ROOT}/verification/workloads"
RUNS="${ROOT}/verification/results/runs.csv"
rm -rf "${OUT}"
mkdir -p "${OUT}"

INDICES="0,1,2,3,4,5,6,7,8,9"
python3 "${ROOT}/verification/generate_mnist_workloads.py" --indices "${INDICES}" --clean >/dev/null

printf '%s\n' 'workload_id,trojan_id,trojan_present,trigger_location,predicted_class,expected_class,detected,expected_localization,localization_code,inference_cycles,detection_cycle,detection_latency_cycles,status' > "${RUNS}"

for W in "${WORK}"/mnist_*.mem; do
  base=$(basename "${W}" .mem)
  workload_id=$(echo "${base}" | sed -E 's/mnist_([0-9]+)_label([0-9]+)/\1/')
  expected=$(echo "${base}" | sed -E 's/mnist_([0-9]+)_label([0-9]+)/\2/')

  for T in Healthy T1 T2 T3 T4 T5; do
    RUN="${OUT}/workload_${workload_id}/${T}"
    mkdir -p "${RUN}/data"
    cp -a "${ROOT}/cnn_baseline/data/." "${RUN}/data/"
    rm -f "${RUN}/data/mnist_image0_int8.mem"
    ln -s "${W}" "${RUN}/data/mnist_image0_int8.mem"

    if [[ "${T}" == "Healthy" ]]; then
      RTL="${ROOT}/cnn_full_small/rtl/cnn_small_core.v"
      TB="${ROOT}/cnn_full_small/tb/tb_cnn_small_core.v"
      loc_expected="00"
      present=0
      trigger="NONE"
    else
      RTL="${ROOT}/trojan_${T}/rtl/cnn_small_core_m10k.v"
      TB="${ROOT}/trojan_${T}/tb/tb_cnn_small_core.v"
      present=1
      trigger="Conv2"
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

    pred=$(grep "Predicted class" "${LOG}" | tail -1 | awk '{print $NF}')
    cyc=$(grep "Cycle count" "${LOG}" | tail -1 | awk '{print $NF}')
    if [[ "${T}" == "Healthy" ]]; then
      detected=0; loc="00"; dcycle=0; latency=0
      if grep -q "PASS: CNN predicted expected digit" "${LOG}"; then status=PASS; else status=FAIL; fi
    else
      detected=$(grep "DETECTED" "${LOG}" | tail -1 | awk '{print $NF}' || true)
      [[ "${detected}" == "1" ]] || detected=0
      loc=$(grep "LOCALIZATION_OUTPUT" "${LOG}" | tail -1 | sed "s/.*2'b//" || true)
      dcycle=$(grep "DETECTION_CYCLE" "${LOG}" | tail -1 | awk '{print $NF}' || true)
      latency=$(grep "DETECTION_LATENCY" "${LOG}" | tail -1 | awk '{print $NF}' || true)
      if grep -q "PASS:" "${LOG}" && [[ "${pred}" == "${expected}" && "${detected}" == "1" && "${loc}" == "${loc_expected}" ]]; then status=PASS; else status=FAIL; fi
    fi

    printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\\n' "${workload_id}" "${T}" "${present}" "${trigger}" "${pred}" "${expected}" "${detected}" "${loc_expected}" "${loc}" "${cyc}" "${dcycle}" "${latency}" "${status}" >> "${RUNS}"

    if [[ "${status}" != "PASS" ]]; then
      echo "FAIL: workload=${workload_id} target=${T}" >&2
      cat "${LOG}" >&2
      exit 1
    fi
  done
done

python3 "${ROOT}/verification/generate_metrics_report.py"
python3 - "${RUNS}" <<'PY'
import csv,sys
from pathlib import Path
p=Path(sys.argv[1])
rows=list(csv.DictReader(p.open()))
assert len(rows)==60, len(rows)
assert all(r["status"]=="PASS" for r in rows)
print(f"PASS: archived 60/60 simulation rows in {p}")
PY
