---
name: okf-query
description: Trả lời câu hỏi của user bằng cách đọc tài liệu OKF trong folder OpenKnowledge trên Drive — chỉ đọc, đi theo manifest trước, có trích nguồn. Dùng khi user hỏi về tri thức dự án nằm trong OpenKnowledge, ví dụ "kiến trúc HRM là gì", "tìm business rule về X", "tài liệu nào nói về Y".
---

## OKF Query — read OpenKnowledge Drive (progressive disclosure)

Read-only. Implements "Luồng khi AI đọc" từ `OKF-Drive-Organization-Navigation.md`: đi từ metadata (rẻ) rồi mới mở body (đắt), không quét toàn Drive.

## Ràng buộc tuyệt đối — Drive scope guard

Cùng hook `block-drive-out-of-scope.sh` như `okf-push`. Vì skill này chỉ đọc, `create_file`/`copy_file` không được gọi ở đây. `list_recent_files` và `search_files` thiếu `ALLOWED_ROOT_ID` vẫn bị BLOCK — không có ngoại lệ cho việc "đọc thì chắc an toàn hơn".

## Khi nào dùng

✅ User hỏi về tri thức đã có trong OpenKnowledge (kiến trúc, business rule, plan, glossary...).

❌ Câu hỏi về live data (task/status trong Jira, người đang làm gì) → route sang Jira MCP, không dùng skill này.
❌ User muốn sửa/ghi tài liệu → `okf-push`, không phải skill này.

## Quy trình

1. **Đọc root `_manifest.json`** (`OpenKnowledge/_manifest.json`) → xác định project liên quan tới câu hỏi.
2. Nếu vẫn mơ hồ → đọc `<PROJECT>/index.md` (progressive disclosure).
3. **Đọc `<PROJECT>/_manifest.json`** → khớp theo `doc_id` / `type` / `role` / từ khoá trong `summary`.
4. Mở doc top-N phù hợp nhất (`read_file_content` hoặc `download_file_content`), **ưu tiên `status: approved`**; chỉ mở `draft` nếu không còn lựa chọn khác hoặc user yêu cầu rõ ("cho tôi xem cả bản draft").
5. Theo `related[]` trong frontmatter để mở rộng ngữ cảnh nếu câu hỏi cần (khi có `_graph.json`, dùng nó để tránh phải mở từng doc để dò `related`).
6. Trả lời kèm **provenance**: `doc_id`, đường dẫn/`viewUrl` Drive, `status` (đặc biệt nếu là draft — nói rõ "tài liệu này còn ở trạng thái draft, chưa review chính thức").

## Hard rules

- ❌ Không `list_recent_files`.
- ❌ Không `search_files` thiếu `ALLOWED_ROOT_ID`/parentId.
- ❌ Không bịa nội dung khi không tìm thấy doc phù hợp — nói rõ "chưa có tài liệu OKF nào khớp câu hỏi này" thay vì suy diễn.
- ✅ Luôn nói rõ `status` của doc đã dùng để trả lời, đặc biệt khi là `draft`/`deprecated`.

## Related skills

- Nếu user muốn cập nhật doc sau khi đọc: `okf-validate` → `okf-push`.
