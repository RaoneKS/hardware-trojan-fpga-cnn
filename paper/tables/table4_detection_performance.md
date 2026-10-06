# Table 4: Statistical Detection & Localization Metrics Across 60 Measured Runs

| Metric Category | Metric Name | Mathematical Definition | Measured Empirical Value |
|---|---|---|:---:|
| **Detection Confusion** | True Positives (TP) | Verified Trojan detected | 50 / 50 |
| | True Negatives (TN) | Healthy run, detector quiescent | 10 / 10 |
| | False Positives (FP) | Healthy run, detector falsely asserted | 0 / 10 |
| | False Negatives (FN) | Trojan active, detector missed | 0 / 50 |
| **Classification Rates** | True Positive Rate (TPR / Recall) | $\text{TP} / (\text{TP} + \text{FN})$ | **100.0%** (1.000000) |
| | False Positive Rate (FPR) | $\text{FP} / (\text{FP} + \text{TN})$ | **0.0%** (0.000000) |
| | Precision (PPV) | $\text{TP} / (\text{TP} + \text{FP})$ | **100.0%** (1.000000) |
| | F1 Score | $2 \times (\text{Prec} \times \text{Rec}) / (\text{Prec} + \text{Rec})$ | **1.000000** |
| **Localization Accuracy** | Code `2'b01` (PE Datapath) | Attributed to Conv2 PE MAC Unit | 10 / 10 (100.0%) |
| | Code `2'b10` (Memory) | Attributed to Weight Storage RAM | 10 / 10 (100.0%) |
| | Code `2'b11` (Routing/Control) | Attributed to Interconnect / FSM | 30 / 30 (100.0%) |
| | Overall Localization Accuracy | Correctly attributed runs / Total Trojan runs | **100.0%** (50 / 50) |
