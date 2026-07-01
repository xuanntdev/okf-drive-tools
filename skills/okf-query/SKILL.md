---
name: okf-query
description: Trả lời câu hỏi của user bằng cách đọc tài liệu OKF trong folder OpenKnowledge trên Drive — chỉ đọc, đi theo manifest trước, có trích nguồn. Dùng khi user hỏi về tri thức dự án nằm trong OpenKnowledge, ví dụ "kiến trúc HRM là gì", "tìm business rule về X", "tài liệu nào nói về Y".
---

## OKF Query — read OpenKnowledge Drive (progressive disclosure)

Read-only. Đi từ metadata (rẻ) rồi mới mở body (đắt), không quét toàn Drive.

## Root folder cố định

```
OPENKNOWLEDGE_ROOT_ID = 1Z2qo8erhxAFP3wqzoUB8GIYcKP3IvP7B
```

Mọi Drive call **phải** scoped vào folder này hoặc subfolder đã verify bên trong. Không dùng ID khác, không search toàn Drive.

## Khi nào dùng

✅ User hỏi về tri thức đã có trong OpenKnowledge (kiến trúc, business rule, plan, glossary...).

❌ Câu hỏi về live data (task/status trong Jira, người đang làm gì) → route sang Jira MCP, không dùng skill này.
❌ User muốn sửa/ghi tài liệu → `okf-push`, không phải skill này.

## Quy trình

1. **Tìm root `_manifest.json`** bằng:
   ```
   search_files(query="name = '_manifest.json' and '1Z2qo8erhxAFP3wqzoUB8GIYcKP3IvP7B' in parents")
   ```
   Đọc file tìm được → xác định project liên quan tới câu hỏi.

2. Nếu vẫn mơ hồ → đọc `<PROJECT>/index.md` (progressive disclosure).

3. **Tìm `<PROJECT>/_manifest.json`** bằng:
   ```
   search_files(query="name = '_manifest.json' and '<project-folder-id>' in parents")
   ```
   Khớp theo `doc_id` / `type` / `role` / từ khoá trong `summary`.

4. Mở doc top-N phù hợp nhất (`read_file_content` hoặc `download_file_content`), **ưu tiên `status: approved`**; chỉ mở `draft` nếu không còn lựa chọn khác hoặc user yêu cầu rõ.

5. Theo `related[]` trong frontmatter để mở rộng ngữ cảnh nếu cần (khi có `_graph.json`, dùng nó để tránh phải mở từng doc).

6. Trả lời kèm **provenance**: `doc_id`, đường dẫn/`viewUrl` Drive, `status` (nói rõ nếu là draft).

## Hard rules

- ❌ Không `list_recent_files`.
- ❌ Không `search_files` thiếu `'1Z2qo8erhxAFP3wqzoUB8GIYcKP3IvP7B' in parents` hoặc parentId của subfolder đã verify.
- ❌ Không bịa nội dung khi không tìm thấy doc — nói rõ "chưa có tài liệu OKF nào khớp câu hỏi này".
- ✅ Luôn nói rõ `status` của doc đã dùng để trả lời, đặc biệt khi là `draft`/`deprecated`.

## Related skills

- Nếu user muốn cập nhật doc sau khi đọc: `okf-validate` → `okf-push`.
