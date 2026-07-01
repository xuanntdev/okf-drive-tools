#!/usr/bin/env python3
"""Merge okf-drive-tools hook + env vào ~/.claude/settings.json (idempotent)."""

import json
import os
import sys


def main() -> None:
    plugin_root = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
        os.path.expanduser("~"), ".claude", "plugins", "okf-drive-tools"
    )
    settings_path = os.path.join(os.path.expanduser("~"), ".claude", "settings.json")

    if os.path.exists(settings_path):
        with open(settings_path, encoding="utf-8") as f:
            settings = json.load(f)
    else:
        settings = {}

    # Set CLAUDE_PLUGIN_ROOT
    settings.setdefault("env", {})
    settings["env"]["CLAUDE_PLUGIN_ROOT"] = plugin_root

    # Add Drive scope-guard hook
    settings.setdefault("hooks", {})
    settings["hooks"].setdefault("PreToolUse", [])

    hook_matcher = "mcp__claude_ai_Google_Drive__.*"
    new_hook_entry = {
        "matcher": hook_matcher,
        "hooks": [
            {
                "type": "command",
                "command": 'ALLOWED_ROOT_ID="${ALLOWED_ROOT_ID:-1Z2qo8erhxAFP3wqzoUB8GIYcKP3IvP7B}" "${CLAUDE_PLUGIN_ROOT}"/hooks/block-drive-out-of-scope.sh',
                "timeout": 10,
            }
        ],
    }

    existing = [h for h in settings["hooks"]["PreToolUse"] if h.get("matcher") == hook_matcher]
    if existing:
        existing[0]["hooks"] = new_hook_entry["hooks"]
        print(f"  hook updated  ({hook_matcher})")
    else:
        settings["hooks"]["PreToolUse"].append(new_hook_entry)
        print(f"  hook added    ({hook_matcher})")

    with open(settings_path, "w", encoding="utf-8") as f:
        json.dump(settings, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print(f"  CLAUDE_PLUGIN_ROOT = {plugin_root}")
    print(f"  saved → {settings_path}")


if __name__ == "__main__":
    main()
