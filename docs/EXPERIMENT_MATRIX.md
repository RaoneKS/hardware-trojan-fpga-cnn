# Experiment Matrix

| ID | Trojan behavior | Detector | Localization | Physical status |
|---|---|---:|---:|---|
| H | Reference CNN | 0 | 00 | Validated |
| T1 | Selected Conv2 MAC product sign inversion | 1 | 01 | Detector physically validated |
| T2 | Selected Conv2 weight bit flip | 1 | 10 | Detector + localization physically validated |
| T3 | Selected Conv2 feature interconnect bit flip | 1 | 11 | Simulation validated; Quartus/physical pending |
| T4 | Selected Conv2 source-address/routing alteration | 1 | 11 | Simulation validated; Quartus/physical pending |
| T5 | Selected Conv2 control-cycle stall | 1 | 11 | Simulation validated; Quartus/physical pending |

## Required statistical evaluation

For each workload/Trojan run record: workload ID, Trojan ID, trigger location, predicted class, expected class, detected flag, localization code, inference cycles, detection cycle, and detection latency.

Compute TP, TN, FP, FN, TPR, FPR, precision, and F1 from measured runs. Do not substitute deterministic trigger counts for these rates.

## Hardware overhead

Use the same Quartus target and constraints for healthy and each detector/Trojan implementation. Record ALMs, registers, block memory bits/RAM blocks, DSP blocks, worst-case setup slack, worst-case hold slack, and Fmax. Report absolute values and percentage change relative to healthy.
