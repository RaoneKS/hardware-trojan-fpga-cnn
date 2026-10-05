#!/usr/bin/env bash

set -u

PROJECT="$HOME/DE10_Project/cnn_baseline"
cd "$PROJECT" || exit 1

echo "============================================================"
echo " HARDWARE TROJAN PROJECT - HEALTHY BASELINE AUTOMATION"
echo "============================================================"
echo

# ------------------------------------------------------------
# 0. Environment
# ------------------------------------------------------------
echo "[0/8] Checking environment..."

if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
fi

PYTHON="python3"

echo "Project : $PROJECT"
echo "Python  : $($PYTHON --version 2>&1)"
echo "Icarus  : $(iverilog -V 2>&1 | head -1 || true)"
echo

mkdir -p reports
mkdir -p /tmp/cnn_baseline_tests

# ------------------------------------------------------------
# 1. Check required files
# ------------------------------------------------------------
echo "============================================================"
echo "[1/8] Checking project files"
echo "============================================================"

required_files=(
    "rtl/cnn_pe_mac.v"
    "rtl/cnn_conv3x3_pe.v"
    "rtl/cnn_conv1_8filter_pe.v"
    "rtl/cnn_conv1_image_8filter_pe.v"
    "rtl/cnn_pool1_relu_maxpool_pe.v"
    "rtl/cnn_conv2_pe.v"
    "rtl/cnn_pool2_pe.v"
    "rtl/cnn_fc_pe.v"
    "tb/tb_cnn_pe_mac.v"
    "tb/tb_cnn_pool1_relu_maxpool_pe.v"
    "tb/tb_cnn_pool2_pe.v"
    "quartus/cnn_baseline.qpf"
    "quartus/cnn_baseline.qsf"
    "quartus/cnn_baseline.sdc"
)

missing=0

for f in "${required_files[@]}"; do
    if [ -f "$f" ]; then
        echo "OK      $f"
    else
        echo "MISSING $f"
        missing=$((missing+1))
    fi
done

if [ "$missing" -ne 0 ]; then
    echo
    echo "ERROR: $missing required files are missing."
    echo "Fix the missing files before continuing."
    exit 1
fi

# ------------------------------------------------------------
# 2. PE MAC verification
# ------------------------------------------------------------
echo
echo "============================================================"
echo "[2/8] Verifying PE MAC"
echo "============================================================"

iverilog -g2012 -Wall \
    -o /tmp/cnn_tb_pe_mac \
    rtl/cnn_pe_mac.v \
    tb/tb_cnn_pe_mac.v

if [ $? -ne 0 ]; then
    echo "ERROR: PE MAC compilation failed."
    exit 1
fi

vvp /tmp/cnn_tb_pe_mac | tee reports/pe_mac_test.txt

# ------------------------------------------------------------
# 3. Pool1 verification
# ------------------------------------------------------------
echo
echo "============================================================"
echo "[3/8] Verifying Pool1"
echo "============================================================"

iverilog -g2012 -Wall \
    -o /tmp/cnn_tb_pool1 \
    rtl/cnn_pool1_relu_maxpool_pe.v \
    tb/tb_cnn_pool1_relu_maxpool_pe.v

if [ $? -ne 0 ]; then
    echo "ERROR: Pool1 compilation failed."
    exit 1
fi

vvp /tmp/cnn_tb_pool1 | tee reports/pool1_test.txt

echo
echo "Pool1 RTL output count:"
if [ -f reports/rtl_pool1_results.txt ]; then
    wc -l reports/rtl_pool1_results.txt
else
    echo "WARNING: reports/rtl_pool1_results.txt was not generated."
fi

if [ -f scripts/compare_pool1.py ]; then
    echo
    echo "Running Python vs RTL Pool1 comparison..."
    $PYTHON scripts/compare_pool1.py | tee reports/pool1_compare.txt
else
    echo "WARNING: compare_pool1.py not found."
fi

