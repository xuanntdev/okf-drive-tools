---
okf_version: "1.0"
doc_id: "DEV-TECHDESIGN-PROJECT-001"
title: "Tech Design — <Chức năng>"
type: "TechDesign"
role: "DEV"
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
  Thiết kế kỹ thuật cho <chức năng>: giải pháp, data model, API contract, edge case.
keywords: ["tech design", "API", "schema"]
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

# Tech Design — <Chức năng>

## Summary
<Mở rộng từ summary frontmatter.>

## Giải pháp
...

## Data model
...

## API contract
| Method | Endpoint | Request | Response | Error |
|-----|-----|-----|-----|-----|
| POST | ... | ... | ... | ... |

## Xử lý edge case & lỗi
- ...

## Related
- `<doc_id>` — <mô tả>

## Changelog
| Version | Date | Author | Change |
|---------|------------|--------|--------------------|
| 1.0.0 | 2026-07-01 | | Khởi tạo tài liệu. |

<!-- VALIDATION (type-specific) — ngoài rule chung §9:
  - role BẮT BUỘC = DEV, type = TechDesign
  - Section body BẮT BUỘC: Giải pháp, API contract, Xử lý edge case & lỗi
  - Thay PROJECT bằng mã dự án thật; xem golden example: examples/DEV-TECHDESIGN-DEMO-001.md -->
