import numpy as np

rtl_file = "reports/rtl_conv1_8pe_results.txt"
old_file = "reports/rtl_conv1_pe_results.txt"

rtl = np.loadtxt(rtl_file, dtype=np.int64)
old = np.loadtxt(old_file, dtype=np.int64)

print("RTL 8-PE positions :", len(rtl))
print("Old Conv1 outputs  :", len(old))

if len(rtl) != 784:
    print("FAIL: expected 784 image positions")
    raise SystemExit(1)

if len(old) != 6272:
    print("FAIL: expected 6272 reference outputs")
    raise SystemExit(1)

mismatches = 0
checked = 0

for r in range(28):
    for c in range(28):

        pos = r * 28 + c

        rtl_row = rtl[pos]

        if rtl_row[0] != r or rtl_row[1] != c:
            print(
                f"Metadata mismatch at position {pos}: "
                f"got row={rtl_row[0]} col={rtl_row[1]}, "
                f"expected row={r} col={c}"
            )
            mismatches += 1

        for f in range(8):

            rtl_value = rtl_row[2 + f]

            old_index = pos * 8 + f
            old_value = old[old_index, 3]

            checked += 1

            if rtl_value != old_value:

                if mismatches < 20:
                    print(
                        f"Mismatch: row={r} col={c} filter={f} "
                        f"8PE={rtl_value} reference={old_value}"
                    )

                mismatches += 1

print()
print("Outputs checked =", checked)
print("Mismatches       =", mismatches)

if mismatches == 0:
    print("PASS: All 6272 Conv1 PE results match.")
else:
    print("FAIL: Conv1 mismatch detected.")
