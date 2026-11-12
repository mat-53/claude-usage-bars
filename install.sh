#!/usr/bin/env bash
# Installs Claude Usage Bars from this folder: the Plasma widget and the connection to Claude Code.
set -euo pipefail
cd "$(dirname "$0")"
ID=com.github.mat-53.claude-usage-bars

if [ -d "$HOME/.local/share/plasma/plasmoids/$ID" ]; then
    kpackagetool6 -t Plasma/Applet -u "$PWD/package"
    UPDATED=1
else
    kpackagetool6 -t Plasma/Applet -i "$PWD/package"
    UPDATED=0
fi

python3 package/contents/code/setup.py install

echo
if [ "$UPDATED" = 1 ]; then
    echo "Updated. Restart Plasma once to load the new version:"
    echo "    systemctl --user restart plasma-plasmashell.service"
else
    echo "Done. Add the widget: right-click the panel > Add or Manage Widgets > search for \"Claude Usage Bars\"."
fi
echo "The bars fill in after Claude Code's next reply."
