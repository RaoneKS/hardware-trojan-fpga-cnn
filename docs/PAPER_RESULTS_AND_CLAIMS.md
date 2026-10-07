# Paper Results and Claims — Final Evidence Boundary

## Evidence classes
The manuscript distinguishes:
1. Physical hardware evidence: direct DE10-Standard programming and board-output observations.
2. Simulation evidence: cycle-accurate Verilog simulation from the canonical 10-workload × 6-target matrix.
3. Statistical evidence: metrics calculated from the committed simulation ledger.
4. Tool-estimation evidence: Quartus Power Analyzer thermal estimates.
5. Literature evidence: published external results.

No category is presented as another category.

## Validated project evidence

### Baseline
- LeNet-style MNIST CNN: Conv1 1→8, MaxPool1, Conv2 8→16, MaxPool2, FC 784→10.
- INT8 quantized weights/biases and bit-true reference flow.
- Verified synthesizable synchronous-M10K reference.
- Canonical healthy inference: 634,281 cycles at 50 MHz.
- Historical 301,854-cycle distributed-RAM and 346,563-cycle intermediate-M10K values are development artifacts, not current reference results.

### Trojan suite
- T1: Conv2 PE/MAC computation corruption → region 01.
- T2: Conv2 weight/data-path corruption → region 10.
- T3: Conv2 feature-interconnect alteration → region 11.
- T4: Conv2 source-routing alteration → region 11.
- T5: Conv2 control-path alteration → region 11.

### Simulation matrix
- 10 deterministic MNIST workloads covering classes 0–9.
- 6 targets: Healthy, T1, T2, T3, T4, T5.
- 60 PASS rows in verification/results/runs.csv.
- TP=50, TN=10, FP=0, FN=0.
- TPR=100%, FPR=0%, Precision=100%, F1=1.000.
- Regional localization is correct for all 50 Trojan rows at the defined regional-code level.

These are simulation-regression metrics only. They are not 60 physical measurements and do not imply universal detection.

### Timing
At 50 MHz:
- Healthy/T1–T4: 634,281 cycles = 12.68562 ms.
- T5: 634,282 cycles = 12.68564 ms.
- T1–T4 detection latency: 149,136 cycles = 2.98272 ms.
- T5 detection latency: 149,135 cycles = 2.98270 ms.

### Physical board evidence
T3, T4 and T5 were programmed successfully on the DE10-Standard JTAG chain:
- FPGA JTAG ID 02D020DD, device index @2.
- T3 checksum 0x022CD4EE.
- T4 checksum 0x022B88DC.
- T5 checksum 0x022990E2.
- For each, LEDR0–LEDR5 were observed ON: class 7, detector asserted, localization 11.

This demonstrates board-level output behavior for the selected bitstreams. It does not establish statistical TPR/FPR/F1 or physical power overhead.

### Resource evidence
Canonical exact resource values are published only for Healthy, T1 and T2:
- Healthy: 1,153 ALMs, 902 registers, 71 RAM blocks, 13 DSPs.
- T1: 1,170 ALMs, 910 registers, 71 RAM blocks, 13 DSPs.
- T2: 1,192 ALMs, 919 registers, 71 RAM blocks, 15 DSPs.
- Exact final T3–T5 fitter counts are not in the canonical resource ledger.

Important target note: the final DE10-Standard device is 5CSXFC6D6F31C6. Legacy Healthy/T1/T2 QSFs currently target the I7 variant, so those resource snapshots should be treated as archived implementation evidence until rebuilt on C6.

### Power
Quartus Power Analyzer figures are tool estimates, not physical measurements. Physical rail/current instrumentation was not collected.

## Non-claims / future work
- No universal Hardware Trojan detection guarantee.
- No exact T3-vs-T4-vs-T5 identification from code 11.
- No physical power-overhead claim.
- No broader cross-CNN/generalization claim.
- No numerical ablation claim beyond the documented design rationale.
