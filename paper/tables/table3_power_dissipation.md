# Table 3: Thermal and Dynamic Power Dissipation (Quartus Power Analyzer)

Thermal and power characterization under vectorless transition activity estimation at 50 MHz.

| Architecture Variant | Core Dynamic Power (mW) | Dynamic Power Change | Core Static Power (mW) | I/O Power (mW) | Total Thermal Dissipation (mW) | Total Power Overhead vs. Healthy |
|---|---:|---:|---:|---:|---:|---:|
| **Healthy Baseline** | 40.65 | Baseline | 412.18 | 10.97 | **463.79** | Baseline |
| **Trojan T1 (PE MAC)** | 41.88 | +1.23 mW (+3.03%) | 412.19 | 11.44 | **465.51** | +1.72 mW (+0.37%) |
| **Trojan T2 (Weight RAM)** | 42.66 | +2.01 mW (+4.94%) | 412.19 | 11.43 | **466.28** | +2.49 mW (+0.54%) |
| **Trojan T3 (Interconnect)**| 43.09 | +2.44 mW (+6.00%) | 412.20 | 11.88 | **467.17** | +3.38 mW (+0.73%) |
| **Trojan T4 (Routing)** | 40.69 | +0.04 mW (+0.10%) | 412.18 | 11.88 | **464.75** | +0.96 mW (+0.21%) |
| **Trojan T5 (Control Stall)**| 40.21 | -0.44 mW (-1.08%) | 412.18 | 11.88 | **464.27** | +0.48 mW (+0.10%) |
