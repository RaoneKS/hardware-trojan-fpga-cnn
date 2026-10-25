#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUT="${TMPDIR:-/tmp}/tb_trusted_runtime_monitor.out"
iverilog -g2012 -s tb_trusted_runtime_monitor -o "$OUT" \
  "$ROOT/verification/tb/tb_trusted_runtime_monitor.v" \
  "$ROOT/trojan_T1/rtl/cnn_small_core_m10k.v"
vvp "$OUT"
rm -f "$OUT"
