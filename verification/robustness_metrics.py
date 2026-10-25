#!/usr/bin/env python3
"""Reproducible detection metrics with explicit uncertainty estimates.

TPR/FPR/precision use Wilson score intervals. F1 uses a deterministic cluster
bootstrap that resamples workload IDs, preserving rows within each workload.
These intervals describe the supplied ledger only; they do not imply generalization.
"""
from __future__ import annotations
import argparse, csv, json, math, random
from collections import defaultdict
from pathlib import Path

REQUIRED = {"trojan_present", "detected", "workload_id"}

def as_bool(value):
    v = str(value).strip().lower()
    if v in {"1", "true", "yes", "y"}: return True
    if v in {"0", "false", "no", "n"}: return False
    raise ValueError(f"Expected boolean-like 0/1 value, got {value!r}")

def wilson_interval(successes, total, z=1.959963984540054):
    if total <= 0: return None
    if successes < 0 or successes > total: raise ValueError("successes must be between 0 and total")
    p = successes / total
    z2 = z*z
    denom = 1 + z2/total
    center = (p + z2/(2*total))/denom
    half = z*math.sqrt((p*(1-p) + z2/(4*total))/total)/denom
    return [max(0.0, center-half), min(1.0, center+half)]

def confusion(rows):
    tp=tn=fp=fn=0
    for r in rows:
        present, detected = r["_present"], r["_detected"]
        if present and detected: tp += 1
        elif present: fn += 1
        elif detected: fp += 1
        else: tn += 1
    return {"tp":tp, "tn":tn, "fp":fp, "fn":fn}

def divide(a,b): return a/b if b else None

def derived(c):
    tp,tn,fp,fn=(c[k] for k in ("tp","tn","fp","fn"))
    tpr=divide(tp,tp+fn); fpr=divide(fp,fp+tn); precision=divide(tp,tp+fp)
    f1=divide(2*tp,2*tp+fp+fn)
    return {
        "tpr":{"estimate":tpr,"ci95":wilson_interval(tp,tp+fn)},
        "fpr":{"estimate":fpr,"ci95":wilson_interval(fp,fp+tn)},
        "precision":{"estimate":precision,"ci95":wilson_interval(tp,tp+fp)},
        "f1":{"estimate":f1,"ci95":None},
    }

def load_rows(path):
    with path.open(newline="",encoding="utf-8") as f:
        reader=csv.DictReader(f)
        missing=REQUIRED-set(reader.fieldnames or [])
        if missing: raise ValueError("Missing required columns: "+", ".join(sorted(missing)))
        rows=[]
        for line_no,r in enumerate(reader,start=2):
            try:
                r["_present"]=as_bool(r["trojan_present"])
                r["_detected"]=as_bool(r["detected"])
                r["_workload"]=r["workload_id"].strip()
                if not r["_workload"]: raise ValueError("empty workload_id")
            except ValueError as exc: raise ValueError(f"{path}:{line_no}: {exc}") from exc
            rows.append(r)
    if not rows: raise ValueError(f"No measured rows found in {path}")
    return rows

def bootstrap_f1_ci(rows,iterations=4000,seed=20261026):
    clusters=defaultdict(list)
    for r in rows: clusters[r["_workload"]].append(r)
    keys=sorted(clusters)
    if len(keys)<2: return None
    rng=random.Random(seed); values=[]
    for _ in range(iterations):
        sample=[]
        for key in (rng.choice(keys) for _ in keys): sample.extend(clusters[key])
        v=derived(confusion(sample))["f1"]["estimate"]
        if v is not None and math.isfinite(v): values.append(v)
    if not values: return None
    values.sort()
    return [values[max(0,int(.025*(len(values)-1)))],values[min(len(values)-1,int(.975*(len(values)-1)))]]

def pct(v): return "NA" if v is None else f"{100*v:.2f}%"
def fmt_ci(ci): return "NA" if ci is None else f"[{pct(ci[0])}, {pct(ci[1])}]"

def analyze(rows,iterations=4000,seed=20261026):
    c=confusion(rows); m=derived(c); m["f1"]["ci95"]=bootstrap_f1_ci(rows,iterations,seed)
    return {
      "n_rows":len(rows),"n_workloads":len({r["_workload"] for r in rows}),
      "confusion":c,"metrics":m,
      "interval_methods":{
        "tpr":"Wilson score interval, two-sided 95%",
        "fpr":"Wilson score interval, two-sided 95%",
        "precision":"Wilson score interval, two-sided 95%",
        "f1":"Percentile cluster bootstrap over workload_id, 95%; deterministic seed"},
      "bootstrap_iterations":iterations,"bootstrap_seed":seed,
      "interpretation":("Intervals quantify uncertainty within the supplied ledger. Wilson intervals "
        "treat run outcomes as binomial observations; workload dependence may make them optimistic. "
        "F1 uses workload-cluster resampling. Selected or Healthy-screened workloads imply conditional "
        "estimates, not population-wide performance.")
    }

def write_report(result,outdir,input_path):
    outdir.mkdir(parents=True,exist_ok=True)
    (outdir/"ROBUSTNESS_METRICS.json").write_text(json.dumps(result,indent=2,sort_keys=True)+"\n",encoding="utf-8")
    lines=["# Robustness metrics with uncertainty","",
      f"- Input ledger: {input_path}",f"- Measured rows: {result['n_rows']}",
      f"- Distinct workloads: {result['n_workloads']}",
      f"- Confusion counts: TP={result['confusion']['tp']}, TN={result['confusion']['tn']}, FP={result['confusion']['fp']}, FN={result['confusion']['fn']}","",
      "| Metric | Estimate | 95% interval | Method |","|---|---:|---|---|"]
    for key,label in (("tpr","TPR / recall"),("fpr","FPR"),("precision","Precision"),("f1","F1")):
        v=result["metrics"][key]
        lines.append(f"| {label} | {pct(v['estimate'])} | {fmt_ci(v['ci95'])} | {result['interval_methods'][key]} |")
    lines += ["","## Interpretation and limits","",result["interpretation"],"",
      "These values are calculated from the supplied measured-run ledger. They do not establish unseen-Trojan performance, cross-model generalization, or physical-board statistical performance.",""]
    (outdir/"ROBUSTNESS_METRICS.md").write_text("\n".join(lines),encoding="utf-8")

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--input",type=Path,default=Path("verification/results/runs.csv"))
    p.add_argument("--output-dir",type=Path,default=Path("verification/results"))
    p.add_argument("--bootstrap-iterations",type=int,default=4000)
    p.add_argument("--seed",type=int,default=20261026)
    a=p.parse_args()
    if a.bootstrap_iterations<100: p.error("--bootstrap-iterations must be at least 100")
    rows=load_rows(a.input); result=analyze(rows,a.bootstrap_iterations,a.seed)
    write_report(result,a.output_dir,a.input)
    print(f"Metrics written for {result['n_rows']} rows / {result['n_workloads']} workloads.")
    for key,v in result["metrics"].items(): print(f"{key.upper()}={pct(v['estimate'])}; 95% CI={fmt_ci(v['ci95'])}")

if __name__=="__main__": main()
