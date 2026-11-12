#!/usr/bin/env bash
# Removes Claude Usage Bars: the Claude Code connection (your old status line comes back) and the widget.
set -euo pipefail
cd "$(dirname "$0")"
ID=com.github.mat-53.claude-usage-bars

python3 package/contents/code/setup.py uninstall
kpackagetool6 -t Plasma/Applet -r "$ID" || true
rm -f "${XDG_STATE_HOME:-$HOME/.local/state}/claude-limits.json"
echo "Removed. If the widget is still in your panel, remove it there with a right-click."
