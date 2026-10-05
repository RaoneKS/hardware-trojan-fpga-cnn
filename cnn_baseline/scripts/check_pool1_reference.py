import numpy as np

IMAGE_SIZE = 28
FILTERS = 8

# Load image
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

# Conv1 output
conv1 = np.zeros((8, 28, 28), dtype=np.int32)

for f in range(FILTERS):
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

# 2x2 max pool, stride 2
pool1 = np.zeros((8, 14, 14), dtype=np.int32)

for f in range(8):
    for r in range(14):
        for c in range(14):
            window = conv1[f,
                            r*2:r*2+2,
                            c*2:c*2+2]

            pool1[f, r, c] = np.max(window)

print()
print("==============================================")
print(" REAL Conv1 -> ReLU -> Pool1 GOLDEN REFERENCE")
print("==============================================")
print()

print("Conv1 shape =", conv1.shape)
print("Pool1 shape =", pool1.shape)
print("Total Pool1 outputs =", pool1.size)

print()
print("First 8 Pool1 outputs:")

for f in range(8):
    print(f"Filter {f} =", pool1[f, 0, 0])

print()
print("Pool1 position row=0 col=1:")

for f in range(8):
    print(f"Filter {f} =", pool1[f, 0, 1])

print()
print("Pool1 position row=1 col=1:")

for f in range(8):
    print(f"Filter {f} =", pool1[f, 1, 1])

print()
