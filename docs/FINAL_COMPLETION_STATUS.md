# Final Completion Status — Three-Bit Branch

As of 2026-10-28. Branch: localization-refinement-3bit. The default main branch is intentionally unchanged.

## Completed within the controlled scope
- Canonical cycle-accurate simulation: 60 PASS rows (10 workloads × Healthy/T1–T5); CI run 40700346008 succeeded.
- Metrics for that selected simulation matrix: TP=50, TN=10, FP=0, FN=0; TPR/recall=100%, FPR=0%, precision=100%, F1=1.000. All 50 Trojan-present rows emit their expected code.
- Three-bit map: Healthy 000; T1 001 (Conv2 PE arithmetic); T2 010 (Conv2 weight-memory path); T3 011 (feature interconnect); T4 100 (spatial source routing); T5 101 (control sequencing).
- Fresh Quartus full compilation of all six targets: zero failed compile commands; all listed Fmax values exceed the 50 MHz target. See docs/QUARTUS_3BIT_VALIDATION.md.
- Healthy and T1–T5 board LED patterns were reported and match the expected codes. See docs/PHYSICAL_BOARD_VALIDATION_3BIT.md.

## Not claimed complete
1. The previous 300-row held-out study used the old two-bit codebook. A fresh 300-row three-bit run is not yet evidenced.
2. The full current Quartus raw report bundle/SOF binaries and a complete final six-target fitter-resource table are not included in the professor package.
3. No physical rail/current power was measured.
4. New-session board photographs and raw programmer logs are not included.
5. This is variant-aware identification for five known controlled RTL variants, not blind detection/localization of unknown or mixed Trojans.

Status: canonical simulation, six Quartus builds, and six reported board output patterns are complete within the boundaries above. Do not conflate the earlier two-bit study with the current three-bit codebook.
