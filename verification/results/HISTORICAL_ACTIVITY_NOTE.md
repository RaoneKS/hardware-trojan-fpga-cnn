# Historical activity/simulation artifacts

The files named healthy_simulation.log, healthy_activity.csv and healthy_activity_summary.txt are retained as development-history evidence from the earlier distributed-RAM healthy RTL.

They report the historical 301,854-cycle implementation and must **not** be used as the canonical current healthy timing/activity result.

The canonical current healthy reference is the synchronous-M10K implementation:
- RTL: cnn_full_small/rtl/cnn_small_core_m10k.v
- Reference latency: 634,281 cycles at 50 MHz
- Canonical multi-workload ledger: verification/results/runs.csv
- Canonical runner: verification/run_full_matrix.sh

This note prevents the historical artifacts from being mistaken for current final evidence.
