import torch
import torch.nn as nn
import torchvision
import torchvision.transforms as transforms
import numpy as np

# ------------------------------------------------------------
# Model
# ------------------------------------------------------------

class MNIST_CNN(nn.Module):
    def __init__(self):
        super().__init__()

        self.conv1 = nn.Conv2d(1, 8, 3, padding=1)
        self.conv2 = nn.Conv2d(8, 16, 3, padding=1)
        self.fc1 = nn.Linear(16 * 7 * 7, 10)

    def forward(self, x):
        x = torch.relu(self.conv1(x))
        x = torch.max_pool2d(x, 2)

        x = torch.relu(self.conv2(x))
        x = torch.max_pool2d(x, 2)

        x = x.view(x.size(0), -1)
        x = self.fc1(x)

        return x


# ------------------------------------------------------------
# Load trained model
# ------------------------------------------------------------

model = MNIST_CNN()

state = torch.load(
    "data/mnist_cnn_fp32.pth",
    map_location="cpu"
)

model.load_state_dict(state)
model.eval()

print("Model loaded")


# ------------------------------------------------------------
# MNIST image
# ------------------------------------------------------------

transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.1307,), (0.3081,))
])

dataset = torchvision.datasets.MNIST(
    root="./data",
    train=False,
    download=True,
    transform=transform
)

image, label = dataset[0]

print("Actual label =", label)


# ------------------------------------------------------------
# FP32 reference
# ------------------------------------------------------------

with torch.no_grad():
    x = image.unsqueeze(0)

    y1 = torch.relu(model.conv1(x))
    p1 = torch.max_pool2d(y1, 2)

    y2 = torch.relu(model.conv2(p1))
    p2 = torch.max_pool2d(y2, 2)

    flat = p2.reshape(1, -1)

    logits = model.fc1(flat)

    predicted = torch.argmax(logits, dim=1).item()

print("FP32 prediction =", predicted)
print("FP32 logits:")
print(logits.numpy())


# ------------------------------------------------------------
# Load INT8 weights
# ------------------------------------------------------------

def load_mem(filename):
    values = []

    with open(filename) as f:
        for line in f:
            line = line.strip()

            if not line:
                continue

            value = int(line, 16)

            if value >= 128:
                value -= 256

            values.append(value)

    return np.array(values, dtype=np.int8)


w1 = load_mem("data/int8/conv1_weight.mem")
w2 = load_mem("data/int8/conv2_weight.mem")
wf = load_mem("data/int8/fc1_weight.mem")

print()
print("INT8 weight sizes:")
print("Conv1 =", len(w1))
print("Conv2 =", len(w2))
print("FC    =", len(wf))


# ------------------------------------------------------------
# Verify dimensions
# ------------------------------------------------------------

assert len(w1) == 72
assert len(w2) == 1152
assert len(wf) == 7840

w1 = w1.reshape(8, 1, 3, 3).astype(np.int32)
w2 = w2.reshape(16, 8, 3, 3).astype(np.int32)
wf = wf.reshape(10, 784).astype(np.int32)


# ------------------------------------------------------------
# INT8 input
# ------------------------------------------------------------

img = image.numpy()[0]

input_scale = np.max(np.abs(img)) / 127.0

img_q = np.round(img / input_scale)
img_q = np.clip(img_q, -128, 127).astype(np.int32)

print()
print("Input scale =", input_scale)


# ------------------------------------------------------------
# INT8 Conv1
# ------------------------------------------------------------

conv1 = np.zeros((8, 28, 28), dtype=np.int32)

for f in range(8):

    for r in range(28):

        for c in range(28):

            acc = 0

            for kr in range(-1, 2):

                for kc in range(-1, 2):

                    rr = r + kr
                    cc = c + kc

                    if 0 <= rr < 28 and 0 <= cc < 28:

                        acc += (
                            img_q[rr, cc] *
                            w1[f, 0, kr + 1, kc + 1]
                        )

            conv1[f, r, c] = acc


# ------------------------------------------------------------
# ReLU
# ------------------------------------------------------------

relu1 = np.maximum(conv1, 0)


# ------------------------------------------------------------
# Pool1
# ------------------------------------------------------------

pool1 = np.zeros((8, 14, 14), dtype=np.int32)

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


# ------------------------------------------------------------
# Conv2
# ------------------------------------------------------------

conv2 = np.zeros((16, 14, 14), dtype=np.int64)

for f in range(16):

    for r in range(14):

        for c in range(14):

            acc = 0

            for ch in range(8):

                for kr in range(-1, 2):

                    for kc in range(-1, 2):

                        rr = r + kr
                        cc = c + kc

                        if 0 <= rr < 14 and 0 <= cc < 14:

                            acc += (
                                pool1[ch, rr, cc] *
                                w2[f, ch, kr + 1, kc + 1]
                            )

            conv2[f, r, c] = acc


# ------------------------------------------------------------
# ReLU2
# ------------------------------------------------------------

relu2 = np.maximum(conv2, 0)


# ------------------------------------------------------------
# Pool2
# ------------------------------------------------------------

pool2 = np.zeros((16, 7, 7), dtype=np.int64)

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


# ------------------------------------------------------------
# Flatten
# ------------------------------------------------------------

flat_int = pool2.reshape(-1)

print()
print("Final feature-map shape =", pool2.shape)
print("Flattened size =", len(flat_int))


# ------------------------------------------------------------
# FC
# ------------------------------------------------------------

fc_acc = np.zeros(10, dtype=np.int64)

for o in range(10):

    acc = 0

    for i in range(784):

        acc += flat_int[i] * wf[o, i]

    fc_acc[o] = acc


# ------------------------------------------------------------
# Prediction
# ------------------------------------------------------------

prediction = int(np.argmax(fc_acc))

print()
print("====================================")
print("INT8 HEALTHY CNN REFERENCE")
print("====================================")

print("Actual label     =", label)
print("FP32 prediction  =", predicted)
print("INT8 prediction  =", prediction)

print()
print("INT8 FC outputs:")
print(fc_acc)

print()
print("Feature-map sizes:")
print("Conv1 :", conv1.shape)
print("Pool1 :", pool1.shape)
print("Conv2 :", conv2.shape)
print("Pool2 :", pool2.shape)
print("FC    :", fc_acc.shape)

print()
print("Total FC inputs =", len(flat_int))
