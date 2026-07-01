#!/usr/bin/env bash
# install.sh — cài okf-drive-tools plugin vào Claude Code
# Chạy được trên: macOS, Linux, Windows Git Bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="${HOME}/.claude/plugins/okf-drive-tools"
COMMANDS_DIR="${HOME}/.claude/commands"

echo "=== OKF Drive Tools — Cài plugin ==="
echo "  Repo   : ${REPO_DIR}"
echo "  Plugin : ${PLUGIN_ROOT}"
echo ""

# 1. Copy plugin files vào thư mục cố định
echo "[1/3] Copy plugin → ${PLUGIN_ROOT}"
rm -rf "${PLUGIN_ROOT}"
cp -r "${REPO_DIR}" "${PLUGIN_ROOT}"

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
