import numpy as np

# Load Conv2 output memory
data = np.loadtxt(
    "reports/conv2_pool2_input.mem",
    dtype=str
)

data = np.array(
    [int(x, 16) for x in data],
    dtype=np.uint64
).view(np.int64)

# Conv2 layout: row, column, filter
conv2 = data.reshape(14, 14, 16)

# Python golden Pool2
golden = []

for r in range(7):
    for c in range(7):
        for f in range(16):

            window = conv2[
                r*2:r*2+2,
                c*2:c*2+2,
                f
            ]

            # ReLU + MaxPool
            value = max(0, int(np.max(window)))

            golden.append(value)

# Load RTL results
rtl = []

with open("reports/rtl_pool2_results.txt") as f:
    for line in f:
        p = line.split()

        if len(p) == 4:
            rtl.append(int(p[3]))

print()
print("==============================================")
print(" POOL2 RTL vs PYTHON GOLDEN COMPARISON")
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

            row = i // (7 * 16)
            col = (i // 16) % 7
            filt = i % 16

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
    print("PASS: All 784 Pool2 results match Python.")
else:
    print("FAIL: Pool2 numerical mismatch detected.")

print()
