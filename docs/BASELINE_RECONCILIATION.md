# Healthy Baseline Reconciliation

## Purpose

The repository contains more than one historical healthy-CNN RTL implementation. The documented paper result cites **346,563 cycles**, while the current source-level regression produces a different cycle count.

## Current source-level regression

The reproducible healthy regression uses:

- cnn_full_small/rtl/cnn_small_core.v
- cnn_full_small/tb/tb_cnn_small_core.v
- cnn_baseline/data/*

On the current branch, this RTL produces:

- predicted class: **7**
- inference cycles: **301,854**
- 50 MHz testbench clock

The result is functional and reproducible, but it must not be substituted for the historical 346,563-cycle claim without identifying the exact RTL/build that produced the historical measurement.

## Historical documented result

The following project documents currently cite **346,563 cycles** for healthy inference:

- README.md
- docs/PAPER_RESULTS.md
- docs/FINAL_RESEARCH_STATUS.md

Those values are retained as historical evidence rather than overwritten.

## Required reconciliation

Before using healthy latency as a quantitative comparison in the final manuscript:

1. Identify the exact healthy RTL/top-level and Quartus revision used for the physical 346,563-cycle observation.
2. Reproduce that build and simulation.
3. Record the exact commit SHA, RTL path, clock constraint, and cycle count.
4. Update the paper ledger only after the result is reproducible.
5. If 346,563 cannot be reproduced from a preserved build, relabel it as a historical observation and use the reproducible current value for new comparisons.

This prevents mixing measurements from different accelerator implementations.

## Scientific boundary

This discrepancy does **not** invalidate the already documented T1-T5 physical board observations. It does mean that healthy-vs-Trojan latency comparisons must use matched implementations before quantitative overhead claims are made.
