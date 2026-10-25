# Independent Runtime Monitor — Prototype

## Why this exists

The current controlled Trojan variants expose Trojan-specific activation flags. Those flags are useful as experiment ground truth, but they are not an independent detector. This prototype adds a separate comparator module that raises a sticky alarm from trusted-reference versus observed-signal mismatches. It does not consume the Trojan activation flags.

## Region codes

| Code | Check | Meaning |
|---|---|---|
| 000 | No mismatch observed | No alarm during checked events; not proof that the design is Trojan-free |
| 001 | Expected product vs. observed product | Arithmetic/PE result anomaly |
| 010 | Trusted weight vs. weight actually consumed | Weight/data-path anomaly |
| 011 | Trusted feature vs. feature actually consumed | Feature-data/interconnect anomaly |
| 100 | Expected address vs. observed address | Address/routing anomaly |
| 101 | Expected FSM state vs. observed state | Control/FSM anomaly |

The first mismatch is latched until reset. The priority order is arithmetic, weight, feature, address, then control if multiple checks mismatch on the same clock. A production design may instead latch a multi-bit syndrome so simultaneous faults are not hidden.

## Critical trust assumption

The monitor only has value if expected/trusted signals are generated independently of the signals being checked. Looping a DUT signal into both sides, or using Trojan-specific activation flags, is not detection. A credible integration should use:
- a separately computed reference product for the selected Conv2 operation;
- a trusted weight value before any suspect modification;
- a trusted feature value from an independently checked source;
- a reference address derived from the CNN loop counters, compared with the address actually consumed by the RAM;
- an independent transition checker / watchdog for the controller.

This prototype is a monitor primitive, not yet a claim of integrated end-to-end independent detection. The next engineering step is to connect the five trusted/observed pairs to the CNN core, add fault injection tests, and rerun the full regression.

## Unit test

From the repository root, run:

    iverilog -g2012 -o /tmp/monitor_tb verification/independent_monitor/independent_runtime_monitor.v verification/independent_monitor/tb_independent_runtime_monitor.v
    vvp /tmp/monitor_tb

The testbench checks a healthy event, each of the five mismatch classes, sticky-alarm behaviour, and reset. The unit test validates the comparator primitive only; it does not validate integration into the CNN core.

## Evaluation needed before claiming detection performance

1. Integrate the monitor into a clean baseline and each Trojan variant.
2. Use monitor outputs—not Trojan self-flags—as the detector result.
3. Preserve Trojan self-flags only as hidden ground truth for scoring.
4. Test all ten canonical workloads and the held-out workload set.
5. Add benign perturbations and non-triggering cases to estimate false positives.
6. Run mutations that the monitor was not explicitly designed for to evaluate generalization.
7. Rebuild each target with identical Quartus settings; report ALMs, registers, RAM, DSP, setup/hold slack, Fmax where archived, and estimated power separately from measured power.
8. Compare the original detector against the independent monitor in an ablation table.

## Scope boundary

This module is a starting point for a more defensible monitor. It does not detect arbitrary unknown Trojans, and its results must not be reported as project-level TPR/FPR until integration and end-to-end experiments are complete.
