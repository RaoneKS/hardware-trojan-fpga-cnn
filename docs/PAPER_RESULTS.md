# Paper Results Ledger

This file is the single source of truth for manuscript numbers. Only enter values backed by simulation, Quartus reports, or physical-board observations.

## Healthy baseline

### Functional
- MNIST reference image: predicted class 7.
- Software reference accuracy: 98.41%.
- Verified synchronous-M10K FPGA reference: 634,281 cycles.
- Healthy physical board output observed: class 7 on LEDR[2:0] = 111.

Historical latency values are retained and reconciled in `docs/BASELINE_RECONCILIATION.md`; the 346,563-cycle intermediate value is not the canonical current hardware reference.

### Fresh C6 Quartus evidence
- Device: 5CSXFC6D6F31C6.
- ALMs: 1,153.
- Registers: 912.
- Block memory bits: 455,104.
- RAM blocks: 71.
- DSP blocks: 13.
- Worst reported setup slack in the archived fresh C6 evidence: +0.181 ns.
- Worst reported hold slack in the archived fresh C6 evidence: +0.173 ns.
- Exact fresh C6 Fmax: not archived.
- No negative slack is recorded in the archived summary values.

## Trojan simulation evidence

The canonical `verification/results/runs.csv` contains 60 simulation regression rows: 10 workloads × Healthy/T1–T5.

For the deterministic reference image:

| ID | Behavior | Predicted class | Detected | Localization | Inference cycles | Detection cycle | Detection latency |
|---|---|---:|---:|---:|---:|---:|---:|
| T1 | Conv2 PE MAC product sign inversion | 7 | 1 | 01 | 634,281 | 149,144 | 149,136 |
| T2 | Conv2 weight bit flip | 7 | 1 | 10 | 634,281 | 149,144 | 149,136 |
| T3 | Conv2 feature interconnect bit alteration | 7 | 1 | 11 | 634,281 | 149,144 | 149,136 |
| T4 | Conv2 selective source-routing alteration | 7 | 1 | 11 | 634,281 | 149,144 | 149,136 |
| T5 | Conv2 selected control-path stall | 7 | 1 | 11 | 634,282 | 149,143 | 149,135 |

At 50 MHz:
- T1–T4 detection latency = 149,136 cycles = 2.98272 ms.
- T5 detection latency = 149,135 cycles = 2.98270 ms.

## Simulation metrics

For the committed 60-row simulation regression:
- Healthy = 10
- Trojan = 50
- TP = 50
- TN = 10
- FP = 0
- FN = 0
- TPR = 100%
- FPR = 0%
- Precision = 100%
- Recall = 100%
- F1 = 1.000

These are simulation-regression metrics for the evaluated workload set, not universal security guarantees.

## Physical-board validation

Physical board evidence currently archived in `docs/PHYSICAL_BOARD_VALIDATION.md` covers T1, T2, T3, T4 and T5. Each was programmed successfully with 0 programming errors and 0 warnings. T1 showed class 7, detector asserted, localization code 01; T2 showed class 7, detector asserted, localization code 10; T3/T4/T5 showed class 7, detector asserted, localization code 11.

Raw programmer logs for all five physical runs are archived under `verification/results/physical_T1_program.log` through `physical_T5_program.log`.

## Resource and power evidence

Fresh C6 resource evidence currently archived:

| Target | ALMs | Registers | Block memory bits | RAM blocks | DSP blocks | Worst setup slack | Worst hold slack | Fmax |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| Healthy | 1,153 | 912 | 455,104 | 71 | 13 | +0.181 ns | +0.173 ns | not archived |
| T1 | 1,170 | 918 | 455,104 | 71 | 13 | +0.141 ns | +0.141 ns | not archived |
| T2 | 1,192 | 919 | 455,104 | 71 | 15 | +0.163 ns | +0.163 ns | not archived |

Exact final fitter ALM/register/RAM/DSP counts for T3–T5 are not retained in the canonical resource ledger and are intentionally not invented.

Quartus Power Analyzer estimates:
- Healthy: 463.79 mW
- T1: 465.51 mW
- T2: 466.28 mW
- T3: 467.17 mW
- T4: 464.75 mW
- T5: 464.27 mW

These are tool estimates, not physical rail/current measurements.

## Separate held-out same-CNN evaluation

The successful [Extended MNIST validation CI run](https://github.com/RaoneKS/hardware-trojan-fpga-cnn/actions/runs/37684517036) screened held-out MNIST candidates using the Healthy baseline and selected five Healthy-correct images per class (50 total). Each selected image was evaluated on Healthy and T1–T5, giving 300 simulation rows. Results: TP=250, TN=50, FP=0, FN=0; TPR/recall=100%, FPR=0%, precision=100%, F1=1.000; expected-class preservation 300/300; regional localization 250/250 Trojan rows. The raw CSV and selection records are in the CI artifact; the documented report is `docs/EXTENDED_HELDOUT_RESULTS.md`. Because Healthy-misclassified inputs were excluded, this is a conditional same-CNN robustness result, not an all-MNIST FPR estimate.

## Scientific boundary

The project establishes runtime detection and regional localization for the selected controlled T1–T5 implementations within the evaluated simulation matrix and physical board-output demonstrations. It does not establish universal Hardware Trojan detection, exact identification among T3/T4/T5 from localization code 11, or physical power overhead.
