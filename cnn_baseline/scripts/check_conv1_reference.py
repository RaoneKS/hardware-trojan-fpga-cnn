import numpy as np

# Same 3x3 input used by RTL
pixels = np.array(
    [1, 2, 3,
     4, 5, 6,
     7, 8, 9],
    dtype=np.int32
)

# Read the exact hardware .mem file
weights = []

with open("data/int8/conv1_weight.mem", "r") as f:
    for line in f:
        value = int(line.strip(), 16)

        # Convert 8-bit two's complement
        if value >= 128:
            value -= 256

        weights.append(value)

weights = np.array(weights, dtype=np.int32)

print("Number of weights:", len(weights))

print()
print("PYTHON GOLDEN REFERENCE")
print("========================")

for filt in range(8):

    w = weights[filt * 9:(filt + 1) * 9]

    result = int(np.sum(pixels * w))

    print(f"Filter {filt} = {result}")
