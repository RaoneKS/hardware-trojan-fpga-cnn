#!/usr/bin/env bash
set -euo pipefail

ROOT=$(pwd)
OUT="$ROOT/verification/results"
mkdir -p "$OUT"

for T in T1 T2 T3 T4 T5; do
  DIR="$ROOT/trojan_$T"
  LOG="$OUT/${T}_simulation.log"
  echo "=== $T ===" | tee "$LOG"
  (
    cd "$DIR"
    iverilog -g2012 -o "cnn_$T_tb" tb/tb_cnn_small_core.v rtl/cnn_fpga_top.v rtl/cnn_small_core_m10k.v
    timeout 30s vvp "cnn_$T_tb"
  ) | tee -a "$LOG"
  if ! grep -q " PASS:" "$LOG"; then
    echo "$T: PASS marker not found" >&2
    exit 1
  fi
done

echo "All Trojan simulation smoke tests passed."
