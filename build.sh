#!/usr/bin/env bash
# Builds dist/claude-usage-bars-<version>.plasmoid, the file for the KDE Store and for
# "Install from file" in Plasma's widget explorer.
set -euo pipefail
cd "$(dirname "$0")"
VERSION=$(python3 -c "import json; print(json.load(open('package/metadata.json'))['KPlugin']['Version'])")
OUT="dist/claude-usage-bars-$VERSION.plasmoid"
mkdir -p dist
rm -f "$OUT"
python3 - "$OUT" <<'EOF'
import os, sys, zipfile
out = sys.argv[1]
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for folder, dirs, files in os.walk("package"):
        dirs[:] = [d for d in dirs if d != "__pycache__"]
        for name in sorted(files):
            path = os.path.join(folder, name)
            info = zipfile.ZipInfo.from_file(path, os.path.relpath(path, "package"))
            with open(path, "rb") as f:
                z.writestr(info, f.read(), zipfile.ZIP_DEFLATED)
EOF
echo "$OUT"
