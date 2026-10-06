# Submission Checklist

## Core implementation and validation
- [x] Research question and threat model
- [x] Trojan taxonomy T1-T5
- [x] Healthy baseline simulation and physical validation
- [x] T1 simulation, Quartus implementation, and physical validation
- [x] T2 simulation, Quartus implementation, and physical validation
- [x] T3 simulation and Quartus implementation
- [x] T3 physical board validation: LEDR0–LEDR5 all ON
- [x] T4 simulation and Quartus implementation
- [x] T4 physical board validation: LEDR0–LEDR5 all ON
- [x] T5 simulation and Quartus implementation
- [x] T5 physical board validation: LEDR0–LEDR5 all ON

## Reproducibility and documentation
- [x] Experiment matrix
- [x] Results/evidence ledger
- [x] Statistical metric calculation script
- [x] Reproducible RTL simulation regression
- [x] Quartus T3-T5 build helper
- [x] DE10 hardware-validation runbook
- [x] Literature review and positioning document
- [x] Viva/research documentation
- [x] Results/claims boundary
- [x] Limitations and threats to validity
- [x] Research paper draft generated from the professor template structure
- [x] Presentation draft generated

## Still required for a statistically complete paper
- [ ] Repeated healthy/Trojan workload data
- [ ] TPR/FPR/precision/F1 from measured repeated runs
- [ ] Localization confusion matrix over repeated cases
- [ ] Power/activity characterization
- [ ] CNN accuracy degradation across multiple workloads
- [ ] Single-vs-multi-signature ablation
- [ ] Stealthiness/robustness evaluation
- [ ] Cross-workload validation
- [ ] Optional cross-CNN validation
- [ ] Final hardware-backed paper revision using those measurements
- [ ] Final Figures 17–27 generated from the measured dataset

## Scientific claim boundary

The T1-T5 physical validation is complete at the board-output level. The project should not report statistical TPR/FPR/F1, cross-workload robustness, power/activity overhead, or ablation results until the corresponding repeated measurements are collected.

A single deterministic input is retained as a functional/controlled evidence case, not as a statistical test set.
