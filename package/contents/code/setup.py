#!/usr/bin/env python3
"""Connects Claude Code to the Claude Usage Bars widget.

    setup.py install     copy the status line helper to ~/.local/bin and register it in
                         ~/.claude/settings.json (an existing status line keeps working)
    setup.py uninstall   undo that and restore the status line you had before
    setup.py status      print "ok" if it is set up, otherwise "missing"
"""
import json
import os
import shlex
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
HELPER_SOURCE = os.path.join(HERE, "claude-usage-bars-statusline")
BIN_DIR = os.environ.get("CLAUDE_USAGE_BARS_BIN_DIR") or os.path.expanduser("~/.local/bin")
HELPER = os.path.join(BIN_DIR, "claude-usage-bars-statusline")
CLAUDE_DIR = os.environ.get("CLAUDE_CONFIG_DIR") or os.path.expanduser("~/.claude")
SETTINGS = os.path.join(CLAUDE_DIR, "settings.json")


def load_settings():
    if not os.path.exists(SETTINGS):
        return {}
    with open(SETTINGS) as f:
        return json.load(f)


def save_settings(settings):
    os.makedirs(CLAUDE_DIR, exist_ok=True)
    backup = SETTINGS + ".bak-claude-usage-bars"
    if os.path.exists(SETTINGS) and not os.path.exists(backup):
        shutil.copy2(SETTINGS, backup)
    with open(SETTINGS + ".tmp", "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    os.replace(SETTINGS + ".tmp", SETTINGS)


def current_command(settings):
    line = settings.get("statusLine")
    return line.get("command", "") if isinstance(line, dict) else ""


def install():
    os.makedirs(os.path.dirname(HELPER), exist_ok=True)
    shutil.copy2(HELPER_SOURCE, HELPER)
    os.chmod(HELPER, 0o755)

    settings = load_settings()
    old = current_command(settings)
    if HELPER in old:
        print("Already set up.")
        return
    line = dict(settings.get("statusLine") or {}) if isinstance(settings.get("statusLine"), dict) else {}
    line["type"] = "command"
    if old:
        # Keep the existing status line: the helper runs first and then passes everything on
        line["command"] = f"{shlex.quote(HELPER)} sh -c {shlex.quote(old)}"
        print("Set up. Your existing status line keeps working.")
    else:
        line["command"] = shlex.quote(HELPER)
        print("Set up.")
    settings["statusLine"] = line
    save_settings(settings)


def uninstall():
    settings = load_settings()
    old = current_command(settings)
    if HELPER in old:
        parts = shlex.split(old)
        if len(parts) == 4 and parts[0] == HELPER and parts[1:3] == ["sh", "-c"]:
            settings["statusLine"]["command"] = parts[3]
        else:
            settings.pop("statusLine", None)
        save_settings(settings)
    if os.path.exists(HELPER):
        os.remove(HELPER)
    print("Removed.")


def status():
    ok = os.path.exists(HELPER) and HELPER in current_command(load_settings())
    print("ok" if ok else "missing")


if __name__ == "__main__":
    actions = {"install": install, "uninstall": uninstall, "status": status}
    if len(sys.argv) != 2 or sys.argv[1] not in actions:
        print(__doc__)
        sys.exit(2)
    actions[sys.argv[1]]()
