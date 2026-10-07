# Runtime Hardware Trojan Detection and Regional Localization in an INT8 FPGA-CNN Accelerator

**Author:** Jeevan K. S.  
**Affiliation:** Department of Electronics and Communication Engineering, IIIT Dharwad, India

## Abstract

Field-programmable gate arrays (FPGAs) provide a practical platform for deploying convolutional neural networks (CNNs) at the edge, but their programmable datapaths, third-party intellectual property, and distributed design flows also create opportunities for malicious hardware modification. Hardware Trojans are particularly difficult to expose when their payload changes an internal computation without necessarily changing the final classification. This work presents a lightweight runtime monitoring and regional localization framework integrated with an INT8 LeNet-style CNN accelerator for MNIST inference. Five controlled Trojan variants are introduced at distinct microarchitectural regions: Conv2 processing-element arithmetic, Conv2 weight memory, Conv2 feature interconnect, Conv2 spatial routing, and the Conv2 control sequencer. The accelerator is implemented for the Intel Cyclone V SoC FPGA on the Terasic DE10-Standard and evaluated using cycle-accurate Verilog simulation, Quartus implementation, and physical board programming. A committed 60-row simulation matrix covers ten MNIST workloads (digits 0–9) and six hardware targets (Healthy and T1–T5). For this controlled matrix, the detector obtains TP=50, TN=10, FP=0 and FN=0, corresponding to 100% TPR/recall, 0% FPR, 100% precision and F1=1.000. Regional localization is correct for all 50 Trojan rows at the defined three-region resolution. T1–T4 trigger after 149,136 cycles (2.98272 ms at 50 MHz), while T5 triggers after 149,135 cycles because its one-cycle control stall shifts the reference point. T1, T2, T3, T4 and T5 bitstreams were also successfully programmed on the physical DE10-Standard and produced the expected class/detector/localization LED patterns. Quartus Power Analyzer results are reported only as tool estimates; physical rail/current power measurements were not performed. Likewise, exact final fitter resource counts for T3–T5 and exact fresh C6 Fmax values are not claimed where they are not archived.

**Keywords:** Hardware Trojans, FPGA security, CNN accelerator, runtime detection, hardware monitoring, regional localization, INT8, MNIST, Cyclone V.

## 1. Introduction

Hardware security has become an important concern as integrated-circuit development increasingly relies on distributed supply chains, reusable intellectual property, external EDA flows, and programmable devices. A Hardware Trojan (HT) is a malicious modification introduced into a hardware design to alter functionality, leak information, degrade availability, or create a covert control path. Classic Trojan literature emphasizes the difficulty of detecting small or rarely activated malicious modifications using conventional functional verification alone [1].

The risk is particularly relevant to machine-learning accelerators. CNN implementations contain repeated arithmetic units, weight memories, activation buffers, interconnects, and control sequencers. A small change to one of these structures can affect an intermediate tensor while leaving the final top-1 classification unchanged for a selected workload. Previous work has demonstrated that neural-network implementations themselves can be targeted by hardware Trojans [2], while broader surveys identify Trojan attacks, side-channel leakage, and fault injection as important hardware-security dimensions for DNN accelerators [3].

This paper investigates a complementary defense direction: **runtime architectural monitoring with regional localization**. Instead of relying only on output classification or physical side channels, the proposed monitor checks selected internal invariants and exposes a compact detector/localization result at the FPGA board interface. The objective is not to claim universal Trojan detection, but to demonstrate a reproducible end-to-end methodology for detecting and regionally localizing a defined family of controlled Trojans.

The contributions are:
1. an INT8 LeNet-style FPGA-CNN reference implementation targeting Cyclone V;
2. five controlled Trojan variants spanning arithmetic, memory, interconnect, routing, and control regions;
3. a runtime detector with three regional localization classes;
4. a deterministic ten-workload simulation matrix covering Healthy and T1–T5;
5. Quartus implementation evidence and physical DE10-Standard validation for T3–T5; and
6. an evidence-cleaned reporting methodology that explicitly separates simulation metrics, FPGA implementation results, tool-estimated power, and physical observations.

