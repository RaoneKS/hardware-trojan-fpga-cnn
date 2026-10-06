# Runtime Hardware Trojan Detection and Spatial Localization in FPGA-Based Convolutional Neural Network Accelerators

**Authors:** Raone K. S. and Jeevan K. S.  
*Department of Electronics and Communication Engineering / Computer Science and Engineering*

---

## Abstract
FPGA-accelerated Convolutional Neural Networks (CNNs) are increasingly deployed in latency-critical and mission-critical edge embedded systems. However, outsourced semiconductor design chains and untrusted third-party intellectual property (IP) cores expose these hardware accelerators to Hardware Trojans. While functional black-box verification can detect coarse disruptions that flip top-1 classification decisions, stealthy Trojans deliberately manipulate internal arithmetic elements, weight memory interfaces, spatial interconnects, or control-path sequencers without causing overt end-to-end misclassifications on standard test datasets.

In this work, we present a lightweight runtime hardware assertion monitoring and spatial localization architecture for an INT8 quantized LeNet-style FPGA-CNN accelerator. We implement a systematic taxonomy of five controlled Hardware Trojan variants ($T_1$ through $T_5$) spanning processing elements, memory paths, interconnect fabrics, routing engines, and pipeline control. We evaluate the proposed architecture using Intel Quartus Prime on the Cyclone V 5CSXFC6D6F31C6 FPGA (Terasic DE10-Standard). Through a rigorous 60-run regression matrix spanning ten distinct MNIST digit workloads ($0$ to $9$) across healthy and malicious hardware targets, our proposed detector achieves a True Positive Rate (TPR) of 100.0%, a False Positive Rate (FPR) of 0.0%, Precision of 100.0%, and an F1 score of 1.0000, with 100.0% localization accuracy. The detection latency is strictly bounded at 149,136 clock cycles (2.98 ms at 50 MHz), identifying intrusions within the first 23.5% of inference execution. Furthermore, the complete detection and 2-bit regional localization subsystem imposes only 0.52% to 6.38% ALM overhead and less than 0.73% thermal power overhead, proving that high-reliability runtime security can be integrated into edge CNN accelerators without compromising real-time throughput or physical budget.

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
We assume an adversary situated in the untrusted third-party design house or EDA synthesis synthesis stage. The attacker has access to the register-transfer level (RTL) netlist and can introduce low-overhead triggers and payloads without violating timing closure.
- **Trigger Mechanisms**: Spatial and temporal triggers activated by specific layer coordinates and channel indices.
- **Payload Mechanisms**:
  1. *Computation Corruption*: Bitwise sign manipulation within the arithmetic datapath.
  2. *Memory Corruption*: Inverting stored or retrieved synaptic weights.
  3. *Interconnect Corruption*: Bus-level bit alteration across layer boundaries.
  4. *Routing Corruption*: Manipulating addressing logic to redirect source operands.
  5. *Control Disruption*: Introducing pipeline stalls into the execution sequencer.
- **Attacker Goal**: Evade standard functional validation by ensuring overall top-1 accuracy on canonical benchmarks remains unaffected.

---

## 4. Related Work
Hardware Trojan detection techniques broadly fall into two paradigms:
1. **Side-Channel Analysis**: Offline techniques monitoring power consumption, electromagnetic emissions, or path delays \cite{karimi2021survey}. While non-invasive, they suffer from process-voltage-temperature (PVT) variation and environmental noise, often failing to detect stealthy digital Trojans whose dynamic footprint is within noise margins (< 1%).
2. **Runtime Assertion Monitoring**: On-chip monitors that trace invariant state properties \cite{li2020runtime}. However, prior works focus predominantly on general-purpose microprocessors or generic crypto-cores. Specific adaptations to CNN accelerators have either incurred high memory replication costs (e.g., dual-modular redundancy) or failed to provide regional localization.

---

## 5. Proposed CNN Accelerator Architecture
The baseline accelerator executes an INT8 LeNet-style architecture designed for the MNIST benchmark:
- **Input**: $28 \times 28$ grayscale images quantized to signed 8-bit integers.
- **Conv1**: 8 filters ($3 \times 3$ kernel, stride 1, zero padding), followed by ReLU.
- **Pool1**: $2 \times 2$ Max-Pooling ($14 \times 14 \times 8$).
- **Conv2**: 16 filters ($3 \times 3 \times 8$ kernel, stride 1, zero padding), followed by ReLU.
- **Pool2**: $2 \times 2$ Max-Pooling ($7 \times 7 \times 16$).
- **FC1**: Dense projection $784 \to 10$ classes.
- **ArgMax**: Classification register outputting the predicted digit ($0$–$9$).

