# Remaining Measurement Protocol

This protocol is the bridge from the completed deterministic/physical validation to the statistical evidence required by the professor template.

## Frozen designs

Do not modify the validated T1-T5 payload RTL while collecting measurements.

Cases:
- H: healthy
- T1: Conv2 PE computation corruption
- T2: Conv2 weight/data-path corruption
- T3: Conv2 interconnect data-path alteration
- T4: Conv2 selective source-routing alteration
- T5: Conv2 control-path stall

## Minimum repeated dataset

Use at least 10 distinct valid MNIST inputs if available. A stronger paper uses 20-50 inputs.

For every input:
1. Run healthy.
2. Run T1.
3. Run T2.
4. Run T3.
5. Run T4.
6. Run T5.

This creates paired measurements under identical workload inputs.

For every run record:
- workload_id
- trojan_id
- trojan_present
- trigger_location
- predicted_class
- expected_class
- detected
- expected_localization
- localization_code
- inference_cycles
- detection_cycle
- detection_latency_cycles
- switching/activity measurement if available
- power measurement/estimate if available

## Statistical rules

Do not duplicate the deterministic reference run.

Detection:
- TP = Trojan present and detector asserted
- FN = Trojan present and detector absent
- FP = Trojan absent and detector asserted
- TN = Trojan absent and detector absent

Report:
- TPR = TP/(TP+FN)
- FPR = FP/(FP+TN)
- Precision = TP/(TP+FP)
- F1 = 2TP/(2TP+FP+FN)

Localization:
- compare expected_localization against localization_code only for Trojan-present runs
- report accuracy and the full confusion matrix
- document ambiguous/tied cases rather than silently resolving them

Latency:
- report per-case cycles and microseconds
- report mean/std/min/max when enough repeated samples exist

## Normal-operation signature characterization

For healthy runs, collect the available runtime signatures supported by the implementation:
- inference timing/cycle count
- switching/activity proxy
- communication/control activity
- functional mismatch
- power estimate or board measurement

For each feature report mean, standard deviation, minimum, maximum, and the threshold/window actually used by the detector.

## False-positive stress test

Use Trojan-free inputs spanning different MNIST classes and activity patterns. The detector must be evaluated on healthy runs not used to establish a threshold when a train/calibration split is claimed.

## Cross-workload validation

Where feasible:
- calibrate the normal envelope on one subset
- evaluate on a disjoint subset
- report the resulting FPR/TPR separately

## Stealthiness sweep

Only perform this if the RTL supports a controlled payload-strength parameter without changing the detector in a way that invalidates the comparison.

Report detection probability versus the controlled signature/payload strength. Do not label arbitrary manual perturbations as a stealthiness experiment.

## Power/activity

Use the same Quartus device, constraints, clock and analysis assumptions for all designs.

If using Quartus Power Analyzer:
- document whether activity is vectorless or VCD-based
- use the same operating conditions for all cases
- record total thermal power and relevant dynamic/static components

If using board measurement:
- record instrument, sampling method, voltage/current measurement point and averaging window

Do not mix estimated and measured power in one table without labeling them.

## Final paper generation

Once runs.csv is populated with real measurements:
1. Run verification/aggregate_metrics.py.
2. Generate the detection-performance table.
3. Generate the localization confusion matrix.
4. Generate latency statistics.
5. Generate hardware-overhead comparison from hardware_resources.csv.
6. Generate normal-signature distributions.
7. Generate ablation/robustness plots only when their corresponding measurements exist.
8. Update docs/PAPER_RESULTS.md.
9. Regenerate the paper and presentation.
