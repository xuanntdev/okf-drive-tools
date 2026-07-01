---
okf_version: "1.0"
doc_id: "QA-UAT-PROJECT-001"
title: "UAT — <Chức năng>"
type: "UAT"
role: "QA"
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
  Kịch bản nghiệm thu (UAT) cho <chức năng>, kèm ma trận truy vết và sign-off.
keywords: ["UAT", "nghiệm thu"]
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

# UAT — <Chức năng>

## Summary
<Mở rộng từ summary frontmatter.>

## Ma trận truy vết
| Yêu cầu/BR | Test case | Ưu tiên |
|-----|-----|-----|
| `BA-URD-PROJECT-001` · BR01 | TC-001 | P1 |

## Kịch bản UAT (E2E)
| UAT id | Kịch bản | Vai trò | Kết quả mong đợi | Pass/Fail |
|-----|-----|-----|-----|-----|
| UAT-01 | ... | Người dùng | ... | |

## Sign-off
| Người duyệt | Vai trò | Ngày | Kết luận |
|-----|-----|-----|-----|
| | | | |

## Related
- `<doc_id>` — <mô tả>

## Changelog
| Version | Date | Author | Change |
|---------|------------|--------|--------------------|
| 1.0.0 | 2026-07-01 | | Khởi tạo tài liệu. |

<!-- VALIDATION (type-specific) — ngoài rule chung §9:
  - role BẮT BUỘC = QA, type = UAT
  - Section body BẮT BUỘC: Ma trận truy vết, Kịch bản UAT (E2E), Sign-off
  - Thay PROJECT bằng mã dự án thật; xem golden example: examples/QA-UAT-DEMO-001.md -->
