# Runtime Hardware Trojan Detection and Regional Localization in an INT8 FPGA-CNN Accelerator

**Author:** Jeevan K. S.  
**Affiliation:** Department of Electronics and Communication Engineering, IIIT Dharwad, India

## Abstract

Field-programmable gate arrays (FPGAs) provide a practical platform for deploying convolutional neural networks (CNNs) at the edge, but their programmable datapaths, third-party intellectual property, and distributed design flows also create opportunities for malicious hardware modification. Hardware Trojans are particularly difficult to expose when their payload changes an internal computation without necessarily changing the final classification. This work presents a lightweight runtime monitoring and regional localization framework integrated with an INT8 LeNet-style CNN accelerator for MNIST inference. Five controlled Trojan variants are introduced at distinct microarchitectural regions: Conv2 processing-element arithmetic, Conv2 weight memory, Conv2 feature interconnect, Conv2 spatial routing, and the Conv2 control sequencer. The accelerator is implemented for the Intel Cyclone V SoC FPGA on the Terasic DE10-Standard and evaluated using cycle-accurate Verilog simulation, Quartus implementation, and physical board programming. A committed 60-row simulation matrix covers ten MNIST workloads (digits 0–9) and six hardware targets (Healthy and T1–T5). For this controlled matrix, the detector obtains TP=50, TN=10, FP=0 and FN=0, corresponding to 100% TPR/recall, 0% FPR, 100% precision and F1=1.000. Regional localization is correct for all 50 Trojan rows at the defined three-region resolution. T1–T4 trigger after 149,136 cycles (2.98272 ms at 50 MHz), while T5 triggers after 149,135 cycles because its one-cycle control stall shifts the reference point. T3, T4 and T5 bitstreams were also successfully programmed on the physical DE10-Standard and produced the expected class/detector/localization LED pattern. Quartus Power Analyzer results are reported only as tool estimates; physical rail/current power measurements were not performed. Likewise, exact final fitter resource counts for T3–T5 and exact fresh C6 Fmax values are not claimed where they are not archived.

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

## 3. CNN Accelerator

The reference accelerator is a compact LeNet-style architecture for 28×28 grayscale MNIST images. The model is quantized to signed INT8 at the hardware interface.

The computation is represented as

$$
Y = operatorname{ArgMax}left(
f_{mathrm{FC}}left(
f_{mathrm{Pool2}}left(
f_{mathrm{Conv2}}left(
f_{mathrm{Pool1}}left(
f_{mathrm{Conv1}}(X)
ight)ight)ight)ight)ight).
$$

The major stages are:
- Conv1: 8 filters with 3×3 kernels;
- ReLU;
- Pool1: 2×2 max pooling;
- Conv2: 16 filters with 3×3×8 kernels;
- ReLU;
- Pool2: 2×2 max pooling;
- FC1: projection to ten class scores;
- ArgMax: predicted digit 0–9.

The FPGA implementation uses Intel Cyclone V M10K memories through synchronous read interfaces. The project history contained three latency milestones: 301,854 cycles for an earlier distributed-logic/asynchronous-memory baseline, 346,563 cycles for an intermediate M10K implementation with read-latency hazards, and 634,281 cycles for the verified synchronous-M10K reference. Only the final value is used as the canonical current reference.

## 4. Trojan Campaign

Five controlled Trojans were inserted around Conv2.

| Trojan | Region | Controlled payload | Detector region |
|---|---|---|---|
| T1 | Conv2 PE | invert the selected MAC product sign | 01 |
| T2 | Conv2 weight memory | flip a selected weight bit | 10 |
| T3 | Conv2 interconnect | alter a selected activation-bus bit | 11 |
| T4 | Conv2 routing | redirect a selected source-memory address | 11 |
| T5 | Conv2 control | inject a one-cycle sequencer stall | 11 |

For T1, the selected corrupted product is

$$
P_{mathrm{corrupt}}=-P=-(A	imes B).
$$

For T2, a selected Conv2 weight operand is modified by a one-bit perturbation. T3 changes one selected activation-interconnect bit. T4 changes the selected spatial source address to an adjacent coordinate. T5 inserts the controlled `T5STALL` wait state.

The localization code is intentionally regional rather than Trojan-specific:
- `00`: healthy/quiescent;
- `01`: Conv2 arithmetic/PE;
- `10`: Conv2 weight-memory;
- `11`: shared interconnect/routing/control region.

Consequently, code `11` cannot distinguish T3 from T4 or T5.

## 5. Runtime Detection Architecture

The monitor observes selected architectural invariants and latches a detector flag when an unexpected event is observed. The detector output is exposed on `LEDR[3]`. The 2-bit localization code is exposed on `LEDR[5:4]`, while `LEDR[2:0]` reports the predicted class.

