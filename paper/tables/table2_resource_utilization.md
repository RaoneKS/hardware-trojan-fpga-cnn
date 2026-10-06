# Table 2: Cyclone V FPGA Resource Utilization and Timing Summary

Target Device: Intel Cyclone V 5CSXFC6D6F31C6 (DE10-Standard Development Kit). Operating Frequency: 50.0 MHz ($\tau = 20.0\text{ ns}$).

| Architecture Variant | Logic ALMs | ALM Overhead vs. Healthy | Dedicated Registers | Register Overhead | M10K RAM Blocks | Block Memory Bits | DSP Blocks | Worst Setup Slack (ns) | Worst Hold Slack (ns) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **Healthy Baseline** | 1,145 | Baseline | 889 | Baseline | 71 | 455,104 | 13 | +2.669 | +0.129 |
| **Trojan T1 (PE MAC)** | 1,167 | +1.92% | 924 | +3.94% | 71 | 455,104 | 13 | +0.999 | +0.124 |
| **Trojan T2 (Weight RAM)** | 1,190 | +3.93% | 915 | +2.92% | 71 | 455,104 | 15 | +2.634 | +0.140 |
| **Trojan T3 (Interconnect)**| 1,195 | +4.37% | 924 | +3.94% | 71 | 455,104 | 15 | +4.447 | +0.159 |
| **Trojan T4 (Routing)** | 1,218 | +6.38% | 902 | +1.46% | 71 | 455,104 | 13 | +5.581 | +0.105 |
| **Trojan T5 (Control Stall)**| 1,151 | +0.52% | 918 | +3.26% | 71 | 455,104 | 13 | +4.648 | +0.134 |
