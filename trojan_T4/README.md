# T4 — Selective Interconnect Routing Alteration

T4 is distinct from T3: it corrupts the selected Conv2 source routing/address rather than flipping a data bit.

Trigger: out_f=1, out_r=0, out_c=0, in_ch=1, kr=1, kc=1.
Payload: route the requested MaxPool1 source to the adjacent spatial element.
Localization: 2'b11.
The Conv2 weight memory is unchanged.

Run the checked-in T4 testbench and Quartus build before reporting measured T4 results.
