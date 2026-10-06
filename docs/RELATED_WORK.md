# Related Work and Positioning

Literature was reviewed against the professor's required four categories. The emphasis is on work published from 2023 onward, with older work retained only when it directly establishes a relevant baseline.

## 1. CNN accelerator Trojan attacks

| Paper | Platform / target | Main method or attack | Key result | Gap relative to this project |
|---|---|---|---|---|
| J. Hou et al., 2024, “Hardware Trojan Attacks on the Reconfigurable Interconnections of FPGA-Based CNN Accelerators and a PUF-Based Countermeasure Detection Technique,” Micromachines | Xilinx Zynq XC7Z100; CNN reconfigurable interconnect | Trojan changes PE interconnection paths; Arbiter-PUF countermeasure | 0.27% hardware overhead; reports CNN accuracy degradation and interconnect localization | PUF-centric and focused on interconnect; this project evaluates PE, weight/data path, interconnect, and control anomalies with a lightweight runtime monitor |
| C. Guo, M. Yanagisawa, Y. Shi, 2025, “DSE-Based Hardware Trojan Attack for Neural Network Accelerators on FPGAs,” IEEE TNNLS | FPGA NN accelerators; LeNet/VGG-16/YOLO | Evolutionary DSE-generated Trojan insertion | Reported LUT overhead ≤0.6%; controlled accuracy/category attacks | Attack-generation work rather than runtime detection/localization |
| Z. Liu, J. Hou, J. Wang, C. Yang, 2024, “A Novel Two-Level Protection Scheme against Hardware Trojans on a Reconfigurable CNN Accelerator,” Cryptography | Xilinx Zynq XC7Z100; RI/MAC/ReLU | PE-space randomization plus voting/IORD/PCC | ≥99.88% mitigation effectiveness in evaluated cases | Protection/mitigation emphasis; not a multi-signature statistical runtime monitor |
| P. Sun, B. Halak, T. J. Kazmierski, 2025, “Towards Hardware Trojan Resilient Convolutional Neural Network Accelerators,” Journal of Hardware and Systems Security | MobileNetV2, ShuffleNetV2, GhostNet accelerators | Selective hardware redundancy and hardware/time redundancy | SHR area overhead about 6–10%; SHTR about 0.3% in reported configurations | Strong resilience study, but uses redundancy/recovery rather than explainable runtime signature localization |

## 2. FPGA runtime / side-channel / configuration detection

| Paper | Signal / method | Result | Gap |
|---|---|---|---|
| “Natural Language Processing for Hardware Security: Case of Hardware Trojan Detection in FPGAs,” Cryptography 2024 | RNN/LSTM analysis of FPGA configuration bitstreams | LSTM average accuracy 93.5% in reported ISCAS-85 evaluation | Pre-deployment/bitstream-level analysis rather than accelerator-runtime monitoring |
| T. Krachenfels, J.-P. Seifert, S. Tajik, 2023, “Trojan awakener: detecting dormant malicious hardware using laser logic state imaging,” Journal of Cryptographic Engineering | Laser logic state imaging of FPGA configuration | Detects small combinational/sequential and routing changes, including dormant Trojans | Specialized optical laboratory technique; not lightweight on-board runtime monitoring |
| “The Impact of Run-Time Variability on Side-Channel Attacks Targeting FPGAs,” 2024 | Real-hardware power side-channel analysis under DVFS variability | Demonstrates trade-offs between variability and side-channel resistance | Cryptographic SCA focus rather than CNN Trojan runtime detection |

## 3. FPGA / RTL Trojan localization

