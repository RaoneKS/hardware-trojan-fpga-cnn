#!/usr/bin/env python3
"""Generate research-quality statistics from verification/results/runs.csv."""
from __future__ import annotations
import csv, math, statistics
from collections import defaultdict
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
PATH=ROOT/"verification/results/runs.csv"
OUT=ROOT/"verification/results"
REQUIRED={"workload_id","trojan_id","trojan_present","predicted_class","expected_class","detected","expected_localization","localization_code","inference_cycles","detection_cycle","detection_latency_cycles"}
def b(v): return str(v).strip().lower() in {"1","true","yes","y"}
def f(v):
    try: return float(v)
    except (TypeError,ValueError): return math.nan
def metric(a,d): return a/d if d else math.nan
with PATH.open(newline="") as fh: rows=list(csv.DictReader(fh))
if not rows: print("No measured runs. Nothing synthetic was generated."); raise SystemExit(0)
missing=REQUIRED-set(rows[0])
if missing: raise SystemExit("runs.csv missing columns: "+", ".join(sorted(missing)))
for r in rows:
    r["_present"]=b(r["trojan_present"]); r["_detected"]=b(r["detected"]); r["_cycles"]=f(r["inference_cycles"])
tp=sum(r["_present"] and r["_detected"] for r in rows); fn=sum(r["_present"] and not r["_detected"] for r in rows)
fp=sum((not r["_present"]) and r["_detected"] for r in rows); tn=sum((not r["_present"]) and not r["_detected"] for r in rows)
loc=[r for r in rows if r["_present"]]; correct=sum(r["expected_localization"].strip()==r["localization_code"].strip() for r in loc)
healthy=[r for r in rows if not r["_present"] and math.isfinite(r["_cycles"])]
baseline=statistics.mean(r["_cycles"] for r in healthy) if healthy else math.nan
by_trojan=defaultdict(list)
for r in rows:
    if r["_present"] and math.isfinite(r["_cycles"]): by_trojan[r["trojan_id"]].append(r["_cycles"])
OUT.mkdir(parents=True,exist_ok=True); out=OUT/"METRICS_SUMMARY.md"
with out.open("w") as fh:
    fh.write("# Measured Evaluation Summary\n\n")
    fh.write("Generated only from measured rows in verification/results/runs.csv; no synthetic measurements are inserted.\n\n")
    fh.write(f"TP={tp}, TN={tn}, FP={fp}, FN={fn}\n\n")
    fh.write(f"TPR={metric(tp,tp+fn):.6f}\nFPR={metric(fp,fp+tn):.6f}\nPrecision={metric(tp,tp+fp):.6f}\nF1={metric(2*tp,2*tp+fp+fn):.6f}\n\n")
    fh.write(f"Localization accuracy={metric(correct,len(loc)):.6f}\n\n")
    fh.write(f"Measured rows={len(rows)}\n")
    fh.write(f"Workloads={len(set(r["workload_id"] for r in rows))}\n\n")
    fh.write("| Trojan | N | Mean cycles | Min | Max | Overhead vs healthy mean |\n|---|---:|---:|---:|---:|---:|\n")
    for t,vals in sorted(by_trojan.items()):
        mean=statistics.mean(vals); overhead=(mean/baseline-1)*100 if math.isfinite(baseline) and baseline else math.nan
        fh.write(f"| {t} | {len(vals)} | {mean:.2f} | {min(vals):.0f} | {max(vals):.0f} | {overhead:.2f}% |\n")
print(f"Wrote {out}")