# ------------------------------------------------------------
# 4. Conv1 verification
# ------------------------------------------------------------
echo
echo "============================================================"
echo "[4/8] Verifying Conv1"
echo "============================================================"

if [ -f rtl/cnn_conv1_image_8filter_pe.v ] && \
   [ -f tb/tb_cnn_conv1_image_8filter_pe.v ]; then

    iverilog -g2012 -Wall \
        -o /tmp/cnn_tb_conv1 \
        rtl/cnn_conv1_image_8filter_pe.v \
        tb/tb_cnn_conv1_image_8filter_pe.v

    if [ $? -ne 0 ]; then
        echo "ERROR: Conv1 compilation failed."
        exit 1
    fi

    vvp /tmp/cnn_tb_conv1 | tee reports/conv1_test.txt

    if [ -f scripts/compare_conv1_pe.py ]; then
        echo
        echo "Running Python vs RTL Conv1 comparison..."
        $PYTHON scripts/compare_conv1_pe.py | tee reports/conv1_compare.txt
    fi

else
    echo "WARNING: Conv1 image PE files unavailable."
fi

# ------------------------------------------------------------
# 5. Conv2 verification
# ------------------------------------------------------------
echo
echo "============================================================"
echo "[5/8] Verifying Conv2"
echo "============================================================"

if [ -f rtl/cnn_conv2_pe.v ] && \
   [ -f tb/tb_cnn_conv2_pe.v ]; then

    iverilog -g2012 -Wall \
        -o /tmp/cnn_tb_conv2 \
        rtl/cnn_conv2_pe.v \
        tb/tb_cnn_conv2_pe.v

    if [ $? -ne 0 ]; then
        echo "ERROR: Conv2 compilation failed."
        exit 1
    fi

    vvp /tmp/cnn_tb_conv2 | tee reports/conv2_test.txt

    if [ -f scripts/compare_conv2.py ]; then
        echo
        echo "Running Python vs RTL Conv2 comparison..."
        $PYTHON scripts/compare_conv2.py | tee reports/conv2_compare.txt
    fi

else
    echo "WARNING: Conv2 files unavailable."
fi

# ------------------------------------------------------------
# 6. Pool2 verification
# ------------------------------------------------------------
echo
echo "============================================================"
echo "[6/8] Verifying Pool2"
echo "============================================================"

if [ -f rtl/cnn_pool2_pe.v ] && \
   [ -f tb/tb_cnn_pool2_pe.v ]; then

    iverilog -g2012 -Wall \
        -o /tmp/cnn_tb_pool2 \
        rtl/cnn_pool2_pe.v \
        tb/tb_cnn_pool2_pe.v

    if [ $? -ne 0 ]; then
        echo "ERROR: Pool2 compilation failed."
        exit 1
    fi

    vvp /tmp/cnn_tb_pool2 | tee reports/pool2_test.txt

    if [ -f scripts/compare_pool2.py ]; then
        echo
        echo "Running Python vs RTL Pool2 comparison..."
        $PYTHON scripts/compare_pool2.py | tee reports/pool2_compare.txt
    fi

else
    echo "WARNING: Pool2 files unavailable."
fi

# ------------------------------------------------------------
# 7. FC verification
# ------------------------------------------------------------
echo
echo "============================================================"
echo "[7/8] Verifying FC"
echo "============================================================"

if [ -f rtl/cnn_fc_pe.v ] && \
   [ -f tb/tb_cnn_fc_pe.v ]; then

    iverilog -g2012 -Wall \
        -o /tmp/cnn_tb_fc \
        rtl/cnn_fc_pe.v \
        tb/tb_cnn_fc_pe.v

    if [ $? -ne 0 ]; then
        echo "ERROR: FC compilation failed."
        exit 1
    fi

    vvp /tmp/cnn_tb_fc | tee reports/fc_test.txt

else
    echo "WARNING: FC testbench not found."
fi

