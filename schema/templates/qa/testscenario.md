---
okf_version: "1.0"
doc_id: "QA-TESTSCENARIO-PROJECT-001"
title: "Test Scenario — <Chức năng>"
type: "TestScenario"
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
  Kịch bản kiểm thử cho <chức năng>, kèm ma trận truy vết yêu cầu → test case.
keywords: ["test scenario", "kiểm thử"]
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

# Test Scenario — <Chức năng>

## Summary
<Mở rộng từ summary frontmatter.>

## Ma trận truy vết
| Yêu cầu/BR (doc_id · BR) | Test case | Ưu tiên |
|-----|-----|-----|
| `BA-URD-PROJECT-001` · BR01 | TC-001 | P1 |

## Test case
| TC id | Tiền ĐK | Bước | Dữ liệu | Kết quả mong đợi | Ưu tiên |
|-----|-----|-----|-----|-----|-----|
| TC-001 | ... | ... | ... | ... | P1 |

## Related
- `<doc_id>` — <mô tả>

## Changelog
| Version | Date | Author | Change |
|---------|------------|--------|--------------------|
| 1.0.0 | 2026-07-01 | | Khởi tạo tài liệu. |

<!-- VALIDATION (type-specific) — ngoài rule chung §9:
  - role BẮT BUỘC = QA, type = TestScenario
  - Section body BẮT BUỘC: Ma trận truy vết, Test case
  - Thay PROJECT bằng mã dự án thật; xem golden example: examples/QA-TESTSCENARIO-DEMO-001.md -->
