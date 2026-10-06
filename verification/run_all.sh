#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUT="$ROOT/verification/results"
mkdir -p "$OUT"

SUMMARY="$OUT/simulation_summary.csv"
printf '%s\n' 'trojan_id,predicted_class,detected,localization_code,inference_cycles,detection_cycle,detection_latency_cycles,status' > "$SUMMARY"

for T in T1 T2 T3 T4 T5; do
  DIR="$ROOT/trojan_$T"
  LOG="$OUT/${T}_simulation.log"
  echo "=== $T ===" | tee "$LOG"
  (
    cd "$DIR"
    if [[ -L data || -d data ]]; then
      rm -rf data
    fi
    ln -s "$ROOT/cnn_baseline/data" data
    trap 'rm -f data' EXIT
    iverilog -g2012 -o "cnn_${T}_tb" tb/tb_cnn_small_core.v rtl/cnn_fpga_top.v rtl/cnn_small_core_m10k.v
    timeout 30s vvp "cnn_${T}_tb"
  ) | tee -a "$LOG"

  case "$T" in
    T1) EXPECTED_LOC="01"; EXPECTED_CYCLES="634281"; EXPECTED_LATENCY="149136";;
    T2) EXPECTED_LOC="10"; EXPECTED_CYCLES="634281"; EXPECTED_LATENCY="149136";;
    T3) EXPECTED_LOC="11"; EXPECTED_CYCLES="634281"; EXPECTED_LATENCY="149136";;
    T4) EXPECTED_LOC="11"; EXPECTED_CYCLES="634281"; EXPECTED_LATENCY="149136";;
    T5) EXPECTED_LOC="11"; EXPECTED_CYCLES="634282"; EXPECTED_LATENCY="149135";;
  esac

  if ! grep -q "PASS:" "$LOG"; then
    echo "$T: PASS marker not found" >&2
    exit 1
  fi
  if ! grep -q "Predicted class.*= 7" "$LOG"; then
    echo "$T: expected class 7 not observed" >&2
    exit 1
  fi
  if ! grep -Eq "PASS:.*${T} Detected" "$LOG"; then
    echo "$T: detector assertion not confirmed by PASS marker" >&2
    exit 1
  fi
  if ! grep -q "LOCALIZATION_OUTPUT = 2'b${EXPECTED_LOC}" "$LOG"; then
    echo "$T: expected localization ${EXPECTED_LOC} not observed" >&2
    exit 1
  fi
  if ! grep -q "Cycle count.*= ${EXPECTED_CYCLES}" "$LOG"; then
    echo "$T: expected inference cycle count ${EXPECTED_CYCLES} not observed" >&2
    exit 1
  fi
  if ! grep -q "DETECTION_LATENCY.*= ${EXPECTED_LATENCY}" "$LOG"; then
    echo "$T: expected detection latency ${EXPECTED_LATENCY} not observed" >&2
    exit 1
  fi

  PRED=$(grep "Predicted class" "$LOG" | tail -1 | awk '{print $NF}')
  DET=1
  LOC=$(grep "LOCALIZATION_OUTPUT" "$LOG" | tail -1 | sed "s/.*2'b//")
  CYC=$(grep "Cycle count" "$LOG" | tail -1 | awk '{print $NF}')
  DCYC=$(grep "${T}_DETECTION_CYCLE" "$LOG" | tail -1 | awk '{print $NF}')
  LAT=$(grep "DETECTION_LATENCY" "$LOG" | tail -1 | awk '{print $NF}')
  printf '%s,%s,%s,%s,%s,%s,%s,PASS\n' "$T" "$PRED" "$DET" "$LOC" "$CYC" "$DCYC" "$LAT" >> "$SUMMARY"
done

echo "All Trojan simulation smoke tests passed."
echo "Structured results: $SUMMARY"
