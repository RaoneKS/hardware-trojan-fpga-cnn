# Power and Activity Measurement Protocol

## 1. Scientific Integrity Boundary
- **Simulation Activity Proxy vs. Physical Power**: Signal toggle counts extracted from Value Change Dump (`.vcd`) files represent simulation switching activity proxies. They reflect theoretical gate-level signal transition counts under a specific simulator stimulus, **not** physical electric current, thermal dissipation, or physical milliwatts.
- **Quartus Power Analyzer**: Power values reported below are derived from Intel Quartus Prime Lite Edition Power Analyzer models for the Cyclone V 5CSXFC6D6F31C6 FPGA under vectorless activity estimation (50 MHz clock).
- **Physical Instrumentation**: Any physical power values must be measured directly from the board power supplies using physical multimeters or current sense resistors.

---

## 2. Quartus Power Analyzer Estimates

Operating conditions reported by the project: 50 MHz, VCCINT = 1.1 V, Cyclone V thermal model.

These values are **tool estimates**, not direct measurements from the DE10-Standard power rails.

| Implementation | Core Dynamic Power (mW) | Core Static Power (mW) | I/O Power (mW) | Total Thermal Power (mW) | Overhead vs. Healthy |
|---|---:|---:|---:|---:|---:|
| Healthy Baseline | 40.65 | 412.18 | 10.97 | 463.79 | Baseline |
| T1 | 41.88 | 412.19 | 11.44 | 465.51 | +1.72 mW (+0.37%) |
| T2 | 42.66 | 412.19 | 11.43 | 466.28 | +2.49 mW (+0.54%) |
| T3 | 43.09 | 412.20 | 11.88 | 467.17 | +3.38 mW (+0.73%) |
| T4 | 40.69 | 412.18 | 11.88 | 464.75 | +0.96 mW (+0.21%) |
| T5 | 40.21 | 412.18 | 11.88 | 464.27 | +0.48 mW (+0.10%) |

**Evidence boundary:** the power table is independent of the canonical resource ledger. Do not infer ALM/register/RAM/DSP counts for T3–T5 from this table; those exact final fitter counts are not archived in the canonical resource CSV.

## 3. Physical Hardware Power Measurement Protocol (DE10-Standard)

When physical benchtop instruments are available, execute the following protocol to measure physical electric power:

### Equipment Required
1. Keysight/Rigol Digital Multimeter (6.5 digit precision) or DC Power Analyzer.
2. In-line current shunt resistor (e.g., $0.05\,\Omega$, 1% precision) inserted in series with the 5V DC barrel jack input or the FPGA core voltage test points.
3. Oscilloscope with current probe (Tektronix TCP0030A or similar) for transient dynamic power profiling.

### Measurement Procedure
1. **Power Supply Idle Baseline**:
   - Power on the DE10-Standard board without configuring the FPGA.
   - Record DC voltage $V_{\text{in}}$ and idle current $I_{\text{idle}}$.
2. **Healthy CNN Active Measurement**:
   - Program `cnn_full_small/cnn_full_small.sof` using `scripts/program_de10_autodetect.sh`.
   - Trigger repeated CNN inferences by pulsing `KEY[0]`.
   - Record average current $I_{\text{healthy}}$ and peak current $I_{\text{peak,healthy}}$.
   - Compute total electrical power: $P_{\text{healthy}} = V_{\text{in}} \times I_{\text{healthy}}$.
3. **Trojan Configurations (T1–T5)**:
   - For each Trojan variant ($T \in \{T_1, T_2, T_3, T_4, T_5\}$), program `trojan_T$T/cnn_full_small.sof`.
   - Trigger inference and measure active current $I_{T}$.
   - Compute electrical power: $P_{T} = V_{\text{in}} \times I_{T}$.
   - Compute measured hardware power differential: $\Delta P = P_{T} - P_{\text{healthy}}$.
4. **Recording**: Record all measured values in `verification/results/physical_power_ledger.csv`.
