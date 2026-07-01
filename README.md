# okf-drive-tools

Claude Code plugin: validate, push, và query tài liệu OKF (Open Knowledge Flow) đối chiếu với folder `OpenKnowledge` trên Google Drive.

## Nội dung plugin

| Path | Vai trò |
|------|---------|
| `skills/okf-validate/` | Validate frontmatter OKF của file local (không đụng Drive). |
| `skills/okf-push/` | Đẩy file đã validate lên đúng path trong `OpenKnowledge/<PROJECT>/...`. |
| `skills/okf-query/` | Đọc tri thức đã có trên `OpenKnowledge` để trả lời câu hỏi (manifest-first, có provenance). |
| `hooks/block-drive-out-of-scope.sh` + `hooks/hooks.json` | PreToolUse guard — mọi lệnh `mcp__claude_ai_Google_Drive__*` chỉ được chạy trong `ALLOWED_ROOT_ID`. |
| `schema/okf.schema.json` | Bản bundle của JSON Schema OKF v1.0 (nguồn: `okf-templates-v1/okf-v1-templates/schema/`). |
| `scripts/validate_okf.py` | Validator gốc (§9), dùng lại nguyên vẹn, không viết lại logic. |
| `scripts/generate_graph.py` | Sinh `_graph.json` từ field `related` trong frontmatter — không cần DB, chạy lại toàn bộ mỗi lần (không incremental). |
| `schema/templates/<role>/<type>.md` | 16 template khung theo role/type (nguồn: `okf-templates-v1/okf-v1-templates/templates/`). |

## Cài đặt

> **Yêu cầu:** Claude Code CLI · git · Python 3 · Git Bash (Windows — cho hook runtime)

### Cài đặt

Mở terminal, chạy `claude` để vào Claude Code CLI, rồi gõ:

```
/plugin marketplace add https://gitlab.com/xuandev/okf-drive-tools.git
/plugin install okf-drive-tools@okf-plugin
/reload-plugins
```

### Sau khi cài — Restart Claude Code

3 skill xuất hiện trong `/`:

| Skill | Dùng khi |
|-------|----------|
| `/okf-validate` | Kiểm tra frontmatter OKF trước khi push |
| `/okf-push` | Đẩy tài liệu đã validate lên Drive |
| `/okf-query` | Tra cứu tài liệu trong OpenKnowledge |

---

> **Claude Web / Claude Desktop:** Skills là tính năng của **Claude Code CLI** — không khả dụng trên web hay Desktop.
> Trên Claude Web, nếu đã kết nối Google Drive connector, bạn vẫn có thể hỏi Claude đọc/ghi Drive
> thủ công, nhưng không có `/okf-*` workflow.

## `ALLOWED_ROOT_ID` — đã tự động, không cần config

Hook scope-guard **fail-closed** — nhưng `hooks/hooks.json` đã nhúng sẵn default `ALLOWED_ROOT_ID=1Z2qo8erhxAFP3wqzoUB8GIYcKP3IvP7B` (folder `OpenKnowledge` trong `OKE`) ngay trong lệnh gọi hook (`"${ALLOWED_ROOT_ID:-1Z2qo8erhxAFP3wqzoUB8GIYcKP3IvP7B}"`). Cài plugin xong là dùng được ngay, **không cần** sửa `.claude/settings.local.json`.

Muốn trỏ tới folder Drive khác (vd môi trường test riêng) → set biến môi trường `ALLOWED_ROOT_ID` trước khi chạy Claude Code, giá trị đó sẽ override default:

```json
{
  "env": { "ALLOWED_ROOT_ID": "<id-folder-khác>" }
}
```

## Luồng dùng

1. Sửa/tạo file `.md` local theo template ở `schema/templates/<role>/<type>.md`.
2. Gọi `okf-validate` → phải PASS.
3. Gọi `okf-push` → đẩy lên đúng path trong `OpenKnowledge/<PROJECT>/...` (từ chối nếu chưa validate).
4. Chạy lại `generate_graph.py` trên toàn bộ file local đang track, push `_graph.json` mới lên root `OpenKnowledge/` (workaround: tạo file mới, không có update — xem "Giới hạn đã biết").
5. Sau đó, ai cần tra cứu thì gọi `okf-query` — không cần biết cấu trúc folder, chỉ hỏi bằng ngôn ngữ tự nhiên.

```bash
python3 scripts/generate_graph.py "/path/to/local/okf-docs/**/*.md" --out /tmp/_graph.json
```

## Giới hạn đã biết (chưa làm ở bản 0.1.0)

- MCP `claude_ai_Google_Drive` chưa có `update_file_content` — "update" thực chất tạo file `[v2-<date>]` mới, cần xoá tay bản cũ trên Drive UI.
- Chưa có ACL/permission mapping theo dự án — mọi người có quyền vào folder `OpenKnowledge` hiện đọc/ghi như nhau, phân quyền theo `access:` trong frontmatter mới chỉ là gợi ý, chưa enforce ở tầng Drive.
- `generate_graph.py` chạy full-scan trên **file local** (chưa có bước tự kéo toàn bộ `OpenKnowledge/` về để scan) — hiện phải chạy trên tập file bạn đang track ở máy, rồi push `_graph.json` lên tay/qua `okf-push`.
- Claude Desktop: chưa test — chỉ xác nhận chạy được trên Claude Code CLI.
