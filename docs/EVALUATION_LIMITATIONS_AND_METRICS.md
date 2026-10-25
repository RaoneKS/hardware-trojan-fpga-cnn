# Evaluation limitations and reporting policy

## What the current evidence supports

The canonical ledger contains 60 RTL simulation rows: ten MNIST workloads, each evaluated with a healthy design and T1–T5. It reports TP=50, TN=10, FP=0, FN=0 for this fixed matrix. These counts are not a universal detection guarantee. The separately documented 300-row held-out same-CNN evaluation screened for Healthy-correct images and is conditional on that selection.

The workflow should regenerate the ledger from RTL before computing metrics. The uncertainty-aware metrics tool reads the measured-run ledger and does not invent rows or rewrite the original ledger.

## Confidence intervals

- TPR, FPR, and precision are reported with two-sided 95% Wilson score intervals.
- F1 is reported with a deterministic 95% percentile cluster-bootstrap interval, resampling workload IDs and keeping rows within a sampled workload together.
- Zero observed false positives does not imply a zero population false-positive rate. For example, 0/10 healthy observations has a nonzero upper confidence bound.
- Wilson intervals at the run-row level assume binomial observations and may be optimistic when rows share workloads or trigger logic. Cluster bootstrap addresses workload dependence for F1 only; it does not eliminate all sampling limitations.
- The canonical ledger is a deterministic regression suite, not a random sample. Intervals are descriptive uncertainty summaries, not proof that ten workloads represent a random population.

## Classification accuracy is distinct from Trojan detection

The predicted MNIST class, the class-ID bit width, and the detector's binary decision are separate quantities. The canonical ledger has one Healthy row and five Trojan rows for each of ten workload IDs. Detection metrics compare the detector output with trojan_present; they do not measure CNN classification accuracy. Report classification integrity separately by comparing predicted_class with expected_class and, where useful, the healthy prediction for the same workload.

## Localization accuracy

Localization is evaluated only on Trojan-present rows and only at the declared three-region resolution: 01 = Conv2 PE arithmetic, 10 = weight/data path, and 11 = shared interconnect/routing/control. Because T3, T4, and T5 all map to 11, the current encoding cannot distinguish these variants. Report per-region counts and a confusion matrix; do not describe this as exact component-level localization.

## Synthesis and timing overhead

The currently archived fresh C6 resource/timing snapshot covers Healthy, T1, and T2 only. Exact final fitter counts for T3–T5 and exact fresh-C6 Fmax are not archived. Do not infer missing values. For a valid overhead comparison, synthesize healthy and monitor-enabled RTL with identical device settings, constraints, tool version, and optimization options; archive the reports; compute absolute and percentage deltas; and report timing-constraint status. Historical results from an earlier RTL revision are not evidence for a newer revision unless source revisions are matched.

## Power measurement methodology

Quartus Power Analyzer values are estimates. VCD toggle counts are activity proxies. Neither is a physical power measurement. Physical power requires a documented measurement point, instrumentation, voltage/current capture, idle baseline, workload duty cycle, temperature, repeated trials, and uncertainty. The project does not claim physical rail/current power measurements.

## External validity and future experiments

Current evidence uses one compact MNIST CNN and five controlled Trojan variants. It does not establish unseen-Trojan detection or cross-model generalization. The planned matrix in docs/UNSEEN_TROJAN_AND_GENERALIZATION_PLAN.md defines held-out payloads, broader workload sampling, cross-model transfer, synthesis overhead, and power experiments. These experiments remain planned until raw evidence is archived.
