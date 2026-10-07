# Research Project Submission Checklist

## 1. CNN baseline
- [x] INT8 quantized CNN
- [x] Healthy baseline RTL
- [x] Bit-true/reference verification
- [x] Baseline latency reconciliation

## 2. Hardware Trojan suite
- [x] T1 — PE MAC computation corruption
- [x] T2 — Weight-memory corruption
- [x] T3 — Interconnect corruption
- [x] T4 — Spatial routing corruption
- [x] T5 — Control-path stall

## 3. Reproducible simulation
- [x] Ten deterministic MNIST workloads covering digits 0–9
- [x] Canonical 10 × 6 simulation matrix
- [x] 60-row `verification/results/runs.csv` ledger
- [x] TPR/FPR/Precision/F1 derived from the committed simulation ledger
- [x] Regional localization metrics
- [x] Cross-workload simulation evidence
- [x] CI regression and artifact archiving
- [x] No unsupported numerical ablation claims

## 4. FPGA implementation
- [x] Healthy/T1/T2 archived resource evidence (refresh on C6 recommended)
- [x] Quartus timing evidence
- [x] T3–T5 Quartus timing/build evidence retained where available
- [x] Conservative resource policy: unarchived T3–T5 fitter counts are not invented

## 5. Power/activity
- [x] Quartus Power Analyzer estimates documented
- [x] VCD switching/activity proxy documented
- [ ] Physical rail/current power measurement — limitation, not required for the defined controlled-project completion

## 6. Physical DE10-Standard validation
- [x] Healthy/T1/T2 documented board validation
- [x] T3 physical LED/output observation
- [x] T4 physical LED/output observation
- [x] T5 physical LED/output observation

## 7. Paper
- [x] Manuscript
- [x] Tables
- [x] Figures/evidence package
- [x] Professor requirements audit
- [x] Physical T3–T5 validation record
- [x] Conservative claim boundaries

## Final status

**PROJECT COMPLETE for the defined controlled course/research scope.**

The project includes the INT8 CNN baseline, five controlled Trojan variants, reproducible multi-workload simulation, detection/localization metrics, Quartus implementation evidence, and physical DE10-Standard validation for T3–T5.

The following remain explicitly documented limitations/future work rather than completion blockers:
- physical rail/current power instrumentation;
- exact final T3–T5 fitter resource counts that were not archived;
- broader statistical datasets and cross-CNN generalization;
- executable numerical ablation.
