---
okf_version: "1.0"
doc_id: "BA-URD-PROJECT-001"
title: "URD — <Tên chức năng>"
type: "URD"
role: "BA"
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
  Tài liệu yêu cầu người dùng cho <chức năng>: mô tả, business rule và đặc tả trường màn hình.
keywords: ["URD", "yêu cầu"]
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

# URD — <Tên chức năng>

## Summary
<Mở rộng từ summary frontmatter.>

## Mô tả (Description)
Actor, Trigger, Pre/Post-conditions.

## Luồng thực hiện
| Bước | Mô tả | Actor |
|------|-------|-------|
| 1 | ... | Người dùng |

## Yêu cầu chức năng
- FR-01: ...

## Yêu cầu phi chức năng
- NFR-01: ...

## Business Rule
| BR ID | Mô tả |
|-------|-------|
| BR01 | ... |

## Đặc tả trường màn hình
| STT | Tên trường | Bắt buộc | Kiểu | Mô tả |
|-----|-----|-----|-----|-----|
| 1 | ... | Y | Textbox | ... |

## Related
- `<doc_id>` — <mô tả>

## Changelog
| Version | Date | Author | Change |
|---------|------------|--------|--------------------|
| 1.0.0 | 2026-07-01 | | Khởi tạo tài liệu. |

<!-- VALIDATION (type-specific) — ngoài rule chung §9:
  - role BẮT BUỘC = BA, type = URD
  - Section body BẮT BUỘC: Mô tả (Description), Business Rule, Đặc tả trường màn hình
  - Thay PROJECT bằng mã dự án thật; xem golden example: examples/BA-URD-DEMO-001.md -->
