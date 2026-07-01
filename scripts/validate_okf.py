#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""validate_okf.py — Gác cổng CI cho OKF v1.0 (§9).

Dùng: python3 validate_okf.py <schema.json> <file_or_glob...>
Kiểm: schema frontmatter + regex doc_id + duy nhất + semver + ISO date +
enum + related không gãy + changelog có >=1 mục và mục mới nhất khớp version.
"""
import sys, re, json, glob, datetime
import yaml
from jsonschema import Draft202012Validator

ID_RE = re.compile(r"^[A-Z]+-[A-Z]+-[A-Z0-9]+-\d{3}$")
SEMVER = re.compile(r"^\d+\.\d+\.\d+$")


def coerce_dates(o):
    """YAML parse ngày không-quote thành date -> chuẩn hóa về ISO string."""
    if isinstance(o, dict):
        return {k: coerce_dates(v) for k, v in o.items()}
    if isinstance(o, list):
        return [coerce_dates(x) for x in o]
    if isinstance(o, (datetime.date, datetime.datetime)):
        return o.isoformat()[:10]
    return o


def parse_frontmatter(text):
    m = re.match(r"^---\n(.*?)\n---", text, re.S)
    if not m:
        return None
    return coerce_dates(yaml.safe_load(m.group(1)))


def collect_ids(files):
    ids = {}
    for f in files:
        fm = parse_frontmatter(open(f, encoding="utf-8").read())
        if fm and "doc_id" in fm:
            ids.setdefault(fm["doc_id"], []).append(f)
    return ids


def validate_file(f, fm, validator, all_ids):
    errs = []
    if fm is None:
        return ["[S1] Không parse được YAML frontmatter."]
    # Schema (§9.2, §9.4 semver, §9.5 date, §9.6 enum)
    for e in validator.iter_errors(fm):
        errs.append(f"[schema] {'/'.join(map(str, e.path)) or '(root)'}: {e.message}")
    # §9.3 doc_id regex + duy nhất
    did = str(fm.get("doc_id", ""))
    if not ID_RE.match(did):
        errs.append(f"[S3] doc_id sai regex: {did}")
    elif len(all_ids.get(did, [])) > 1:
        errs.append(f"[S3] doc_id trùng ở: {all_ids[did]}")
    # §9.5 updated >= created
    c, u = fm.get("created"), fm.get("updated")
    if c and u and str(u) < str(c):
        errs.append(f"[S5] updated ({u}) < created ({c})")
    # §9.7 related không gãy
    for r in fm.get("related", []) or []:
        if r not in all_ids:
            errs.append(f"[T] related gãy: {r}")
    # §9.8 changelog >=1 & mục mới nhất khớp version
    cl = fm.get("changelog") or []
    if not cl:
        errs.append("[S8] changelog rỗng")
    elif cl[0].get("version") != fm.get("version"):
        errs.append(f"[S8] changelog[0].version ({cl[0].get('version')}) != version ({fm.get('version')})")
    return errs


def main():
    if len(sys.argv) < 3:
        print("Usage: validate_okf.py <schema.json> <file_or_glob...>"); sys.exit(2)
    schema = json.load(open(sys.argv[1], encoding="utf-8"))
    validator = Draft202012Validator(schema)
    files = []
    for pat in sys.argv[2:]:
        files += glob.glob(pat, recursive=True)
    files = sorted(set(files))
    all_ids = collect_ids(files)

    total, failed = 0, 0
    for f in files:
        fm = parse_frontmatter(open(f, encoding="utf-8").read())
        # Bỏ qua file skeleton template (owner rỗng, doc_id ...-001 mẫu) nếu muốn:
        errs = validate_file(f, fm, validator, all_ids)
        total += 1
        status = "PASS" if not errs else "FAIL"
        if errs:
            failed += 1
        print(f"[{status}] {f}")
        for e in errs:
            print("        " + e)
    print(f"\n=> {total - failed}/{total} PASS, {failed} FAIL")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
