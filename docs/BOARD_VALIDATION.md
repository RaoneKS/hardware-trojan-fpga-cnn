# DE10-Standard Hardware Validation Runbook

Use this runbook after the T3/T4/T5 SOFs have been built locally.

## Preconditions

- Quartus Prime Lite 25.1 installed.
- DE10-Standard connected by USB-Blaster.
- JTAG cable appears as a `DE-SoC [n]` cable.
- FPGA JTAG ID is `02D020DD` at index 2.
- Do not report a Trojan as hardware-validated until its detector/localization LEDs are observed.

## Build T3-T5

From the repository root:

```bash
./verification/build_quartus_t3_t5.sh
```

Expected result: T3, T4 and T5 each finish with 0 Quartus errors and a `cnn_full_small.sof`.

## Program each design

Run from the corresponding Trojan directory:

```bash
./scripts/program_de10_autodetect.sh
```

The script validates the DE-SoC cable and FPGA ID before programming JTAG device @2.

## LED interpretation

- LEDR[2:0] = predicted CNN class (for the reference image, expected `111` = class 7).
- LEDR[3] = runtime Trojan detector.
- localization_code[1:0] is exposed on the two localization LEDs:
  - `01` = T1 / Conv2 PE computation region
  - `10` = T2 / Conv2 weight-memory region
  - `11` = T3/T4/T5 / Conv2 interconnect/control region

## Required observations

For each T3/T4/T5 run record:

1. predicted class
2. detector LED state
3. localization LED state
4. SOF checksum (optional but recommended)
5. Quartus resource/timing report
6. any functional anomaly

Do not replace missing observations with assumptions.

## Paper update boundary

After the board run, update `docs/PAPER_RESULTS.md` and `docs/SUBMISSION_CHECKLIST.md` with the measured hardware evidence.

Only then can T3/T4/T5 be marked physically validated.
