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
- [x] Healthy/T1/T2 canonical resource evidence
- [x] Quartus timing evidence
- [x] T3–T5 Quartus timing/build evidence retained where available
- [x] Conservative resource policy: unarchived T3–T5 fitter counts are not invented

## 5. Power/activity
- [x] Quartus Power Analyzer estimates documented
- [x] VCD switching/activity proxy documented
- [ ] Physical rail/current power measurement

## 6. Physical DE10-Standard validation
- [x] Healthy/T1/T2 documented board validation
- [ ] T3 physical LED/output observation
- [ ] T4 physical LED/output observation
- [ ] T5 physical LED/output observation

## 7. Paper
- [x] Manuscript
- [x] Tables
- [x] Figures/evidence package
- [x] Professor requirements audit
- [x] Conservative claim boundaries
- [ ] Final evidence freeze after physical T3–T5 validation, if required by professor

## Final status

The project is **engineering-complete and simulation-evaluation-complete**. It becomes fully hardware-validated only after the remaining physical DE10 observations (and physical power measurement if explicitly required) are completed.

Never present the simulation ledger as physical measurements, Quartus power estimates as physical power, or regional code `11` as exact T3/T4/T5 identification.
