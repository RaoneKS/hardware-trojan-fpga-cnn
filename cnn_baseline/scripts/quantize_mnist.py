import torch
import torch.nn as nn
from torchvision import datasets, transforms
from torch.utils.data import DataLoader
import numpy as np
import os


# ============================================================
# CNN definition — must exactly match the trained model
# ============================================================

class MNIST_CNN(nn.Module):

    def __init__(self):
        super().__init__()

        self.conv1 = nn.Conv2d(
            1, 8, kernel_size=3, stride=1, padding=1
        )

        self.relu1 = nn.ReLU()
        self.pool1 = nn.MaxPool2d(2)

        self.conv2 = nn.Conv2d(
            8, 16, kernel_size=3, stride=1, padding=1
        )

        self.relu2 = nn.ReLU()
        self.pool2 = nn.MaxPool2d(2)

        self.fc1 = nn.Linear(16 * 7 * 7, 10)


    def forward(self, x):

        x = self.conv1(x)
        x = self.relu1(x)
        x = self.pool1(x)

        x = self.conv2(x)
        x = self.relu2(x)
        x = self.pool2(x)

        x = torch.flatten(x, 1)

        x = self.fc1(x)

        return x


# ============================================================
# Load trained model
# ============================================================

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

model = MNIST_CNN().to(device)

model.load_state_dict(
    torch.load(
        "./data/mnist_cnn_fp32.pth",
        map_location=device
    )
)

model.eval()

print("Loaded FP32 model")
print("Device:", device)


# ============================================================
# Test FP32 model
# ============================================================

transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.1307,), (0.3081,))
])

test_dataset = datasets.MNIST(
    root="./data",
    train=False,
    download=True,
    transform=transform
)

test_loader = DataLoader(
    test_dataset,
    batch_size=256,
    shuffle=False,
    num_workers=0
)


correct = 0
total = 0

with torch.no_grad():

    for images, labels in test_loader:

        images = images.to(device)
        labels = labels.to(device)

        outputs = model(images)

        predictions = outputs.argmax(dim=1)

        correct += (predictions == labels).sum().item()
        total += labels.size(0)

fp32_accuracy = 100.0 * correct / total

print()
print(f"FP32 accuracy: {fp32_accuracy:.2f}%")


# ============================================================
# INT8 weight quantization
# ============================================================

os.makedirs("./data/int8", exist_ok=True)


def quantize_tensor(tensor):

    tensor = tensor.detach().cpu()

    max_value = tensor.abs().max()

    scale = max_value / 127.0

    if scale == 0:
        scale = torch.tensor(1.0)

    quantized = torch.round(
        tensor / scale
    ).clamp(-128, 127)

    return quantized.to(torch.int8), scale


# ============================================================
# Export each layer
# ============================================================

layers = {
    "conv1_weight": model.conv1.weight,
    "conv1_bias": model.conv1.bias,

    "conv2_weight": model.conv2.weight,
    "conv2_bias": model.conv2.bias,

    "fc1_weight": model.fc1.weight,
    "fc1_bias": model.fc1.bias,
}


print()
print("INT8 quantization:")
print("------------------")


for name, tensor in layers.items():

    q_tensor, scale = quantize_tensor(tensor)

    np.save(
        f"./data/int8/{name}.npy",
        q_tensor.numpy()
    )

    with open(
        f"./data/int8/{name}.mem",
        "w"
    ) as f:

        for value in q_tensor.flatten():

            value = int(value)

            if value < 0:
                value += 256

            f.write(
                f"{value:02X}\n"
            )

    print(
        f"{name:15s} "
        f"shape={tuple(tensor.shape)} "
        f"scale={scale.item():.8f}"
    )


# ============================================================
# Save quantization scales
# ============================================================

with open(
    "./data/int8/scales.txt",
    "w"
) as f:

    for name, tensor in layers.items():

        _, scale = quantize_tensor(tensor)

        f.write(
            f"{name} {scale.item():.10f}\n"
        )


print()
print("INT8 weights exported.")
print("Location: ./data/int8/")
