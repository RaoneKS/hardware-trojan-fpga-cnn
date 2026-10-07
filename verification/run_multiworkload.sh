#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
echo "run_multiworkload.sh is retained as a compatibility entry point."
echo "Running the canonical 10-workload x 6-target regression instead."
exec "${ROOT}/verification/run_full_matrix.sh"
