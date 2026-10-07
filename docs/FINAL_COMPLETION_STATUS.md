# Final Completion Status

## Repository state

The repository contains the final reproducibility pipeline, evidence-cleanup changes, and physical DE10-Standard observations for T3, T4, and T5.

## What is complete

- INT8 CNN baseline and golden/reference flow
- T1–T5 controlled Trojan RTL and testbenches
- Workload-aware Trojan testbenches
- Ten deterministic MNIST workloads covering digits 0–9
- Canonical 10 workloads × 6 targets regression runner
- Canonical `verification/results/runs.csv` 60-row simulation ledger
- Automated TP/TN/FP/FN and derived metric generation
- CI execution of the canonical matrix
- CI artifact archiving of per-run simulation logs
- Canonical resource/timing evidence policy
- Conservative power/activity evidence wording
- Paper manuscript and tables
- Professor requirements audit
- Submission checklist
- Physical DE10-Standard board-output validation for T3, T4, and T5

## Committed simulation result

The committed ledger contains 60 PASS rows:

- Healthy: 10
- T1–T5: 50
- TP = 50
- TN = 10
- FP = 0
- FN = 0
- TPR = 100%
- FPR = 0%
- Precision = 100%
- F1 = 1.000
- Regional localization is correct for all committed Trojan rows

These statistics describe the committed simulation regression cases only. The ledger is not presented as 60 independent physical measurements.

## Physical DE10-Standard validation

T3, T4, and T5 were programmed successfully through the DE10-Standard USB-Blaster/JTAG chain at FPGA device index 2 (JTAG ID `02D020DD`), with 0 programming errors and 0 warnings.

Observed board output for each of T3, T4, and T5:

- LEDR0 = ON
- LEDR1 = ON
- LEDR2 = ON
- LEDR3 = ON
- LEDR4 = ON
- LEDR5 = ON
- `LEDR[2:0] = 111` → predicted class 7
- `LEDR3 = 1` → detector asserted
- `LEDR[5:4] = 11` → regional localization code 11

The physical observations are recorded in `docs/PHYSICAL_BOARD_VALIDATION.md`.

## Remaining limitations

Physical rail/current power measurement is not present. Quartus Power Analyzer values remain tool estimates, and VCD switching analysis remains an activity proxy.

Exact final fitter ALM/register/RAM/DSP counts for T3–T5 are not retained in the canonical resource ledger and must not be invented. Healthy/T1/T2 resource snapshots should also be refreshed on C6 after the final device-target correction.

The 100%/0% detection metrics are scoped to the committed 60-row simulation regression. They are not a universal guarantee for arbitrary Hardware Trojans.

Localization code `11` identifies the interconnect/routing/control region used by T3–T5; it does not distinguish T3 from T4 from T5.

## Final status

**PROJECT COMPLETE for the defined course/research implementation and validation scope.**

The repository now contains:
1. the working INT8 CNN baseline;
2. five controlled Trojan implementations;
3. reproducible multi-workload simulation and metrics;
4. Quartus implementation/timing evidence;
5. physical DE10-Standard output validation for T3–T5;
6. paper/documentation and conservative evidence boundaries.

The remaining items—physical power instrumentation, exact unarchived T3–T5 fitter counts, broader statistical/generalization studies, and executable ablation—are research extensions or evidence improvements, not blockers for the completed controlled project scope.
