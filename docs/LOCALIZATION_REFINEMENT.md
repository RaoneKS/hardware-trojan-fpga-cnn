# Three-Bit Variant-Aware Localization

| Code | Configuration |
|---|---|
| 000 | Healthy / detector inactive |
| 001 | T1 — Conv2 PE arithmetic |
| 010 | T2 — Conv2 weight-memory path |
| 011 | T3 — feature interconnect |
| 100 | T4 — spatial source routing |
| 101 | T5 — control sequencing |
| 110, 111 | Reserved |

## Evidence
The canonical 60-row simulation passed, with 10 rows for each configuration and expected codes on all 50 Trojan-present rows. Fresh Quartus compilation succeeded for all six configurations, with all listed Fmax values above 50 MHz. Physical LED observations were reported for all six configurations and match the codebook.

The older held-out 300-row study used the former two-bit codebook (T3/T4/T5 shared code 11); it is historical detection evidence only, not a fresh three-bit localization result. The current codebook is variant-aware and is not blind inference of unknown/mixed Trojan locations. Physical rail/current power was not measured. See docs/QUARTUS_3BIT_VALIDATION.md and docs/PHYSICAL_BOARD_VALIDATION_3BIT.md.
