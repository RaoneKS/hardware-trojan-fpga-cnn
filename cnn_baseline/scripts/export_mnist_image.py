import torch
from torchvision import datasets, transforms
import numpy as np

transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.1307,), (0.3081,))
])

dataset = datasets.MNIST(
    root="./data",
    train=False,
    download=True,
    transform=transform
)

image, label = dataset[0]

# Convert normalized image to signed INT8.
# Scale approximately from [-1, +1] into [-127, +127].
image = image.squeeze(0).numpy()

max_value = np.max(np.abs(image))

scale = max_value / 127.0

if scale == 0:
    scale = 1.0

image_int8 = np.round(image / scale)
image_int8 = np.clip(image_int8, -128, 127).astype(np.int8)

print("MNIST label:", label)
print("Image shape:", image_int8.shape)
print("INT8 scale:", scale)

# Export row-major 28x28 image
with open("./data/mnist_image0_int8.mem", "w") as f:
    for value in image_int8.flatten():
        unsigned_value = int(value)

        if unsigned_value < 0:
            unsigned_value += 256

        f.write(f"{unsigned_value:02X}\n")

print()
print("Exported:")
print("./data/mnist_image0_int8.mem")
