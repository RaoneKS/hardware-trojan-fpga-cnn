# Experiment Matrix

| ID | Trojan behavior | Monitor code | Region code | Monitor-enhanced simulation | Legacy Quartus | Legacy physical DE10 |
|---|---|---:|---:|---|---|---|
| H | Reference CNN | 0 | 00 | 10/10 no alerts | Pre-monitor build | Pre-monitor build |
| T1 | Selected Conv2 MAC product sign inversion | 1 | 01 | 10/10 detected | Pre-monitor build | Pre-monitor build |
| T2 | Selected Conv2 weight-operand bit flip | 1 | 10 | 10/10 detected | Pre-monitor build | Pre-monitor build |
| T3 | Selected Conv2 feature-operand bit flip | 1 | 11 | 10/10 detected | Pre-monitor build | Pre-monitor build |
| T4 | Selected Conv2 source-address/routing alteration | 1 | 11 | 10/10 detected after prefetch-path fix | Pre-monitor build | Pre-monitor build |
| T5 | Selected Conv2 control-cycle stall | 1 | 11 | 10/10 detected | Pre-monitor build | Pre-monitor build |

## Evidence revision boundary

The current draft branch adds an independent runtime monitor and has passed the canonical 60-row RTL simulation matrix plus monitor unit tests. The Quartus and physical DE10 records below describe the earlier pre-monitor bitstreams. They must not be used as hardware-overhead or physical-validation evidence for the monitor-enhanced RTL until new SOFs are built and programmed.

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

## Current monitor-enhanced statistical status

The committed verification/results/runs.csv contains the canonical 10-workload × 6-target simulation regression.

- 10 healthy rows
- 50 Trojan rows
- TP=50, TN=10, FP=0, FN=0
- TPR=100%, FPR=0%, Precision=100%, F1=1.000 for the 60 controlled simulation rows
- 95% Wilson CI: TPR 92.9–100% (n=50), FPR 0–27.8% (n=10)
- Regional localization is correct for all 50 Trojan rows

These are monitor-enhanced simulation-only metrics, not physical-board statistics. The 300-row held-out evaluation has not yet been rerun against the independent monitor. The canonical runner is verification/run_full_matrix.sh and it consumes verification/workloads/workload_manifest.csv using the synchronous-M10K healthy reference.
