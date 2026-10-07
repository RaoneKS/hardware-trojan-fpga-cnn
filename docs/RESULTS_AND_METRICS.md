# Final Results and Metrics

## Simulation matrix
10 workloads × 6 targets = 60 rows.

| Metric | Value |
|---|---:|
| Healthy rows | 10 |
| Trojan rows | 50 |
| TP | 50 |
| TN | 10 |
| FP | 0 |
| FN | 0 |
| TPR / Recall | 100% |
| FPR | 0% |
| Precision | 100% |
| F1 | 1.000 |
| Regional localization | 50/50 = 100% |

These are controlled simulation results only.

## Latency
- 50 MHz clock = 20 ns/cycle.
- T1–T4 detection: 149,136 cycles = 2.98272 ms.
- T5 detection: 149,135 cycles = 2.98270 ms.
- T1–T4 inference: 634,281 cycles.
- T5 inference: 634,282 cycles.

## Fresh C6 resource evidence
| Target | ALMs | Registers | RAM blocks | DSP | Setup | Hold |
|---|---:|---:|---:|---:|---:|---:|
| Healthy | 1153 | 912 | 71 | 13 | +0.181 ns | +0.173 ns |
| T1 | 1170 | 918 | 71 | 13 | +0.141 ns | +0.141 ns |
| T2 | 1192 | 919 | 71 | 15 | +0.163 ns | +0.163 ns |

T3–T5 final fitter resource counts are not archived. Fresh C6 Fmax is not archived.

## Power estimates
Healthy 463.79 mW; T1 465.51 mW; T2 466.28 mW; T3 467.17 mW; T4 464.75 mW; T5 464.27 mW.

These are Quartus Power Analyzer estimates, not physical measurements.
