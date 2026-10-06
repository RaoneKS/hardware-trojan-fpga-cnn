# Cross-Workload Robustness Evaluation

## Overview
A critical concern in Hardware Trojan detection within deep learning accelerators is input sensitivity: whether detection mechanisms trigger false alarms on diverse legitimate inputs (false positives) or fail to detect malicious activity when features change dynamically across different input classes (false negatives).

This evaluation reports empirical cross-workload measurements collected across 10 distinct MNIST digit classes ($0, 1, 2, 3, 4, 5, 6, 7, 8, 9$) on the clean healthy baseline and all five Trojan variants ($T_1$ through $T_5$).

---

## Experimental Dataset

| Workload ID | MNIST Test Index | Expected Class Label | INT8 Scaling Factor | File Path |
|---|---:|---:|---:|---|
| $W_0$ | 3 | 0 | 0.02111 | `verification/workloads/mnist_w0_class0_idx3.mem` |
| $W_1$ | 2 | 1 | 0.02159 | `verification/workloads/mnist_w1_class1_idx2.mem` |
| $W_2$ | 1 | 2 | 0.02166 | `verification/workloads/mnist_w2_class2_idx1.mem` |
| $W_3$ | 30 | 3 | 0.02111 | `verification/workloads/mnist_w3_class3_idx30.mem` |
| $W_4$ | 4 | 4 | 0.02213 | `verification/workloads/mnist_w4_class4_idx4.mem` |
| $W_5$ | 8 | 5 | 0.02111 | `verification/workloads/mnist_w5_class5_idx8.mem` |
| $W_6$ | 11 | 6 | 0.02111 | `verification/workloads/mnist_w6_class6_idx11.mem` |
| $W_7$ | 0 | 7 | 0.02241 | `verification/workloads/mnist_w7_class7_idx0.mem` |
| $W_8$ | 61 | 8 | 0.02159 | `verification/workloads/mnist_w8_class8_idx61.mem` |
| $W_9$ | 7 | 9 | 0.02111 | `verification/workloads/mnist_w9_class9_idx7.mem` |

---

## Empirical Cross-Workload Matrix

| Workload | True Class | Healthy Pred | Healthy Det | T1 Det (Loc) | T2 Det (Loc) | T3 Det (Loc) | T4 Det (Loc) | T5 Det (Loc) | Healthy Cycles | T5 Cycles |
|---|---:|---:|---:|:---:|:---:|:---:|:---:|:---:|---:|---:|
| **W0** | 0 | 0 | 0 (00) | 1 (01) | 1 (10) | 1 (11) | 1 (11) | 1 (11) | 634,281 | 634,282 |
| **W1** | 1 | 1 | 0 (00) | 1 (01) | 1 (10) | 1 (11) | 1 (11) | 1 (11) | 634,281 | 634,282 |
| **W2** | 2 | 2 | 0 (00) | 1 (01) | 1 (10) | 1 (11) | 1 (11) | 1 (11) | 634,281 | 634,282 |
| **W3** | 3 | 3 | 0 (00) | 1 (01) | 1 (10) | 1 (11) | 1 (11) | 1 (11) | 634,281 | 634,282 |
| **W4** | 4 | 4 | 0 (00) | 1 (01) | 1 (10) | 1 (11) | 1 (11) | 1 (11) | 634,281 | 634,282 |
| **W5** | 5 | 5 | 0 (00) | 1 (01) | 1 (10) | 1 (11) | 1 (11) | 1 (11) | 634,281 | 634,282 |
| **W6** | 6 | 6 | 0 (00) | 1 (01) | 1 (10) | 1 (11) | 1 (11) | 1 (11) | 634,281 | 634,282 |
| **W7** | 7 | 7 | 0 (00) | 1 (01) | 1 (10) | 1 (11) | 1 (11) | 1 (11) | 634,281 | 634,282 |
| **W8** | 8 | 8 | 0 (00) | 1 (01) | 1 (10) | 1 (11) | 1 (11) | 1 (11) | 634,281 | 634,282 |
| **W9** | 9 | 9 | 0 (00) | 1 (01) | 1 (10) | 1 (11) | 1 (11) | 1 (11) | 634,281 | 634,282 |

---

## Statistical Analysis of Robustness

1. **Detection Invariance**:
   - Detection Rate across all 10 workloads: **100.0%** (50 / 50 detections).
   - False Alarm Rate across all 10 healthy workloads: **0.0%** (0 / 10 false alarms).
2. **Localization Consistency**:
   - Every Trojan variant reported its exact dedicated 2-bit localization code without confusion across all digit classes.
   - Code `2'b01` (T1 Conv2 PE): 10/10 correct.
   - Code `2'b10` (T2 Conv2 Weight Memory): 10/10 correct.
   - Code `2'b11` (T3 Interconnect, T4 Routing, T5 Control): 30/30 correct.
3. **Temporal Invariance**:
   - For T1, T2, T3, and T4, detection latency was strictly invariant at **149,136 cycles** across all 10 workloads.
   - For T5, detection latency was strictly invariant at **149,135 cycles** across all 10 workloads.
   - Standard deviation of detection latency across workloads: **0.00 cycles**.
4. **Classification Integrity & Trojan Stealthiness**:
   - For all 10 workloads, the CNN output classification was identical between the healthy baseline and Trojan-injected runs.
   - This empirically confirms the **stealthiness** of the injected Trojans: all five Trojans operate at internal intermediate feature stages without causing top-1 classification flipping on standard MNIST images, making simple black-box output monitoring ineffective and proving the necessity of internal runtime assertion detectors.