The overall interface is therefore

$$
mathrm{LEDR}[5:4] parallel mathrm{LEDR}[3] parallel mathrm{LEDR}[2:0]
=
mathrm{localization}parallelmathrm{detected}parallelmathrm{class}.
$$

This compact interface makes the detector observable both in simulation and on the physical DE10-Standard without requiring an external software monitor.

The design goal is lightweight runtime checking rather than a full side-channel measurement system. Side-channel techniques can detect subtle changes in power, timing, or electromagnetic behavior, but they require careful treatment of PVT variation and measurement noise [3]. The proposed design instead checks internal digital behavior directly.

## 6. Experimental Methodology

### 6.1 Simulation

Cycle-accurate simulation is performed with Icarus Verilog. The canonical workload manifest contains ten deterministic MNIST workloads corresponding to digits 0 through 9. Each workload is evaluated on six targets:

$$
10;mathrm{workloads}	imes6;mathrm{targets}=60;mathrm{simulation rows}.
$$

The Healthy target supplies ten negative cases; T1–T5 supply fifty positive cases. The repository stores the complete ledger in `verification/results/runs.csv`.

### 6.2 FPGA implementation

Intel Quartus Prime Lite 25.1 targets the DE10-Standard Cyclone V SoC FPGA, device 5CSXFC6D6F31C6. The current canonical resource ledger contains exact fresh-C6 values for Healthy, T1 and T2. Exact final fitter resource counts for T3–T5 are not retained and are therefore not inferred.

### 6.3 Physical validation

T3, T4 and T5 were programmed through the DE10-Standard JTAG chain. Each programming operation completed with zero programming errors and zero warnings. The board-output observation for all three cases was:
- predicted class = 7;
- detector = asserted;
- localization = `11`;
- LEDR0–LEDR5 = ON.

These observations establish physical board-level observability for the three tested Trojan bitstreams, but they are not equivalent to a physical power measurement.

### 6.4 Power

Quartus Power Analyzer estimates are retained as implementation-estimation evidence. They are not physical rail/current measurements and are not used to claim experimentally measured power overhead.

## 7. Results

### 7.1 Detection metrics

The committed 60-row ledger contains:
- 10 Healthy rows;
- 50 Trojan rows;
- TP = 50;
- TN = 10;
- FP = 0;
- FN = 0.

Therefore,

$$
mathrm{TPR}=rac{TP}{TP+FN}=1.0,
$$

$$
mathrm{FPR}=rac{FP}{FP+TN}=0.0,
$$

$$
mathrm{Precision}=rac{TP}{TP+FP}=1.0,
$$

and

$$
F_1=2rac{mathrm{Precision}cdotmathrm{Recall}}
{mathrm{Precision}+mathrm{Recall}}=1.0.
$$

These values describe the evaluated simulation matrix only.

### 7.2 Localization

T1 is localized to region `01` for all ten workloads, T2 to region `10` for all ten workloads, and T3–T5 to region `11` for all thirty corresponding rows. Thus regional localization accuracy is 50/50 = 100% for the Trojan rows in the simulation ledger.

The corresponding confusion matrix at the **regional** resolution is:

| True region | Pred. 01 | Pred. 10 | Pred. 11 |
|---|---:|---:|---:|
| PE (T1) | 10 | 0 | 0 |
| Weight memory (T2) | 0 | 10 | 0 |
| Shared interconnect/routing/control (T3–T5) | 0 | 0 | 30 |

The matrix must not be interpreted as exact T3/T4/T5 identification.

### 7.3 Latency

At 50 MHz, one clock cycle is 20 ns. The deterministic reference results are:

| Target | Inference cycles | Detection latency | Detection latency |
|---|---:|---:|---:|
| T1 | 634,281 | 149,136 cycles | 2.98272 ms |
| T2 | 634,281 | 149,136 cycles | 2.98272 ms |
| T3 | 634,281 | 149,136 cycles | 2.98272 ms |
| T4 | 634,281 | 149,136 cycles | 2.98272 ms |
| T5 | 634,282 | 149,135 cycles | 2.98270 ms |

The detection event occurs at approximately 23.51% of the total inference-cycle budget for T1–T4.

### 7.4 FPGA resource evidence

| Target | ALMs | Registers | M10K/RAM blocks | DSP blocks | Setup slack | Hold slack |
|---|---:|---:|---:|---:|---:|---:|
| Healthy | 1,153 | 912 | 71 | 13 | +0.181 ns | +0.173 ns |
| T1 | 1,170 | 918 | 71 | 13 | +0.141 ns | +0.141 ns |
| T2 | 1,192 | 919 | 71 | 15 | +0.163 ns | +0.163 ns |
| T3 | Not archived | Not archived | Not archived | Not archived | +4.447 ns* | +0.159 ns* |
| T4 | Not archived | Not archived | Not archived | Not archived | +5.581 ns* | +0.105 ns* |
| T5 | Not archived | Not archived | Not archived | Not archived | +4.648 ns* | +0.134 ns* |

