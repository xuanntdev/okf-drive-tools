#!/usr/bin/env bash
# PreToolUse hook — enforces the Google Drive scope-guard for MCP Drive tools.
#
# PROBLEM: CLAUDE.local.md documents a whitelist/blacklist for the
# `mcp__claude_ai_Google_Drive__*` tools — "Claude may ONLY operate inside
# ALLOWED_ROOT". But that was pure prose: a behavioural fence, not enforced.
# The OAuth scope of the connector covers the WHOLE Drive, so a misbehaving
# agent could read/write any file. (Issue #4.)
#
# SOLUTION: Intercept every MCP Drive PreToolUse event and encode the
# documented policy. Unlike the Bash secret-read hook (which FAILS OPEN),
# this hook FAILS CLOSED: if the scope (`ALLOWED_ROOT_ID`) is not configured,
# we BLOCK — "no scope configured" must never mean "whole-Drive access".
#
# Hook input (stdin, from Claude Code):
#   {"tool_name":"mcp__claude_ai_Google_Drive__<tool>","tool_input":{...},"cwd":"..."}
#
# Exit codes:
#   0  — allow
#   2  — block (stderr returned to model so it can adapt)
#
# POLICY (mirrors CLAUDE.local.md "Google Drive MCP — scope guard"):
#   ALLOWED_ROOT_ID unset/empty .......... BLOCK every Drive tool (fail-closed).
#   list_recent_files .................... BLACKLIST → always BLOCK.
#   get_file_permissions ................. BLACKLIST → always BLOCK.
#   search_files ......................... BLOCK unless the query explicitly
#                                          contains ALLOWED_ROOT_ID (parent-scoped).
#   create_file / copy_file .............. BLOCK unless the destination parent
#                                          (parents[]/parentId/folderId/parent)
#                                          equals ALLOWED_ROOT_ID. Ambiguous → BLOCK.
#   read_file_content / download_file_content / get_file_metadata (by fileId):
#       The hook CANNOT resolve a fileId's parent chain offline, so it cannot
#       prove the file lives under ALLOWED_ROOT. We enforce what we CAN
#       (ALLOWED_ROOT_ID must be set — covered by fail-closed above) and, IF
#       the tool_input carries a parent/folder hint, require it to match.
#       Otherwise ALLOW — the residual relies on the behavioural fence in
#       CLAUDE.local.md (agent calls get_file_metadata first to verify the
#       parent chain). We do NOT pretend to verify a chain we cannot see.
#   any other / unknown Drive tool ....... ALLOW once ALLOWED_ROOT_ID is set.
#
# Non-Drive tools: the settings.json matcher won't invoke this hook for them,
# but we defensively exit 0 if tool_name isn't an MCP Drive tool.

set -uo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')

python3 - <<'PYEOF' "$INPUT"
import sys, os, json

raw = sys.argv[1] if len(sys.argv) > 1 else '{}'

try:
    data = json.loads(raw)
except Exception:
    # Parse failure on a Drive event is suspicious, but blocking on garbage we
    # cannot attribute to a Drive tool would wedge unrelated work. We only fail
    # closed once we KNOW it's a Drive tool (below); unparseable → allow.
    sys.exit(0)

tool_name = data.get('tool_name', '') or ''

DRIVE_PREFIX = 'mcp__claude_ai_Google_Drive__'
if not tool_name.startswith(DRIVE_PREFIX):
    sys.exit(0)  # not a Drive tool — defensive no-op

tool = tool_name[len(DRIVE_PREFIX):]
tool_input = data.get('tool_input', {}) or {}


def block(msg: str) -> None:
    print(
        f"\n[BLOCKED] block-drive-out-of-scope.sh\n"
        f"  tool : {tool_name}\n"
        f"{msg}\n\n"
        f"Policy: CLAUDE.local.md \"Google Drive MCP — scope guard\". "
        f"Claude may operate ONLY inside ALLOWED_ROOT.",
        file=sys.stderr,
    )
    sys.exit(2)


# ── Fail-CLOSED: scope must be configured ────────────────────────────────────
ALLOWED_ROOT = os.environ.get("ALLOWED_ROOT_ID", "").strip()
if not ALLOWED_ROOT:
    block(
        "  reason: ALLOWED_ROOT_ID env is NOT set — the Drive scope-guard\n"
        "          cannot be enforced, so every Drive tool is blocked.\n"
        "  fix   : configure ALLOWED_ROOT_ID in `.claude/settings.local.json#env`\n"
        "          (or export it / set it in CLAUDE.local.md) to the Drive\n"
        "          folder id Claude is allowed to operate inside."
    )

