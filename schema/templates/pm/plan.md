---
okf_version: "1.0"
doc_id: "PM-PLAN-PROJECT-001"
title: "Kế hoạch — <Sprint/Feature>"
type: "Plan"
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
  Kế hoạch triển khai cho <sprint/feature>: mục tiêu, milestone, trạng thái và rủi ro.
keywords: ["kế hoạch", "sprint", "milestone"]
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

# Kế hoạch — <Sprint/Feature>

## Summary
<Mở rộng từ summary frontmatter.>

## Mục tiêu & Phạm vi
- **Mục tiêu:** ...
- **In scope:** ...
- **Out of scope:** ...

## Milestone
| ID | Mốc | Ngày dự kiến | DoD | Trạng thái |
|----|-----|------|-----|------|
| M1 | ... | 2026-07-15 | ... | planned |

## Trạng thái
| Ngày | % | Tóm tắt | Blocker |
|------|---|---------|---------|
| 2026-07-01 | 0% | ... | ... |

## Rủi ro
| ID | Rủi ro | KN (L/M/H) | TĐ (L/M/H) | Giảm thiểu | Owner |
|----|--------|-----|-----|-----|-------|
| R1 | ... | M | H | ... | ... |

## Related
- `<doc_id>` — <mô tả>

## Changelog
| Version | Date | Author | Change |
|---------|------------|--------|--------------------|
| 1.0.0 | 2026-07-01 | | Khởi tạo tài liệu. |

<!-- VALIDATION (type-specific) — ngoài rule chung §9:
  - role BẮT BUỘC = PM, type = Plan
  - Section body BẮT BUỘC: Mục tiêu & Phạm vi, Milestone, Trạng thái, Rủi ro
  - Thay PROJECT bằng mã dự án thật; xem golden example: examples/PM-PLAN-DEMO-001.md -->
