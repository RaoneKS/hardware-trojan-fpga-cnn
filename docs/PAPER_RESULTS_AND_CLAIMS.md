## Single Source of Truth
This document defines the strict scientific boundary between empirical verified evidence and planned future work.

### Claim Rules
Never convert a planned metric into an empirical result without real execution. The manuscript distinguishes:
1. **Physical hardware evidence:** Board-level programming and LED observations on DE10-Standard.
2. **Simulation evidence:** Cycle-accurate bit-true Verilog simulation across multi-workload test matrices.
3. **Statistical evidence:** Metrics calculated directly from the empirical repeated-run ledger (`runs.csv`).
4. **Tool estimation evidence:** Power dissipation derived from Intel Quartus Prime Lite Power Analyzer thermal models.
5. **Literature evidence:** Published values from verified sources, never mixed with project measurements.

---

## 1. Validated Empirical Results (Submission Ready)

### A. Algorithmic and Quantization Baseline
- **Model Architecture**: LeNet-style CNN for MNIST (Conv1 1->8 3x3, MaxPool1 2x2, Conv2 8->16 3x3, MaxPool2 2x2, FC 784->10).
- **Software Accuracy**: FP32 reference accuracy = 98.41% on MNIST test set.
- **Quantization**: INT8 bit-true quantized parameters and bit-true Python reference (`check_full_int8_reference_fixed.py`).

### B. Synthesizable FPGA Accelerator Implementations (Cyclone V 5CSXFC6D6F31)
- **Healthy Baseline**:
  - 1,145 ALMs (3% of device), 889 registers, 455,104 block memory bits (71 M10K blocks), 13 DSP blocks.
  - Worst setup slack: +2.669 ns at Slow -40C; +3.290 ns at Slow 100C.
  - Thermal power dissipation (Quartus Power Analyzer): 463.79 mW total (40.65 mW dynamic, 412.18 mW static).
- **Trojan Variants & Detector Overhead**:
  - **T1 (PE MAC Product Inversion)**: 1,167 ALMs (+1.92%), 924 regs (+3.94%), 13 DSPs (+0.0%), 465.51 mW (+0.37%).
  - **T2 (Weight Memory Alteration)**: 1,190 ALMs (+3.93%), 915 regs (+2.92%), 15 DSPs (+15.38%), 466.28 mW (+0.54%).
  - **T3 (Interconnect Feature Bus Alteration)**: 1,195 ALMs (+4.37%), 924 regs (+3.94%), 15 DSPs (+15.38%), 467.17 mW (+0.73%).
  - **T4 (Spatial Routing Alteration)**: 1,218 ALMs (+6.38%), 902 regs (+1.46%), 13 DSPs (+0.0%), 464.75 mW (+0.21%).
  - **T5 (Control-Path Pipeline Stall)**: 1,151 ALMs (+0.52%), 918 regs (+3.26%), 13 DSPs (+0.0%), 464.27 mW (+0.10%).

### C. Detection and Statistical Security Metrics
- **Dataset**: 60 empirical simulation runs across 10 distinct MNIST digit classes (0 to 9) and 6 architectures (Healthy, T1–T5).
- **True Positives (TP)**: 50
- **True Negatives (TN)**: 10
- **False Positives (FP)**: 0
- **False Negatives (FN)**: 0
- **TPR (Sensitivity / Recall)**: 100.0%
- **FPR (Fall-out)**: 0.0%
- **Precision**: 100.0%
- **F1 Score**: 1.0000
- **Localization Accuracy**: 100.0% (50/50 correct attribution: 10/10 for 01, 10/10 for 10, 30/30 for 11).

### D. Timing and Latency
- **Inference Latency**: 634,281 cycles (Healthy, T1–T4); 634,282 cycles (T5, +1 stall cycle).
- **Detection Cycle**: Cycle 149,144 (T1–T4); Cycle 149,143 (T5).
- **Detection Latency**: 149,136 cycles (T1–T4); 149,135 cycles (T5), equal to 2.98272 ms and 2.98270 ms at 50 MHz.

### E. Physical Hardware Validation Status
- **Healthy Baseline**: Programmed and physically observed on DE10-Standard (Predicted class 7 on LEDR[2:0] = 111).
- **T1 Hardware Trojan**: Programmed and physically validated on DE10-Standard (LEDR[3] asserted, localization 01 observed).
- **T2 Hardware Trojan**: Programmed and physically validated on DE10-Standard (LEDR[3] asserted, localization 10 observed).
- **T3, T4, T5 Bitstreams**: Clean Quartus SOFs compiled and verified with automated JTAG programmer detection script (`program_de10_autodetect.sh`).

---

## 2. Pending Work (Explicit Non-Claims)
1. **Physical Visual LED Confirmation for T3, T4, T5**: Although bitstreams compile cleanly and JTAG chain configuration succeeds without errors, physical visual confirmation of LEDs by human inspection is pending until hands-on board access.
2. **Physical Multimeter Power Measurements**: Real benchtop multimeter current measurements have not been performed; all power values in the paper must be clearly designated as **Quartus Power Analyzer thermal estimation models**.

