---
name: okf-push
description: Đẩy một tài liệu OKF Markdown đã validate từ repo local lên đúng path trong folder OpenKnowledge trên Drive, định tuyến theo frontmatter (project/role/type). Dùng khi user nói "đẩy tài liệu OKF lên Drive", "đẩy tài liệu lên OpenKnowledge", "sync doc lên Drive".
---

## OKF Push — knowledge → OpenKnowledge Drive (outbound)

> Chiều một: local là source of truth. Không có `update_file_content` trong MCP Drive hiện tại — update thật chỉ tạo file mới kèm versioned suffix (xem Phase 3).

## Ràng buộc tuyệt đối — Drive scope guard

Plugin này bundle hook `hooks/block-drive-out-of-scope.sh` (PreToolUse trên mọi `mcp__claude_ai_Google_Drive__*`), enforce:
- `ALLOWED_ROOT_ID` phải được set (env) = ID folder `OpenKnowledge` — thiếu thì mọi Drive call bị BLOCK (fail-closed).
- `list_recent_files`, `get_file_permissions` → luôn BLOCK.
- `search_files` phải chứa `ALLOWED_ROOT_ID` trong query.
- `create_file`/`copy_file` phải có `parents` == `ALLOWED_ROOT_ID` (hoặc subfolder đã verify).

Tuyên bố trước mỗi tool call Drive (tool + key param).

## Khi nào dùng

✅ File đã PASS `okf-validate` **trong lượt hiện tại**.
✅ User đã xác nhận đúng project/role/type trong frontmatter.

❌ **KHÔNG dùng nếu chưa validate** — refuse và gợi ý chạy `okf-validate` trước.
❌ Không tự đoán `ALLOWED_ROOT_ID` nếu chưa biết — hỏi user hoặc đọc từ config/state đã lưu.

## Quy trình

### Phase 1 — Precondition

1. Xác nhận file đã PASS `okf-validate` trong turn hiện tại. Chưa có → DỪNG, chạy `okf-validate` trước.
2. Đọc frontmatter file: `project`, `role`, `type`, `doc_id`, `status`.

### Phase 2 — Route target path

3. Suy ra đường dẫn Drive theo blueprint (`OKF-Drive-Organization-Navigation.md`):
   - Doc tổng quan dự án (Plan/Architecture/Glossary chung) → `<PROJECT>/_overview/<doc_id-lowercase>.md`.
   - Doc gắn 1 feature cụ thể → `<PROJECT>/features/<feature-slug>/<doc_id-lowercase>.md`.
   - Không chắc → hỏi user, không tự đoán feature slug.
4. Tìm/verify folder đích bằng `search_files` (query có `ALLOWED_ROOT_ID` hoặc subfolder id đã biết). Thiếu folder → tạo bằng `create_file` (`mimeType: application/vnd.google-apps.folder`, `parents: [ALLOWED_ROOT hoặc subfolder id]`), tuyên bố trước.

### Phase 3 — Upload

5. **File mới (chưa có trên Drive):**
   ```
   Call: mcp__claude_ai_Google_Drive__create_file
   Args: title, parentId=<folder đích>, contentMimeType="text/markdown",
         disableConversionToGoogleType=true, textContent=<nội dung file>
   ```
6. **File đã tồn tại (update):** MCP chưa có update — theo workaround đã dùng ở `sync-drive`:
   - Tạo file mới tên `"<title> [v2-<date>]"` cùng folder.
   - Báo user: file cũ `<id>` cần xóa tay trên Drive UI.
7. Cập nhật `<PROJECT>/_manifest.json` (root và project) thêm/sửa entry cho `doc_id` này — đọc file hiện tại trước, chỉ patch mục liên quan, rồi `create_file` phiên bản mới (cùng workaround versioned-suffix nếu file đã tồn tại).

### Phase 4 — Report

```
✓ Push hoàn tất
  • File: <doc_id> → <path Drive>
  • Folder tạo mới: N (nếu có)
  • Cần xóa tay (version cũ): <list nếu có>
  • Manifest đã cập nhật: root + <PROJECT>
```

## Hard rules

- ❌ Không push file chưa PASS validate.
- ❌ Không suy đoán feature slug — hỏi user khi mơ hồ.
- ❌ Không xóa file cũ trên Drive tự động.
- ❌ Không retry tự động khi Drive tool lỗi — dừng, báo user.
- ✅ Mỗi Drive call: tuyên bố trước.

## Related skills

- Trước: `okf-validate` (bắt buộc).
- Đọc lại sau khi push: `okf-query`.