# ── Blacklist: always block ──────────────────────────────────────────────────
if tool in ('list_recent_files', 'get_file_permissions'):
    block(
        f"  reason: `{tool}` is blacklisted — it leaks files / sharing metadata\n"
        f"          outside ALLOWED_ROOT."
    )

# ── Helpers ──────────────────────────────────────────────────────────────────
def input_blob() -> str:
    """Whole tool_input serialised — used for substring scope checks."""
    try:
        return json.dumps(tool_input)
    except Exception:
        return str(tool_input)


def collect_parent_hints() -> list[str]:
    """
    Gather every value in tool_input that names a destination/parent folder,
    across the shapes the MCP Drive tools use:
      - parents: ["<id>"]      (create_file, copy_file — list form)
      - parentId: "<id>"
      - parent:   "<id>"
      - folderId: "<id>"
      - destinationFolderId / targetFolderId / folder_id
    Returns the flat list of string ids found (may be empty).
    """
    hints: list[str] = []
    KEYS = (
        'parents', 'parentId', 'parent', 'folderId', 'folder_id',
        'destinationFolderId', 'targetFolderId', 'destination_folder_id',
    )
    for k in KEYS:
        if k not in tool_input:
            continue
        v = tool_input[k]
        if isinstance(v, str):
            hints.append(v)
        elif isinstance(v, (list, tuple)):
            hints.extend(str(x) for x in v)
    return hints


# ── search_files: must be parent-scoped to ALLOWED_ROOT ──────────────────────
if tool == 'search_files':
    # The documented rule: a search must explicitly contain
    # `parentId = '<ALLOWED_ROOT_ID>'` (or a verified subfolder id). We accept
    # the ALLOWED_ROOT id appearing anywhere in the query/args (covers both the
    # `'<id>' in parents` Drive-query syntax and `parentId = '<id>'`).
    query = ''
    for k in ('query', 'q'):
        if isinstance(tool_input.get(k), str):
            query += ' ' + tool_input[k]
    # also consider explicit parent hints
    haystack = query + ' ' + ' '.join(collect_parent_hints())
    if ALLOWED_ROOT not in haystack:
        block(
            "  reason: search_files is not scoped to ALLOWED_ROOT.\n"
            "          Its query must explicitly contain the ALLOWED_ROOT_ID\n"
            f"          ('{ALLOWED_ROOT}' in parents, or parentId = '{ALLOWED_ROOT}').\n"
            "          Free-text / owner='me' / sharedWithMe searches are forbidden."
        )
    sys.exit(0)

# ── create_file / copy_file: destination must be ALLOWED_ROOT ─────────────────
if tool in ('create_file', 'copy_file'):
    hints = collect_parent_hints()
    if not hints:
        # Ambiguous destination → fail closed.
        block(
            f"  reason: `{tool}` has no resolvable destination parent in tool_input\n"
            f"          (expected parents[]/parentId/folderId == ALLOWED_ROOT).\n"
            f"          Ambiguous destination → blocked (fail-closed)."
        )
    if not any(h == ALLOWED_ROOT for h in hints):
        block(
            f"  reason: `{tool}` targets a parent outside ALLOWED_ROOT.\n"
            f"          parent(s) seen : {hints}\n"
            f"          ALLOWED_ROOT_ID: {ALLOWED_ROOT}\n"
            f"          Writes are only allowed INSIDE ALLOWED_ROOT (a verified\n"
            f"          subfolder id must be added to the allow-set explicitly)."
        )
    sys.exit(0)

# ── Read-by-fileId tools ─────────────────────────────────────────────────────
# LIMITATION (documented honestly): a fileId does not carry its parent chain,
# and this hook runs offline (no Drive API call), so we cannot verify the file
# is under ALLOWED_ROOT. We enforce what we can:
#   1. ALLOWED_ROOT_ID is set (already checked above → fail-closed default).
#   2. IF the tool_input carries a parent/folder hint, it MUST match.
# The residual gap is covered by the behavioural fence (CLAUDE.local.md: the
# agent must call get_file_metadata first to verify the parentId chain).
if tool in ('read_file_content', 'download_file_content', 'get_file_metadata'):
    hints = collect_parent_hints()
    if hints and not any(h == ALLOWED_ROOT for h in hints):
        block(
            f"  reason: `{tool}` carries a parent/folder hint outside ALLOWED_ROOT.\n"
            f"          parent(s) seen : {hints}\n"
            f"          ALLOWED_ROOT_ID: {ALLOWED_ROOT}"
        )
    # No parent hint → allow (residual relies on the behavioural fence; the
    # hook cannot resolve a fileId's parent chain offline).
    sys.exit(0)

# ── Any other Drive tool: allowed once scope is configured ───────────────────
sys.exit(0)
PYEOF
