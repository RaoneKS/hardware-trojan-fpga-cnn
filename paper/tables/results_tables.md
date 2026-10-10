# Paper Tables

## Detection metrics
| Metric | Result |
|---|---:|
| TP | 50 |
| TN | 10 |
| FP | 0 |
| FN | 0 |
| TPR / Recall | 100% |
| FPR | 0% |
| Precision | 100% |
| F1 | 1.000 |

## Held-out same-CNN robustness matrix
| Metric | Result |
|---|---:|
| Selected held-out images | 50 (5 per digit class) |
| Healthy/T1–T5 simulation rows | 300 |
| TP / TN / FP / FN | 250 / 50 / 0 / 0 |
| TPR / Recall | 100% |
| FPR | 0% (conditional on Healthy-correct screening) |
| Precision | 100% |
| F1 | 1.000 |
| Expected class preserved | 300/300 |
| Regional localization correct | 250/250 Trojan rows |

## Regional localization
| True region | Predicted 01 | Predicted 10 | Predicted 11 |
|---|---:|---:|---:|
| T1 PE | 10 | 0 | 0 |
| T2 Weight memory | 0 | 10 | 0 |
| T3/T4/T5 shared region | 0 | 0 | 30 |
