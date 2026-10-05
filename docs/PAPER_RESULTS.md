# Paper Results Ledger

This file is the single source of truth for manuscript numbers. Only enter values backed by simulation, Quartus reports, or physical-board observations.

## Healthy baseline
- End-to-end functional simulation: recorded in cnn_baseline evidence.
- Physical classification: recorded in baseline evidence.
- Quartus resource/timing data: recorded in cnn_baseline/quartus evidence.

## Trojan evidence

### T1 — PE computation corruption
Measured simulation, Quartus, detector, and localization evidence already exists in the T1 experiment directory.

### T2 — Weight/data-path corruption
Measured simulation, Quartus, detector, localization, and physical-board evidence already exists in the T2 experiment directory.

### T3 — Interconnect data-path alteration
Implementation is present. The corrected testbench now checks:
- predicted class
- T3 detector assertion
- localization code 11
- detection cycle and latency

Before manuscript entry, run the T3 simulation and Quartus build and copy the measured values here.

### T4 — Selective interconnect routing alteration
Implementation is present. The payload changes the selected Conv2 source address to an adjacent spatial element and does not flip the data bus bit.

Before manuscript entry, run simulation and Quartus build and copy measured values here.

### T5 — Control-path anomaly
Implementation is present. The payload is a one-cycle selected Conv2 control-path stall; the data and weight operands are not directly modified.

Before manuscript entry, run simulation and Quartus build and copy measured values here.

## Statistical evaluation
A single deterministic MNIST image is not sufficient for TPR/FPR/F1 or workload robustness. Populate verification/results/runs.csv with multiple healthy and Trojan runs, then run verification/aggregate_metrics.py.

## Hardware validation boundary
Do not label T3/T4/T5 as physically validated until their SOFs are programmed on the DE10-Standard and the detector/localization LEDs are observed.
