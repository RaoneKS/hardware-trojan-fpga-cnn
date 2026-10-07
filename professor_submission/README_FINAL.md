# Professor Submission — Hardware Trojan Detection in FPGA-CNNs

## Primary deliverables
- `paper/manuscript.md` — evidence-cleaned research paper.
- `paper/ieee_paper.tex` — IEEE conference-style LaTeX source.
- `paper/references/references.bib` — bibliography.
- `docs/FINAL_REPORT.md` — final project report.
- `docs/PAPER_RESULTS.md` — canonical results ledger.
- `docs/RESULTS_AND_METRICS.md` — metrics and timing.
- `docs/CONFUSION_MATRIX.csv` — regional matrix.
- `docs/REPRODUCIBILITY.md` — reproduction commands.
- `docs/RESEARCH_CLAIMS.md` — evidence boundaries.
- `docs/PHYSICAL_BOARD_VALIDATION.md` — board observations.
- `docs/PROFESSOR_REQUIREMENTS_AUDIT.md` — requirement audit.
- `docs/VIVA_QA.md` — viva preparation.
- `CITATION.cff` — citation metadata.

## Experimental scope
Board: Terasic DE10-Standard. FPGA: Intel Cyclone V SoC 5CSXFC6D6F31C6. Clock: 50 MHz. Ten deterministic MNIST workloads and six targets give 60 canonical simulation rows.

## Main result
TP=50, TN=10, FP=0, FN=0. TPR/recall=100%, FPR=0%, precision=100%, F1=1.000. Regional localization is 50/50=100% at the defined three-region resolution. These are simulation-regression metrics only.

## Physical validation
T3, T4 and T5 were programmed successfully with zero programming errors and zero warnings. LEDR0–LEDR5 were observed ON for each: class 7, detector asserted, localization code 11. Code 11 is shared and does not distinguish the three variants.

## Evidence boundaries
Quartus power numbers are tool estimates, not physical rail measurements. Exact T3–T5 final fitter resource counts and exact fresh-C6 Fmax are not archived. Universal detection is not claimed.

## Build the final ZIP
```bash
cd ~/hardware-trojan-fpga-cnn
bash professor_submission/build_submission_zip.sh
```
