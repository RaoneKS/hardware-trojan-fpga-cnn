import numpy as np
import torch
import torch.nn as nn
from torchvision import datasets, transforms


# ============================================================
# MODEL
# ============================================================

class MNISTCNN(nn.Module):
    def __init__(self):
        super().__init__()

        self.conv1 = nn.Conv2d(1, 8, 3, padding=1)
        self.conv2 = nn.Conv2d(8, 16, 3, padding=1)

        self.fc1 = nn.Linear(16 * 7 * 7, 10)

    def forward(self, x):
        x = self.conv1(x)
        x = torch.relu(x)
        x = torch.max_pool2d(x, 2)

        x = self.conv2(x)
        x = torch.relu(x)
        x = torch.max_pool2d(x, 2)

        x = x.view(x.size(0), -1)

        x = self.fc1(x)

        return x


# ============================================================
# MEMORY LOADER
# ============================================================

def load_mem(filename):
    values = []

    with open(filename) as f:
        for line in f:
            line = line.strip()

            if line:
                values.append(int(line, 16))

    return np.array(values, dtype=np.int64)


def load_signed_mem(filename, bits=8):
    values = load_mem(filename)

    mask = (1 << bits) - 1
    sign = 1 << (bits - 1)

    values = values & mask
    values = np.where(values & sign, values - (1 << bits), values)

    return values.astype(np.int64)


def load_signed32_mem(filename):
    values = load_mem(filename)

    values = values.astype(np.uint32).astype(np.int32)

    return values.astype(np.int64)


# ============================================================
# LOAD TRAINED MODEL
# ============================================================

print("Loading trained model...")

model = MNISTCNN()

state = torch.load(
    "data/mnist_cnn_fp32.pth",
    map_location="cpu"
)

model.load_state_dict(state)
model.eval()


# ============================================================
# LOAD SAME MNIST IMAGE
# ============================================================

transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.1307,), (0.3081,))
])

dataset = datasets.MNIST(
    root="data",
    train=False,
    download=True,
    transform=transform
)

image, label = dataset[0]

image_np = image.numpy()[0]

print("Actual label =", label)


# ============================================================
# FP32 REFERENCE
# ============================================================

with torch.no_grad():

    fp32_output = model(image.unsqueeze(0))

fp32_prediction = int(torch.argmax(fp32_output, dim=1)[0])

print("FP32 prediction =", fp32_prediction)


# ============================================================
# LOAD INT8 PARAMETERS
# ============================================================

w1 = load_signed_mem(
    "data/int8/conv1_weight.mem"
).reshape(8, 1, 3, 3)

w2 = load_signed_mem(
    "data/int8/conv2_weight.mem"
).reshape(16, 8, 3, 3)

wf = load_signed_mem(
    "data/int8/fc1_weight.mem"
).reshape(10, 784)

bf1 = load_signed_mem(
    "data/int8/conv1_bias.mem"
)

bf2 = load_signed_mem(
    "data/int8/conv2_bias.mem"
)

bfc = load_signed_mem(
    "data/int8/fc1_bias.mem"
)

print()
print("Weight sizes:")
print("Conv1 =", w1.size)
print("Conv2 =", w2.size)
print("FC    =", wf.size)


# ============================================================
# INT8 IMAGE
# ============================================================

input_scale = np.max(np.abs(image_np)) / 127.0

img_q = np.round(image_np / input_scale)

img_q = np.clip(
    img_q,
    -128,
    127
).astype(np.int64)

print()
print("Input scale =", input_scale)


# ============================================================
# CONV1
# ============================================================

conv1 = np.zeros(
    (8, 28, 28),
    dtype=np.int64
)

for f in range(8):

    for r in range(28):

        for c in range(28):

            acc = int(bf1[f])

            for kr in range(-1, 2):

                for kc in range(-1, 2):

                    rr = r + kr
                    cc = c + kc

                    if (
                        0 <= rr < 28
                        and
                        0 <= cc < 28
                    ):

                        acc += (
                            int(img_q[rr, cc])
                            *
                            int(w1[f, 0, kr + 1, kc + 1])
                        )

            conv1[f, r, c] = acc


# ============================================================
# RELU1
# ============================================================

relu1 = np.maximum(conv1, 0)


# ============================================================
# POOL1
# ============================================================

pool1 = np.zeros(
    (8, 14, 14),
    dtype=np.int64
)

for f in range(8):

    for r in range(14):

        for c in range(14):

            pool1[f, r, c] = np.max(
                relu1[
                    f,
                    r * 2:r * 2 + 2,
                    c * 2:c * 2 + 2
                ]
            )


# ============================================================
# CONV2
# ============================================================

conv2 = np.zeros(
    (16, 14, 14),
    dtype=np.int64
)

for f in range(16):

    for r in range(14):

        for c in range(14):

            acc = int(bf2[f])

            for ch in range(8):

                for kr in range(-1, 2):

                    for kc in range(-1, 2):

                        rr = r + kr
                        cc = c + kc

                        if (
                            0 <= rr < 14
                            and
                            0 <= cc < 14
                        ):

                            acc += (
                                int(pool1[ch, rr, cc])
                                *
                                int(w2[
                                    f,
                                    ch,
                                    kr + 1,
                                    kc + 1
                                ])
                            )

            conv2[f, r, c] = acc


# ============================================================
# RELU2
# ============================================================

relu2 = np.maximum(conv2, 0)


# ============================================================
# POOL2
# ============================================================

pool2 = np.zeros(
    (16, 7, 7),
    dtype=np.int64
)

for f in range(16):

    for r in range(7):

        for c in range(7):

            pool2[f, r, c] = np.max(
                relu2[
                    f,
                    r * 2:r * 2 + 2,
                    c * 2:c * 2 + 2
                ]
            )


# ============================================================
# FLATTEN
# ============================================================

flat = pool2.reshape(-1)

print()
print("Pool2 shape =", pool2.shape)
print("Flattened size =", len(flat))


# ============================================================
# FC
# ============================================================

fc = np.zeros(
    10,
    dtype=np.int64
)

for o in range(10):

    acc = int(bfc[o])

    for i in range(784):

        acc += (
            int(flat[i])
            *
            int(wf[o, i])
        )

    fc[o] = acc


# ============================================================
# RESULT
# ============================================================

prediction = int(np.argmax(fc))


print()
print("==========================================")
print(" AUTHORITATIVE HEALTHY INT8 CNN REFERENCE")
print("==========================================")

print("Actual label     =", label)

print("FP32 prediction  =", fp32_prediction)

print("INT8 prediction  =", prediction)

print()
print("INT8 FC outputs:")

for i, value in enumerate(fc):

    print(
        f"class {i}: {value}"
    )

print()
print("Feature maps:")

print("Conv1 =", conv1.shape)

print("Pool1 =", pool1.shape)

print("Conv2 =", conv2.shape)

print("Pool2 =", pool2.shape)

print("FC    =", fc.shape)

print()

if prediction == label:

    print("PASS: INT8 prediction matches label.")

else:

    print("WARNING: INT8 prediction differs from label.")


# ============================================================
# EXPORT GOLDEN DATA
# ============================================================

np.savetxt(
    "reports/python_fc_reference.txt",
    fc,
    fmt="%d"
)

pool2.astype(np.int64).reshape(-1).tofile(
    "reports/python_pool2_raw.bin"
)

print()
print("Golden FC saved to:")
print("reports/python_fc_reference.txt")