## 2. Background and Threat Model

### 2.1 Hardware Trojans in DNN accelerators

Hardware Trojan research traditionally considers malicious additions or modifications to digital circuits and classifies them according to trigger, payload, activation condition, and location [1]. Neural-network accelerators provide additional attack surfaces because computation is distributed across many repeated MAC operations and memory accesses. Clements and Lao demonstrated the feasibility of inserting malicious hardware into neural-network implementations while preserving benign-test behavior and activating on selected inputs [2]. More recent surveys organize DNN hardware threats across Trojan, side-channel, and fault-injection categories [3].

Runtime detection is also an established research direction. Changepoint-based monitoring has been used to detect activated Trojans from runtime performance behavior [4], while other work has explored low-overhead runtime validation for FPGA implementations [5]. The present work adapts the runtime-monitoring concept to a CNN datapath and adds explicit **microarchitectural region codes**.

### 2.2 Threat model

The attacker is assumed to have RTL/netlist-level access during an untrusted design, IP, or synthesis stage. The attacker may add a small trigger and payload while attempting to preserve timing closure and avoid obvious classification errors on the evaluated clean workloads.

The controlled payload families are:
- **T1:** arithmetic corruption in a Conv2 processing element;
- **T2:** Conv2 weight-memory/data-path corruption;
- **T3:** feature-interconnect alteration between Pool1 and Conv2;
- **T4:** selective spatial source-routing alteration;
- **T5:** one-cycle control-sequencer stall.

The attacker is not assumed to bypass or compromise the runtime monitor itself. This is an important scope boundary: the study evaluates whether the monitor detects the selected controlled implementations, not whether every possible adversarial Trojan can be detected.

## III. Related Work and Positioning

The literature is grouped into CNN accelerator Trojan attacks, runtime/behavioral detection, Trojan localization, and lightweight accelerator security. Recent representative works include FeSHI [6], CNN resilience studies [7], [14], golden-reference-free localization [8], TrojanSAINT [9], interconnect attacks [11], two-level protection [12], and explainable LUT localization [13].

The project occupies a narrower runtime position: a compact digital monitor is embedded in the accelerator, controlled Trojans are inserted into multiple architectural regions, ten deterministic MNIST workloads are exercised, and selected variants are physically demonstrated on a Cyclone V DE10-Standard. Fine-grained graph/netlist localization and runtime architectural-region localization are complementary objectives rather than directly interchangeable methods.

## IV. Baseline FPGA CNN Accelerator

The reference accelerator processes 28x28 grayscale MNIST images using INT8 data. Conv1 uses 8 filters with 3x3 kernels, followed by ReLU and 2x2 max pooling. Conv2 uses 16 filters with 3x3 kernels over eight input channels, followed by ReLU and 2x2 max pooling. A fully connected classifier produces ten class scores followed by ArgMax.

The software reference accuracy is 98.41%. The verified synchronous-M10K Healthy reference requires 634,281 cycles at 50 MHz, or:

$T_{inf}=634281\times20\mathrm{ns}=12.68562\mathrm{ms}.$

The fresh C6 Healthy snapshot contains 1,153 ALMs, 912 registers, 71 RAM blocks, 455,104 block-memory bits, and 13 DSP blocks. Worst archived setup and hold slack are +0.181 ns and +0.173 ns.

## V. Experimental Inputs and Expected Outputs

Ten deterministic MNIST workloads represent classes 0 through 9. The canonical top-level interface reports predicted class on LEDR[2:0], detector status on LEDR3, and a two-bit regional code on LEDR[5:4].

Healthy uses localization 00. T1 uses 01 for Conv2 PE computation. T2 uses 10 for Conv2 weight/data path. T3, T4 and T5 use shared regional code 11 for interconnect/routing/control.

