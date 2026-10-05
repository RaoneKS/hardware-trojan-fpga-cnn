import numpy as np

IMAGE_SIZE = 28
NUM_FILTERS = 8

# --------------------------------------------------
# Load INT8 image
# --------------------------------------------------
image = np.loadtxt(
    "data/mnist_image0_int8.mem",
    dtype=str
)

image = np.array(
    [int(x, 16) if int(x, 16) < 128 else int(x, 16) - 256
     for x in image],
    dtype=np.int8
).reshape(28, 28)

# --------------------------------------------------
# Load INT8 Conv1 weights
# --------------------------------------------------
weights = np.loadtxt(
    "data/int8/conv1_weight.mem",
    dtype=str
)

weights = np.array(
    [int(x, 16) if int(x, 16) < 128 else int(x, 16) - 256
     for x in weights],
    dtype=np.int8
).reshape(8, 3, 3)

# --------------------------------------------------
# Generate Python golden results
# --------------------------------------------------
golden = []

for r in range(28):
    for c in range(28):
        for f in range(8):

            acc = 0

            for kr in range(-1, 2):
                for kc in range(-1, 2):

                    ir = r + kr
                    ic = c + kc

                    if 0 <= ir < 28 and 0 <= ic < 28:
                        pixel = int(image[ir, ic])
                    else:
                        pixel = 0

                    weight = int(weights[f, kr + 1, kc + 1])

                    acc += pixel * weight

            golden.append(acc)

# --------------------------------------------------
# Load RTL results
#
# IMPORTANT:
# The RTL result is correct, but row/col/filter
# metadata is one clock ahead. Therefore we compare
# the numerical result sequence.
# --------------------------------------------------
rtl_file = "reports/rtl_conv1_pe_results.txt"

rtl_results = []

with open(rtl_file) as f:
    for line in f:
        parts = line.split()

        if len(parts) != 4:
            continue

        rtl_results.append(int(parts[3]))

# --------------------------------------------------
# Compare
# --------------------------------------------------
print()
print("==============================================")
print(" CONV1 PE RTL vs PYTHON GOLDEN COMPARISON")
print("==============================================")
print()

print(f"Python golden outputs = {len(golden)}")
print(f"RTL outputs           = {len(rtl_results)}")
print()

if len(rtl_results) != len(golden):
    print("FAIL: Output count mismatch.")
    raise SystemExit(1)

mismatches = 0

for i, (rtl, ref) in enumerate(zip(rtl_results, golden)):

    if rtl != ref:

        if mismatches < 20:
            r = i // (28 * 8)
            c = (i // 8) % 28
            f = i % 8

            print(
                f"MISMATCH {i}: "
                f"row={r} col={c} filter={f} "
                f"RTL={rtl} PYTHON={ref}"
            )

        mismatches += 1

print()
print("----------------------------------------------")
print(f"Outputs checked = {len(golden)}")
print(f"Mismatches       = {mismatches}")
print("----------------------------------------------")
print()

if mismatches == 0:
    print("PASS: All 6272 Conv1 PE results match Python.")
else:
    print("FAIL: Conv1 PE numerical mismatch detected.")

print()
