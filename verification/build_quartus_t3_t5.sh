#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
QUARTUS_SH="${QUARTUS_SH:-/home/raone/intelFPGA/25.1lite/quartus/bin/quartus_sh}"
LOG_DIR="$ROOT/verification/results/quartus"
mkdir -p "$LOG_DIR"

if [[ ! -x "$QUARTUS_SH" ]]; then
  echo "ERROR: quartus_sh not found at $QUARTUS_SH" >&2
  exit 1
fi

for T in T3 T4 T5; do
  DIR="$ROOT/trojan_$T"
  LOG="$LOG_DIR/${T}_quartus.log"
  echo "=== Building $T ===" | tee "$LOG"
  (
    cd "$DIR"
    "$QUARTUS_SH" --flow compile cnn_full_small
  ) 2>&1 | tee -a "$LOG"

  if grep -Eq 'Error \([0-9]+\)' "$LOG"; then
    echo "$T: Quartus reported errors." >&2
    exit 1
  fi

  if [[ ! -f "$DIR/cnn_full_small.sof" ]]; then
    echo "$T: expected SOF was not generated." >&2
    exit 1
  fi

  echo "$T: Quartus compile completed and SOF exists."
done

echo "T3/T4/T5 Quartus builds completed."