## VI. Hardware Trojan Experimental Setup

| ID | Target | Controlled payload | Region code |
|---|---|---|---|
| T1 | Conv2 PE | selected MAC product sign inversion | 01 |
| T2 | Conv2 weight/data path | selected weight bit flip | 10 |
| T3 | Conv2 interconnect | selected feature-interconnect alteration | 11 |
| T4 | Conv2 routing | selected source-address/routing alteration | 11 |
| T5 | Conv2 control | one-cycle control-path stall | 11 |

The injection/build flow is Healthy RTL -> controlled Trojan RTL -> Icarus simulation -> Quartus compile -> SOF -> DE10 programming. The same workload and clock configuration are retained across variants.

For this work, output-stealthy means that the selected Trojan-present run retains the same top-1 class as the corresponding Healthy run while the runtime monitor detects the internal anomaly. This is a workload-scoped definition.

## VII. Normal Runtime Signature Characterization

All ten Healthy rows report the expected class, detector 0, localization 00, and 634,281 inference cycles. This establishes controlled signature stability for the selected deterministic workload set. It does not constitute a complete PVT or application-distribution characterization.

## VIII. Proposed Lightweight Multi-Signature Anomaly Detection

The detector observes selected architectural invariants and trigger-state information near the controlled Trojan regions. It latches a detector bit and a corresponding regional code when the selected anomaly occurs.

The runtime procedure is: start inference, monitor the selected event, latch detection, expose the region code, and complete inference. The monitor is integrated in RTL and does not require an external software classification oracle during runtime.

## IX. Trojan Localization

The localization map is:

- 00: Healthy;
- 01: Conv2 PE computation;
- 10: Conv2 weight/data path;
- 11: shared interconnect/routing/control.

The 11 code intentionally does not distinguish T3 from T4 or T5. In the committed simulation matrix, T1 is correct on 10/10 rows, T2 on 10/10, and T3-T5 on 30/30, giving 50/50 = 100% regional localization accuracy.

## X. Results and Discussion

### A. Detection performance

The 60 simulation rows contain 10 Healthy and 50 Trojan cases. The resulting counts are TP=50, TN=10, FP=0, FN=0. Therefore TPR/recall = 100%, FPR = 0%, precision = 100%, and F1 = 1.000. These values apply only to the committed controlled matrix.

### B. Detection latency

T1-T4 detect at 149,136 cycles = 2.98272 ms at 50 MHz. T5 detects at 149,135 cycles = 2.98270 ms. The committed ten-workload matrix shows the same latency for every row of a given Trojan class.

### C. CNN functional impact

All 50 Trojan-present rows retain the expected top-1 class. This demonstrates output-stealthy behavior for the selected controlled cases and does not prove universal stealthiness.

### D. Hardware resource evidence

| Target | ALMs | Registers | RAM | DSP | Setup slack | Hold slack |
|---|---:|---:|---:|---:|---:|---:|
| Healthy | 1153 | 912 | 71 | 13 | +0.181 ns | +0.173 ns |
| T1 | 1170 | 918 | 71 | 13 | +0.141 ns | +0.141 ns |
| T2 | 1192 | 919 | 71 | 15 | +0.163 ns | +0.163 ns |

Exact final T3-T5 fitter counts and exact fresh-C6 Fmax are not archived and are not inferred.

### E. Power estimates

Quartus Power Analyzer estimates are Healthy 463.79 mW, T1 465.51 mW, T2 466.28 mW, T3 467.17 mW, T4 464.75 mW, and T5 464.27 mW. These are tool estimates, not physical rail/current measurements.

### F. Ablation and security-overhead trade-off

