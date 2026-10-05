# Viva / Professor Q&A

1. **Problem?** Detect controlled Hardware Trojans in an FPGA CNN accelerator during runtime and localize the affected region.
2. **Why CNN accelerators?** Repeated MACs, memories and interconnects let small malicious changes propagate through many computations.
3. **T1?** Selected Conv2 PE MAC product sign inversion.
4. **T2?** Selected Conv2 weight/data-path bit flip, changing 5 to 4.
5. **Key T1 result?** Product +10075 to -10075; detector cycle 149144; latency 149136 cycles; final class remains 7.
6. **Why does class 7 remaining matter?** Output-only checking can miss internal Trojan corruption.
7. **T2 localization 10?** Conv2 weight/data-path region.
8. **Physical evidence?** Healthy/T1/T2 have simulation/build evidence; T1/T2 were programmed; T2 physically demonstrated detector and localization.
9. **T3-T5 hardware validated?** Not yet.
10. **Why no TPR/FPR/F1?** They require repeated positive and negative workload runs.
11. **Defensible contribution?** Controlled lightweight FPGA-CNN runtime detection/localization across PE, data, interconnect, routing and control behaviors.
12. **Universal detector?** No. Only selected Trojan families are evaluated.
13. **Remaining work?** T3-T5 hardware validation, repeated workloads, statistical metrics and power/activity characterization.
