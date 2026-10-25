# Unseen-Trojan, workload-diversity, and cross-model experiment plan

## Status

**Planned, not executed.** This document defines experiments and reporting rules; it contains no new measurements.

## Research questions

1. Does the detector identify payloads not used while developing the monitor?
2. Does false-alarm behavior remain stable across diverse, non-screened MNIST samples?
3. Does the monitor transfer to another CNN architecture without redesigning its reference logic?
4. What area, timing, latency, and power costs does the final monitor-enabled implementation incur?

## Split discipline and leakage prevention

- Freeze detector RTL and thresholds before generating the held-out test matrix.
- Maintain separate development, validation, and final test manifests. Record hashes for images, RTL sources, scripts, tool versions, and constraints.
- Do not choose final test inputs based on detector output or exclude Healthy-misclassified inputs from the primary detector false-positive estimate.
- Report all-input detector metrics; a separately labelled Healthy-correct subset can be reported for classification-integrity analysis.
- Treat workload as a cluster: multiple Trojan variants on the same image are related observations. Report row-level binomial intervals as descriptive and include workload-cluster resampling where feasible.

## Experiment A — unseen Trojan variants

- Preserve T1–T5 as known-attack development cases.
- Add at least one held-out payload per region with a different trigger and payload implementation: alternate arithmetic perturbation, alternate weight-bit mutation, different feature-bit/word mutation, alternate address corruption, and a control anomaly other than a fixed one-cycle stall.
- Do not add held-out variants to monitor design or threshold selection.
- Include trigger-negative and near-trigger inputs to measure false alarms and missed detections.
- Record source hashes and an explicit attack specification for each held-out variant.
- Report per-variant TP/TN/FP/FN, TPR, FPR, precision, F1, confidence intervals, localization confusion matrix, detection latency, and classification agreement with the clean baseline.
- A missed unseen attack is a result to report, not a reason to tune on the test set.

## Experiment B — broader workload evaluation

- Use a predeclared random sample from the full MNIST test set, retaining both correctly and incorrectly classified clean inputs for detector metrics.
- Stratify reporting by digit class, image difficulty, and activation/trigger conditions without selecting samples based on detector output.
- Add a second dataset only after defining a compatible preprocessing pipeline; archive sample identifiers and hashes.
- Keep the canonical 60-case matrix unchanged as a regression benchmark.

## Experiment C — cross-model generalization

- Evaluate at least one structurally different model, such as a compact MLP and a second CNN, with independently verified weights.
- Distinguish (i) reuse of the same detector unchanged, (ii) porting the monitor to a new datapath, and (iii) retraining or reconfiguring thresholds. Only the first is strict transfer.
- Report topology, parameter quantization, training seed, baseline accuracy, synthesis settings, and per-model results.

## Experiment D — synthesis overhead and timing

- Synthesize healthy and monitor-enabled builds with identical device, constraints, Quartus version, optimization settings, and clock assumptions.
- Archive full fitter, timing analyzer, and resource reports for every build. Report ALMs, registers, M10K/RAM bits, DSPs, worst setup/hold slack, Fmax, and percentage overhead relative to the healthy baseline.
- Report whether timing constraints are met; positive slack alone is not a substitute for a documented clock constraint and full timing report.
- Do not reuse older pre-monitor reports as evidence for a newer RTL revision.

## Experiment E — power methodology

- Separate Quartus vectorless estimates, VCD-driven estimates, and physical measurements in different columns.
- For physical measurement, record measurement point, rail, instrument model/calibration, sampling rate, idle baseline, workload duty cycle, temperature, supply voltage, repeated trials, mean, standard deviation, and confidence interval.
- Never describe VCD toggles or Power Analyzer estimates as measured physical watts.
- If physical instrumentation is unavailable, mark physical power as not measured.

## Minimum evidence bundle

- Immutable manifests and SHA-256 hashes.
- Machine-readable per-run ledger with tool versions.
- Scripted metrics and unit tests.
- Raw logs and failure logs for every run.
- Per-Trojan localization confusion matrix.
- Baseline-versus-monitor synthesis comparison.
- Explicit list of failed, missing, and unexecuted experiments.
