# Runtime Hardware Trojan Detection and Spatial Localization in FPGA-Based Convolutional Neural Network Accelerators

**Authors:** Raone K. S. and Jeevan K. S.  
*Department of Electronics and Communication Engineering / Computer Science and Engineering*

---

## Abstract
FPGA-accelerated Convolutional Neural Networks (CNNs) are increasingly deployed in latency-critical and mission-critical edge embedded systems. However, outsourced semiconductor design chains and untrusted third-party intellectual property (IP) cores expose these hardware accelerators to Hardware Trojans. While functional black-box verification can detect coarse disruptions that flip top-1 classification decisions, stealthy Trojans deliberately manipulate internal arithmetic elements, weight memory interfaces, spatial interconnects, or control-path sequencers without causing overt end-to-end misclassifications on standard test datasets.

In this work, we present a lightweight runtime hardware assertion monitoring and spatial localization architecture for an INT8 quantized LeNet-style FPGA-CNN accelerator. We implement a systematic taxonomy of five controlled Hardware Trojan variants ($T_1$ through $T_5$) spanning processing elements, memory paths, interconnect fabrics, routing engines, and pipeline control. We evaluate the proposed architecture using Intel Quartus on the Cyclone V 5CSXFC6D6F31C FPGA (Terasic DE10-Standard). A committed 60-row cycle-accurate simulation regression ledger spanning ten distinct MNIST digit workloads ($0$ to $9$) across healthy and malicious hardware targets yields TPR 100.0%, FPR 0.0%, Precision 100.0%, and F1 1.000 for the evaluated cases. These statistics are explicitly scoped to the committed simulation regression ledger. Regional localization is correct for all evaluated Trojan rows. The same controlled T3, T4, and T5 bitstreams were successfully programmed on the physical DE10-Standard and produced the expected board-output pattern: class 7, detector asserted, and localization code 11. Detection latency is 149,136 clock cycles (2.98272 ms at 50 MHz) for T1–T4 and 149,135 cycles (2.98270 ms) for T5 in the deterministic reference experiment. Quartus power figures are tool estimates rather than physical rail measurements, and exact final fitter resource counts for T3–T5 are not retained in the canonical resource ledger.

**Keywords:** Hardware Trojans, FPGA-CNN Accelerators, Deep Learning Security, Runtime Anomaly Detection, Spatial Localization, Cyclone V FPGA.

---

## 1. Introduction
Deep learning inference on Field-Programmable Gate Arrays (FPGAs) has achieved widespread adoption due to their deterministic low latency, reconfigurability, and superior energy efficiency compared to general-purpose GPUs. Nevertheless, the modern electronic design automation (EDA) ecosystem relies heavily on geographically distributed supply chains, third-party soft IP cores, and external synthesis tooling. This reliance exposes hardware implementations to maliciously inserted subcircuits known as Hardware Trojans (HTs) \cite{chakraborty2009hardware, karimi2021survey}.

Hardware Trojans targeting neural network accelerators pose a particularly insidious threat \cite{clements2018hardware}. Due to the inherent error resilience and overparameterization of deep learning models, small perturbations injected into intermediate processing element (PE) multiply-accumulate (MAC) arrays or activation memory buses do not necessarily degrade overall test accuracy on clean inputs. A stealthy adversary can exploit this property to evade conventional pre-silicon functional verification and post-silicon manufacturing tests \cite{liu2019fault}.

To address this challenge, this paper introduces an integrated, lightweight runtime monitoring and spatial localization architecture implemented on an INT8 FPGA-CNN accelerator. Unlike offline side-channel analysis or post-facto software checking, our framework detects malicious intrusions in real time and attributes the anomaly directly to the responsible microarchitectural subsystem.

---

