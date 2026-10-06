#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUT="$ROOT/verification/results"
mkdir -p "$OUT"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

cp "$ROOT/cnn_full_small/rtl/cnn_small_core.v" "$WORK/"
cp "$ROOT/cnn_full_small/tb/tb_cnn_small_core.v" "$WORK/"
ln -s "$ROOT/cnn_baseline/data" "$WORK/data"

cd "$WORK"

echo "=== HEALTHY ==="
iverilog -g2012 -o healthy_tb tb_cnn_small_core.v cnn_small_core.v
timeout 30s vvp healthy_tb | tee "$OUT/healthy_simulation.log"
cp cnn_full.vcd "$OUT/healthy.vcd"

if ! grep -q "PASS: CNN predicted expected digit 7" "$OUT/healthy_simulation.log"; then
  echo "Healthy regression failed: expected class 7" >&2
  exit 1
fi

PRED=$(grep "Predicted class" "$OUT/healthy_simulation.log" | tail -1 | awk '{print $NF}')
CYC=$(grep "Cycle count" "$OUT/healthy_simulation.log" | tail -1 | awk '{print $NF}')

printf '%s\n' 'trojan_id,predicted_class,detected,localization_code,inference_cycles,detection_cycle,detection_latency_cycles,status' > "$OUT/healthy_simulation_summary.csv"
printf 'H,%s,0,00,%s,,,PASS\n' "$PRED" "$CYC" >> "$OUT/healthy_simulation_summary.csv"

echo "Healthy simulation passed."
echo "Observed healthy inference cycles: $CYC"
echo "Note: the repository documentation currently cites a different historical healthy cycle count; this regression records the current RTL result without silently rewriting that evidence."
echo "Structured results: $OUT/healthy_simulation_summary.csv"
