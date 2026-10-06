# Power and Activity Measurement Protocol

## 1. Scientific Integrity Boundary
- **Simulation Activity Proxy vs. Physical Power**: Signal toggle counts extracted from Value Change Dump (`.vcd`) files represent simulation switching activity proxies. They reflect theoretical gate-level signal transition counts under a specific simulator stimulus, **not** physical electric current, thermal dissipation, or physical milliwatts.
- **Quartus Power Analyzer**: Power values reported below are derived from Intel Quartus Prime Lite Edition Power Analyzer models for the Cyclone V 5CSXFC6D6F31C6 FPGA under vectorless activity estimation (50 MHz clock).
- **Physical Instrumentation**: Any physical power values must be measured directly from the board power supplies using physical multimeters or current sense resistors.

---

## 2. Quartus Power Analyzer Measurements (Cyclone V 5CSXFC6D6F31)

Operating Conditions: $f = 50.0\text{ MHz}$, $V_{\text{CCINT}} = 1.1\text{ V}$, Industrial/Commercial Temperature Models.

| Implementation | Logic ALMs | Registers | M10K Blocks | DSP Blocks | Core Dynamic Power (mW) | Core Static Power (mW) | I/O Power (mW) | Total Thermal Power (mW) | Power Overhead vs. Healthy |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **Healthy Baseline** | 1,145 | 889 | 71 | 13 | 40.65 | 412.18 | 10.97 | **463.79** | Baseline |
| **Trojan T1 (PE MAC)** | 1,167 | 924 | 71 | 13 | 41.88 | 412.19 | 11.44 | **465.51** | +1.72 mW (+0.37%) |
| **Trojan T2 (Weight RAM)**| 1,190 | 915 | 71 | 15 | 42.66 | 412.19 | 11.43 | **466.28** | +2.49 mW (+0.54%) |
| **Trojan T3 (Interconnect)**| 1,195 | 924 | 71 | 15 | 43.09 | 412.20 | 11.88 | **467.17** | +3.38 mW (+0.73%) |
| **Trojan T4 (Routing)** | 1,218 | 902 | 71 | 13 | 40.69 | 412.18 | 11.88 | **464.75** | +0.96 mW (+0.21%) |
| **Trojan T5 (Control Stall)**| 1,151 | 918 | 71 | 13 | 40.21 | 412.18 | 11.88 | **464.27** | +0.48 mW (+0.10%) |

### Observations
1. **Stealthiness**: Total power dissipation increases by less than **0.75%** across all Trojan and detector configurations relative to the healthy CNN baseline.
2. **Dominance of Static Power**: Core static thermal dissipation (~412.2 mW) dominates Cyclone V power consumption, confirming that side-channel external power analysis alone would struggle to identify these stealthy Trojans without internal architectural monitors.

---

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
