#!/usr/bin/env python3
import csv
import math
from collections import Counter, defaultdict

PATH = "verification/results/runs.csv"

with open(PATH, newline="") as f:
    rows = list(csv.DictReader(f))

def b(v):
    return str(v).strip().lower() in {"1", "true", "yes", "y"}

def ratio(a, d):
    return a / d if d else math.nan

if not rows:
    print("No measured runs are present in verification/results/runs.csv.")
    print("Add healthy and Trojan measurements before reporting security statistics.")
    raise SystemExit(0)

tp = tn = fp = fn = 0
for r in rows:
    present = b(r["trojan_present"])
    detected = b(r["detected"])
    if present and detected:
        tp += 1
    elif present and not detected:
        fn += 1
    elif not present and detected:
        fp += 1
    else:
        tn += 1

print(f"TP={tp} TN={tn} FP={fp} FN={fn}")
print(f"TPR={ratio(tp, tp + fn):.6f}")
print(f"FPR={ratio(fp, fp + tn):.6f}")
print(f"Precision={ratio(tp, tp + fp):.6f}")
print(f"F1={ratio(2 * tp, 2 * tp + fp + fn):.6f}")

trojan_rows = [r for r in rows if b(r["trojan_present"])]
if trojan_rows:
    confusion = Counter(
        (r["expected_localization"].strip(), r["localization_code"].strip())
        for r in trojan_rows
    )
    correct = sum(n for (expected, actual), n in confusion.items() if expected == actual)
    total = sum(confusion.values())
    print(f"Localization accuracy={ratio(correct, total):.6f}")

    print("Localization confusion matrix (expected -> actual):")
    for (expected, actual), n in sorted(confusion.items()):
        print(f"  {expected} -> {actual}: {n}")
else:
    print("Localization accuracy=nan (no Trojan-present runs)")

workloads = Counter(r["workload_id"] for r in rows)
print(f"Measured rows={len(rows)}")
print(f"Workloads={len(workloads)}")

if tp + fn == 0:
    print("WARNING: no Trojan-present runs; TPR is not measurable.")
if fp + tn == 0:
    print("WARNING: no Trojan-absent runs; FPR is not measurable.")
if len(workloads) < 2:
    print("WARNING: fewer than two workloads; cross-workload robustness is not measurable.")
