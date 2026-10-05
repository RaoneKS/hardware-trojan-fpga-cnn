import numpy as np


def load_rtl_fc(filename):

    values = []

    with open(filename) as f:

        for line in f:

            line = line.strip()

            if not line:
                continue

            parts = line.split()

            if len(parts) >= 2:

                values.append(int(parts[-1]))

    return np.array(values, dtype=np.int64)


python_fc = np.loadtxt(
    "reports/python_fc_reference.txt",
    dtype=np.int64
)

rtl_fc = load_rtl_fc(
    "reports/rtl_fc_results.txt"
)


print()
print("====================================")
print(" FINAL FC RTL / PYTHON COMPARISON")
print("====================================")

print("Python outputs =", len(python_fc))

print("RTL outputs    =", len(rtl_fc))


if len(python_fc) != len(rtl_fc):

    print("FAIL: Output count mismatch.")

    raise SystemExit(1)


mismatch = 0


for i in range(10):

    if python_fc[i] != rtl_fc[i]:

        mismatch += 1

        print(
            f"MISMATCH class {i}: "
            f"Python={python_fc[i]} "
            f"RTL={rtl_fc[i]}"
        )


print()
print("Mismatches =", mismatch)


if mismatch == 0:

    print(
        "PASS: Final FC outputs match Python."
    )

else:

    print(
        "FAIL: FC outputs do not match."
    )
