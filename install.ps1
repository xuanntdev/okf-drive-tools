# install.ps1 — cài okf-drive-tools plugin vào Claude Code (Windows PowerShell)
# Yêu cầu: Python 3 · Git Bash (hook runtime cần bash)

$ErrorActionPreference = "Stop"

$RepoDir     = Split-Path -Parent $MyInvocation.MyCommand.Path
$PluginRoot  = "$env:USERPROFILE\.claude\plugins\okf-drive-tools"
$CommandsDir = "$env:USERPROFILE\.claude\commands"

Write-Host "=== OKF Drive Tools - Cai plugin ===" -ForegroundColor Cyan
Write-Host "  Repo   : $RepoDir"
Write-Host "  Plugin : $PluginRoot"
Write-Host ""

# 1. Copy plugin files vao thu muc co dinh
Write-Host "[1/3] Copy plugin -> $PluginRoot"
if (Test-Path $PluginRoot) { Remove-Item $PluginRoot -Recurse -Force -Confirm:$false }
Copy-Item $RepoDir -Destination $PluginRoot -Recurse

# 2. Copy skills vao ~/.claude/commands/
Write-Host "[2/3] Copy skills -> $CommandsDir"
New-Item -ItemType Directory -Force $CommandsDir | Out-Null
Copy-Item "$PluginRoot\skills\okf-validate\SKILL.md" "$CommandsDir\okf-validate.md" -Force
Copy-Item "$PluginRoot\skills\okf-push\SKILL.md"     "$CommandsDir\okf-push.md"     -Force
Copy-Item "$PluginRoot\skills\okf-query\SKILL.md"    "$CommandsDir\okf-query.md"    -Force

# 3. Merge settings.json (env CLAUDE_PLUGIN_ROOT + PreToolUse hook)
Write-Host "[3/3] Merge settings.json"
python3 "$PluginRoot\scripts\merge_settings.py" $PluginRoot

Write-Host ""
Write-Host "=== Xong! ===" -ForegroundColor Green
Write-Host "Khoi dong lai Claude Code roi dung:"
Write-Host "  /okf-validate  - kiem tra frontmatter OKF"
Write-Host "  /okf-push      - day tai lieu len Drive"
Write-Host "  /okf-query     - tra cuu tai lieu trong OpenKnowledge"
Write-Host ""
Write-Host "[!] Hook script (.sh) can Git Bash de chay — cai dat tai git-scm.com/download/win" -ForegroundColor Yellow
