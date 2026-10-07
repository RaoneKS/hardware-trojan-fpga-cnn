#!/usr/bin/env python3
from __future__ import annotations
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "cnn_baseline" / "data" / "MNIST" / "raw"
OUT = ROOT / "verification" / "results" / "extended_workloads"
IMAGES = RAW / "t10k-images-idx3-ubyte"
LABELS = RAW / "t10k-labels-idx1-ubyte"
PER_CLASS = 5
CANONICAL = {3, 2, 1, 30, 4, 8, 11, 0, 61, 7}

def read_idx_images(path: Path):
    with path.open("rb") as f:
        magic, count, rows, cols = struct.unpack(">IIII", f.read(16))
        if magic != 2051 or rows != 28 or cols != 28:
            raise SystemExit(f"Unexpected MNIST image IDX header: {path}")
        payload = f.read()
    stride = rows * cols
    if len(payload) != count * stride:
        raise SystemExit("MNIST image file length mismatch")
    for i in range(count):
        yield i, payload[i * stride:(i + 1) * stride]

def read_idx_labels(path: Path):
    with path.open("rb") as f:
        magic, count = struct.unpack(">II", f.read(8))
        if magic != 2049:
            raise SystemExit(f"Unexpected MNIST label IDX header: {path}")
        labels = list(f.read())
    if len(labels) != count:
        raise SystemExit("MNIST label file length mismatch")
    return labels

def image_to_mem(pixels: bytes) -> list[str]:
    vals = [((p / 255.0) - 0.1307) / 0.3081 for p in pixels]
    max_abs = max(abs(v) for v in vals)
    scale = max_abs / 127.0 if max_abs else 1.0
    q = [max(-128, min(127, round(v / scale))) for v in vals]
    return [f"{(v & 0xFF):02X}" for v in q]

def main() -> None:
    if not IMAGES.is_file() or not LABELS.is_file():
        raise SystemExit("MNIST test IDX files are missing from cnn_baseline/data/MNIST/raw/")
    labels = read_idx_labels(LABELS)
    OUT.mkdir(parents=True, exist_ok=True)
    chosen = []
    per = {d: 0 for d in range(10)}
    for idx, pixels in read_idx_images(IMAGES):
        label = labels[idx]
        if idx in CANONICAL or per[label] >= PER_CLASS:
            continue
        per[label] += 1
        name = f"mnist_ext_{len(chosen):03d}_class{label}_idx{idx}.mem"
        path = OUT / name
        path.write_text("\n".join(image_to_mem(pixels)) + "\n")
        chosen.append((len(chosen), idx, label, path))
        if all(per[d] == PER_CLASS for d in range(10)):
            break
    if len(chosen) != 50:
        raise SystemExit(f"Expected 50 held-out samples, generated {len(chosen)}")
    manifest = OUT / "extended_manifest.csv"
    with manifest.open("w") as f:
        f.write("workload_id,mnist_index,label,mem_path\n")
        for wid, idx, label, path in chosen:
            f.write(f"{wid},{idx},{label},{path.relative_to(ROOT).as_posix()}\n")
    print(f"PASS: generated {len(chosen)} held-out workloads at {OUT}")

if __name__ == "__main__":
    main()