An evidence-bounded numerical evaluation-layer ablation is derived from the committed 60-row ledger by masking the observable decision channels. Final CNN classification alone gives 0% TPR because the selected Trojans are output-stealthy; timing alone gives 20% TPR because only T5 changes the total inference-cycle count; accepting only regional code 01, 10, or 11 gives 20%, 20%, and 60% TPR, respectively; accepting any non-zero regional code gives 100% TPR with 0% FPR. This is a coverage ablation over already implemented monitor events, not a separate set of synthesized no-monitor/PE-only/memory-only hardware builds, so no independent resource-overhead delta is claimed.

## XI. Robustness, Stealthiness, and Generalization

The ten Healthy rows produce zero detector assertions, and the 50 Trojan rows produce 50 detections. All five selected Trojan variants preserve the expected top-1 class across all ten workloads, giving 100% output-stealthiness under the study definition. T1-T4 are timing-invisible at the measured inference-cycle level, whereas T5 introduces a one-cycle timing deviation. These results provide an evidence-bounded stealthiness/observability sensitivity analysis, but not a graded payload-severity sweep. Only one compact CNN is evaluated, so cross-CNN generalization remains future work.

## XII. Cross-Layer Security Analysis

Each controlled Trojan maps from a defined architectural region to a detector event and regional code. The important cross-layer observation is that detection occurs while the selected Trojan-present runs retain the expected CNN class. This demonstrates that runtime internal monitoring can expose a selected anomaly before output-level misclassification is required.

## XIII. Comparison With State of the Art

| Work | Main objective | Resolution | Runtime FPGA CNN | Physical validation |
|---|---|---|---|---|
| Clements & Lao | CNN Trojan attack | Architecture-dependent | No | No |
| Odetola et al. | Stealthy CNN Trojan attack | Feature-map level | PYNQ | Yes |
| Yasaei et al. | Golden-reference-free localization | RTL node | No | No |
| TrojanSAINT | Detection + localization | Gate level | No | No |
| Hou et al. | CNN interconnect attack + PUF defense | Interconnect | Yes | Yes |
| Su et al. | Explainable LUT localization | LUT/node | No | No |
| This work | Runtime detection + regional localization | 3 architectural regions | Yes | T1-T5 |

This comparison is by objective and evidence layer, not a universal performance ranking.

## XIV. Reproducibility

Canonical simulation:

~~~bash
cd ~/hardware-trojan-fpga-cnn
chmod +x verification/run_full_matrix.sh
./verification/run_full_matrix.sh
~~~

The repository contains the workload manifest, 60-row simulation ledger, RTL/testbenches, Quartus projects, physical validation record, paper tables/figures, and professor submission scripts.

## XV. Limitations and Threats to Validity

1. The 60-row matrix is controlled simulation, not 60 independent physical measurements.
2. Physical rail/current power was not measured.
3. Quartus Power Analyzer values are estimates.
4. Exact final T3-T5 fitter counts and fresh C6 Fmax are not archived.
5. T3-T5 share localization code 11.
6. Only one compact MNIST CNN is evaluated.
7. The ablation is evaluation-layer channel masking over the committed ledger rather than independently synthesized monitor variants.
8. No continuous trigger-probability or payload-severity sweep was performed.
9. The monitor itself is outside the attacker-compromise model.

## XVI. Conclusion and Future Perspective

A reproducible INT8 FPGA-CNN prototype with runtime Hardware Trojan detection and regional localization was implemented on Cyclone V. Five controlled Trojan variants cover arithmetic, weight/data path, interconnect, routing, and control regions. The 60-row simulation matrix achieves 100% detection and 0% false positives for the selected controlled cases, with 100% regional localization at the defined three-region resolution. T1, T2, T3, T4 and T5 were physically programmed and validated on the DE10-Standard.

The result is a controlled research prototype rather than a universal detector. Future work should add physical power instrumentation, a graded trigger-probability/payload-severity sweep, independently synthesized monitor-ablation variants, additional CNNs, broader datasets, and finer localization.

## References

See `paper/references/references.bib` for the expanded source-checked bibliography.
