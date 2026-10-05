import numpy as np

# -----------------------------
# Load Pool1 input
# -----------------------------
pool1 = np.loadtxt(
    "reports/pool1_conv2_input.mem",
    dtype=str
)

pool1 = np.array(
    [int(x, 16) for x in pool1],
    dtype=np.uint32
).view(np.int32)

pool1 = pool1.reshape(14, 14, 8)


# -----------------------------
# Load Conv2 weights
# -----------------------------
weights = np.loadtxt(
    "data/int8/conv2_weight.mem",
    dtype=str
)

weights = np.array(
    [int(x, 16) if int(x, 16) < 128
     else int(x, 16) - 256
     for x in weights],
    dtype=np.int8
)

weights = weights.reshape(16, 8, 3, 3)


# -----------------------------
# Load Conv2 biases
# -----------------------------
bias = np.loadtxt(
    "data/int8/conv2_bias.mem",
    dtype=str
)

bias = np.array(
    [int(x, 16) if int(x, 16) < 128
     else int(x, 16) - 256
     for x in bias],
    dtype=np.int32
)


# -----------------------------
# Python golden Conv2
# -----------------------------
golden = []

for r in range(14):

    for c in range(14):

        for f in range(16):

            acc = int(bias[f])

            for ch in range(8):

                for kr in range(-1, 2):

                    for kc in range(-1, 2):

                        ir = r + kr
                        ic = c + kc

                        if 0 <= ir < 14 and 0 <= ic < 14:

                            acc += (
                                int(pool1[ir, ic, ch]) *
                                int(weights[f, ch, kr + 1, kc + 1])
                            )

            # ReLU
            acc = max(0, acc)

            golden.append(acc)


# -----------------------------
# Load RTL results
# -----------------------------
rtl = []

with open("reports/rtl_conv2_results.txt") as f:

    for line in f:

        p = line.split()

        if len(p) == 4:
            rtl.append(int(p[3]))


# -----------------------------
# Compare
# -----------------------------
print()
print("==============================================")
print(" CONV2 RTL vs PYTHON GOLDEN COMPARISON")
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

            row = i // (14 * 16)
            col = (i // 16) % 14
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

    print("PASS: All 3136 Conv2 results match Python.")

else:

    print("FAIL: Conv2 numerical mismatch detected.")

print()