### Memory Architecture & Latency Reconciliation
The accelerator is synthesized using single-port synchronous Intel Cyclone V M10K block RAMs (`cnn_sp_ram`). In our experimental audit, we reconciled historical documentation discrepancies:
1. *301,854 cycles*: The initial distributed-logic asynchronous RAM baseline, which allowed zero-wait combinational reads but exhausted FPGA routing resources.
2. *346,563 cycles*: An intermediate development milestone using M10K blocks that suffered from read-latency data hazards.
3. *634,281 cycles*: The verified, synthesizable reference architecture implementing synchronous memory handshake cycles, achieving robust functional closure and zero timing violations.

---

## 6. Trojan Models T1–T5
To systematically benchmark defense mechanisms, five controlled Trojan variants were engineered into the Conv2 layer:

- **T1 (Processing Element MAC Corruption)**: Inverts the arithmetic sign of the MAC product:
  $$P_{\text{corrupt}} = -P = -(A \times B)$$
  Triggered at Conv2 output filter $f=1$, row $r=0$, col $c=0$, input channel $\text{ch}=1$.
- **T2 (Weight Memory Alteration)**: Flips bit 0 of the Conv2 weight operand read from M10K RAM ($5 \to 4$).
- **T3 (Interconnect Feature Bus Alteration)**: Inverts bit 0 of the activation stream transferred across the Pool1-to-Conv2 interconnect bus.
- **T4 (Spatial Routing Alteration)**: Redirects the Conv2 source memory read address to an adjacent spatial coordinate $(r, c-1)$.
- **T5 (Control-Path Sequencer Stall)**: Injects an unexpected 1-cycle pipeline wait state (`T5STALL`) into the FSM sequencing logic without corrupting numeric data values.

---

## 7. Runtime Detection and Localization Architecture
The proposed detection subsystem integrates distributed hardware assertion checking:
1. **Assertion Engine**: Compares transient arithmetic signs, memory access ranges, and expected sequencer step sequences against valid microarchitectural bounds.
2. **Detection Flag**: A latched binary output (`detected_out` routed to `LEDR[3]`) asserting upon the first observed anomaly.
3. **Spatial Localization Bus**: A 2-bit regional encoder (`localization_code[1:0]` routed to `LEDR[5:4]`):
   - `2'b00`: Quiescent (Healthy / Trojan Absent).
   - `2'b01`: Arithmetic Processing Element Domain (Conv2 MAC PE).
   - `2'b10`: Storage / Synaptic Weight Memory Domain.
   - `2'b11`: Interconnect Fabric / Routing / Control Sequencer Domain.

---

## 8. Experimental Methodology
- **Simulation Regression**: Cycle-accurate Verilog simulation using Icarus Verilog (`iverilog` / `vvp`).
- **Multi-Workload Dataset**: 10 distinct MNIST test images spanning digits 0 through 9 ($W_0$ through $W_9$).
- **Total Experimental Ledger**: $10\text{ workloads} \times 6\text{ architectures} = 60\text{ measured runs}$ recorded in `verification/results/runs.csv`.
- **FPGA Synthesis & Implementation**: Intel Quartus Prime Standard & Lite Editions targeting the Cyclone V SoC FPGA (5CSXFC6D6F31C6 / 5CSXFC6D6F31I7).
- **Power Characterization**: Intel Quartus Prime Power Analyzer estimating core dynamic, core static, and I/O thermal power dissipation.

---

## 9. FPGA Implementation Results
All designs were synthesized, placed, routed, and timing-analyzed on the Cyclone V device at 50 MHz.

### Resource Utilization Comparison
| Target Architecture | ALMs | ALM Overhead | Registers | Register Overhead | M10K Blocks | DSP Blocks | Worst Setup Slack | Worst Hold Slack |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| **Healthy Baseline** | 1,145 | Baseline | 889 | Baseline | 71 | 13 | +2.669 ns | +0.129 ns |
| **Trojan T1 (PE MAC)** | 1,167 | +1.92% | 924 | +3.94% | 71 | 13 | +0.999 ns | +0.124 ns |
| **Trojan T2 (Weight RAM)**| 1,190 | +3.93% | 915 | +2.92% | 71 | 15 | +2.634 ns | +0.140 ns |
| **Trojan T3 (Interconnect)**| 1,195 | +4.37% | 924 | +3.94% | 71 | 15 | +4.447 ns | +0.159 ns |
| **Trojan T4 (Routing)** | 1,218 | +6.38% | 902 | +1.46% | 71 | 13 | +5.581 ns | +0.105 ns |
| **Trojan T5 (Control Stall)**| 1,151 | +0.52% | 918 | +3.26% | 71 | 13 | +4.648 ns | +0.134 ns |

The maximum logic overhead is merely 73 ALMs (+6.38%) in the routing-monitored variant, representing less than 0.18% of the Cyclone V chip's total ALM capacity (41,910 ALMs). Timing closure is maintained across all models with positive setup and hold slacks.

