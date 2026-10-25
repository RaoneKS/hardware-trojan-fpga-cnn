# Paper Results Ledger — Independent Monitor Revision

This ledger separates current monitor-enhanced simulation results from legacy pre-monitor hardware and held-out results.

## Current monitor-enhanced canonical simulation

GitHub Actions validated the canonical matrix on the independent-monitor branch.

- Workloads: 10 MNIST digit-class examples.
- Targets: Healthy, T1, T2, T3, T4, T5.
- Total rows: 60.
- Healthy rows: 10; no monitor alerts in 10/10.
- Trojan rows: 50; monitor alerts in 50/50.
- TP=50, TN=10, FP=0, FN=0.
- Point estimates: TPR=100%, FPR=0%, precision=100%, F1=1.000.
- Coarse regional localization correct: 50/50.
- 95% Wilson intervals: TPR 92.9–100% (n=50); FPR 0–27.8% (n=10).
- Dedicated monitor unit tests pass for healthy, T1/T2/T3 product signatures, address/control anomalies, and reset/re-arm.
- T4's payload was moved to the Conv2 prefetch path; the monitor now observes the changed registered address.

These metrics are conditional on the selected controlled RTL cases. Zero false alarms in ten healthy rows does not establish a low population-wide FPR, and the result is not a universal Trojan-detection guarantee.

## Current monitor detection latency

| Variant | Inference cycles | Detection latency | Time at 50 MHz | Coarse code |
|---|---:|---:|---:|---:|
| T1 | 634,281 | 149,137 | 2.98274 ms | 01 |
| T2 | 634,281 | 149,137 | 2.98274 ms | 10 |
| T3 | 634,281 | 149,137 | 2.98274 ms | 11 |
| T4 | 634,281 | 149,135 | 2.98270 ms | 11 |
| T5 | 634,282 | 149,136 | 2.98272 ms | 11 |

Healthy inference: 634,281 cycles = 12.68562 ms at 50 MHz. T5 adds one inference cycle. Code 11 is intentionally coarse and shared by T3/T4/T5.

## Legacy pre-monitor hardware evidence — not current monitor validation

### Healthy baseline and old C6 resource snapshots
- Device: 5CSXFC6D6F31C6.
- Healthy: 1,153 ALMs, 912 registers, 455,104 block-memory bits, 71 RAM blocks, 13 DSP blocks, +0.181 ns setup slack, +0.173 ns hold slack.
- T1: 1,170 ALMs, 918 registers, 455,104 block-memory bits, 71 RAM blocks, 13 DSP blocks, +0.141 ns setup slack, +0.141 ns hold slack.
- T2: 1,192 ALMs, 919 registers, 455,104 block-memory bits, 71 RAM blocks, 15 DSP blocks, +0.163 ns setup slack, +0.163 ns hold slack.
- Exact fresh C6 Fmax is not archived; final T3–T5 fitter counts are not inferred.

These counts predate the independent monitor and cannot quantify its area/timing overhead.

### Old power estimates
Quartus Power Analyzer estimates from the pre-monitor builds: Healthy 463.79 mW, T1 465.51 mW, T2 466.28 mW, T3 467.17 mW, T4 464.75 mW, T5 464.27 mW. These are tool estimates, not physical rail/current measurements, and do not describe the new monitor-enhanced builds.

### Old physical board observations
The pre-monitor T1–T5 SOFs were programmed on the DE10-Standard and produced the recorded class/detector/2-bit localization LED patterns. Those records do not validate the monitor-enhanced RTL. New Quartus builds, programming logs, and board observations are required.

### Historical held-out same-CNN evaluation
The old 50-image × 6-target / 300-row evaluation belongs to the pre-monitor RTL and is not included in the current monitor performance claims. Rerun it before citing held-out robustness for the independent monitor.

## Current scientific boundary

The current monitor checks sampled Conv2 MAC product consistency, the expected feature-memory address, and the T5 stall state. It assumes trusted clock/reset, operation counters, sampled reference operands, and monitor logic. It does not establish detection of arbitrary unknown Trojans. The monitor-enhanced RTL still needs held-out testing, Quartus resource/timing analysis, and physical DE10 validation.
