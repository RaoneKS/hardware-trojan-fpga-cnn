import torch
import numpy as np
from pathlib import Path

MODEL = "data/mnist_cnn_fp32.pth"
OUT = Path("data/int8")
OUT.mkdir(parents=True, exist_ok=True)

checkpoint = torch.load(
    MODEL,
    map_location="cpu",
    weights_only=False
)

# Handle either a complete model or state_dict
if hasattr(checkpoint, "state_dict"):
    state = checkpoint.state_dict()
elif isinstance(checkpoint, dict) and "state_dict" in checkpoint:
    state = checkpoint["state_dict"]
else:
    state = checkpoint

def quantize(tensor):
    tensor = tensor.detach().cpu().numpy()

    scale = np.max(np.abs(tensor)) / 127.0

    if scale == 0:
        scale = 1.0

    q = np.round(tensor / scale)
    q = np.clip(q, -128, 127).astype(np.int8)

    return q, scale


def write_mem(array, filename):
    flat = array.flatten()

    with open(filename, "w") as f:
        for value in flat:
            f.write(f"{int(value) & 0xff:02X}\n")


# ------------------------------------------------------------
# Conv2
# ------------------------------------------------------------

w = state["conv2.weight"]
b = state["conv2.bias"]

qw, sw = quantize(w)
qb, sb = quantize(b)

write_mem(qw, OUT / "conv2_weight.mem")
write_mem(qb, OUT / "conv2_bias.mem")

np.save(OUT / "conv2_weight.npy", qw)
np.save(OUT / "conv2_bias.npy", qb)

with open(OUT / "conv2_scales.txt", "w") as f:
    f.write(f"conv2_weight_scale={sw}\n")
    f.write(f"conv2_bias_scale={sb}\n")

print("Conv2 exported")
print("Weight shape:", qw.shape)
print("Bias shape:", qb.shape)
print("Weight scale:", sw)
print("Bias scale:", sb)
print("Total Conv2 weights:", qw.size)
