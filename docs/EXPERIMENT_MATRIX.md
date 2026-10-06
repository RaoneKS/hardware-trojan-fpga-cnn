# Experiment Matrix

| ID | Trojan behavior | Detector | Localization | Simulation | Quartus | Physical DE10 |
|---|---|---:|---:|---|---|---|
| H | Reference CNN | 0 | 00 | Validated | Validated | Validated |
| T1 | Selected Conv2 MAC product sign inversion | 1 | 01 | Validated | Validated | Validated |
| T2 | Selected Conv2 weight bit flip | 1 | 10 | Validated | Validated | Validated |
| T3 | Selected Conv2 feature interconnect bit alteration | 1 | 11 | Validated | Validated | Validated |
| T4 | Selected Conv2 source-address/routing alteration | 1 | 11 | Validated | Validated | Validated |
| T5 | Selected Conv2 control-cycle stall | 1 | 11 | Validated | Validated | Validated |

## Physical validation interpretation

For the DE10-Standard top-level interface:
- LEDR[2:0] = predicted class bits.
- LEDR3 = Trojan detector.
- localization code is exported on LEDR4/LEDR5 in the board wrapper.
- For T3/T4/T5, LEDR0–LEDR5 all ON was observed, meaning class 7, detector asserted, and localization code 11.

Physical validation demonstrates that the implemented RTL/SOF produces the intended external result on the target FPGA. It does not by itself establish statistical TPR/FPR.

## Required statistical evaluation

For each repeated workload/Trojan run record:
- workload ID
- Trojan ID
- trigger location
- predicted class
- expected class
- detected flag
- localization code
- inference cycles
- detection cycle
- detection latency
- optional activity/power measurement

Compute TP, TN, FP, FN, TPR, FPR, precision, and F1 only from the repeated measured-run ledger.

## Hardware overhead

Use the same Quartus target and constraints for healthy and each detector/Trojan implementation. Record:
- ALMs
- registers
- block memory bits/RAM blocks
- DSP blocks
- worst setup slack
- worst hold slack
- Fmax
- power estimate or measured power, if available

Report absolute values and percentage change relative to healthy.

## Current statistical status

verification/results/runs.csv intentionally remains empty because only the deterministic reference-image measurements are currently available in repository form. Do not populate it with synthetic duplicates merely to manufacture TPR/FPR/F1.