---

## 10. Experimental Results

### 10.1 Functional Correctness and Stealthiness
Across all 60 empirical simulation runs, the predicted class matched the ground truth label in 100% of cases. The Trojan payloads in T1–T5 successfully remained stealthy to output-only monitoring, demonstrating the insufficiency of black-box prediction tracking.

### 10.2 Timing and Latency
- **Healthy & T1–T4 Inference Latency**: 634,281 clock cycles (12.685 ms at 50 MHz).
- **T5 Inference Latency**: 634,282 clock cycles (+1 cycle due to the injected stall).
- **Detection Trigger Cycle**: Cycle 149,144 for T1–T4; Cycle 149,143 for T5.
- **Detection Latency**: Exactly 149,136 cycles (2.98272 ms) for T1–T4 and 149,135 cycles (2.98270 ms) for T5.
The detector trips within the first 23.51% of total inference, allowing prompt system mitigation before outputs are latched.

### 10.3 Power Dissipation Characterization
| Architecture | Core Dynamic Power (mW) | Core Static Power (mW) | Total Thermal Dissipation (mW) | Overhead vs. Healthy |
|---|---:|---:|---:|---:|
| **Healthy Baseline** | 40.65 | 412.18 | 463.79 | Baseline |
| **Trojan T1** | 41.88 | 412.19 | 465.51 | +0.37% |
| **Trojan T2** | 42.66 | 412.19 | 466.28 | +0.54% |
| **Trojan T3** | 43.09 | 412.20 | 467.17 | +0.73% |
| **Trojan T4** | 40.69 | 412.18 | 464.75 | +0.21% |
| **Trojan T5** | 40.21 | 412.18 | 464.27 | +0.10% |

The power overhead of the monitored designs is negligible (< 0.73%), rendering side-channel power anomaly detection ineffective and justifying internal digital assertion logic.

### 10.4 Detection and Statistical Security Metrics
From the 60 measured runs (10 negative, 50 positive):
$$\text{TPR} = \frac{50}{50 + 0} = 1.000000 \quad (100.0\%)$$
$$\text{FPR} = \frac{0}{0 + 10} = 0.000000 \quad (0.0\%)$$
$$\text{Precision} = \frac{50}{50 + 0} = 1.000000 \quad (100.0\%)$$
$$\text{F1 Score} = 1.000000$$

### 10.5 Localization Performance
Across all 50 Trojan runs:
- T1 (PE MAC): 10/10 localized to `2'b01`.
- T2 (Weight Memory): 10/10 localized to `2'b10`.
- T3, T4, T5 (Interconnect/Routing/Control): 30/30 localized to `2'b11`.
- **Overall Localization Accuracy**: **100.0% (50 / 50)**.

### 10.6 Cross-Workload Robustness
Evaluating workloads $W_0$ through $W_9$ revealed zero latency jitter (standard deviation = 0.0 cycles) and zero false alarms on healthy workloads across all ten digit classes.

---

## 11. Discussion
The empirical findings prove that internal architectural monitoring overcomes the fundamental limitation of black-box testing. Because neural networks possess inherent noise margin tolerances, small malicious corruptions can easily escape top-level functional tests while establishing persistent microarchitectural backdoors. By embedding lightweight checkers directly at processing element interfaces and memory address decoders, detection is guaranteed at the cycle of Trojan activation.

---

## 12. Limitations
1. **Physical Visual Validation**: Healthy, T1, and T2 have been physically demonstrated on the DE10-Standard board. T3, T4, and T5 bitstreams compile cleanly and have verified JTAG download automation, but direct human visual observation of board LEDs remains pending hands-on benchtop access.
2. **Workload Scope**: Experiments were conducted on INT8 LeNet/MNIST. Scaling to larger workloads (e.g., ResNet-50 on ImageNet) will require hierarchical signature tree monitoring.
3. **Power Instrumentation**: Power results reflect Quartus Power Analyzer thermal models rather than physical multimeter current shunt measurements.

---

## 13. Conclusion
We designed, implemented, and empirically validated a runtime Hardware Trojan detection and spatial localization framework for FPGA-accelerated CNNs. Evaluating five distinct Trojan families across ten diverse MNIST workloads demonstrated 100.0% detection and localization accuracy with zero false alarms. Implemented on an Intel Cyclone V FPGA, the architecture incurs under 6.4% ALM overhead and 0.73% power overhead, establishing a practical defense mechanism for secure edge AI accelerators.

---

## 14. Future Work
Future work will extend the monitoring architecture to multi-tenant FPGA CNN engines, evaluate runtime self-healing rollback capabilities upon Trojan assertion, and conduct physical current-probe transient power profiling on physical benchtop hardware.

---

## References
\bibliography{references/references}
