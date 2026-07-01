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

**Claude Code (đã xác nhận hỗ trợ):**

```bash
# Dev/test nhanh trong 1 session (không cần marketplace):
claude --plugin-dir /path/to/okf-drive-tools

# Cài lâu dài — repo này TỰ LÀ marketplace (đã có .claude-plugin/marketplace.json,
# source: "." trỏ về chính plugin ở root repo):
/plugin marketplace add /path/to/okf-drive-tools        # local path
/plugin marketplace add <owner>/<repo>                   # GitHub, dạng ngắn
/plugin marketplace add https://gitlab.../okf-plugin.git # GitLab hoặc git URL đầy đủ
/plugin install okf-drive-tools
```

> Theo plan trong `plugin-claude.md`: repo đích là `isc/project_research/ai/open-knowledge-engine/okf-plugin` (GitLab). Sau khi push nội dung `okf-drive-tools/` lên đó, dùng đúng lệnh `/plugin marketplace add <url-repo-đó>`.

**Claude Desktop:** chưa xác nhận được hỗ trợ plugin theo tài liệu chính thức tại thời điểm viết README này — nếu bạn dùng Desktop, kiểm tra lại trong app trước khi giả định các skill này hoạt động tương tự CLI.

## Bắt buộc: cấu hình `ALLOWED_ROOT_ID`

Hook scope-guard **fail-closed** — nếu biến môi trường `ALLOWED_ROOT_ID` không được set, **mọi** lệnh Drive trong 3 skill trên sẽ bị block. Set biến này = ID của folder `OpenKnowledge` (hiện tại: `1Z2qo8erhxAFP3wqzoUB8GIYcKP3IvP7B`, nằm trong folder `OKE`), ví dụ trong `.claude/settings.local.json`:

```json
{
  "env": { "ALLOWED_ROOT_ID": "1Z2qo8erhxAFP3wqzoUB8GIYcKP3IvP7B" }
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
