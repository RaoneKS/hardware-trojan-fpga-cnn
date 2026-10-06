#!/usr/bin/env python3
import os
import sys
import shutil
import subprocess
import csv
import re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RESULTS_DIR = os.path.join(ROOT, "verification/results")
WORKLOADS_MANIFEST = os.path.join(ROOT, "verification/workloads/workload_manifest.csv")
RUNS_CSV = os.path.join(RESULTS_DIR, "runs.csv")

os.makedirs(RESULTS_DIR, exist_ok=True)

# Load workloads
workloads = []
with open(WORKLOADS_MANIFEST, newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        workloads.append(row)

designs = [
    ("Healthy", False, "00"),
    ("T1", True, "01"),
    ("T2", True, "10"),
    ("T3", True, "11"),
    ("T4", True, "11"),
    ("T5", True, "11"),
]

output_rows = []

print(f"Starting regression: {len(workloads)} workloads x {len(designs)} designs = {len(workloads)*len(designs)} runs.")

fieldnames = [
    "workload_id",
    "trojan_id",
    "trojan_present",
    "trigger_location",
    "predicted_class",
    "expected_class",
    "detected",
    "expected_localization",
    "localization_code",
    "inference_cycles",
    "detection_cycle",
    "detection_latency_cycles",
    "status"
]

# We will use a single reused sandbox directory to keep disk usage near zero
sandbox = "/tmp/sim_reg_active"

for w in workloads:
    w_id = w["workload_id"]
    exp_class = w["label"]
    mem_file = os.path.join(ROOT, w["mem_path"])

    for trojan_id, trojan_present, exp_loc in designs:
        print(f"Running Workload {w_id} (exp {exp_class}) on {trojan_id}...", end="", flush=True)

        if os.path.exists(sandbox):
            shutil.rmtree(sandbox)
        os.makedirs(sandbox, exist_ok=True)
        os.makedirs(os.path.join(sandbox, "data"), exist_ok=True)

        # Symlink weights to avoid copying and symlink memory image
        for item in os.listdir(os.path.join(ROOT, "cnn_baseline/data/int8")):
            src = os.path.join(ROOT, "cnn_baseline/data/int8", item)
            dst_dir = os.path.join(sandbox, "data/int8")
            os.makedirs(dst_dir, exist_ok=True)
            os.symlink(src, os.path.join(dst_dir, item))

        shutil.copy(mem_file, os.path.join(sandbox, "data/mnist_image0_int8.mem"))

        if trojan_id == "Healthy":
            tb_orig = os.path.join(ROOT, "cnn_full_small/tb/tb_cnn_small_core.v")
            top_file = os.path.join(ROOT, "cnn_full_small/rtl/cnn_fpga_top.v")
            core_file = os.path.join(ROOT, "cnn_full_small/rtl/cnn_small_core_m10k.v")
            trigger_loc = "NONE"
        else:
            tb_orig = os.path.join(ROOT, f"trojan_{trojan_id}/tb/tb_cnn_small_core.v")
            top_file = os.path.join(ROOT, f"trojan_{trojan_id}/rtl/cnn_fpga_top.v")
            core_file = os.path.join(ROOT, f"trojan_{trojan_id}/rtl/cnn_small_core_m10k.v")
            trigger_loc = "Conv2_PE" if trojan_id == "T1" else ("Conv2_Weight" if trojan_id == "T2" else ("Conv2_Interconnect" if trojan_id in ["T3", "T4"] else "Conv2_Control"))

        # Strip $dumpfile and $dumpvars so vcd files are not created to prevent disk bloat
        with open(tb_orig) as f_tb:
            tb_content = f_tb.read()
        tb_content_nodump = re.sub(r'\$dump[a-z]+\([^)]*\);', '', tb_content)
        tb_file = os.path.join(sandbox, "tb.v")
        with open(tb_file, "w") as f_tb_out:
            f_tb_out.write(tb_content_nodump)

        sim_bin = os.path.join(sandbox, "sim.vvp")
        compile_cmd = ["iverilog", "-g2012", "-o", sim_bin, tb_file, top_file, core_file]
        res = subprocess.run(compile_cmd, cwd=sandbox, capture_output=True, text=True)
        if res.returncode != 0:
            print(f" COMPILE FAIL: {res.stderr}")
            continue

        run_cmd = ["vvp", sim_bin]
        try:
            res_run = subprocess.run(run_cmd, cwd=sandbox, capture_output=True, text=True, timeout=60)
            log = res_run.stdout
        except subprocess.TimeoutExpired:
            print(" TIMEOUT")
            continue

        # Parse outputs
        pred_match = re.search(r"Predicted class\s*=\s*(\d+)", log)
        pred_class = pred_match.group(1) if pred_match else "nan"

        cyc_match = re.search(r"Cycle count\s*=\s*(\d+)", log)
        inf_cycles = cyc_match.group(1) if cyc_match else "nan"

        if trojan_id == "Healthy":
            detected = 0
            loc_code = "00"
            det_cycle = "0"
            det_lat = "0"
            status = "PASS" if pred_class == exp_class else "FAIL_PRED"
        else:
            det_match = re.search(rf"{trojan_id}_DETECTED\s*=\s*([01])", log)
            if det_match:
                detected = int(det_match.group(1))
            else:
                dcyc_tmp = re.search(rf"{trojan_id}_DETECTION_CYCLE\s*=\s*(\d+)", log)
                detected = 1 if (dcyc_tmp and int(dcyc_tmp.group(1)) > 0) else 0

            dcyc_match = re.search(rf"{trojan_id}_DETECTION_CYCLE\s*=\s*(\d+)", log)
            det_cycle = dcyc_match.group(1) if dcyc_match else "0"

            dlat_match = re.search(r"DETECTION_LATENCY\s*=\s*(\d+)", log)
            det_lat = dlat_match.group(1) if dlat_match else "0"

            loc_match = re.search(r"LOCALIZATION_OUTPUT\s*=\s*2'b([01]{2})", log)
            loc_code = loc_match.group(1) if loc_match else "00"

            status = "PASS" if (detected == 1 and loc_code == exp_loc) else "FAIL_DET"

        row_dict = {
            "workload_id": w_id,
            "trojan_id": trojan_id,
            "trojan_present": 1 if trojan_present else 0,
            "trigger_location": trigger_loc,
            "predicted_class": pred_class,
            "expected_class": exp_class,
            "detected": detected,
            "expected_localization": exp_loc,
            "localization_code": loc_code,
            "inference_cycles": inf_cycles,
            "detection_cycle": det_cycle,
            "detection_latency_cycles": det_lat,
            "status": status
        }
        output_rows.append(row_dict)
        print(f" Done. Pred={pred_class}, Det={detected}, Loc={loc_code}, Lat={det_lat}, Cycles={inf_cycles}")

# Cleanup sandbox
if os.path.exists(sandbox):
    shutil.rmtree(sandbox)

# Write to verification/results/runs.csv
with open(RUNS_CSV, "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(output_rows)

print(f"\nRegression completed successfully. Wrote {len(output_rows)} rows to {RUNS_CSV}")