# ------------------------------------------------------------
# 8. Check complete intermediate data chain
# ------------------------------------------------------------
echo
echo "============================================================"
echo "[8/8] Checking healthy CNN data chain"
echo "============================================================"

echo
echo "Expected intermediate files:"
echo

chain_files=(
    "data/int8/conv1_weight.mem"
    "data/int8/conv1_bias.mem"
    "data/int8/conv2_weight.mem"
    "data/int8/conv2_bias.mem"
    "data/int8/fc1_weight.mem"
    "data/int8/fc1_bias.mem"
    "data/mnist_image0_int8.mem"
    "reports/conv1_pool_input.mem"
    "reports/pool1_conv2_input.mem"
    "reports/conv2_pool2_input.mem"
    "reports/pool2_fc_input.mem"
)

for f in "${chain_files[@]}"; do
    if [ -f "$f" ]; then
        printf "OK      %-45s " "$f"
        wc -l < "$f"
    else
        echo "MISSING $f"
    fi
done

echo
echo "============================================================"
echo " INTERMEDIATE RESULT COUNTS"
echo "============================================================"

for f in \
    reports/rtl_conv1_pe_results.txt \
    reports/rtl_pool1_results.txt \
    reports/rtl_conv2_results.txt \
    reports/rtl_pool2_results.txt \
    reports/rtl_fc_results.txt
do
    if [ -f "$f" ]; then
        printf "%-45s " "$f"
        wc -l < "$f"
    fi
done

# ------------------------------------------------------------
# Generate healthy baseline summary
# ------------------------------------------------------------
echo
echo "============================================================"
echo " GENERATING HEALTHY BASELINE SUMMARY"
echo "============================================================"

{
    echo "============================================================"
    echo "HEALTHY FPGA-CNN BASELINE"
    echo "============================================================"
    echo
    echo "Project: Hardware Trojan Detection in FPGA-CNN Accelerators"
    echo "Target: Terasic DE10-Standard / Cyclone V"
    echo "CNN: MNIST CNN"
    echo "Current phase: Objective 1 - Healthy Baseline"
    echo
    echo "Architecture:"
    echo "  Input       : 28x28 grayscale MNIST"
    echo "  Conv1       : 1 -> 8 channels, 3x3"
    echo "  Pool1       : 2x2"
    echo "  Conv2       : 8 -> 16 channels, 3x3"
    echo "  Pool2       : 2x2"
    echo "  FC          : 784 -> 10"
    echo
    echo "Verified stages:"
    echo "  PE MAC      : see reports/pe_mac_test.txt"
    echo "  Conv1       : see reports/conv1_compare.txt"
    echo "  Pool1       : see reports/pool1_compare.txt"
    echo "  Conv2       : see reports/conv2_compare.txt"
    echo "  Pool2       : see reports/pool2_compare.txt"
    echo "  FC          : see reports/fc_test.txt"
    echo
    echo "Intermediate data:"
    for f in \
        reports/conv1_pool_input.mem \
        reports/pool1_conv2_input.mem \
        reports/conv2_pool2_input.mem \
        reports/pool2_fc_input.mem
    do
        if [ -f "$f" ]; then
            echo "  $f : $(wc -l < "$f") values"
        fi
    done
    echo
    echo "IMPORTANT:"
    echo "  Trojan injection has NOT been performed."
    echo "  Final integrated synthesizable CNN datapath is still required."
    echo "  Final FPGA timing/power/resource measurements must be"
    echo "  collected after the integrated top-level is synthesized."
    echo
    echo "============================================================"
} | tee reports/HEALTHY_BASELINE_AUTOMATED.txt

echo
echo "============================================================"
echo " AUTOMATION FINISHED"
echo "============================================================"
echo
echo "Reports are in:"
echo "  $PROJECT/reports/"
echo
echo "Next engineering task:"
echo "  Build the final integrated synthesizable healthy CNN top."
echo
echo "DO NOT inject the Trojan yet."
echo
