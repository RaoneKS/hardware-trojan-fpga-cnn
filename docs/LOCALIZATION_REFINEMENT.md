# Three-bit Trojan Localization Refinement (Experimental Branch)

## Purpose
This branch upgrades the original two-bit, three-region localization output to a three-bit code distinguishing the five *known, controlled* Trojan variants. The extra output bit changes the RTL interface and requires fresh synthesis and board validation; this is not a drop-in replacement for the tested DE10 image.

## Encoding
| Code | Meaning |
|---|---|
| `000` | Healthy / no detector assertion |
| `001` | T1 — Conv2 processing-element arithmetic |
| `010` | T2 — Conv2 weight-memory data path |
| `011` | T3 — feature interconnect |
| `100` | T4 — spatial source routing |
| `101` | T5 — control sequencing |
| `110` | Reserved: ambiguous/conflicting evidence |
| `111` | Reserved: invalid/unknown code |

Each variant-specific RTL emits its code and its testbench checks the corresponding three-bit value. This distinguishes the five known injected variants, but does not prove a general-purpose classifier for unseen or simultaneous Trojans.

## Required validation before replacing current paper/board results
1. Run the canonical 60-row Healthy/T1–T5 regression and confirm predicted classes, detection flags, and new localization codes.
2. Re-run the held-out 300-row same-CNN test and preserve the Healthy-correct screening qualification.
3. Compile each variant with Quartus; record warnings, fitter resources, setup/hold slack and Fmax.
4. Assign a physical FPGA pin for the third localization bit, regenerate programming files, and re-test every physical variant.
5. Only after these steps, update the paper's headline localization results and board claims. Existing two-bit/three-region results remain the validated baseline until this branch passes these checks.

## Research limitation
The code is emitted within each controlled RTL variant after its corresponding detector path fires. This is variant-aware identification for the known campaign, not blind inference of arbitrary Trojan location. General localization requires independent diagnostic signatures and tests for unseen/mixed variants.
