# Viva / Professor Q&A

1. **Problem?** Detect controlled Hardware Trojans in an FPGA CNN accelerator during runtime and localize the affected region.
2. **Why CNN accelerators?** Repeated MACs, memories and interconnects let small malicious changes propagate through many computations.
3. **T1?** Selected Conv2 PE MAC product sign inversion.
4. **T2?** Selected Conv2 weight/data-path bit flip.
5. **T3?** Selected Conv2 feature-interconnect alteration; localization code 11.
6. **T4?** Selected Conv2 source-routing alteration; localization code 11.
7. **T5?** Selected Conv2 control-path one-cycle stall; localization code 11.
8. **Why does unchanged class matter?** Output-only checking can miss internal Trojan corruption while the runtime monitor observes the internal event.
9. **What does code 01 mean?** Conv2 PE computation region.
10. **What does code 10 mean?** Conv2 weight-memory/data-path region.
11. **What does code 11 mean?** Shared Conv2 interconnect/routing/control region; it does not identify T3 vs T4 vs T5.
12. **Simulation result?** Ten MNIST workloads × six targets = 60 PASS rows; TP=50, TN=10, FP=0, FN=0 for the evaluated simulation matrix.
13. **Physical evidence?** T3, T4 and T5 were programmed on the DE10-Standard and observed with class 7, detector asserted and localization 11.
14. **Canonical timing?** 634,281 cycles for Healthy/T1–T4, 634,282 for T5; detection latency 149,136 cycles for T1–T4 and 149,135 for T5 at 50 MHz.
15. **Power?** Quartus Power Analyzer estimates only; no physical rail/current measurement was collected.
16. **Universal detector?** No. The result is limited to the selected controlled Trojan implementations and workloads.
17. **What remains?** Physical power instrumentation, broader generalization/cross-CNN validation, executable ablation, and rebuilding legacy I7-targeted projects on C6 if final-device resource numbers are required.
