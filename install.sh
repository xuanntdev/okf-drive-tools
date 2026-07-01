#!/usr/bin/env bash
# install.sh — cài okf-drive-tools plugin vào Claude Code
# Chạy trực tiếp: curl -sSL <url>/install.sh | bash
# Yêu cầu: git · python3

set -euo pipefail

REPO_URL="https://gitlab.com/xuandev/okf-drive-tools.git"
PLUGIN_ROOT="${HOME}/.claude/plugins/okf-drive-tools"
COMMANDS_DIR="${HOME}/.claude/commands"

echo "=== OKF Drive Tools — Cài plugin ==="
echo ""

# 1. Clone repo vào thư mục plugin cố định
echo "[1/3] Clone repo → ${PLUGIN_ROOT}"
rm -rf "${PLUGIN_ROOT}"
git clone --depth 1 "${REPO_URL}" "${PLUGIN_ROOT}"

# 2. Copy skills vào ~/.claude/commands/
echo "[2/3] Copy skills → ${COMMANDS_DIR}"
mkdir -p "${COMMANDS_DIR}"
cp "${PLUGIN_ROOT}/skills/okf-validate/SKILL.md" "${COMMANDS_DIR}/okf-validate.md"
cp "${PLUGIN_ROOT}/skills/okf-push/SKILL.md"     "${COMMANDS_DIR}/okf-push.md"
cp "${PLUGIN_ROOT}/skills/okf-query/SKILL.md"    "${COMMANDS_DIR}/okf-query.md"

# 3. Merge settings.json (env CLAUDE_PLUGIN_ROOT + PreToolUse hook)
echo "[3/3] Merge settings.json"
python3 "${PLUGIN_ROOT}/scripts/merge_settings.py" "${PLUGIN_ROOT}"

echo ""
echo "=== Xong! ==="
echo "Khởi động lại Claude Code rồi dùng:"
echo "  /okf-validate  — kiểm tra frontmatter OKF"
echo "  /okf-push      — đẩy tài liệu lên Drive"
echo "  /okf-query     — tra cứu tài liệu trong OpenKnowledge"
