# T5 — Controlled Conv2 Control-Path Anomaly

T5 injects a deterministic one-cycle control-path stall immediately before one selected Conv2 MAC transaction.

Trigger: out_f=1, out_r=0, out_c=0, in_ch=1, kr=1, kc=1.
Payload: insert T5STALL for one extra cycle.
Localization: 2'b11, representing the interconnect/data-path/control region.
Weights and feature data are not directly modified.

The expected signature is an anomalous inference-cycle count and a T5 detector assertion. Run simulation before reporting the measured cycle delta.
