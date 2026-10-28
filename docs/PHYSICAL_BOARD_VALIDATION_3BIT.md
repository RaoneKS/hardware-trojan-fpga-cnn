# Physical DE10-Standard Validation — Three-Bit Codebook

Date: 2026-10-28. Board: Terasic DE10-Standard. These rows record the physical LED observations reported during the current session.

## Interface
- LEDR[2:0]: predicted CNN class (reference image observed as class 7 / 111).
- LEDR3: detector status; OFF for Healthy, ON for T1–T5.
- LEDR[6:4]: code, with bit 0 on LEDR4, bit 1 on LEDR5, bit 2 on LEDR6.
- Codebook: Healthy 000; T1 001; T2 010; T3 011; T4 100; T5 101. Codes 110 and 111 reserved.

| Configuration | Expected code | LEDs observed ON | Code bits LEDR[6:4] | Result |
|---|---:|---|---:|---|
| Healthy | 000 | 0,1,2 | 000 | PASS |
| T1 — Conv2 PE arithmetic | 001 | 0,1,2,3,4 | 001 | PASS |
| T2 — Conv2 weight-memory path | 010 | 0,1,2,3,5 | 010 | PASS |
| T3 — feature interconnect | 011 | 0,1,2,3,4,5 | 011 | PASS |
| T4 — spatial source routing | 100 | 0,1,2,3,6 | 100 | PASS |
| T5 — control sequencing | 101 | 0,1,2,3,4,6 | 101 | PASS |

These are reported output-pattern observations, not six independent statistical detection trials. This supports visible distinction among the five known controlled bitstreams only; it does not establish blind localization of unknown, mixed or simultaneous Trojans. No physical power/current measurement is claimed. Historical two-bit logs are not raw logs for this updated three-bit session.
