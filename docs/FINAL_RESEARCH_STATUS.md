# Final Research Status

## Status as of 2026-10-07

The controlled course/research implementation is complete for the defined evidence scope.

### Completed
- Healthy INT8 CNN baseline with verified synchronous-M10K reference RTL.
- T1–T5 controlled Trojan RTL variants and workload-aware testbenches.
- Ten deterministic MNIST workloads covering classes 0–9.
- Canonical 10-workload × 6-target simulation matrix.
- 60-row committed simulation ledger with TP/TN/FP/FN metrics.
- Quartus implementation/timing evidence.
- Physical DE10-Standard board-output validation for T1, T2, T3, T4 and T5.
- Paper manuscript, tables, evidence audit and submission checklist.

### Canonical simulation result
The committed verification/results/runs.csv contains 60 PASS rows:
- Healthy: 10
- Trojan: 50
- TP=50, TN=10, FP=0, FN=0
- TPR=100%, FPR=0%, Precision=100%, F1=1.000
- Regional localization code matches the expected region for all 50 Trojan rows.

These are simulation-regression results for the selected workload set, not universal detection guarantees and not 60 physical measurements.

### Canonical timing result
At 50 MHz:
- Healthy/T1–T4 inference: 634,281 cycles
- T5 inference: 634,282 cycles
- T1–T4 detection latency: 149,136 cycles = 2.98272 ms
- T5 detection latency: 149,135 cycles = 2.98270 ms

Historical 301,854-cycle distributed-RAM and 346,563-cycle intermediate-M10K values remain documented only as development-history artifacts.

### Physical board evidence
T1, T2, T3, T4 and T5 were programmed successfully on the DE10-Standard:
- FPGA JTAG ID: 02D020DD
- Device index: @2
- T1/T2/T3/T4/T5 physical programming logs are archived under `verification/results/physical_T1_program.log` through `physical_T5_program.log`.
- T1: LEDR0–LEDR4 ON, LEDR5 OFF → class 7, detector asserted, localization code 01.
- T2: LEDR0/1/2/3/5 ON, LEDR4 OFF → class 7, detector asserted, localization code 10.
- T3/T4/T5: all six observed board-output LEDs ON → class 7, detector asserted, localization code 11.
- Physical rerun ledger: `verification/results/PHYSICAL_BOARD_RERUN_2026-10-08.md`.

Code 11 is a shared interconnect/routing/control region code; it does not distinguish T3, T4 and T5 individually.

### Resource and power evidence
Canonical exact resource counts are retained only where explicitly archived in verification/results/hardware_resources.csv:
- Healthy: 1,153 ALMs, 912 registers, 71 RAM blocks, 13 DSPs.
- T1: 1,170 ALMs, 918 registers, 71 RAM blocks, 13 DSPs.
- T2: 1,192 ALMs, 919 registers, 71 RAM blocks, 15 DSPs.
- T3–T5 exact final fitter counts: not archived in the canonical ledger.

Quartus Power Analyzer values are tool estimates, not physical rail/current measurements. VCD switching results are activity proxies.

### Remaining limitations / future extensions
1. Physical rail/current power instrumentation.
2. Broader datasets and cross-CNN generalization.
3. Independently synthesized build-level monitor ablation variants.
4. Graded trigger-probability/payload-severity sweep.
5. Exact final T3/T4/T5 fitter resource counts and fresh C6 Fmax, if those are required by the final paper.

The repository already contains an evidence-bounded evaluation-layer ablation and cross-variant stealthiness analysis; these are not substitutes for independently synthesized variants or a graded payload sweep.

These are evidence extensions/cleanup items, not blockers for the defined controlled project scope.
