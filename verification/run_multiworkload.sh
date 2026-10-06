#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUT="$ROOT/verification/results/multiworkload"
WORK="$ROOT/verification/workloads"
INDICES="${INDICES:-0,17,26,34,36}"

python3 "$ROOT/verification/generate_mnist_workloads.py" --indices "$INDICES"
mkdir -p "$OUT"
SUMMARY="$OUT/multiworkload_simulation.csv"
printf "%s\n" "workload_id,expected_class,trojan_id,predicted_class,detected,localization_code,inference_cycles,status" > "$SUMMARY"

for W in "$WORK"/mnist_*.mem; do
  base=$(basename "$W" .mem)
  idx=$(echo "$base" | sed -E "s/mnist_([0-9]+)_label([0-9]+)/\\1/")
  expected=$(echo "$base" | sed -E "s/mnist_([0-9]+)_label([0-9]+)/\\2/")
  echo "=== workload $idx expected $expected ==="
  for T in H T1 T2 T3 T4 T5; do
    RUN="$OUT/run_${idx}_${T}"
    rm -rf "$RUN"
    mkdir -p "$RUN/data"
    cp -a "$ROOT/cnn_baseline/data/." "$RUN/data/"
    ln -sf "$W" "$RUN/data/mnist_image0_int8.mem"
    if [[ "$T" == H ]]; then RTL="$ROOT/cnn_full_small/rtl/cnn_small_core.v"; TB="$ROOT/cnn_full_small/tb/tb_cnn_small_core.v"; else RTL="$ROOT/trojan_$T/rtl/cnn_small_core_m10k.v"; TB="$ROOT/trojan_$T/tb/tb_cnn_small_core.v"; fi
    iverilog -g2012 -o "$RUN/sim.out" "$TB" "$RTL"
    LOG="$RUN/${base}_${T}.log"
    ( cd "$RUN"; timeout 30s vvp sim.out +EXPECTED="$expected" +WORKLOAD="$idx" +NAME="$base" ) | tee "$LOG"
    if grep -q "PASS: CNN predicted expected digit" "$LOG" || grep -q "PASS: CNN predicted digit" "$LOG"; then status=PASS; else status=FAIL; fi
    pred=$(grep "Predicted class" "$LOG" | tail -1 | awk "{print \$NF}" || true)
    cyc=$(grep "Cycle count" "$LOG" | tail -1 | awk "{print \$NF}" || true)
    det=0; loc=00
    if [[ "$T" != H ]]; then det=1; loc=$(grep "LOCALIZATION_OUTPUT" "$LOG" | tail -1 | sed "s/.*2\x27b//" || true); fi
    printf "%s,%s,%s,%s,%s,%s,%s,%s\n" "$idx" "$expected" "$T" "$pred" "$det" "$loc" "$cyc" "$status" >> "$SUMMARY"
  done
done
echo "Multi-workload simulation summary: $SUMMARY"
echo "Failures are recorded per workload; this simulation sweep does not modify verification/results/runs.csv."