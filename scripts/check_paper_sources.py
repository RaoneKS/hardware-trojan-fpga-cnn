#!/usr/bin/env python3
"""Static checks for the paper source, bibliography, and professor figures."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
paper = ROOT / "paper"
md = (paper / "manuscript.md").read_text(encoding="utf-8")
tex = (paper / "ieee_paper.tex").read_text(encoding="utf-8")
bib = (paper / "references" / "references.bib").read_text(encoding="utf-8")

errors = []
bib_keys = set(re.findall(r"@\w+\s*\{\s*([^,\s]+)\s*,", bib))
cite_keys = set()
for match in re.finditer(r"\\cite\w*\s*\{([^}]+)\}", tex):
    cite_keys.update(k.strip() for k in match.group(1).split(",") if k.strip())
missing = sorted(cite_keys - bib_keys)
if missing:
    errors.append("Unresolved BibTeX citation keys: " + ", ".join(missing))
if "\\bibliographystyle{IEEEtran}" not in tex or "\\bibliography{references/references}" not in tex:
    errors.append("IEEE LaTeX source is missing its IEEEtran bibliography directives.")

figure_paths = re.findall(r"!\[[^]]*\]\((figures/figure(\d+)_professor\.svg)\)", md)
figure_numbers = {int(n) for _, n in figure_paths}
missing_files = [p for p, _ in figure_paths if not (paper / p).is_file()]
if missing_files:
    errors.append("Missing embedded figure files: " + ", ".join(missing_files))
required = set(range(13, 28))
if figure_numbers != required:
    errors.append(f"Professor figure set must be exactly 13–27; found {sorted(figure_numbers)}.")
if len(re.findall(r"^\[\d+\] ", md, re.MULTILINE)) < 10:
    errors.append("Markdown manuscript must include at least 10 numbered references.")

if errors:
    print("PAPER SOURCE CHECK FAILED")
    for err in errors:
        print(" - " + err)
    sys.exit(1)

print(f"PASS: {len(cite_keys)} LaTeX citation keys resolve to {len(bib_keys)} BibTeX entries.")
print(f"PASS: professor figures 13–27 are embedded and exist ({len(figure_paths)} figures).")
print(f"PASS: Markdown bibliography contains {len(re.findall(r'^\[\d+\] ', md, re.MULTILINE))} numbered references.")
