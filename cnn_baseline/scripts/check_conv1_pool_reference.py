import numpy as np

IMAGE_FILE = "data/mnist_image0_int8.mem"
WEIGHT_FILE = "data/int8/conv1_weight.mem"


def read_int8_mem(filename):
    values = []

    with open(filename, "r") as f:
        for line in f:
            line = line.strip()

            if line:
                value = int(line, 16)

                if value >= 128:
                    value -= 256

                values.append(value)

    return np.array(values, dtype=np.int8)


image = read_int8_mem(IMAGE_FILE).reshape(28, 28)
weights = read_int8_mem(WEIGHT_FILE).reshape(8, 3, 3)


# ------------------------------------------------------------
# Conv1: 3x3, padding=1
# ------------------------------------------------------------

conv1 = np.zeros((8, 28, 28), dtype=np.int32)

for f in range(8):

    for r in range(28):

        for c in range(28):

            acc = 0

            for kr in range(3):

                for kc in range(3):

                    ir = r + kr - 1
                    ic = c + kc - 1

                    if 0 <= ir < 28 and 0 <= ic < 28:

                        acc += (
                            int(image[ir, ic]) *
                            int(weights[f, kr, kc])
                        )

            conv1[f, r, c] = acc


# ------------------------------------------------------------
# ReLU
# ------------------------------------------------------------

relu = np.maximum(conv1, 0)


# ------------------------------------------------------------
# 2x2 MaxPool
# ------------------------------------------------------------

pool = np.zeros((8, 14, 14), dtype=np.int32)

for f in range(8):

    for r in range(14):

        for c in range(14):

            window = relu[
                f,
                r*2:r*2+2,
                c*2:c*2+2
            ]

            pool[f, r, c] = np.max(window)


print()
print("PYTHON CONV1 -> RELU -> MAXPOOL")
print("================================")

print()
print("Output shape:", pool.shape)
print("Total outputs:", pool.size)

print()
print("Position row=0 col=0")

for f in range(8):
    print(
        f"Filter {f} = {pool[f, 0, 0]}"
    )

print()
print("Position row=0 col=1")

for f in range(8):
    print(
        f"Filter {f} = {pool[f, 0, 1]}"
    )

print()
print("Position row=1 col=1")

for f in range(8):
    print(
        f"Filter {f} = {pool[f, 1, 1]}"
    )

print()
print("Last position row=13 col=13")

for f in range(8):
    print(
        f"Filter {f} = {pool[f, 13, 13]}"
    )

# Save golden output for later comparison
np.save(
    "data/conv1_pool_golden.npy",
    pool
)

print()
print("Golden reference saved:")
print("data/conv1_pool_golden.npy")

