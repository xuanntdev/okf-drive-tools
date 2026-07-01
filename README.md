# okf-drive-tools

Claude plugin: validate, push, và query tài liệu OKF (Open Knowledge Flow) đối chiếu với folder `OpenKnowledge` trên Google Drive.

## Nội dung plugin

| Path | Vai trò |
|------|---------|
| `skills/okf-validate/` | Validate frontmatter OKF của file local (không đụng Drive). |
| `skills/okf-push/` | Đẩy file đã validate lên đúng path trong `OpenKnowledge/<PROJECT>/...`. |
| `skills/okf-query/` | Đọc tri thức đã có trên `OpenKnowledge` để trả lời câu hỏi (manifest-first, có provenance). |
| `hooks/block-drive-out-of-scope.sh` + `hooks/hooks.json` | PreToolUse guard — mọi lệnh `mcp__claude_ai_Google_Drive__*` chỉ được chạy trong `ALLOWED_ROOT_ID`. |
| `schema/okf.schema.json` | Bản bundle của JSON Schema OKF v1.0. |
| `scripts/validate_okf.py` | Validator gốc (§9), dùng lại nguyên vẹn. |
| `scripts/generate_graph.py` | Sinh `_graph.json` từ field `related` trong frontmatter. |
| `schema/templates/<role>/<type>.md` | 16 template khung theo role/type. |

## Cài đặt

### Claude Code CLI / VS Code extension

> **Yêu cầu:** Claude Code CLI · git · Python 3 · Git Bash (Windows — cho hook runtime)

Mở terminal, chạy `claude` để vào Claude Code CLI, rồi gõ:

```
/plugin marketplace add https://gitlab.com/xuandev/okf-drive-tools.git
/plugin install okf-drive-tools@okf-plugin
/reload-plugins
```

Sau khi cài qua CLI, skills tự động có sẵn trong cả VS Code extension.

### Sau khi cài — 3 skills xuất hiện trong `/`

| Skill | Dùng khi |
|-------|----------|
| `/okf-validate` | Kiểm tra frontmatter OKF trước khi push |
| `/okf-push` | Đẩy tài liệu đã validate lên Drive |
| `/okf-query` | Tra cứu tài liệu trong OpenKnowledge |

## `ALLOWED_ROOT_ID` — đã tự động, không cần config

Hook scope-guard **fail-closed** — `hooks/hooks.json` đã nhúng sẵn default `ALLOWED_ROOT_ID=1Z2qo8erhxAFP3wqzoUB8GIYcKP3IvP7B` (folder `OpenKnowledge`). Cài plugin xong là dùng được ngay.

Muốn trỏ tới folder Drive khác → set biến môi trường `ALLOWED_ROOT_ID`:

```json
{
  "env": { "ALLOWED_ROOT_ID": "<id-folder-khác>" }
}
```

## Luồng dùng

1. Sửa/tạo file `.md` local theo template ở `schema/templates/<role>/<type>.md`.
2. Gọi `/okf-validate` → phải PASS.
3. Gọi `/okf-push` → đẩy lên đúng path trong `OpenKnowledge/<PROJECT>/...`.
4. Chạy lại `generate_graph.py` rồi push `_graph.json` mới lên root `OpenKnowledge/`.
5. Gọi `/okf-query` để tra cứu bằng ngôn ngữ tự nhiên.

```bash
python3 scripts/generate_graph.py "/path/to/local/okf-docs/**/*.md" --out /tmp/_graph.json
```

## Giới hạn đã biết (v0.1.0)

- MCP `claude_ai_Google_Drive` chưa có `update_file_content` — "update" tạo file `[v2-<date>]` mới, cần xoá tay bản cũ trên Drive UI.
- Chưa có ACL/permission mapping theo dự án.
- `generate_graph.py` chạy full-scan trên file local, chưa tự kéo toàn bộ `OpenKnowledge/` về.
- Claude Desktop: chưa xác nhận hỗ trợ.
