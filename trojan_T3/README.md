# T3 — Interconnect Data-Path Alteration

T3 flips bit 0 of one selected MaxPool1-to-Conv2 feature interconnect value before the Conv2 MAC.

Trigger: out_f=1, out_r=0, out_c=0, in_ch=1, kr=1, kc=1.
Payload: p1_q XOR 32'h00000001.
Localization: 2'b11.
The original weight memory is unchanged.

Use the checked-in T3 testbench to verify detector assertion, localization, and the end-to-end CNN result before reporting quantitative T3 results.
