#!/usr/bin/env python3
"""Lightweight Icarus VCD activity summarizer.

This is a simulation activity proxy, not a physical power measurement.
It reports value-change counts and binary bit transitions per VCD signal.
"""

from __future__ import annotations

import csv
import re
import sys
from pathlib import Path


VAR_RE = re.compile(r"\$var\s+\S+\s+(\d+)\s+(\S+)\s+(.+?)\s+\$end")


def normalize(value: str, width: int) -> str:
    value = value.lower()
    if value.startswith("b"):
        bits = value[1:]
    else:
        bits = value
    if len(bits) < width:
        bits = bits.rjust(width, "0")
    return bits[-width:]


def bit_delta(old: str, new: str) -> int:
    width = max(len(old), len(new))
    old = old.rjust(width, "x")
    new = new.rjust(width, "x")
    return sum(a != b and a in "01" and b in "01" for a, b in zip(old, new))


def summarize(vcd: Path):
    signals: dict[str, dict] = {}
    current: dict[str, str] = {}
    in_header = True
    time_value_changes = 0
    bit_transitions = 0

    with vcd.open("r", errors="replace") as f:
        for raw in f:
            line = raw.strip()
            if not line:
                continue

            if line.startswith("$var"):
                m = VAR_RE.match(line)
                if m:
                    width, ident, name = m.groups()
                    signals[ident] = {
                        "width": int(width),
                        "name": name.split()[0],
                        "value_changes": 0,
                        "bit_transitions": 0,
                    }
                continue

            if line.startswith("$enddefinitions"):
                in_header = False
                continue

            if in_header or line.startswith("$"):
                continue

            ident = None
            value = None

            if line[0] in "01xXzZ":
                value = line[0]
                ident = line[1:].strip()
            elif line[0] in "bBrR":
                parts = line.split()
                if len(parts) == 2:
                    value, ident = parts

            if ident not in signals or value is None:
                continue

            meta = signals[ident]
            new_value = normalize(value, meta["width"])

            if ident in current:
                if current[ident] != new_value:
                    delta = bit_delta(current[ident], new_value)
                    meta["value_changes"] += 1
                    meta["bit_transitions"] += delta
                    time_value_changes += 1
                    bit_transitions += delta
            current[ident] = new_value

    rows = []
    for meta in signals.values():
        rows.append(meta)
    rows.sort(key=lambda x: (-x["bit_transitions"], -x["value_changes"], x["name"]))
    return signals, rows, time_value_changes, bit_transitions


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} INPUT.vcd OUTPUT.csv", file=sys.stderr)
        return 2

    vcd = Path(sys.argv[1])
    out = Path(sys.argv[2])
    if not vcd.is_file():
        print(f"VCD not found: {vcd}", file=sys.stderr)
        return 2

    _, rows, value_changes, bit_transitions = summarize(vcd)
    out.parent.mkdir(parents=True, exist_ok=True)

    with out.open("w", newline="") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=["signal", "width", "value_changes", "bit_transitions"],
        )
        writer.writeheader()
        for row in rows:
            writer.writerow({
                "signal": row["name"],
                "width": row["width"],
                "value_changes": row["value_changes"],
                "bit_transitions": row["bit_transitions"],
            })

    non_clock = [
        r for r in rows
        if not any(token in r["signal"].lower() for token in ("clk", "clock"))
    ]
    non_clock_changes = sum(r["value_changes"] for r in non_clock)
    non_clock_bits = sum(r["bit_transitions"] for r in non_clock)

    print(f"VCD={vcd}")
    print(f"Signals={len(rows)}")
    print(f"Value changes={value_changes}")
    print(f"Binary bit transitions={bit_transitions}")
    print(f"Non-clock value changes={non_clock_changes}")
    print(f"Non-clock binary bit transitions={non_clock_bits}")
    print(f"CSV={out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
