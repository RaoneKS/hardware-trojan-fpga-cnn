# Historical Extended Held-Out MNIST Validation (Two-Bit Codebook)

## Evidence provenance
- GitHub Actions workflow: [Extended MNIST validation](https://github.com/RaoneKS/hardware-trojan-fpga-cnn/actions/runs/37684517036)
- Commit tested: `c2c7492886774ba6912eb8df5756d71621818ca4`
- Run completed successfully on 2026-10-07.
- The CI artifact `extended-mnist-validation` contains the 300-row CSV, selected workload manifest, selection/screening record, and generated report.

## Protocol
The canonical ten MNIST test indices were excluded. Candidate images were screened with the Healthy synchronous-M10K implementation. The selected set contains five Healthy-correct images from each digit class (50 total); each selected image was then run on Healthy and T1–T5, yielding 50 × 6 = 300 cycle-accurate RTL simulations. Fifty-one candidates were screened to obtain the class-balanced selected set.

## Historical results (not a fresh three-bit evaluation)
| Measure | Result |
|---|---:|
| Held-out selected images | 50 (5 per class) |
| Healthy/T1–T5 simulation rows | 300 |
| Healthy rows | 50 |
| Trojan-present rows | 250 |
| TP / TN / FP / FN | 250 / 50 / 0 / 0 |
| TPR / recall | 100% |
| FPR | 0% |
| Precision | 100% |
| F1 | 1.000 |
| Expected class preserved | 300/300 rows |
| Regional code correct under former two-bit map | 250/250 Trojan rows |
| T1–T4 detection latency | 149,136 cycles (2.98272 ms at 50 MHz) |
| T5 detection latency | 149,135 cycles (2.98270 ms at 50 MHz) |

All rows in the archived extended ledger have status PASS under the historical two-bit implementation. Healthy detection remained 0 for all 50 selected images; all 250 Trojan-present runs asserted detection and emitted their former regional code.

## Important qualification
This is a held-out, same-CNN simulation evaluation—not physical validation of 300 cases. The Healthy screening deliberately retains only inputs classified correctly by the Healthy baseline; therefore the reported FPR is conditional on that screened population and should not be presented as an estimate over all MNIST inputs. It does not establish cross-CNN generalization, physical power overhead, or universal Trojan detection. This run used the former two-bit map: T1=01, T2=10, and T3/T4/T5 shared code 11. It must not be cited as evidence that the updated three-bit map 011/100/101 was evaluated on these 300 rows. A fresh three-bit held-out run remains pending.
