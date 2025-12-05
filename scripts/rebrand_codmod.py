#!/usr/bin/env python3
"""
rebrand_codmod.py

Searches the repository for user-visible occurrences of a brand string and optionally replaces them.

Default behavior is a dry-run that prints matches (file, line, snippet). Use --apply to write changes.

Designed to be conservative: by default it only touches files likely to contain UI-visible text (locales, views, seeders, docs,
and public metadata). It avoids frontend source and code files unless --include-frontend is passed.

Usage examples:
  # Dry-run (default)
  ./scripts/rebrand_codmod.py

  # Dry-run for a different replacement
  ./scripts/rebrand_codmod.py --from "OpenProject" --to "MarvalProject"

  # Apply changes
  ./scripts/rebrand_codmod.py --apply

  # Include frontend files (use with caution)
  ./scripts/rebrand_codmod.py --include-frontend --apply

"""
from __future__ import annotations
import argparse
import fnmatch
import os
import re
import sys
from pathlib import Path
from typing import List, Tuple


DEFAULT_FROM = "OpenProject"
# Use plural "MarvalProjects" per request (labels only)
DEFAULT_TO = "MarvalProjects"

# Conservative default file globs to operate on (user-visible content only)
# Conservative, narrow scope: only language / seeder YAML files (labels & error messages)
DEFAULT_GLOBS = [
    "config/locales/**/*.yml",
    "modules/**/config/locales/**/*.yml",
    "app/seeders/**/*.yml",
    "modules/**/app/seeders/**/*.yml",
    # some projects keep seed data under db/seeders or db/seeds/*.yml
    "db/seeders/**/*.yml",
    "db/seeds/**/*.yml",
]

# Optional frontend globs (may include import paths and other code; use cautiously)
FRONTEND_GLOBS = [
    "frontend/**",
    "modules/**/frontend/**",
]


def iter_files_from_globs(root: Path, globs: List[str]):
    seen = set()
    for g in globs:
        for p in root.glob(g):
            if p.is_file():
                # canonicalize
                try:
                    k = str(p.resolve())
                except Exception:
                    k = str(p)
                # only operate on YAML files (language and seeder files) to avoid touching
                # runtime code, HTML, or documentation.
                if p.suffix.lower() not in ('.yml', '.yaml'):
                    continue
                if k not in seen:
                    seen.add(k)
                    yield p


def find_matches_in_text(text: str, needle: str) -> List[Tuple[int, int, str]]:
    # returns list of (start_pos, end_pos, snippet)
    flags = re.IGNORECASE
    pattern = re.compile(re.escape(needle), flags)
    matches = []
    lines = text.splitlines()
    for m in pattern.finditer(text):
        start, end = m.span()
        lineno = pos_to_lineno(text, start)
        line = lines[lineno - 1] if lineno <= len(lines) else ""
        # Skip comments (lines starting with #)
        if line.strip().startswith('#'):
            continue
        # Skip if preceded by 'www.' or followed by '.org'
        before = text[max(0, start - 10):start].lower()
        after = text[end:end + 10].lower()
        if before.endswith('www.') or after.startswith('.org'):
            continue
        # Skip if it's part of a YAML key (followed by ':' on the same line)
        start_of_line = text.rfind('\n', 0, start) + 1
        local_start = start - start_of_line
        end_local = local_start + len(needle)
        if ':' in line and line.find(':') > end_local:
            continue
        # create a small context snippet
        snip_start = max(0, start - 40)
        snip_end = min(len(text), end + 40)
        snippet = text[snip_start:snip_end].replace('\n', '\\n')
        matches.append((start, end, snippet))
    return matches


def pos_to_lineno(text: str, pos: int) -> int:
    return text.count("\n", 0, pos) + 1


def process_file(path: Path, from_s: str) -> List[dict]:
    content = path.read_text(encoding="utf-8", errors="ignore")
    matches = find_matches_in_text(content, from_s)
    results = []
    for start, end, snippet in matches:
        lineno = pos_to_lineno(content, start)
        results.append({
            "file": str(path),
            "lineno": lineno,
            "snippet": snippet,
        })
    return results


def replace_in_file(path: Path, matches: List[Tuple[int, int, str]], to_s: str) -> int:
    content = path.read_text(encoding="utf-8", errors="ignore")
    # Replace from the end to keep positions
    for start, end, _ in reversed(matches):
        content = content[:start] + to_s + content[end:]
    path.write_text(content, encoding="utf-8")
    return len(matches)


def main(argv: List[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="Conservative rebranding codemod for UI-visible strings")
    p.add_argument("--from", dest="from_s", default=DEFAULT_FROM, help="String to replace (case-insensitive)")
    p.add_argument("--to", dest="to_s", default=DEFAULT_TO, help="Replacement string")
    p.add_argument("--apply", action="store_true", help="Apply replacements (default: dry-run)")
    p.add_argument("--include-frontend", action="store_true", help="Also include frontend files (use with caution)")
    p.add_argument("--root", default=".", help="Repository root (default: current directory)")
    p.add_argument("--output-csv", default=None, help="Write matches to CSV file (dry-run or after apply)")
    args = p.parse_args(argv)

    root = Path(args.root).resolve()
    globs = list(DEFAULT_GLOBS)
    if args.include_frontend:
        globs.extend(FRONTEND_GLOBS)

    files = list(iter_files_from_globs(root, globs))
    total_matches = 0
    matches = []

    for f in files:
        res = process_file(f, args.from_s)
        if res:
            matches.extend(res)
            total_matches += len(res)

    if total_matches == 0:
        print(f"No matches for '{args.from_s}' found in {len(files)} files (using conservative globs).")
        return 0

    # Print matches grouped by file
    from collections import defaultdict
    by_file = defaultdict(list)
    for m in matches:
        by_file[m["file"]].append(m)

    print(f"Found {total_matches} matches in {len(by_file)} files (search='{args.from_s}' -> replace='{args.to_s}').")
    for file, items in sorted(by_file.items()):
        print(f"\n{file} ({len(items)} match{'es' if len(items)>1 else ''}):")
        for it in items[:20]:
            print(f"  line {it['lineno']:5d}: ...{it['snippet']}...")

    if args.output_csv:
        import csv
        with open(args.output_csv, "w", newline='', encoding="utf-8") as csvf:
            writer = csv.writer(csvf)
            writer.writerow(["file", "lineno", "snippet"])
            for m in matches:
                writer.writerow([m["file"], m["lineno"], m["snippet"]])
        print(f"Wrote CSV to {args.output_csv}")

    if not args.apply:
        print("\nDry-run complete. To apply the replacements, re-run with --apply (and --backup recommended).")
        return 0

    # Apply replacements
    total_replacements = 0
    for f in files:
        content = f.read_text(encoding="utf-8", errors="ignore")
        matches = find_matches_in_text(content, args.from_s)
        if matches:
            count = replace_in_file(f, matches, args.to_s)
            print(f"Replaced {count} occurrence(s) in: {f}")
            total_replacements += count

    print(f"\nApplied replacements: {total_replacements} total occurrences replaced.")
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
