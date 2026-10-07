#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="${ROOT}/verification/results/extended_workloads/extended_manifest.csv"
OUTROOT="${ROOT}/verification/results/extended_matrix"
RUNS="${ROOT}/verification/results/extended_runs.csv"

python3 "${ROOT}/verification/generate_extended_workloads.py"
rm -rf "${OUTROOT}"
mkdir -p "${OUTROOT}"
printf '%s\n' 'workload_id,trojan_id,trojan_present,trigger_location,predicted_class,expected_class,detected,expected_localization,localization_code,inference_cycles,detection_cycle,detection_latency_cycles,status' > "${RUNS}"

for T in Healthy T1 T2 T3 T4 T5; do
  TARGET="${OUTROOT}/${T}"
  mkdir -p "${TARGET}"
  cp -a "${ROOT}/cnn_baseline/data/." "${TARGET}/data/"
  if [[ "${T}" == "Healthy" ]]; then
    RTL="${ROOT}/cnn_full_small/rtl/cnn_small_core_m10k.v"
    TB="${ROOT}/cnn_full_small/tb/tb_cnn_small_core.v"
  else
    RTL="${ROOT}/trojan_${T}/rtl/cnn_small_core_m10k.v"
    TB="${ROOT}/trojan_${T}/tb/tb_cnn_small_core.v"
  fi
  iverilog -g2012 -o "${TARGET}/sim.out" "${TB}" "${RTL}"
  while IFS=, read -r workload_id mnist_index expected mem_path; do
    [[ "${workload_id}" == "workload_id" ]] && continue
    W="${ROOT}/${mem_path}"
    RUN="${TARGET}/w_${workload_id}"
    mkdir -p "${RUN}"
    rm -rf "${TARGET}/data/mnist_image0_int8.mem"
    ln -s "${W}" "${TARGET}/data/mnist_image0_int8.mem"
    LOG="${RUN}/simulation.log"
    (cd "${TARGET}" && timeout 45s vvp sim.out +EXPECTED="${expected}" +WORKLOAD="${workload_id}" +NAME="extended_${workload_id}") > "${LOG}" 2>&1
    pred=$(grep "Predicted class" "${LOG}" | tail -1 | awk '{print $NF}')
    cyc=$(grep "Cycle count" "${LOG}" | tail -1 | awk '{print $NF}')
    if [[ "${T}" == "Healthy" ]]; then
      detected=0; loc="00"; dcycle=0; latency=0; loc_expected="00"; present=0; trigger="NONE"
      grep -q "PASS: CNN predicted expected digit" "${LOG}" && [[ "${pred}" == "${expected}" ]] || { cat "${LOG}" >&2; exit 1; }
    else
      present=1
      case "${T}" in
        T1) loc_expected="01"; trigger="Conv2_PE";;
        T2) loc_expected="10"; trigger="Conv2_Weight";;
        T3) loc_expected="11"; trigger="Conv2_Interconnect";;
        T4) loc_expected="11"; trigger="Conv2_Routing";;
        T5) loc_expected="11"; trigger="Conv2_Control";;
      esac
      detected=$(grep "DETECTED" "${LOG}" | tail -1 | awk '{print $NF}' || true)
      [[ "${detected}" == "1" ]] || detected=0
      loc=$(grep "LOCALIZATION_OUTPUT" "${LOG}" | tail -1 | sed "s/.*2'b//" || true)
      dcycle=$(grep "DETECTION_CYCLE" "${LOG}" | tail -1 | awk '{print $NF}' || true)
      latency=$(grep "DETECTION_LATENCY" "${LOG}" | tail -1 | awk '{print $NF}' || true)
      if grep -q "PASS:" "${LOG}" && [[ "${pred}" == "${expected}" && "${detected}" == "1" && "${loc}" == "${loc_expected}" ]]; then
        :
      else
        cat "${LOG}" >&2
        exit 1
      fi
    fi
    printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' "${workload_id}" "${T}" "${present}" "${trigger:-NONE}" "${pred}" "${expected}" "${detected}" "${loc_expected}" "${loc}" "${cyc}" "${dcycle}" "${latency}" "PASS" >> "${RUNS}"
  done < "${MANIFEST}"
done

python3 "${ROOT}/verification/analyze_extended_matrix.py"
