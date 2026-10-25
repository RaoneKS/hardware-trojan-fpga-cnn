# Independent Runtime Monitor — Prototype and Validation Boundaries

## Why this change exists

The original variant RTL exposed detector outputs that were driven by Trojan-specific activation flags. Those flags are useful for confirming that an injected trigger executed, but they are not independent evidence that a detector can identify the resulting behaviour. This prototype routes the public detector status through a separate monitor module instead.

## Checks implemented

1. **MAC arithmetic consistency.** At each valid Conv2 MAC, the core samples the post-payload product and a reference product independently computed from the unmodified feature/weight operands. The monitor raises a sticky alert when the sampled products differ.
2. **Feature-memory address consistency.** During Conv2's address-wait state, the monitor compares the registered feature read address with the address implied by the current channel/row/column/kernel counters.
3. **Control-path anomaly.** In T5, the monitor flags the inserted T5STALL state rather than consuming the Trojan's t5_detected flag.
4. **Healthy false-alarm measurement.** The clean reference core now instantiates the same monitor. The canonical regression explicitly observes no alert and localization code 00 for each healthy workload.

The monitor does not read the Trojan-specific t1_detected/t2_detected/... flags. The public detector outputs in the variants are driven by the monitor alert, and the public localization output is driven by the monitor's localization register.

## Localization interpretation

| Code | Meaning in this prototype |
|---|---|
| 00 | No monitored anomaly observed during this inference |
| 01 | Observed product is the negation of the nonzero reference product (PE arithmetic signature) |
| 10 | Observed product uniquely matches the weight-bit-flip candidate |
| 11 | Feature-operand/data-path signature, address mismatch, control anomaly, or ambiguous arithmetic signature |

Code 11 intentionally remains a shared region. It does not uniquely distinguish T3, T4, and T5. Code 00 means no anomaly was observed by these checks; it is not proof that arbitrary Trojans are absent.

## Threat model and trust assumptions

The monitor is independent of the Trojan-specific activation flags, but it is not a tamper-proof security island. It assumes the monitor logic, clock/reset, operation counters, and sampled reference inputs are trusted. A Trojan that also corrupts those trusted signals, avoids the monitored Conv2 operations, or causes a payload with no observable arithmetic effect may evade these checks. The current reference-product comparison is a targeted functional checker for the five controlled variants, not a general unknown-Trojan detector.

The expected product is recomputed from the sampled feature and weight operands. The weight/feature candidate products are used only to assign the coarse region code. If candidate signatures collide, fine-grained localization is not guaranteed.

## Validation plan

Run the canonical integration regression:

```bash
chmod +x verification/run_full_matrix.sh
./verification/run_full_matrix.sh
```

The runner now exercises ten healthy cases with the monitor active and requires zero false alerts, then exercises all five controlled Trojan variants across ten workloads. It records detection/localization output from the monitor-facing testbench ports. A passing run is required before publishing new metrics.

Additional validation still required before a paper or physical-security claim:

- Run the held-out 50-image / 300-condition matrix against this monitor-enhanced RTL, not only the old self-reporting variants.
- Add dedicated unit tests for each checker, reset/re-arm behaviour, zero-product/ambiguous-signature cases, and deliberate benign deviations.
- Rebuild every affected Quartus project with identical constraints and report ALM/register/RAM/DSP/timing deltas versus the clean reference.
- Program the newly built monitor-enhanced SOFs on the DE10-Standard and archive programmer logs plus observed outputs. Existing physical-board evidence refers to the previously built SOFs and must not be represented as physical validation of this new monitor.
- Report monitor latency separately for arithmetic samples, address checks, and control checks.

## Literature positioning

The design is a small, reference-assisted functional monitor. It should be compared with (not claimed to supersede) runtime assertion/statistical monitoring such as SIMCom, FPGA runtime detection approaches such as CADEFT, formal RTL Trojan-detection methods, and side-channel approaches such as UniGuard. Those works use different threat models and evidence; numerical results are not directly comparable without matched workloads and platforms.

- SIMCom: https://arxiv.org/abs/1901.07299
- CADEFT: https://arxiv.org/abs/2005.07332
- Design for Assurance / functional verification tools: https://arxiv.org/abs/2311.12321
- UniGuard: https://arxiv.org/abs/2311.16684

## Current measured status

The monitor-enhanced RTL passed the canonical 60-case GitHub Actions regression (10 healthy + 50 controlled Trojan rows). The run recorded TP=50, TN=10, FP=0, FN=0 and 50/50 correct coarse regional codes. The dedicated monitor unit test also passes healthy, T1/T2/T3 arithmetic signatures, address fault, control fault, and reset/re-arm checks.

For context, the 95% Wilson score intervals for this small sample are approximately 92.9–100% for TPR (50/50) and 0–27.8% for FPR (0/10). The point estimates are conditional on these selected controlled cases; the interval width shows why zero observed false alarms in ten healthy workloads does not establish a low population-wide FPR.

| Variant | Monitor detection latency | Time at 50 MHz | Region code |
|---|---:|---:|---:|
| T1 | 149,137 cycles | 2.98274 ms | 01 |
| T2 | 149,137 cycles | 2.98274 ms | 10 |
| T3 | 149,137 cycles | 2.98274 ms | 11 |
| T4 | 149,135 cycles | 2.98270 ms | 11 |
| T5 | 149,136 cycles | 2.98272 ms | 11 |

These latencies are from the monitor-facing simulation ledger and are measured from the runner's recorded inference-start reference.

**Still pending:** rerun the 300-row held-out campaign against the monitor-enhanced RTL; synthesize all variants with the monitor using identical Quartus constraints and record resource/timing deltas; rebuild and program monitor-enhanced SOFs on the DE10-Standard; archive new physical evidence. The older held-out results, Quartus tables, and physical observations belong to the pre-monitor revision and are not evidence for this new monitor.

Do not claim universal Trojan detection, arbitrary unknown-Trojan coverage, current monitor hardware overhead, or physical validation of the monitor-enhanced revision until those additional experiments are complete.
