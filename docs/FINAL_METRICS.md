# Verification & Statistical Metrics Summary

This summary is generated strictly from the recorded simulation execution ledger: `verification/results/runs.csv`.

## Summary of recorded simulation dataset
- **Total Workloads**: 10 distinct MNIST test images (Digit classes 0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
- **Target Hardware Architectures**: 6 (Healthy Baseline, Trojan T1, Trojan T2, Trojan T3, Trojan T4, Trojan T5)
- **Total Recorded Simulation Rows**: 60
- **Negative Runs (Healthy, Trojan Absent)**: 10
- **Positive Runs (Trojan Present)**: 50 (10 per Trojan variant)

---

## Confusion Matrix (Detection)

| Actual \ Predicted | Trojan Detected (Positive) | Trojan Undetected (Negative) | Total |
|---|---:|---:|---:|
| **Trojan Present** | 50 (TP) | 0 (FN) | 50 |
| **Trojan Absent (Healthy)** | 0 (FP) | 10 (TN) | 10 |
| **Total** | 50 | 10 | 60 |

---

## Statistical Security Performance Metrics

- **True Positives (TP)**: 50
- **True Negatives (TN)**: 10
- **False Positives (FP)**: 0
- **False Negatives (FN)**: 0
- **True Positive Rate (TPR / Sensitivity / Recall)**: **1.000000 (100.0%)**
  $$\text{TPR} = \frac{\text{TP}}{\text{TP} + \text{FN}} = \frac{50}{50 + 0} = 1.0$$
- **False Positive Rate (FPR / Fall-out)**: **0.000000 (0.0%)**
  $$\text{FPR} = \frac{\text{FP}}{\text{FP} + \text{TN}} = \frac{0}{0 + 10} = 0.0$$
- **Precision (Positive Predictive Value)**: **1.000000 (100.0%)**
  $$\text{Precision} = \frac{\text{TP}}{\text{TP} + \text{FP}} = \frac{50}{50 + 0} = 1.0$$
- **F1 Score**: **1.000000 (1.00)**
  $$\text{F1} = 2 \times \frac{\text{Precision} \times \text{Recall}}{\text{Precision} + \text{Recall}} = 1.0$$
- **Overall Accuracy**: **1.000000 (100.0%)**

---

## Trojan Localization Confusion Matrix

Evaluated across all 50 Trojan-active instances:

| Expected Region \ Observed Code | 2'b00 (None) | 2'b01 (PE Datapath) | 2'b10 (Weight Memory) | 2'b11 (Interconnect/Control) | Total | Accuracy |
|---|---:|---:|---:|---:|---:|---:|
| **2'b01 (T1: Conv2 PE MAC)** | 0 | 10 | 0 | 0 | 10 | 100.0% |
| **2'b10 (T2: Conv2 Weight Memory)** | 0 | 0 | 10 | 0 | 10 | 100.0% |
| **2'b11 (T3: Interconnect Bus)** | 0 | 0 | 0 | 10 | 10 | 100.0% |
| **2'b11 (T4: Routing Logic)** | 0 | 0 | 0 | 10 | 10 | 100.0% |
| **2'b11 (T5: Control Pipeline Stall)** | 0 | 0 | 0 | 10 | 10 | 100.0% |
| **Total** | 0 | 10 | 10 | 30 | 50 | **100.0%** |

- **Localization Accuracy**: **1.000000 (50 / 50 = 100.0%)**

---

## Detection Latency Distribution

Operating Clock: 50 MHz ($\tau = 20.0\text{ ns}$).

| Variant | Trojan Target | Sample Count | Min Latency (cycles) | Max Latency (cycles) | Mean Latency (cycles) | Latency Time (ms) | Total Inference (cycles) |
|---|---|---:|---:|---:|---:|---:|---:|
| **Healthy** | None | 10 | N/A | N/A | N/A | N/A | 634,281 |
| **T1** | Conv2 PE MAC Product | 10 | 149,136 | 149,136 | 149,136 | 2.98272 ms | 634,281 |
| **T2** | Conv2 Weight Memory | 10 | 149,136 | 149,136 | 149,136 | 2.98272 ms | 634,281 |
| **T3** | Interconnect Feature Bus | 10 | 149,136 | 149,136 | 149,136 | 2.98272 ms | 634,281 |
| **T4** | Source Address Routing | 10 | 149,136 | 149,136 | 149,136 | 2.98272 ms | 634,281 |
| **T5** | FSM Control-Path Stall | 10 | 149,135 | 149,135 | 149,135 | 2.98270 ms | 634,282 |

- **Detection Speed**: Detection occurs within the first **23.51%** of total inference time.
- **Inference Timing Overhead**:
  - T1–T4: **0.00%** (0 additional cycles).
  - T5: **+1 cycle (+0.00016%)** due to the single malicious stall state.


## Evidence provenance note
The metrics in this file are calculations from `verification/results/runs.csv`. The repository does not archive a distinct raw simulator log for every canonical row, so these values must be presented as simulation-ledger results rather than independently archived physical measurements.

## Separate held-out same-CNN evaluation
A separate successful GitHub Actions run evaluated 50 held-out MNIST images (five per class) after screening with the Healthy baseline, across Healthy and T1–T5 (300 rows). It reported TP=250, TN=50, FP=0, FN=0; TPR=100%, FPR=0%, precision=100%, F1=1.000, 250/250 regional-localization matches, and expected-class preservation for all selected cases. Because inputs misclassified by Healthy were excluded, the FPR is conditional on this Healthy-correct sample selection. This matrix is separate from the canonical `runs.csv` ledger and is documented in `docs/EXTENDED_HELDOUT_RESULTS.md`; raw CSV and screening records are retained in the successful [CI artifact](https://github.com/RaoneKS/hardware-trojan-fpga-cnn/actions/runs/37684517036).
