#!/usr/bin/env python3
"""Compatibility entry point for the canonical hardware-Trojan regression."""

from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
runner = ROOT / "verification" / "run_full_matrix.sh"

result = subprocess.run(["bash", str(runner)], cwd=ROOT)
sys.exit(result.returncode)
