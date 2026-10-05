import numpy as np

IMAGE_FILE = "data/mnist_image0_int8.mem"
WEIGHT_FILE = "data/int8/conv1_weight.mem"


def read_int8_mem(filename):
    values = []

    with open(filename, "r") as f:
        for line in f:
            line = line.strip()

            if not line:
                continue

            value = int(line, 16)

            if value >= 128:
                value -= 256

            values.append(value)

    return np.array(values, dtype=np.int8)


image = read_int8_mem(IMAGE_FILE)
weights = read_int8_mem(WEIGHT_FILE)

print("Image values :", len(image))
print("Weight values:", len(weights))

image = image.reshape(28, 28)
weights = weights.reshape(8, 3, 3)

outputs = np.zeros((8, 28, 28), dtype=np.int32)

# Conv1 with padding = 1
for filt in range(8):

    for row in range(28):

        for col in range(28):

            acc = 0

            for kr in range(3):

                for kc in range(3):

                    ir = row + kr - 1
                    ic = col + kc - 1

                    if ir < 0 or ir >= 28 or ic < 0 or ic >= 28:
                        pixel = 0
                    else:
                        pixel = int(image[ir, ic])

                    weight = int(weights[filt, kr, kc])

                    acc += pixel * weight

            outputs[filt, row, col] = acc


print()
print("PYTHON FULL-IMAGE GOLDEN REFERENCE")
print("===================================")

print()
print("Position: row=0 col=0")

for filt in range(8):
    print(
        f"Filter {filt} = "
        f"{outputs[filt, 0, 0]}"
    )

print()
print("Position: row=0 col=1")

for filt in range(8):
    print(
        f"Filter {filt} = "
        f"{outputs[filt, 0, 1]}"
    )

print()
print("Position: row=1 col=1")

for filt in range(8):
    print(
        f"Filter {filt} = "
        f"{outputs[filt, 1, 1]}"
    )

print()
print("Total outputs =", outputs.size)
