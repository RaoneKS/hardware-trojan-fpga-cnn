# Physical DE10-Standard Board Validation — T3/T4/T5

Validation date: 2026-10-07  
Board: Terasic DE10-Standard  
FPGA: Cyclone V SoC 5CSXFC6D6F31C6  
JTAG chain: DE-SoC [3-2]  
FPGA JTAG ID: 02D020DD  
Programming device index: @2

## T3

- Bitstream: `trojan_T3/cnn_full_small.sof`
- SOF checksum: `0x022CD4EE`
- Quartus Programmer result: Configuration succeeded
- Programming errors: 0
- Programming warnings: 0
- LEDR0: ON
- LEDR1: ON
- LEDR2: ON
- LEDR3: ON
- LEDR4: ON
- LEDR5: ON

Interpretation:
- `LEDR[2:0] = 111` → predicted class 7
- `LEDR3 = 1` → detector asserted
- `LEDR[5:4] = 11` → regional localization code 11

## T4

- Bitstream: `trojan_T4/cnn_full_small.sof`
- SOF checksum: `0x022B88DC`
- Quartus Programmer result: Configuration succeeded
- Programming errors: 0
- Programming warnings: 0
- LEDR0: ON
- LEDR1: ON
- LEDR2: ON
- LEDR3: ON
- LEDR4: ON
- LEDR5: ON

Interpretation:
- `LEDR[2:0] = 111` → predicted class 7
- `LEDR3 = 1` → detector asserted
- `LEDR[5:4] = 11` → regional localization code 11

## T5

- Bitstream: `trojan_T5/cnn_full_small.sof`
- SOF checksum: `0x022990E2`
- Quartus Programmer result: Configuration succeeded
- Programming errors: 0
- Programming warnings: 0
- LEDR0: ON
- LEDR1: ON
- LEDR2: ON
- LEDR3: ON
- LEDR4: ON
- LEDR5: ON

Interpretation:
- `LEDR[2:0] = 111` → predicted class 7
- `LEDR3 = 1` → detector asserted
- `LEDR[5:4] = 11` → regional localization code 11

## Evidence boundary

These are direct board-output observations recorded during manual DE10-Standard validation. They establish physical output behavior for the selected T3/T4/T5 bitstreams.

They do not constitute physical power/current measurements. They also do not imply that localization code `11` can distinguish T3 from T4 or T5; all three share the same regional code by design.
