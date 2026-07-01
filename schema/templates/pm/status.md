---
okf_version: "1.0"
doc_id: "PM-STATUS-PROJECT-001"
title: "Báo cáo trạng thái — <Kỳ>"
type: "Status"
role: "PM"
project: "PROJECT"
domain: ""
version: "1.0.0"
status: "draft"
language: "vi"
owner: ""
contributors: []
created: 2026-07-01
updated: 2026-07-01
# review_by:
audience: ["human", "machine"]
summary: >
  Báo cáo trạng thái tiến độ, hạng mục hoàn thành và blocker của <kỳ>.
keywords: ["status", "tiến độ"]
source:
  - system: "manual"
    ref: ""
related: []
access: "internal"
template_version: "1.0.0"
changelog:
  - version: "1.0.0"
    date: 2026-07-01
    author: ""
    change: "Khởi tạo tài liệu."
---

# Báo cáo trạng thái — <Kỳ>

## Summary
<Mở rộng từ summary frontmatter.>

## Tổng quan
...

## Tiến độ theo hạng mục
| Hạng mục | % | Ghi chú |
|----------|---|---------|
| ... | 0% | ... |

## Blocker
- ...

## Related
- `<doc_id>` — <mô tả>

## Changelog
| Version | Date | Author | Change |
|---------|------------|--------|--------------------|
| 1.0.0 | 2026-07-01 | | Khởi tạo tài liệu. |

<!-- VALIDATION (type-specific) — ngoài rule chung §9:
  - role BẮT BUỘC = PM, type = Status
  - Section body BẮT BUỘC: Tổng quan, Tiến độ theo hạng mục, Blocker
  - Thay PROJECT bằng mã dự án thật; xem golden example: examples/PM-STATUS-DEMO-001.md -->
