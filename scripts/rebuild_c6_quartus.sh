#!/usr/bin/env bash
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QUARTUS_SH="${QUARTUS_SH:-/home/raone/intelFPGA/25.1lite/quartus/bin/quartus_sh}"
STAMP="$(date +%Y%m%d_%H%M%S)"
RUN_DIR="${ROOT}/quartus_validation_runs/${STAMP}"
mkdir -p "${RUN_DIR}/preexisting_sof" "${RUN_DIR}/builds"

if [[ ! -x "${QUARTUS_SH}" ]]; then
  echo "ERROR: Quartus not found at ${QUARTUS_SH}"
  echo "Set QUARTUS_SH to your Quartus 25.1 Lite quartus_sh executable."
  exit 1
fi

projects=(
  "cnn_full_small"
  "trojan_T1"
  "trojan_T2"
  "trojan_T3"
  "trojan_T4"
  "trojan_T5"
)

echo "Validation output: ${RUN_DIR}"
echo "Quartus executable: ${QUARTUS_SH}"
echo "Project list: ${projects[*]}"
echo

# Preserve every existing SOF before compilation. Never treat old SOFs as
# evidence for the current RTL; these copies are rollback/reference artifacts.
for project_dir in "${projects[@]}"; do
  dir="${ROOT}/${project_dir}"
  if [[ ! -f "${dir}/cnn_full_small.qpf" ]]; then
    echo "ERROR: missing project file: ${dir}/cnn_full_small.qpf"
    exit 1
  fi
  mkdir -p "${RUN_DIR}/preexisting_sof/${project_dir}"
  while IFS= read -r -d '' sof; do
    rel="${sof#"${dir}"/}"
    mkdir -p "${RUN_DIR}/preexisting_sof/${project_dir}/$(dirname "${rel}")"
    cp -p "${sof}" "${RUN_DIR}/preexisting_sof/${project_dir}/${rel}"
    echo "Preserved existing SOF: ${project_dir}/${rel}"
  done < <(find "${dir}" -type f -name '*.sof' -print0)
done

failures=0
for project_dir in "${projects[@]}"; do
  dir="${ROOT}/${project_dir}"
  project="cnn_full_small"
  log="${RUN_DIR}/${project_dir}.compile.log"
  out="${RUN_DIR}/builds/${project_dir}"
  mkdir -p "${out}"

  echo
  echo "============================================================"
  echo "Fresh Quartus compile: ${project_dir}/${project}"
  echo "Log: ${log}"
  echo "============================================================"

  if (cd "${dir}" && "${QUARTUS_SH}" --flow compile "${project}") 2>&1 | tee "${log}"; then
    echo "COMPILE_COMMAND_STATUS=PASS" | tee "${out}/validation_status.txt"
  else
    status=$?
    echo "COMPILE_COMMAND_STATUS=FAIL (exit ${status})" | tee "${out}/validation_status.txt"
    failures=$((failures + 1))
  fi

  # Copy relevant reports and any newly generated SOF into this run's
  # evidence directory, preserving paths and leaving a portable record.
  while IFS= read -r -d '' file; do
    rel="${file#"${dir}"/}"
    mkdir -p "${out}/$(dirname "${rel}")"
    cp -p "${file}" "${out}/${rel}"
  done < <(find "${dir}" -type f \\( -name '*.sof' -o -name '*.fit.summary' -o -name '*.sta.summary' -o -name '*.fit.rpt' -o -name '*.sta.rpt' -o -name '*.flow.rpt' \\) -print0)
done

{
  echo "Quartus validation run: ${STAMP}"
  echo "Quartus executable: ${QUARTUS_SH}"
  echo "Projects: ${projects[*]}"
  echo "Failed compile commands: ${failures}"
  echo "Important: inspect report warnings, unconstrained paths, setup/hold slack,"
  echo "Fmax, I/O pin assignments, and SOF timestamps/checksums before programming."
} | tee "${RUN_DIR}/SUMMARY.txt"

if (( failures > 0 )); then
  echo "RESULT=FAIL" | tee -a "${RUN_DIR}/SUMMARY.txt"
  exit 1
fi

echo "RESULT=COMPILE_COMMANDS_COMPLETED" | tee -a "${RUN_DIR}/SUMMARY.txt"
echo "This is not a sign-off: review all reports and confirm each expected SOF exists."