| Paper | Localization method | Result | Gap |
|---|---|---|---|
| R. Fan, Y. Tang, H. Sun, J. Liu, H. Li, 2024, “An Efficient ML-based Hardware Trojan Localization Framework for RTL Security Analysis,” MLCAD 2024 | Signal-transfer graph + structural/graph-centrality features | Reported 98% recall, 100% TNR, 99% precision, 98% F1 | RTL structural localization; does not demonstrate runtime localization on a physical CNN accelerator |
| H. Su, W. Hu, X. Zhang, D. Zhu, L. Wu, 2025, “Toward Precise and Explainable Hardware Trojan Localization at LUT Level,” IEEE TCAD | Explainable GNN on FPGA LUT-level structural/behavioral features | 95.14% TPR, 95.71% accuracy, 95.46% AUC on 183 benchmarks | Fine-grained netlist localization but not runtime accelerator-level evidence |
| A. J. Tiempo, Y.-J. Jeong, 2023, “Split and Eliminate: A Region-Based Segmentation for Hardware Trojan Detection,” IEICE Transactions on Information and Systems | Region-based segmentation of FPGA cell-level netlists | Reports average detection rate 95.41%, false-alarm rate 2.87%, accuracy 96.27% | Structural pre-silicon detection; no runtime CNN workload analysis |

## 4. Lightweight / ML-based hardware security for accelerator-oriented systems

| Paper | Method | Result | Gap |
|---|---|---|---|
| P. Ma et al., 2025, “GNN-Based Hardware Trojan Detection at Register Transfer Level Leveraging Multiple-Category Features,” IEEE TVLSI | 37-D node type + structural features and GNN at RTL, golden-reference-free | Best model reports 99.1% recall and 96.7% F1 on Trust-Hub data | ML-heavy structural analysis; this project targets a lightweight runtime monitor implemented with the accelerator |
| L. Chen et al., 2025, “GNN4HT: A Two-Stage GNN-Based Approach for Hardware Trojan Multifunctional Classification,” IEEE TCAD | GNN localization followed by Trojan functionality classification | TPR 94.28% for localization; functionality classification also evaluated | Gate/RTL graph analysis rather than physical runtime accelerator monitoring |
| A. J. Tiempo, Y.-J. Jeong, 2025, “FP-GNN: A Graph Neural Network for Hardware Trojan Detection in Gate-Level Netlist,” IEICE Transactions on Information and Systems | Graph representation and GNN classification | Average accuracy 95.34% on benchmark circuits and 90.82% on randomly generated circuits | Structural ML detector; no workload-driven runtime signatures |

## Positioning of the proposed work

The literature shows three recurring patterns:

1. **Attack-focused CNN work** demonstrates that PE, memory, activation, prediction, and interconnect regions are vulnerable, but attack papers do not by themselves establish a practical runtime monitor.
2. **Structural/bitstream/optical detection** can achieve strong detection or localization, but often operates before inference, requires specialized analysis, or depends on structural representations rather than runtime behavior.
3. **Redundancy and ML defenses** can be effective, but may add substantial replicated hardware or require a training/data pipeline.

The proposed project occupies a narrower and experimentally testable position:

**A lightweight accelerator-level runtime monitor is evaluated on a physical Cyclone V CNN accelerator against controlled PE, weight/data-path, interconnect, routing, and control-path Trojan variants, with an explicit region code and measured trigger-to-alarm latency.**

This positioning is deliberately not a claim of universal detection or superiority over all prior methods.

## Verified source links

- Hou et al. 2024: https://doi.org/10.3390/mi15010149
- Guo et al. 2025: https://doi.org/10.1109/TNNLS.2024.3482364
- Liu et al. 2024: https://doi.org/10.3390/cryptography8030034
- Sun et al. 2025: https://doi.org/10.1007/s41635-025-00164-y
- Ma et al. 2025: https://doi.org/10.1109/TVLSI.2024.3513218
- FP-GNN: https://doi.org/10.1587/transinf.2024EDL8057
- Fan et al. 2024: https://ieeexplore.ieee.org/document/10740223
- Su et al. 2025: https://ieeexplore.ieee.org/document/10833822
- Split and Eliminate: https://doi.org/10.1587/transinf.2022EDP7169
- GNN4HT: https://doi.org/10.1109/TCAD.2024.3428469
- FPGA bitstream RNN/LSTM detection: https://doi.org/10.3390/cryptography8030036
- Trojan awakener: https://doi.org/10.1007/s13389-023-00323-3

## Literature limitation

Bibliographic metadata and reported numerical results should still be checked against the publisher version before final journal submission. The comparison table intentionally distinguishes published results from this project's measurements and does not treat different platforms, workloads, or detection objectives as directly interchangeable.
