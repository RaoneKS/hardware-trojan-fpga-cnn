#!/usr/bin/env python3
import csv
import math
from collections import Counter

PATH = "verification/results/runs.csv"

rows = []
with open(PATH, newline="") as f:
    for r in csv.DictReader(f):
        rows.append(r)

def b(v):
    return str(v).strip().lower() in {"1","true","yes","y"}

tp=tn=fp=fn=0
for r in rows:
    present=b(r["trojan_present"])
    detected=b(r["detected"])
    if present and detected: tp += 1
    elif present and not detected: fn += 1
    elif not present and detected: fp += 1
    else: tn += 1

def ratio(a,d):
    return a/d if d else math.nan

print(f"TP={tp} TN={tn} FP={fp} FN={fn}")
print(f"TPR={ratio(tp,tp+fn):.6f}")
print(f"FPR={ratio(fp,fp+tn):.6f}")
print(f"Precision={ratio(tp,tp+fp):.6f}")
print(f"F1={ratio(2*tp,2*tp+fp+fn):.6f}")

loc = Counter()
for r in rows:
    if b(r["trojan_present"]):
        loc[(r["expected_localization"], r["localization_code"])] += 1

correct = sum(n for (expected,actual),n in loc.items() if expected == actual)
total = sum(loc.values())
print(f"Localization accuracy={ratio(correct,total):.6f}")
