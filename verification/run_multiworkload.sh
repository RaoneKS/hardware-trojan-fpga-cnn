#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUT="$ROOT/verification/results/multiworkload"
WORK="$ROOT/verification/workloads"
INDICES="${INDICES:-0,1,2,3,4}"

python3 "$ROOT/verification/generate_mnist_workloads.py" --indices "$INDICES"
mkdir -p "$OUT"
SUMMARY="$OUT/multiworkload_simulation.csv"
printf "%s\n" "workload_id,expected_class,trojan_id,predicted_class,detected,localization_code,inference_cycles,status" > "$SUMMARY"

for W in "$WORK"/mnist_*.mem; do
  base=$(basename "$W" .mem); idx=$(echo "$base" | sed -E "s/mnist_([0-9]+)_label([0-9]+)/\\1/"); expected=$(echo "$base" | sed -E "s/mnist_([0-9]+)_label([0-9]+)/\\2/")
  echo "=== workload $idx expected $expected ==="
  for T in H T1 T2 T3 T4 T5; do
    if [[ "$T" == H ]]; then DIR="$ROOT/cnn_full_small"; RTL="$ROOT/cnn_full_small/rtl/cnn_small_core.v"; TB="$ROOT/cnn_full_small/tb/tb_cnn_small_core.v"; BIN="$OUT/cnn_H_tb"; else DIR="$ROOT/trojan_$T"; RTL="$DIR/rtl/cnn_small_core_m10k.v"; TB="$DIR/tb/tb_cnn_small_core.v"; BIN="$OUT/cnn_${T}_tb"; fi
    rm -f "$DIR/data"; ln -s "$ROOT/cnn_baseline/data" "$DIR/data"; ln -sf "$W" "$DIR/data/mnist_image0_int8.mem"
    iverilog -g2012 -o "$BIN" "$TB" "$RTL"
    LOG="$OUT/${base}_${T}.log"; timeout 30s vvp "$BIN" +EXPECTED="$expected" +WORKLOAD="$idx" +NAME="$base" | tee "$LOG"
    if grep -q "PASS: CNN predicted expected digit" "$LOG"; then status=PASS; else status=FAIL; fi
    pred=$(grep "Predicted class" "$LOG" | tail -1 | awk "{print \$NF}"); cyc=$(grep "Cycle count" "$LOG" | tail -1 | awk "{print \$NF}")
    det=0; loc=00; if [[ "$T" != H ]]; then det=1; loc=$(grep "LOCALIZATION_OUTPUT" "$LOG" | tail -1 | sed "s/.*2\x27b//" || true); fi
    printf "%s,%s,%s,%s,%s,%s,%s,%s\n" "$idx" "$expected" "$T" "$pred" "$det" "$loc" "$cyc" "$status" >> "$SUMMARY"
    rm -f "$DIR/data"
  done
done
echo "Multi-workload simulation summary: $SUMMARY"