* Historical timing evidence retained in the repository; exact final fitter resource counts are not archived for these variants.

The fresh C6 Healthy/T1/T2 evidence shows positive setup and hold slack and confirms implementation on the corrected C6 device.

### 7.5 Power estimates

Quartus Power Analyzer estimates are:

| Target | Total thermal dissipation |
|---|---:|
| Healthy | 463.79 mW |
| T1 | 465.51 mW |
| T2 | 466.28 mW |
| T3 | 467.17 mW |
| T4 | 464.75 mW |
| T5 | 464.27 mW |

These numbers are explicitly **tool estimates**, not physical measurements.

## 8. Discussion

The experiment demonstrates three useful properties. First, the selected Trojans can be detected without relying on a changed top-1 classification for the evaluated workloads. Second, the detector provides more actionable information than a binary alarm by identifying the affected architectural region. Third, the same detector outputs can be observed on the FPGA board for T3–T5.

The main scientific strength of the work is reproducibility and evidence separation. Simulation metrics are derived from a committed 60-row ledger; FPGA resource figures are taken only from retained implementation evidence; physical claims are limited to observations actually made on the DE10-Standard; and tool-estimated power is not presented as measured power.

The 100% simulation detection rate should therefore be interpreted as **100% on the selected controlled campaign**, not as proof that the architecture detects arbitrary future Trojans. This distinction is important because prior Trojan research demonstrates a broad design space of trigger conditions and payload mechanisms [1], [2].

## 9. Limitations

1. Physical rail/current power instrumentation was not performed.
2. Exact final fitter ALM/register/RAM/DSP counts for T3–T5 are not retained.
3. Exact fresh-C6 Fmax is not archived.
4. The evaluated model is an INT8 LeNet-style MNIST accelerator.
5. The ten workloads are deterministic selected cases rather than a statistically comprehensive dataset evaluation.
6. The detector was evaluated against five controlled Trojan implementations and does not establish universal Trojan detection.
7. Localization code `11` is shared by T3, T4 and T5.
8. A numerical executable ablation study is not claimed; the repository documents design rationale separately.

## 10. Conclusion

This work presents and evaluates a runtime Hardware Trojan detection and regional localization framework for an INT8 FPGA-CNN accelerator. Five controlled Trojan families were implemented across arithmetic, memory, interconnect, routing and control regions. The canonical 60-row simulation campaign produced 100% TPR/recall, 0% FPR, 100% precision and F1=1.000 for the evaluated cases, with 100% regional localization accuracy at the defined three-region resolution. Fresh C6 implementation evidence is available for the Healthy, T1 and T2 configurations, while physical DE10-Standard programming and board-output observations were completed for T3, T4 and T5.

The work is therefore suitable as a controlled FPGA/AI hardware-security research prototype and course-project submission. Future work should add physical current/voltage instrumentation, archive complete fitter reports for every Trojan variant, perform executable ablation studies, and evaluate broader CNNs and datasets.

## References

[1] R. S. Chakraborty, S. Narasimhan, and S. Bhunia, “Hardware Trojan: Threats and emerging solutions,” in *Proc. IEEE International High Level Design Validation and Test Workshop*, pp. 166–171, 2009, doi: 10.1109/HLDVT.2009.5340158.

[2] J. Clements and Y. Lao, “Hardware Trojan attacks on neural networks,” arXiv:1806.05768, 2018.

[3] S. Mittal, H. Gupta, and S. Srivastava, “A survey on hardware security of DNN models and accelerators,” *Journal of Systems Architecture*, vol. 117, Art. no. 102163, 2021, doi: 10.1016/j.sysarc.2021.102163.

[4] R. Elnaggar, K. Chakrabarty, and M. B. Tahoori, “Hardware Trojan detection using changepoint-based anomaly detection techniques,” *IEEE Trans. Very Large Scale Integr. Syst.*, vol. 27, no. 12, pp. 2706–2719, 2019, doi: 10.1109/TVLSI.2019.2925807.

[5] B. J. Mohd, S. Abed, T. Hayajneh, and M. H. Alshayeji, “Run-Time Monitoring and Validation Using Reverse Function (RMVRF) for Hardware Trojans Detection,” *IEEE Trans. Dependable Secure Comput.*, vol. 18, no. 6, pp. 2689–2704, 2021, doi: 10.1109/TDSC.2019.2961902.
