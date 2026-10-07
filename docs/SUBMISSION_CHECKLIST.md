# Research Project Submission Checklist

## 1. CNN baseline
- [x] INT8 quantized CNN
- [x] Healthy baseline RTL
- [x] Bit-true/reference verification
- [x] Baseline latency reconciliation

## 2. Hardware Trojan suite
- [x] T1 — PE MAC computation corruption
- [x] T2 — Weight/data-path corruption
- [x] T3 — Interconnect corruption
- [x] T4 — Spatial routing corruption
- [x] T5 — Control-path stall

## 3. Reproducible simulation
- [x] Ten deterministic MNIST workloads covering digits 0–9
- [x] Canonical 10 × 6 simulation matrix
- [x] 60-row runs.csv ledger
- [x] TP/TN/FP/FN and derived metrics
- [x] Regional localization metrics
- [x] Cross-workload simulation evidence
- [x] CI regression infrastructure

## 4. FPGA implementation
- [x] Healthy/T1/T2 fresh C6 resource evidence
- [x] T3/T4/T5 Quartus compilation
- [x] T1 physical DE10 validation
- [x] T2 physical DE10 validation
- [x] T3 physical DE10 validation
- [x] T4 physical DE10 validation
- [x] T5 physical DE10 validation
- [x] Positive timing slack for T3/T4/T5
- [x] Conservative handling of unarchived fitter counts/Fmax

## 5. Power/activity
- [x] Quartus Power Analyzer estimates documented
- [x] Tool-estimate limitation documented
- [ ] Physical rail/current measurement — explicitly a limitation

## 6. Paper structure
- [x] Professor-format sections I–XVI represented in the manuscript
- [x] Related-work positioning across four categories
- [x] Expanded bibliography with recent literature
- [x] Professor-format Figures 13–27
- [x] Results tables and evidence ledger
- [x] State-of-the-art comparison
- [x] Reproducibility section
- [x] Limitations and threats-to-validity section
- [x] Viva/Q&A material

## 7. Evidence boundaries
- [x] 100%/0% metrics explicitly scoped to the 60-row controlled simulation matrix
- [x] T3/T4/T5 localization code 11 explicitly treated as shared regional localization
- [x] No fabricated T3–T5 fitter counts
- [x] No fabricated fresh-C6 Fmax
- [x] No fabricated numerical ablation
- [x] No fabricated stealthiness sweep
- [x] Physical power limitation stated

## Final status

**PROJECT COMPLETE for the defined controlled course/research implementation and validation scope.**

The remaining unchecked item is physical rail/current instrumentation, which is explicitly treated as a limitation rather than a blocker. Broader cross-CNN generalization, parameterized stealthiness sweeps, and executable ablation remain research extensions.
