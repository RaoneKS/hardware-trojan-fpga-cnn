# Research Project Submission Checklist

## 1. Algorithmic and Baseline CNN
- [x] INT8 quantized CNN design and software training references (`cnn_baseline/`)
- [x] Bit-true software vs RTL equivalence validation (`cnn_baseline/scripts/check_full_int8_reference_fixed.py`)
- [x] Healthy baseline FPGA accelerator RTL (`cnn_full_small/`)
- [x] Baseline latency reconciliation documentation (`docs/BASELINE_RECONCILIATION.md`)

## 2. Hardware Trojan Suite (T1–T5)
- [x] T1 (PE MAC computation product inversion) RTL and testbench
- [x] T2 (Weight memory bit flip) RTL and testbench
- [x] T3 (Interconnect feature bus alteration) RTL and testbench
- [x] T4 (Spatial source-address routing alteration) RTL and testbench
- [x] T5 (Control-path execution stall) RTL and testbench

## 3. Verification & Empirical Evaluation
- [x] Multi-workload dataset generator and manifest across 10 classes (`verification/workloads/`)
- [x] 60-run regression execution ledger (`verification/results/runs.csv`)
- [x] Statistical metrics calculation script (`verification/aggregate_metrics.py`)
- [x] Statistical metrics summary (TPR=100%, FPR=0%, Precision=100%, F1=1.000) (`docs/FINAL_METRICS.md`)
- [x] Localization confusion matrix and 100% localization accuracy
- [x] Cross-workload robustness analysis (`docs/CROSS_WORKLOAD_RESULTS.md`)
- [x] Detection and ablation analysis (`docs/ABLATION_RESULTS.md`)

## 4. FPGA Implementation & Synthesis
- [x] Healthy Cyclone V compilation and fitter reports (1,145 ALMs, 889 regs, 71 M10K, 13 DSP)
- [x] T1–T5 Cyclone V compilation and fitter reports (1,151–1,218 ALMs, max +6.38% overhead)
- [x] Timing analysis reports and setup/hold slack verification (positive slack across all corners)
- [x] Quartus Power Analyzer thermal power characterization for all 6 targets (`docs/POWER_MEASUREMENT_PROTOCOL.md`)
- [x] Programming bitstreams generated (`.sof`) for all targets

## 5. Physical Hardware Validation
- [x] Healthy baseline physically validated on DE10-Standard (LEDR[2:0]=111)
- [x] T1 physically validated on DE10-Standard (LEDR[3]=1, localization 01)
- [x] T2 physically validated on DE10-Standard (LEDR[3]=1, localization 10)
- [x] T3–T5 automated JTAG detection and programming scripts verified (`program_de10_autodetect.sh`)
- [ ] T3–T5 physical visual observation of LED outputs on the benchtop board (requires physical board proximity)

## 6. Paper Package & Documentation
- [x] Professor requirements audit table (`docs/PROFESSOR_REQUIREMENTS_AUDIT.md`)
- [x] Viva / Defense Q&A preparation (`docs/VIVA_QA.md`)
- [x] Complete scientific manuscript (`paper/manuscript.md`)
- [x] Paper-ready tables and figures package (`paper/tables/`, `paper/figures/`)

