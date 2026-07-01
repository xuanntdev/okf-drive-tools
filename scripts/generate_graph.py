#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""generate_graph.py — sinh `_graph.json` từ field `related` trong frontmatter OKF.

Dùng: python3 generate_graph.py <file_or_glob...> [--out _graph.json]

`_graph.json` là build-artifact suy ra từ frontmatter (không phải kho dữ liệu sống):
  - nodes: mỗi doc quét được, kèm metadata rẻ (type/role/project/status) để lọc
    trước khi mở body.
  - edges: mỗi cặp (doc_id -> related_id) khai báo trong `related:`.
  - broken: related_id không khớp doc_id nào trong tập file đang quét (cảnh báo,
    không phải lỗi cứng — related có thể trỏ tới doc ở project/lượt scan khác).

Chạy lại toàn bộ mỗi khi có doc mới/sửa — không incremental, không DB.
"""
import sys
import re
import json
import glob
import argparse
import datetime

FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---", re.S)


def coerce_dates(o):
    if isinstance(o, dict):
        return {k: coerce_dates(v) for k, v in o.items()}
    if isinstance(o, list):
        return [coerce_dates(x) for x in o]
    if isinstance(o, (datetime.date, datetime.datetime)):
        return o.isoformat()[:10]
    return o


def parse_frontmatter(text):
    import yaml
    m = FRONTMATTER_RE.match(text)
    if not m:
        return None
    return coerce_dates(yaml.safe_load(m.group(1)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("patterns", nargs="+", help="file hoặc glob (hỗ trợ **)")
    ap.add_argument("--out", default="_graph.json", help="đường dẫn file output")
    args = ap.parse_args()

    files = []
    for pat in args.patterns:
        files += glob.glob(pat, recursive=True)
    files = sorted(set(files))

    nodes = {}
    edges = []
    skipped = []

    for f in files:
        try:
            text = open(f, encoding="utf-8").read()
        except Exception as e:
            skipped.append({"file": f, "reason": str(e)})
            continue
        fm = parse_frontmatter(text)
        if fm is None or "doc_id" not in fm:
            skipped.append({"file": f, "reason": "không có frontmatter / không có doc_id"})
            continue
        doc_id = str(fm["doc_id"])
        if doc_id in nodes:
            skipped.append({"file": f, "reason": f"doc_id trùng (đã có ở {nodes[doc_id]['file']})"})
            continue
        nodes[doc_id] = {
            "doc_id": doc_id,
            "type": fm.get("type"),
            "role": fm.get("role"),
            "project": fm.get("project"),
            "status": fm.get("status"),
            "title": fm.get("title"),
            "file": f,
        }

    for doc_id, node in nodes.items():
        fm = parse_frontmatter(open(node["file"], encoding="utf-8").read())
        for rel in (fm.get("related") or []):
            rel = str(rel)
            edges.append({
                "from": doc_id,
                "to": rel,
                "broken": rel not in nodes,
            })

    out = {
        "generated_at": datetime.date.today().isoformat(),
        "source_files_scanned": len(files),
        "nodes": [
            {k: v for k, v in n.items() if k != "file"}
            for n in nodes.values()
        ],
        "edges": edges,
    }

    with open(args.out, "w", encoding="utf-8") as fh:
        json.dump(out, fh, ensure_ascii=False, indent=2)
        fh.write("\n")

    broken = [e for e in edges if e["broken"]]
    print(f"Node: {len(nodes)} | Edge: {len(edges)} (gãy: {len(broken)}) | Bỏ qua: {len(skipped)}")
    for s in skipped:
        print(f"  [bỏ qua] {s['file']}: {s['reason']}")
    for e in broken:
        print(f"  [related gãy] {e['from']} -> {e['to']}")
    print(f"→ đã ghi {args.out}")


if __name__ == "__main__":
    main()
