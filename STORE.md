# Text for the KDE Store page

Not part of the widget. Copy these fields when creating the product on store.kde.org.

**Name:** Claude Usage Bars

**Category:** Plasma 6 Applets (Plasma Widgets > Plasma 6 Applets)

**Summary:**
Unofficial: your Claude Code 5-hour and weekly usage limits as small bars in the panel.

**Description:**

Shows your Claude Code usage limits as bars in the panel: the 5-hour limit and the weekly limit.

- Percentage inside or next to the bar, with or without %
- Countdown to the next reset (45m, 2h, 3d), left or right, own color, exact time in the tooltip
- Bars drop to 0 by themselves when a limit resets
- Extra limits (e.g. a spend limit) appear on their own while Claude Code reports them
- Palette and color picker, round/square/mixed ends, monospace font, sizes and spacing
- English and German

Setup: add the widget, open its settings and click "Connect" next to "Claude Code". This registers a small status line helper in ~/.claude/settings.json (an existing status line keeps working, "Disconnect" restores it). Needs Claude Code signed in with a Claude.ai Pro or Max subscription, and python3.

Fully offline: no network access, no login data. It only reads what Claude Code already gives to status lines.

Not made by, affiliated with, or endorsed by Anthropic. "Claude" is a trademark of Anthropic.

Source and issues: https://github.com/mat-53/claude-usage-bars

**License:** MIT

**Version:** 1.1.0

**Changelog (1.1.0):**
- Countdown: choose the side (left between text and bar, or right) and its own color
- Countdown width: automatic (as wide as the text shown, no empty gap) or a fixed width in px
- Label width can go down to 1 px

**Changelog (1.0.0):** First release.

**File:** dist/claude-usage-bars-1.1.0.plasmoid (made with ./build.sh)

**Logo:** screenshots/logo.png

**Screenshots:** screenshots/variants.png, screenshots/settings-en.png, screenshots/color-picker.png
