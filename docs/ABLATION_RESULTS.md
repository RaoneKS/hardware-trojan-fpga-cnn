# Ablation and Architectural Evaluation

## 1. Objective
This study investigates the design choices of the proposed runtime detection architecture, specifically analyzing:
1. **Single-Signature vs. Multi-Signature Verification**: Comparing isolated layer checking against distributed multi-layer detection.
2. **Detection Granularity vs. Resource Overhead**: Evaluating the logic cost of 2-bit multi-region localization against monolithic 1-bit detection.
3. **Payload Stealthiness and Classification Invariance**: Evaluating the effect of corruption severity on downstream classification versus detector visibility.

---

## 2. Detection Granularity & Architecture Ablation

| Detection Configuration | Architecture | Monitored Nodes | Supported Trojans | Localization Capability | ALM Overhead vs. Healthy | Register Overhead | Detection Reliability (TPR) |
|---|---|---|---|---|---:|---:|---:|
| **Output-Only Monitoring** | Top-1 class comparator | Output register `predicted_class` | None (all T1–T5 stealthy) | None (0-bit) | 0 ALMs (+0.0%) | 0 (+0.0%) | **0.0%** (0 / 50 detected) |
| **Monolithic Single-Signature** | Conv2 PE MAC checker only | MAC product sign | T1 only | None (1-bit `DETECTED`) | +22 ALMs (+1.92%) | +35 (+3.94%) | **20.0%** (10 / 50 detected) |
| **Memory-Only Monitor** | Weight data parity/range check | Conv2 weight bus | T2 only | Memory-only (1-bit) | +45 ALMs (+3.93%) | +26 (+2.92%) | **20.0%** (10 / 50 detected) |
| **Proposed Multi-Region System** | Unified PE, Memory, Interconnect, Control monitors | MAC, Weights, Feature Bus, FSM states | **T1, T2, T3, T4, T5** | **2-bit Full Region Localization** | +73 ALMs (+6.38% max) | +35 (+3.94% max) | **100.0%** (50 / 50 detected) |

### Key Findings
1. **Output-Only Monitoring Fails**: Because T1–T5 were engineered to corrupt intermediate representations without perturbing the final top-1 argmax on typical inputs, output-only validation yields a 0% true positive rate.
2. **Necessity of Multi-Signature Monitoring**: Single-domain monitors (e.g., PE-only or Memory-only) fail to detect 80% of malicious variants.
3. **Lightweight Cost of Localization**: Augmenting the system with a 2-bit regional localization bus costs fewer than 75 ALMs (< 0.18% of the Cyclone V device logic capacity), providing complete fault attribution with negligible area overhead.

---

## 3. Trojan Trigger Stealthiness Analysis

| Trojan ID | Attack Mechanism | Trigger Condition | Architectural Location | Top-1 Classification Impact on MNIST (10 Digits) | Detector Assertion Cycle |
|---|---|---|---|:---:|---:|
| **T1** | Sign inversion on 1 MAC product | Channel 1, Row 0, Col 0, InCh 1 | Conv2 Processing Element | Invariant (0 flips) | Cycle 149,144 |
| **T2** | Single-bit flip in weight operand | Channel 1, Row 0, Col 0, InCh 1 | Conv2 Weight Memory Interface | Invariant (0 flips) | Cycle 149,144 |
| **T3** | Single-bit flip on feature bus | Channel 1, Row 0, Col 0, InCh 1 | Conv1-to-Conv2 Interconnect | Invariant (0 flips) | Cycle 149,144 |
| **T4** | Spatial source-address rerouting | Channel 1, Row 0, Col 0, InCh 1 | Feature Map Addressing Engine | Invariant (0 flips) | Cycle 149,144 |
| **T5** | 1-cycle pipeline execution stall | Channel 1, Row 0, Col 0, InCh 1 | FSM Control Sequencer | Invariant (0 flips) | Cycle 149,143 |

This confirms that all five Trojan families achieve extreme stealthiness under traditional black-box validation, while the proposed lightweight architectural monitors reliably capture every intrusion within 2.98 ms.
