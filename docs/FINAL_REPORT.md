# Hardware Trojan Detection in FPGA-CNNs — Final Project Report

## Executive Summary
This project implements a runtime hardware-integrity detection and regional localization framework for an INT8 CNN accelerator on an Intel Cyclone V FPGA. Five controlled malicious variants target arithmetic, memory, interconnect, routing and control structures.

## Objectives
1. Build a clean CNN accelerator baseline.
2. Use an INT8 inference datapath.
3. Implement five controlled malicious variants.
4. Add runtime detection and regional localization.
5. Evaluate ten MNIST workloads.
6. Produce reproducible FPGA implementation evidence.
7. Validate selected bitstreams on the DE10-Standard.
8. Prepare a research-paper-ready evidence package.

## Experimental campaign
The canonical simulation matrix contains 60 rows: ten workloads multiplied by Healthy, T1, T2, T3, T4 and T5.

## Results
TP=50, TN=10, FP=0, FN=0. TPR=100%, FPR=0%, precision=100%, recall=100%, F1=1.000. Regional localization is 50/50 = 100% at the defined three-region resolution.

Fresh C6 evidence: Healthy 1153 ALMs, 912 registers, 71 RAM blocks and 13 DSPs; T1 1170 ALMs, 918 registers, 71 RAM blocks and 13 DSPs; T2 1192 ALMs, 919 registers, 71 RAM blocks and 15 DSPs. All three have positive archived setup and hold slack.

T3, T4 and T5 were physically programmed on the DE10-Standard with zero programming errors/warnings; all six LEDs were observed ON, corresponding to class 7, detector asserted and localization 11.

## Limitations
Physical power/current was not measured. Exact T3–T5 final fitter counts and fresh C6 Fmax are not archived. The experiment does not prove universal detection. Code 11 is a shared region code.

## Conclusion
The defined controlled-project scope is complete and submission-ready. Remaining limitations are explicitly documented research extensions.
