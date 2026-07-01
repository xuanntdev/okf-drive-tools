---
name: okf-validate
description: Validate một hoặc nhiều file Markdown local theo chuẩn frontmatter OKF v1.0 trước khi push lên Drive. Dùng khi user nói "validate tài liệu OKF", "kiểm tra frontmatter", "kiểm tra chuẩn OKF", hoặc ngay trước khi gọi "okf-push".
---

## OKF Validate — local, no Drive calls

Wraps the existing `validate_okf.py` gatekeeper (§9 of the OKF standard) against the bundled schema at `${CLAUDE_PLUGIN_ROOT}/schema/okf.schema.json`. Does not touch Drive.

## Khi nào dùng

✅ Trước khi chạy `okf-push` cho bất kỳ file nào (bắt buộc — `okf-push` sẽ từ chối nếu file chưa PASS trong lượt hiện tại).
✅ Khi user hỏi "file này đã đúng chuẩn OKF chưa?".

❌ Không dùng để validate nội dung nghiệp vụ (đúng/sai business rule) — chỉ kiểm cấu trúc frontmatter + liên kết `related`.

## Quy trình

1. Xác định file/glob cần check (từ user hoặc tất cả file `.md` mới sửa trong turn hiện tại).
2. Chạy:
   ```bash
   python3 "${CLAUDE_PLUGIN_ROOT}/scripts/validate_okf.py" "${CLAUDE_PLUGIN_ROOT}/schema/okf.schema.json" <file_or_glob...>
   ```
3. Với mỗi file, script tự in `[PASS]`/`[FAIL]` kèm mã lỗi gốc (không diễn giải lại):
   - `[S1]` không parse được frontmatter YAML.
   - `[schema] <path>: <msg>` — sai schema (thiếu field, sai enum, sai kiểu...).
   - `[S3]` `doc_id` sai regex hoặc trùng.
   - `[S5]` `updated` < `created`.
   - `[T]` `related` trỏ tới `doc_id` không tồn tại trong tập file đang check.
   - `[S8]` `changelog` rỗng hoặc `changelog[0].version` lệch `version`.
4. Báo kết quả nguyên văn cho user (không tự "sửa hộ" nội dung — chỉ báo lỗi).

## Hard rules

- ❌ Không tự động sửa file khi FAIL — báo lỗi, để user hoặc `okf-push` caller quyết định.
- ❌ Không validate file ngoài phạm vi user chỉ định (không quét toàn repo trừ khi được yêu cầu).
- ✅ Luôn dùng schema bundled trong plugin (`${CLAUDE_PLUGIN_ROOT}/schema/okf.schema.json`), không dùng bản trên Drive (tránh lệch version khi offline).

## Related skills

- Sau khi PASS: `okf-push` để đẩy lên Drive.
- Template chuẩn theo role/type: `${CLAUDE_PLUGIN_ROOT}/schema/templates/<role>/<type>.md`.
