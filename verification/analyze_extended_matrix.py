#!/usr/bin/env python3
from __future__ import annotations
import csv
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CSV = ROOT / "verification" / "results" / "extended_runs.csv"
REPORT = ROOT / "verification" / "results" / "EXTENDED_MATRIX_REPORT.md"

def mean(xs):
    return sum(xs) / len(xs) if xs else float("nan")

def stdev(xs):
    if len(xs) < 2:
        return float("nan")
    m = mean(xs)
    return math.sqrt(sum((x - m) ** 2 for x in xs) / (len(xs) - 1))

def pct(a, b):
    return 100.0 * a / b if b else float("nan")

def main():
    if not CSV.is_file():
        raise SystemExit(f"Missing {CSV}")
    rows = list(csv.DictReader(CSV.open(newline="")))
    if len(rows) != 300:
        raise SystemExit(f"Expected 300 rows, found {len(rows)}")
    if not all(r["status"] == "PASS" for r in rows):
        raise SystemExit("Extended regression contains non-PASS rows")
    healthy = [r for r in rows if r["trojan_present"] == "0"]
    trojan = [r for r in rows if r["trojan_present"] == "1"]
    tp = sum(r["detected"] == "1" for r in trojan)
    fn = len(trojan) - tp
    fp = sum(r["detected"] == "1" for r in healthy)
    tn = len(healthy) - fp
    lines = [
        "# Extended Held-Out MNIST Regression\n\n",
        "50 held-out MNIST test images (5 per class), selected disjoint from the canonical 10 images, are paired across Healthy/T1–T5 for 300 cycle-accurate RTL runs.\n\n",
        f"- Rows: {len(rows)} (50 Healthy + 250 Trojan)\n",
        f"- TP={tp}, TN={tn}, FP={fp}, FN={fn}\n",
        f"- TPR/Recall={pct(tp, tp+fn):.2f}%\n",
        f"- FPR={pct(fp, fp+tn):.2f}%\n",
        f"- Precision={pct(tp, tp+fp):.2f}%\n\n",
        "## Per-variant detection\n\n| Variant | Runs | Detected | Detection rate | Mean cycles | Cycle std-dev |\n|---|---:|---:|---:|---:|---:|\n",
    ]
    for t in ["T1", "T2", "T3", "T4", "T5"]:
        rs = [r for r in rows if r["trojan_id"] == t]
        cycles = [int(r["inference_cycles"]) for r in rs]
        det = sum(r["detected"] == "1" for r in rs)
        lines.append(f"| {t} | {len(rs)} | {det} | {100*det/len(rs):.2f}% | {mean(cycles):.2f} | {stdev(cycles):.2f} |\n")
    hc = [int(r["inference_cycles"]) for r in healthy]
    lines += [
        "\n## Healthy timing\n\n",
        f"- Mean inference cycles: {mean(hc):.2f}\n",
        f"- Standard deviation: {stdev(hc):.2f}\n",
        f"- Minimum: {min(hc)}\n",
        f"- Maximum: {max(hc)}\n\n",
        "This is an extended same-CNN held-out workload robustness test, not cross-CNN generalization and not physical power measurement.\n",
    ]
    REPORT.write_text("".join(lines))
    print(f"PASS: extended regression analysis written to {REPORT}")

if __name__ == "__main__":
    main()
