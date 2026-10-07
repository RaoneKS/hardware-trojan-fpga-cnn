# Physical DE10-Standard Validation Rerun — 2026-10-08

## Board and JTAG

- Board: Terasic DE10-Standard
- FPGA: Cyclone V SoC 5CSXFC6D6F31C6
- JTAG cable: DE-SoC [3-2]
- FPGA JTAG ID: 0x02D020DD
- Programming device index: @2
- Quartus Programmer: Prime 25.1std.0 Build 1129

## T3

- SOF: `trojan_T3/cnn_full_small.sof`
- SOF checksum: `0x022CD4EE`
- Configuration: SUCCESS
- Programmer errors: 0
- Programmer warnings: 0
- Physical LEDs observed:
  - LEDR0: ON
  - LEDR1: ON
  - LEDR2: ON
  - LEDR3: ON
  - LEDR4: ON
  - LEDR5: ON
- Interpretation:
  - LEDR[2:0] = `111` → predicted class 7
  - LEDR3 = `1` → Trojan detector asserted
  - LEDR[5:4] = `11` → shared T3/T4/T5 regional localization

Programmer log:
`verification/results/physical_T3_program.log`

## T4

- SOF: `trojan_T4/cnn_full_small.sof`
- SOF checksum: `0x022B88DC`
- Configuration: SUCCESS
- Programmer errors: 0
- Programmer warnings: 0
- Physical LEDs observed:
  - LEDR0: ON
  - LEDR1: ON
  - LEDR2: ON
  - LEDR3: ON
  - LEDR4: ON
  - LEDR5: ON
- Interpretation:
  - LEDR[2:0] = `111` → predicted class 7
  - LEDR3 = `1` → Trojan detector asserted
  - LEDR[5:4] = `11` → shared T3/T4/T5 regional localization

Programmer log:
`verification/results/physical_T4_program.log`

## T5

- SOF: `trojan_T5/cnn_full_small.sof`
- SOF checksum: `0x022990E2`
- Configuration: SUCCESS
- Programmer errors: 0
- Programmer warnings: 0
- Physical LEDs observed:
  - LEDR0: ON
  - LEDR1: ON
  - LEDR2: ON
  - LEDR3: ON
  - LEDR4: ON
  - LEDR5: ON
- Interpretation:
  - LEDR[2:0] = `111` → predicted class 7
  - LEDR3 = `1` → Trojan detector asserted
  - LEDR[5:4] = `11` → shared T3/T4/T5 regional localization

Programmer log:
`verification/results/physical_T5_program.log`

## Evidence boundary

These observations demonstrate physical programming and LED-level output behavior for T3, T4, and T5 on the DE10-Standard.

The localization code `11` is shared by T3/T4/T5 and therefore does not uniquely distinguish those three variants.

No physical rail/current/power measurement is claimed.