## 2. Problem Statement
Consider an FPGA-based CNN accelerator computing sequential layer transformations:
$$Y = \text{ArgMax}\left(f_{\text{FC}}\left(f_{\text{Pool2}}\left(f_{\text{Conv2}}\left(f_{\text{Pool1}}\left(f_{\text{Conv1}}\left(X\right)\right)\right)\right)\right)\right)$$
An adversary implants an architectural Trojan that alters intermediate computation at layer $\ell$ under a specific trigger condition:
$$z_{\ell}' = z_{\ell} \oplus \delta$$
When the corruption vector $\delta$ is small or localized to a single activation element, the downstream pooling and fully connected layers absorb the perturbation, ensuring:
$$\text{ArgMax}\left(Y'\right) = \text{ArgMax}\left(Y\right)$$
Because the classification output matches the golden software label, traditional black-box validation frameworks conclude that the circuit is healthy. The core research problem is: *How can an FPGA accelerator detect such stealthy, classification-invariant intermediate perturbations at runtime, localize the compromised hardware region, and bound detection latency within a fraction of inference time with negligible resource overhead?*

---

## 3. Threat Model
We assume an adversary situated in the untrusted third-party design house or EDA synthesis stage. The attacker has access to the register-transfer level (RTL) netlist and can introduce low-overhead triggers and payloads without violating timing closure.
- **Trigger Mechanisms**: Spatial and temporal triggers activated by specific layer coordinates and channel indices.
- **Payload Mechanisms**:
  1. *Computation Corruption*: Bitwise sign manipulation within the arithmetic datapath.
  2. *Memory Corruption*: Inverting stored or retrieved synaptic weights.
  3. *Interconnect Corruption*: Bus-level bit alteration across layer boundaries.
  4. *Routing Corruption*: Manipulating addressing logic to redirect source operands.
  5. *Control Disruption*: Introducing pipeline stalls into the execution sequencer.
- **Attacker Goal:** Evade standard functional validation by preserving top-1 classification on the evaluated clean inputs while corrupting internal computation.

---

## 4. Related Work
Hardware Trojan detection techniques broadly fall into two paradigms:
1. **Side-Channel Analysis:** Offline techniques monitoring power consumption, electromagnetic emissions, or path delays \cite{karimi2021survey}. While non-invasive, they suffer from process-voltage-temperature (PVT) variation and environmental noise.
2. **Runtime Assertion Monitoring:** On-chip monitors that trace invariant state properties \cite{li2020runtime}. Prior work focuses predominantly on general-purpose processors or generic cryptographic cores; this work adapts the approach to a CNN accelerator and adds regional localization.

---

## 5. Proposed CNN Accelerator Architecture
The baseline accelerator executes an INT8 LeNet-style architecture designed for the MNIST benchmark:
- **Input:** $28 \times 28$ grayscale images quantized to signed 8-bit integers.
- **Conv1:** 8 filters ($3 \times 3$ kernel, stride 1, zero padding), followed by ReLU.
- **Pool1:** $2 \times 2$ Max-Pooling ($14 \times 14 \times 8$).
- **Conv2:** 16 filters ($3 \times 3 \times 8$ kernel, stride 1, zero padding), followed by ReLU.
- **Pool2:** $2 \times 2$ Max-Pooling ($7 \times 7 \times 16$).
- **FC1:** Dense projection $784 \to 10$ classes.
- **ArgMax:** Classification register outputting the predicted digit ($0$–$9$).

### Memory Architecture & Latency Reconciliation
The accelerator is synthesized using single-port synchronous Intel Cyclone V M10K block RAMs (`cnn_sp_ram`). The experimental audit reconciled historical documentation discrepancies:
1. *301,854 cycles*: an initial distributed-logic asynchronous RAM baseline.
2. *346,563 cycles*: an intermediate development milestone with M10K read-latency hazards.
3. *634,281 cycles*: the verified synthesizable reference architecture implementing synchronous memory handshake cycles and functional closure.

---

## 6. Trojan Models T1–T5
To systematically benchmark defense mechanisms, five controlled Trojan variants were engineered into the Conv2 layer:

- **T1 (Processing Element MAC Corruption):** Inverts the arithmetic sign of the MAC product:
  $$P_{\text{corrupt}} = -P = -(A \times B)$$
  Triggered at Conv2 output filter $f=1$, row $r=0$, col $c=0$, input channel $\text{ch}=1$.
- **T2 (Weight Memory Alteration):** Flips bit 0 of the Conv2 weight operand read from M10K RAM ($5 \to 4$).
- **T3 (Interconnect Feature Bus Alteration):** Inverts bit 0 of the activation stream transferred across the Pool1-to-Conv2 interconnect bus.
- **T4 (Spatial Routing Alteration):** Redirects the Conv2 source memory read address to an adjacent spatial coordinate $(r, c-1)$.
- **T5 (Control-Path Sequencer Stall):** Injects an unexpected 1-cycle pipeline wait state (`T5STALL`) into the FSM sequencing logic without corrupting numeric data values.

---

## 7. Runtime Detection and Localization Architecture
The proposed detection subsystem integrates distributed hardware assertion checking:
1. **Assertion Engine:** Compares transient arithmetic signs, memory access ranges, and expected sequencer step sequences against valid microarchitectural bounds.
2. **Detection Flag:** A latched binary output (`detected_out` routed to `LEDR[3]`) asserting upon the first observed anomaly.
3. **Spatial Localization Bus:** A 2-bit regional encoder (`localization_code[1:0]` routed to `LEDR[5:4]`):
   - `2'b00`: Quiescent (Healthy / Trojan Absent).
   - `2'b01`: Arithmetic Processing Element Domain (Conv2 MAC PE).
   - `2'b10`: Storage / Synaptic Weight Memory Domain.
   - `2'b11`: Interconnect Fabric / Routing / Control Sequencer Domain.

---

## 8. Experimental Methodology
- **Simulation Regression:** Cycle-accurate Verilog simulation using Icarus Verilog (`iverilog` / `vvp`).
- **Multi-Workload Dataset:** 10 distinct MNIST test images spanning digits 0 through 9 ($W_0$ through $W_9$).
- **Simulation Regression Ledger:** $10\text{ workloads} \times 6\text{ architectures} = 60\text{ recorded simulation rows}$ in `verification/results/runs.csv`. The repository does not claim the ledger itself is equivalent to 60 physical measurements.
- **FPGA Synthesis & Implementation:** Intel Quartus Prime targeting the Cyclone V SoC FPGA (5CSXFC6D6F31C6).
- **Physical Board Validation:** T3, T4, and T5 bitstreams were downloaded through the DE10-Standard JTAG chain and observed at the board-output level. For each, LEDR0–LEDR5 were all ON, corresponding to class 7, detector asserted, and regional localization code 11. The detailed record is in `docs/PHYSICAL_BOARD_VALIDATION.md`.
- **Power Characterization:** Intel Quartus Prime Power Analyzer estimates; these are not physical rail/current measurements.

---

## 9. FPGA Implementation Results
All designs have archived Quartus compilation/timing evidence at 50 MHz. The canonical resource ledger contains exact fitted resource counts for Healthy, T1, and T2; exact T3–T5 final fitter ALM/register counts are not retained in the canonical evidence and are therefore not claimed here.

### Resource Utilization Comparison
| Target Architecture | ALMs | ALM Overhead | Registers | Register Overhead | M10K Blocks | DSP Blocks | Worst Setup Slack | Worst Hold Slack |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| **Healthy Baseline** | 1,153 | Baseline | 902 | Baseline | 71 | 13 | +2.933 ns | +0.116 ns |
| **Trojan T1 (PE MAC)** | 1,170 | +1.47% | 910 | +0.89% | 71 | 13 | +1.078 ns | +0.145 ns |
| **Trojan T2 (Weight RAM)** | 1,192 | +3.38% | 919 | +1.88% | 71 | 15 | +2.634 ns | +0.140 ns |
| **Trojan T3 (Interconnect)** | Not archived | — | Not archived | — | Not archived | Not archived | +4.447 ns | +0.159 ns |
| **Trojan T4 (Routing)** | Not archived | — | Not archived | — | Not archived | Not archived | +5.581 ns | +0.105 ns |
| **Trojan T5 (Control Stall)** | Not archived | — | Not archived | — | Not archived | Not archived | +4.648 ns | +0.134 ns |

Within the variants for which exact canonical ALM counts are archived, T2 uses 39 additional ALMs versus Healthy. Exact T3–T5 ALM overhead is intentionally not stated because the final fitter counts are not retained. Timing closure is maintained across all models with positive setup and hold slack.

---

## 10. Experimental Results

### 10.1 Functional Correctness and Classification Invariance
Across the committed 60-row simulation regression ledger, the predicted class matches the selected workload labels in the recorded cases. The controlled Trojan payloads are classification-invariant for the evaluated workloads; this is not a universal stealthiness guarantee.

### 10.2 Timing and Latency
- **Healthy & T1–T4 Inference Latency:** 634,281 clock cycles (12.685 ms at 50 MHz).
- **T5 Inference Latency:** 634,282 clock cycles (+1 cycle due to the injected stall).
- **Detection Trigger Cycle:** Cycle 149,144 for T1–T4; Cycle 149,143 for T5.
- **Detection Latency:** 149,136 cycles (2.98272 ms) for T1–T4 and 149,135 cycles (2.98270 ms) for T5.
The detector trips within the first 23.51% of total inference in the deterministic reference experiment.

### 10.3 Power Dissipation Characterization
The Quartus Power Analyzer values are tool estimates, not physical rail/current measurements. They are retained as implementation-estimation evidence only.

| Architecture | Total Thermal Dissipation (mW) | Overhead vs. Healthy |
|---|---:|---:|
| Healthy Baseline | 463.79 | Baseline |
| Trojan T1 | 465.51 | +0.37% |
| Trojan T2 | 466.28 | +0.54% |
| Trojan T3 | 467.17 | +0.73% |
| Trojan T4 | 464.75 | +0.21% |
| Trojan T5 | 464.27 | +0.10% |

### 10.4 Detection and Statistical Security Metrics
From the 60 recorded simulation rows (10 negative, 50 positive):
$$\text{TPR} = \frac{50}{50 + 0} = 1.000000 \quad (100.0\%)$$
$$\text{FPR} = \frac{0}{0 + 10} = 0.000000 \quad (0.0\%)$$
$$\text{Precision} = \frac{50}{50 + 0} = 1.000000 \quad (100.0\%)$$
$$\text{F1 Score} = 1.000000$$
These metrics are scoped to the committed simulation regression ledger.

### 10.5 Localization Performance
Across all 50 Trojan simulation rows:
- T1 (PE MAC): 10/10 localized to `2'b01`.
- T2 (Weight Memory): 10/10 localized to `2'b10`.
- T3, T4, T5: 30/30 localized to `2'b11`.
- Overall regional localization accuracy: 100.0% (50/50) for the evaluated cases.

The physical T3/T4/T5 observations also produced localization code 11. Code 11 is a shared region code and does not distinguish the three variants individually.

### 10.6 Cross-Workload Robustness
The ten workload classes are represented in the committed simulation matrix. The resulting metrics are scoped to these evaluated workloads and should not be generalized beyond them.

---

## 11. Discussion
The evaluated findings support the conclusion that internal architectural monitoring can detect the selected controlled Trojan variants when output-only monitoring remains unchanged on the evaluated workloads. The physical DE10-Standard observations for T3–T5 confirm that the detector/localization outputs are observable at the board interface for those bitstreams.

---

## 12. Limitations
1. **Physical power instrumentation:** Quartus power results are estimates; physical rail/current measurements were not collected.
2. **Resource evidence:** Exact final fitter ALM/register/RAM/DSP counts for T3–T5 are not retained in the canonical resource ledger.
3. **Workload scope:** Experiments use INT8 LeNet/MNIST; larger CNNs and datasets remain future work.
4. **Generalization:** The detector is evaluated on the selected controlled T1–T5 implementations and does not establish universal Hardware Trojan detection.
5. **Ablation:** No unsupported numerical ablation claim is made; a controlled executable ablation remains future work.

---

## 13. Conclusion
We designed, implemented, simulated, synthesized, and physically validated a runtime Hardware Trojan detection and regional localization framework for an INT8 FPGA-CNN accelerator. The project covers five controlled Trojan families, a ten-workload simulation matrix, automated detection/localization metrics, Quartus implementation evidence, and physical DE10-Standard board-output validation for T3–T5. The simulation metrics and physical observations are reported with explicit scope boundaries. Physical power instrumentation, exact unarchived T3–T5 fitter counts, broader generalization, and executable ablation remain future extensions rather than blockers for the defined controlled-project scope.

---

## 14. Future Work
Future work can extend the monitoring architecture to larger CNNs, broader datasets, cross-CNN validation, physical current-probe transient power profiling, and executable multi-signature ablation studies.

---

## References
\bibliography{references/references}
