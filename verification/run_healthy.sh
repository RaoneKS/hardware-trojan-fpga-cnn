#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
echo "run_healthy.sh is retained as a compatibility entry point."
echo "Running the canonical regression (Healthy + T1-T5 across the committed 10-workload manifest)."
exec "${ROOT}/verification/run_full_matrix.sh"
