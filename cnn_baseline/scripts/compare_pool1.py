import numpy as np

# Load the original INT8 image
image = np.loadtxt("data/mnist_image0_int8.mem", dtype=str)
image = np.array(
    [int(x, 16) if int(x, 16) < 128 else int(x, 16) - 256
     for x in image],
    dtype=np.int8
).reshape(28, 28)

# Load Conv1 weights
weights = np.loadtxt("data/int8/conv1_weight.mem", dtype=str)
weights = np.array(
    [int(x, 16) if int(x, 16) < 128 else int(x, 16) - 256
     for x in weights],
    dtype=np.int8
).reshape(8, 3, 3)

# Generate Conv1 + ReLU
conv1 = np.zeros((8, 28, 28), dtype=np.int32)

for f in range(8):
    for r in range(28):
        for c in range(28):
            acc = 0

            for kr in range(-1, 2):
                for kc in range(-1, 2):
                    ir = r + kr
                    ic = c + kc

                    if 0 <= ir < 28 and 0 <= ic < 28:
                        acc += int(image[ir, ic]) * int(weights[f, kr+1, kc+1])

            conv1[f, r, c] = max(0, acc)

# 2x2 MaxPool
golden = []

for r in range(14):
    for c in range(14):
        for f in range(8):
            window = conv1[
                f,
                r*2:r*2+2,
                c*2:c*2+2
            ]

            golden.append(int(np.max(window)))

# Load RTL results
rtl = []

with open("reports/rtl_pool1_results.txt") as f:
    for line in f:
        p = line.split()

        if len(p) == 4:
            rtl.append(int(p[3]))

print()
print("==============================================")
print(" POOL1 RTL vs PYTHON GOLDEN COMPARISON")
print("==============================================")
print()

print("Python golden outputs =", len(golden))
print("RTL outputs           =", len(rtl))
print()

if len(golden) != len(rtl):
    print("FAIL: Output count mismatch.")
    raise SystemExit(1)

mismatches = 0

for i, (r, g) in enumerate(zip(rtl, golden)):

    if r != g:

        if mismatches < 20:
            row = i // (14 * 8)
            col = (i // 8) % 14
            filt = i % 8

            print(
                f"MISMATCH {i}: "
                f"row={row} col={col} filter={filt} "
                f"RTL={r} PYTHON={g}"
            )

        mismatches += 1

print()
print("----------------------------------------------")
print("Outputs checked =", len(golden))
print("Mismatches       =", mismatches)
print("----------------------------------------------")
print()

if mismatches == 0:
    print("PASS: All 1568 Pool1 results match Python.")
else:
    print("FAIL: Pool1 numerical mismatch detected.")

print()
