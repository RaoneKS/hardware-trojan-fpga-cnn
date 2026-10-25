# Current Completion Status — Independent Monitor Revision

## Current branch

Branch: `independent-runtime-monitor`

This branch adds a reference-assisted runtime monitor to the five Trojan variants and the clean reference core. The public detector/localization outputs now come from the monitor rather than Trojan-specific activation flags.

## Verified simulation evidence

- Canonical matrix: 10 workloads × 6 targets = 60 rows.
- Healthy: 10/10 runs had no monitor alert.
- Trojan variants: 50/50 controlled Trojan runs were detected.
- TP=50, TN=10, FP=0, FN=0.
- Coarse regional localization: 50/50 correct.
- All 60 regression rows passed in GitHub Actions.
- Dedicated monitor unit tests passed for healthy behaviour, T1/T2/T3 product signatures, address faults, control faults, and reset/re-arm.
- T4's address payload was moved to the actual Conv2 prefetch path after simulation exposed that the original injection point did not alter the selected address.

These are controlled RTL simulation results, not universal detection guarantees. The 95% Wilson intervals are TPR 92.9–100% (50/50) and FPR 0–27.8% (0/10); the small healthy denominator leaves substantial uncertainty about population-wide FPR.

## Current monitor detection latency

| Variant | Cycles | Time at 50 MHz | Coarse code |
|---|---:|---:|---:|
| T1 | 149,137 | 2.98274 ms | 01 |
| T2 | 149,137 | 2.98274 ms | 10 |
| T3 | 149,137 | 2.98274 ms | 11 |
| T4 | 149,135 | 2.98270 ms | 11 |
| T5 | 149,136 | 2.98272 ms | 11 |

## Legacy evidence — do not attribute to this monitor revision

The following records were produced using the pre-monitor RTL/bitstreams:
- 300-row held-out same-CNN simulation matrix.
- Quartus C6 resource/timing snapshots for Healthy/T1/T2.
- Quartus Power Analyzer estimates.
- Physical DE10-Standard programming and LED observations for T1–T5.

They remain useful historical project evidence, but do not measure the independent monitor's generalization, hardware overhead, or physical behaviour.

## Required next experiments

1. Rerun the held-out 50-image × 6-target matrix with monitor-enhanced RTL.
2. Rebuild Healthy and T1–T5 in Quartus using identical constraints; report ALM, register, RAM, DSP, setup/hold slack, Fmax, and tool-estimated power deltas.
3. Program the monitor-enhanced SOFs on the DE10-Standard and archive programming logs and observed outputs.
4. Test no-effect cases, signature collisions, benign deviations, reset/re-arm, and fault timing.
5. Evaluate a stronger trust boundary: duplicate/reference arithmetic that synthesis cannot merge, and independent expected-address/state inputs.
6. Expand localization beyond shared code 11 if the board interface and testbenches can support a wider code.

## Final status

**Simulation prototype strengthened and validated for the canonical controlled matrix. Physical implementation and held-out validation of the new monitor are still pending.**
