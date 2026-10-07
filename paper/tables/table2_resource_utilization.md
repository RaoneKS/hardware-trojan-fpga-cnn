# Table 2: Cyclone V FPGA Resource and Timing Evidence

Target device: Intel Cyclone V 5CSXFC6D6F31C6/5CSXFC6D6F31I7 family as used by the repository projects.

**Evidence policy:** only values present in the canonical repository evidence ledger are published here. Exact T3–T5 final fitter resource counts are intentionally shown as unavailable rather than inferred from stale or synthesis-only artifacts.

| Variant | ALMs | Registers | M10K RAM | DSP | Worst setup slack (ns) | Worst hold slack (ns) |
|---|---:|---:|---:|---:|---:|---:|
| Healthy | 1,153 | 902 | 71 | 13 | +2.933 | +0.116 |
| T1 | 1,170 | 910 | 71 | 13 | +1.078 | +0.145 |
| T2 | 1,192 | 919 | 71 | 15 | +2.634 | +0.140 |
| T3 | **Not archived** | **Not archived** | **Not archived** | **Not archived** | +4.447 | +0.159 |
| T4 | **Not archived** | **Not archived** | **Not archived** | **Not archived** | +5.581 | +0.105 |
| T5 | **Not archived** | **Not archived** | **Not archived** | **Not archived** | +4.648 | +0.134 |

The positive timing slacks demonstrate timing closure in the archived Quartus runs. The resource table is deliberately conservative: older paper tables contained conflicting resource snapshots and are superseded by `verification/results/hardware_resources.csv`.
