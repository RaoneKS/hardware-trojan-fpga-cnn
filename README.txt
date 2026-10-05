FULL TRAINED MNIST CNN FPGA INFERENCE
========================================

Target:
  Terasic DE10-Standard / Cyclone V 5CSXFC6D6F31I7
  50 MHz clock

What this version does:
  Image -> Conv1 -> ReLU -> Pool1 -> Conv2 -> ReLU -> Pool2 -> FC -> Argmax
  The datapath uses one MAC per clock for convolution/FC stages.
  Intermediate feature maps are stored in on-chip FPGA memories.
  The input is data/mnist_image0_int8.mem.
  The quantized weights/biases are loaded from data/int8/.

IMPORTANT:
  This is a true hardware-computed end-to-end datapath, unlike the earlier
  monolithic one-clock behavioral reference. It does not read precomputed
  Pool1/Conv2/Pool2/FC intermediate report files.

Expected result for the included MNIST image:
  predicted class = 7

Files to copy:
  rtl/cnn_fpga_top.v
  rtl/cnn_mnist_full_pe.v
  tb/tb_cnn_fpga_top.v
  quartus/cnn_baseline.qsf
  quartus/cnn_baseline.sdc

Keep these existing directories/files in the project:
  data/mnist_image0_int8.mem
  data/int8/conv1_weight.mem
  data/int8/conv1_bias.mem
  data/int8/conv2_weight.mem
  data/int8/conv2_bias.mem
  data/int8/fc1_weight.mem
  data/int8/fc1_bias.mem

The Verilog $readmemh paths are relative to the Quartus project directory.

SIMULATION (from ~/DE10_Project/cnn_baseline):
  iverilog -g2012 -o full_cnn_tb tb/tb_cnn_fpga_top.v rtl/cnn_fpga_top.v rtl/cnn_mnist_full_pe.v
  vvp full_cnn_tb

SYNTHESIS:
  cd ~/DE10_Project/cnn_baseline/quartus
  rm -rf db incremental_db output_files
  /home/raone/intelFPGA/25.1lite/quartus/bin/quartus_sh --flow compile cnn_baseline

PROGRAM:
  /home/raone/intelFPGA/25.1lite/quartus/bin/jtagconfig
  /home/raone/intelFPGA/25.1lite/quartus/bin/quartus_pgm \
    -c "DE-SoC [3-1]" \
    -m jtag \
    -o "p;output_files/cnn_baseline.sof@2"

HARDWARE:
  KEY0 is active-low reset.
  Release KEY0 to start one inference.
  LEDR[3:0] shows the predicted digit in binary.
  LEDR[4] = valid/done.
  LEDR[5] = done indicator.
  For expected class 7, LEDR[3:0] = 0111.

WARNING:
  First compile may take longer than the small PE baseline because this design
  contains on-chip intermediate memories and a serial MAC controller.
  The design is intentionally much smaller than the previous monolithic
  nested-loop design and should be the version to try for actual FPGA inference.

QUANTIZATION NOTE:
  The included trained model uses the project's existing integer quantization
  convention. The reference for this exact image should be generated from the
  same mem files. Do not claim overall MNIST accuracy from this single-image
  hardware test; first validate additional images or a test-set harness.
