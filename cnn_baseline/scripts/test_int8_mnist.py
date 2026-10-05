import torch
import torch.nn as nn
from torchvision import datasets, transforms
from torch.utils.data import DataLoader


class MNIST_CNN(nn.Module):
    def __init__(self):
        super().__init__()

        self.conv1 = nn.Conv2d(1, 8, 3, padding=1)
        self.relu1 = nn.ReLU()
        self.pool1 = nn.MaxPool2d(2)

        self.conv2 = nn.Conv2d(8, 16, 3, padding=1)
        self.relu2 = nn.ReLU()
        self.pool2 = nn.MaxPool2d(2)

        self.fc1 = nn.Linear(16 * 7 * 7, 10)

    def forward(self, x):
        x = self.pool1(self.relu1(self.conv1(x)))
        x = self.pool2(self.relu2(self.conv2(x)))
        x = torch.flatten(x, 1)
        return self.fc1(x)


def quantize_tensor(tensor):
    max_value = tensor.detach().abs().max()
    scale = max_value / 127.0

    if scale == 0:
        scale = torch.tensor(1.0)

    q = torch.round(tensor / scale).clamp(-128, 127)

    return q, scale


# ------------------------------------------------------------
# Load trained FP32 model
# ------------------------------------------------------------

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

model = MNIST_CNN().to(device)

model.load_state_dict(
    torch.load(
        "./data/mnist_cnn_fp32.pth",
        map_location=device
    )
)

model.eval()


# ------------------------------------------------------------
# Quantize weights
# ------------------------------------------------------------

with torch.no_grad():

    q_conv1, s_conv1 = quantize_tensor(model.conv1.weight)
    q_conv2, s_conv2 = quantize_tensor(model.conv2.weight)
    q_fc1, s_fc1 = quantize_tensor(model.fc1.weight)

    q_b1, sb1 = quantize_tensor(model.conv1.bias)
    q_b2, sb2 = quantize_tensor(model.conv2.bias)
    q_b3, sb3 = quantize_tensor(model.fc1.bias)


# ------------------------------------------------------------
# Build dequantized model
# ------------------------------------------------------------

qmodel = MNIST_CNN().to(device)

with torch.no_grad():

    qmodel.conv1.weight.copy_(q_conv1 * s_conv1)
    qmodel.conv1.bias.copy_(q_b1 * sb1)

    qmodel.conv2.weight.copy_(q_conv2 * s_conv2)
    qmodel.conv2.bias.copy_(q_b2 * sb2)

    qmodel.fc1.weight.copy_(q_fc1 * s_fc1)
    qmodel.fc1.bias.copy_(q_b3 * sb3)

qmodel.eval()


# ------------------------------------------------------------
# MNIST test data
# ------------------------------------------------------------

transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize(
        (0.1307,),
        (0.3081,)
    )
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


# ------------------------------------------------------------
# Test quantized model
# ------------------------------------------------------------

correct = 0
total = 0

with torch.no_grad():

    for images, labels in test_loader:

        images = images.to(device)
        labels = labels.to(device)

        outputs = qmodel(images)

        predictions = outputs.argmax(dim=1)

        correct += (
            predictions == labels
        ).sum().item()

        total += labels.size(0)


accuracy = 100.0 * correct / total

print()
print("====================================")
print("INT8 WEIGHT QUANTIZATION TEST")
print("====================================")
print(f"INT8-weight model accuracy: {accuracy:.2f}%")
print("FP32 accuracy:              98.41%")
print(f"Accuracy difference:        {98.41 - accuracy:.2f}%")
print("====================================")
