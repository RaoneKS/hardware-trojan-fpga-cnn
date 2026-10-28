# Quartus Validation — Three-Bit Branch (2026-10-28)

Quartus Prime Lite 25.1; DE10-Standard / Cyclone V target; clock target 50 MHz.

| Target | Full compilation | Errors | Warnings | Fmax slow 85C (MHz) | Fmax slow 0C (MHz) |
|---|---|---:|---:|---:|---:|
| Healthy | Successful | 0 | 35 | 64.99 | 64.25 |
| T1 | Successful | 0 | 34 | 60.71 | 61.24 |
| T2 | Successful | 0 | 34 | 59.79 | 62.93 |
| T3 | Successful | 0 | 33 | 68.06 | 67.24 |
| T4 | Successful | 0 | 35 | 63.48 | 65.87 |
| T5 | Successful | 0 | 34 | 60.45 | 64.30 |

All six builds completed with zero failed compile commands. All listed Fmax values exceed 50 MHz. These are Quartus report-derived values, not oscilloscope measurements. The final report audit recorded zero unconstrained clocks, input ports, input paths, output ports and output paths. The localization output delay of 0.0 ns is a provisional external-I/O assumption, not a measured LED timing specification.

Localization output pins: bit 0 -> PIN_AG25 / LEDR4; bit 1 -> PIN_AF25 / LEDR5; bit 2 -> PIN_AE24 / LEDR6. Constant-zero output bits naturally produce stuck-at-GND warnings for fixed variant codes. T5 also reports an unused t2_trigger signal; this is a cleanup item, not evidence of a functional failure.

The full current raw report bundle and SOF binaries remain on the project workstation; this summary does not include a complete final six-target fitter-resource table. Physical rail/current power was not measured.
