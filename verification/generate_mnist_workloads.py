#!/usr/bin/env python3
"""Create deterministic INT8 MNIST .mem workloads from the repository dataset."""
import argparse, struct
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
RAW=ROOT/"cnn_baseline/data/MNIST/raw"
OUT=ROOT/"verification/workloads"
def read_images(p):
    with p.open("rb") as f:
        magic,n,rows,cols=struct.unpack(">IIII",f.read(16)); assert magic==2051 and rows==28 and cols==28
        return [f.read(rows*cols) for _ in range(n)]
def read_labels(p):
    with p.open("rb") as f:
        magic,n=struct.unpack(">II",f.read(8)); assert magic==2049
        return list(f.read(n))
def main():
    ap=argparse.ArgumentParser(); ap.add_argument("--indices",default="0,17,26,34,36"); ap.add_argument("--clean",action="store_true"); a=ap.parse_args()
    images=read_images(RAW/"t10k-images-idx3-ubyte"); labels=read_labels(RAW/"t10k-labels-idx1-ubyte")
    OUT.mkdir(parents=True,exist_ok=True)
    if a.clean:
        for p in OUT.glob("*.mem"): p.unlink()
    for idx_s in a.indices.split(","):
        idx=int(idx_s); data=images[idx]; path=OUT/f"mnist_{idx:05d}_label{labels[idx]}.mem"
        with path.open("w") as f:
            for x in data:
                q=min(127,max(-128,int(x)-128))
                f.write(f"{q & 255:02x}\n")
        print(f"{idx},{labels[idx]},{path}")
if __name__=="__main__": main()