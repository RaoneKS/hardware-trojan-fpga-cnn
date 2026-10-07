# Reproducibility Guide

## Environment
- Ubuntu 26.04.1 LTS
- Quartus Prime Lite 25.1
- Icarus Verilog 12.0
- Target: Terasic DE10-Standard
- FPGA: Cyclone V SoC 5CSXFC6D6F31C6
- Experiment clock: 50 MHz

## Simulation
From the repository root:

```bash
cd ~/hardware-trojan-fpga-cnn
bash verification/run_full_matrix.sh
```

Then inspect:

```bash
wc -l verification/results/runs.csv
cat verification/results/hardware_resources.csv
```

The canonical ledger should contain 61 lines including the header.

## Quartus
The corrected C6 rebuild script is:

```bash
cd ~/hardware-trojan-fpga-cnn
bash scripts/rebuild_c6_quartus.sh
```

Review generated Quartus fitter/STA reports before changing `hardware_resources.csv`.

## Physical programming
For a validated Trojan bitstream:

```bash
cd ~/hardware-trojan-fpga-cnn/trojan_T3
./scripts/program_de10_autodetect.sh
```

Equivalent directories exist for T4 and T5.

## Evidence discipline
Do not replace missing measurements with estimates. In particular:
- do not infer T3–T5 fitter counts;
- do not call Quartus power estimates physical power;
- do not claim code 11 distinguishes T3/T4/T5;
- do not claim the 60-row simulation is 60 physical measurements.
