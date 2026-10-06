# Table 1: Hardware Trojan Taxonomy and Threat Characteristics

| Trojan ID | Attack Mechanism | Target Microarchitectural Domain | Activation Trigger Condition | Attack Payload | Expected Localization Code | Detection Latency (cycles) |
|---|---|---|---|---|:---:|---:|
| **T1** | Computation Corruption | Conv2 Processing Element (PE) MAC Unit | Spatial coordinate $(f=1, r=0, c=0, \text{ch}=1, \text{kr}=1, \text{kc}=1)$ | Inverts sign of MAC product $(-P)$ before accumulation | `2'b01` | 149,136 |
| **T2** | Memory Alteration | Conv2 Weight Memory Interface | Memory read cycle at coordinate $(f=1, r=0, c=0, \text{ch}=1, \text{kr}=1, \text{kc}=1)$ | Flips single bit of retrieved weight operand ($5 \to 4$) | `2'b10` | 149,136 |
| **T3** | Interconnect Alteration | MaxPool1-to-Conv2 Feature Interconnect Bus | Data transfer cycle at coordinate $(f=1, r=0, c=0, \text{ch}=1, \text{kr}=1, \text{kc}=1)$ | Corrupts bit 0 of inter-layer activation stream | `2'b11` | 149,136 |
| **T4** | Routing Diversion | Feature Buffer Source Addressing Generator | Coordinate $(f=1, r=0, c=0, \text{ch}=1, \text{kr}=1, \text{kc}=1)$ | Alters read address pointer to adjacent memory location | `2'b11` | 149,136 |
| **T5** | Control Flow Disruption | Main Pipeline Finite State Machine (FSM) | State transition into Conv2 MAC at target coordinates | Injects single-cycle pipeline stall (`T5STALL`) | `2'b11` | 149,135 |
