#!/usr/bin/python3
"""Offscreen tests for Claude Usage Bars. Needs the distribution's PySide6 (it must use the system Qt,
so the KDE QML modules load), e.g. `sudo dnf install python3-pyside6` on Fedora.

    /usr/bin/python3 tests/run_tests.py [--screenshots]

--screenshots also saves the pictures in screenshots/.
"""
import os
import sys
import tempfile

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "org.kde.desktop")
# The connect button must never touch the real Claude settings
TEMP = tempfile.mkdtemp(prefix="claude-usage-bars-test-")
os.environ["CLAUDE_CONFIG_DIR"] = os.path.join(TEMP, "claude")
os.environ["CLAUDE_USAGE_BARS_BIN_DIR"] = os.path.join(TEMP, "bin")

from PySide6.QtCore import QCoreApplication, QObject, QPoint, QPointF, Qt, QUrl, QMetaObject, Q_ARG, Q_RETURN_ARG
from PySide6.QtGui import QWheelEvent
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuick import QQuickItem
from PySide6.QtTest import QTest
from PySide6.QtWidgets import QApplication

HERE = os.path.dirname(os.path.abspath(__file__))
SHOTS = os.path.join(HERE, "..", "screenshots")
SAVE_SHOTS = "--screenshots" in sys.argv

app = QApplication(sys.argv)
engine = QQmlApplicationEngine()
warnings = []
engine.warnings.connect(lambda ws: warnings.extend(w.toString() for w in ws))
failures = []


def check(name, ok, detail=""):
    print(("PASS  " if ok else "FAIL  ") + name + (f"   ({detail})" if detail and not ok else ""))
    if not ok:
        failures.append(name)


def load(name):
    engine.load(QUrl.fromLocalFile(os.path.join(HERE, name)))
    if not engine.rootObjects():
        print("Could not load", name)
        print("\n".join(warnings))
        sys.exit(1)
    return engine.rootObjects()[-1]


def named(obj, name):
    return obj.findChildren(QObject, name)


def named_prefix(obj, prefix):
    from PySide6.QtCore import QRegularExpression
    return obj.findChildren(QObject, QRegularExpression("^" + QRegularExpression.escape(prefix)))


def value(obj, name):
    v = obj.property(name)
    return v.toVariant() if hasattr(v, "toVariant") else v


def call(obj, method, *args):
    return QMetaObject.invokeMethod(obj, method, Qt.DirectConnection, Q_RETURN_ARG("QVariant"),
                                    *[Q_ARG("QVariant", a) for a in args])


def shot(window, name):
    if SAVE_SHOTS:
        os.makedirs(SHOTS, exist_ok=True)
        window.grabWindow().save(os.path.join(SHOTS, name))


# ---------- 1) Data logic ----------
root = load("logic.qml")
data = root.findChild(QObject, "data")
display = named(root, "display")[0]

values = value(data, "werte")
check("5-hour value", values["five"] == 33, values)
check("weekly value", values["week"] == 74, values)
check("spend limit value", values["spend_limit"] == 12, values)
check("expired limit counts as 0", values["seven_day_opus"] == 0, values)
rows = value(data, "zeilen")
check("extra limit appears as its own row", [r["key"] for r in rows] == ["five", "week", "spend_limit"], rows)
check("extra row label is $", rows[-1]["label"] == "$", rows)
tip = value(data, "tooltip")
check("tooltip has the 5-hour reset", "5-hour limit: 33% · resets" in tip and "(in 2 h 10 min)" in tip, tip)
check("tooltip has the weekly reset", "(in 3 d 1 h)" in tip, tip)
check("tooltip marks the expired limit", "Weekly limit (opus): 0% (reset done)" in tip, tip)

data.setProperty("autoExtra", False)
check("extra rows hidden when switched off", len(value(data, "zeilen")) == 2)
data.setProperty("autoExtra", True)

data.setProperty("jetzt", 1000000 + 7801)
values = value(data, "werte")
check("5-hour bar drops to 0 after its reset", values["five"] == 0 and values["week"] == 74, values)
check("spend limit row disappears after its reset", [r["key"] for r in value(data, "zeilen")] == ["five", "week"])
data.setProperty("jetzt", 1000000)

data.setProperty("sprache", "de")
tip = value(data, "tooltip")
check("German tooltip", "5-Stunden-Limit: 33% · Reset" in tip and "(in 2 Std 10 Min)" in tip, tip)

data.setProperty("hatDaten", False)
check("hint when there is no data yet", "Connect Claude Code" not in value(data, "tooltip") and "verbinden" in value(data, "tooltip"))
data.setProperty("sprache", "en")
check("English hint", "Connect Claude Code in the settings" in value(data, "tooltip"))

call(data, "laden", '{"five": 20, "week": 30}')
check("old helper format still works", value(data, "werte")["five"] == 20 and value(data, "werte")["week"] == 30)
call(data, "laden", "not json")
check("broken file shows the no-data hint", value(data, "hatDaten") is False)

t0 = 1000000
for seconds, expected in [(45 * 60, "45m"), (2 * 3600 + 600, "2h"), (3 * 86400, "3d"), (-5, "–"), (0, "–")]:
    got = call(display, "countdown", t0 + seconds if seconds else 0)
    check(f"countdown {expected}", got == expected, got)

# ---------- 2) Settings page ----------
win = load("settings_page.qml")
QTest.qWait(1500)
page = named(win, "page")[0]


def qml(function, *args):
    return call(win, function, *args)


def spot(name, index=0, visible=False, fx=0.5, fy=0.5):
    return qml("stelle", name, index, visible, fx, fy).toPoint()


def click(name, index=0, visible=False):
    QTest.mouseClick(win, Qt.LeftButton, Qt.NoModifier, spot(name, index, visible))
    QTest.qWait(300)


def count(name, visible=False):
    return qml("anzahl", name, visible)


def wait_for(condition, ms=5000):
    for _ in range(ms // 100):
        if condition():
            return True
        QTest.qWait(100)
    return False


shot(win, "settings-en.png")

# Connection to Claude Code (temporary folders, see top)
check("connection is checked", wait_for(lambda: page.property("verbindung") == "missing"), page.property("verbindung"))
click("verbinden")
check("connect sets it up", wait_for(lambda: page.property("verbindung") == "ok"), page.property("verbindung"))
check("helper copied", os.path.exists(os.path.join(TEMP, "bin", "claude-usage-bars-statusline")))
check("settings.json written", os.path.exists(os.path.join(TEMP, "claude", "settings.json")))
click("verbinden")
check("disconnect removes it", wait_for(lambda: page.property("verbindung") == "missing"), page.property("verbindung"))

# Colors
check("palette circles", qml("anzahlPraefix", "farbe:") == 30, qml("anzahlPraefix", "farbe:"))
click("farbe:#3B82F6", 0)
check("bar color blue", page.property("cfg_barColor") == "#3B82F6", page.property("cfg_barColor"))
click("farbe:#22C55E", 1)
check("empty part green", page.property("cfg_trackColor") == "#22C55E")
click("farbe:#FFFFFF", 2)
check("text white", page.property("cfg_textColor") == "#FFFFFF")
click("farbe:#D97757", 0)

# Color picker
click("eigeneFarbe", 0)
QTest.qWait(400)
check("color picker opens", count("feld", True) == 1)
QTest.mousePress(win, Qt.LeftButton, Qt.NoModifier, spot("feld", 0, True, 0.5, 0.5))
QTest.mouseMove(win, spot("feld", 0, True, 0.95, 0.05))
QTest.mouseRelease(win, Qt.LeftButton, Qt.NoModifier, spot("feld", 0, True, 0.95, 0.05))
QTest.qWait(200)
check("dragging the dot picks a strong color", page.property("cfg_barColor") not in ("#D97757", ""), page.property("cfg_barColor"))
QTest.mouseClick(win, Qt.LeftButton, Qt.NoModifier, spot("regenbogen", 0, True, 0.6667, 0.5))
QTest.qWait(200)
color = page.property("cfg_barColor")
check("rainbow picks blue", color[5:7] > color[1:3] and color[5:7] > color[3:5], color)
shot(win, "color-picker.png")
click("fertig", 0, True)
check("Done closes the picker", count("feld", True) == 0)
click("farbe:#D97757", 0)

# Shapes, percent, font, extra limits
for name, prop, expected in [("form:square", "cfg_barShape", "square"), ("form:mixed", "cfg_barShape", "mixed"),
                             ("form:round", "cfg_barShape", "round"),
                             ("wahl:outside", "cfg_percentMode", "outside"), ("wahl:left", "cfg_percentSide", "left"),
                             ("wahl:number", "cfg_percentSymbol", False), ("wahl:inside", "cfg_percentMode", "inside"),
                             ("wahl:percent", "cfg_percentSymbol", True), ("wahl:normal", "cfg_monoFont", False),
                             ("wahl:mono", "cfg_monoFont", True), ("wahl:hide", "cfg_autoExtra", False),
                             ("wahl:auto", "cfg_autoExtra", True)]:
    # "wahl:auto" exists twice (language and extra limits), the extra limits row comes last
    click(name, -1 if name == "wahl:auto" else 0)
    check(f"{name} -> {prop}", page.property(prop) == expected, page.property(prop))
# The reset countdown row is the last "off"/"outside" pair on the page
click("wahl:off", -1)
check("countdown off", page.property("cfg_resetMode") == "off", page.property("cfg_resetMode"))
click("wahl:outside", -1)
check("countdown on", page.property("cfg_resetMode") == "outside", page.property("cfg_resetMode"))
# Countdown side and color: the last "left"/"right" pair and the fifth color row
check("countdown color follows the text color while unset", qml("wert", "vorschau", 0, "resetFarbe") ==
      qml("wert", "vorschau", 0, "textFarbe"), qml("wert", "vorschau", 0, "resetFarbe"))
click("wahl:left", -1)
check("countdown left", page.property("cfg_resetSide") == "left", page.property("cfg_resetSide"))
check("percent side unchanged", page.property("cfg_percentSide") == "left", page.property("cfg_percentSide"))
click("farbe:#3B82F6", 4)
check("countdown color blue", page.property("cfg_resetColor") == "#3B82F6", page.property("cfg_resetColor"))
check("text color unchanged", page.property("cfg_textColor") == "#FFFFFF", page.property("cfg_textColor"))
click("wahl:right", -1)
check("countdown right", page.property("cfg_resetSide") == "right", page.property("cfg_resetSide"))
auto_width = qml("wert", "vorschau", 0, "resetBreite")
# The preview shows "2h" and "3d": the automatic width is two characters, not "59m"
check("auto width fits the shown countdowns", 0 < auto_width < qml("wert", "vorschau", 0, "schriftGroesse") * 1.6,
      auto_width)
check("Automatic is ticked by default", qml("wert", "resetBreiteAuto", 0, "checked") is True)
check("width field starts at the automatic width", qml("wert", "resetBreite", 0, "value") == auto_width,
      qml("wert", "resetBreite", 0, "value"))
QTest.mouseClick(win, Qt.LeftButton, Qt.NoModifier, spot("resetBreite", 0, False, 0.97, 0.75))
QTest.qWait(300)
check("arrow down makes it narrower than auto", page.property("cfg_resetWidth") == auto_width - 1,
      page.property("cfg_resetWidth"))
check("Automatic is unticked after a change", qml("wert", "resetBreiteAuto", 0, "checked") is False)
check("preview uses the fixed width", qml("wert", "vorschau", 0, "resetBreite") == auto_width - 1)
click("resetBreiteAuto")
check("ticking Automatic goes back to auto", page.property("cfg_resetWidth") == 0 and
      qml("wert", "vorschau", 0, "resetBreite") == auto_width, page.property("cfg_resetWidth"))
click("wahl:off", -1)
check("countdown side is greyed out while off", qml("wert", "wahl:left", -1, "enabled") is False)
click("wahl:outside", -1)

# Rows
click("hinzufuegen")
check("add a bar", page.property("cfg_labelsJson").count("label") == 3)
click("entfernen", -1)
check("remove a bar", page.property("cfg_labelsJson") == '[{"label":"5H","key":"five"},{"label":"W","key":"week"}]',
      page.property("cfg_labelsJson"))

# Language
click("wahl:de")
check("German texts", qml("wert", "hinzufuegen", 0, "text") == "Balken hinzufügen", qml("wert", "hinzufuegen", 0, "text"))
check("weekly row keeps its choice after a language change", qml("wert", "limitWahl", 1, "currentIndex") == 1,
      qml("wert", "limitWahl", 1, "currentIndex"))
check("weekly row shows the German name", qml("wert", "limitWahl", 1, "displayText") == "Wochenlimit",
      qml("wert", "limitWahl", 1, "displayText"))
shot(win, "settings-de.png")
click("wahl:en")
check("English texts", qml("wert", "hinzufuegen", 0, "text") == "Add bar")

# Scrolling in a small window
win.resize(760, 450)
QTest.qWait(500)
for _ in range(40):
    pos = QPointF(380, 300)
    QCoreApplication.sendEvent(win, QWheelEvent(pos, win.mapToGlobal(pos), QPoint(0, 0), QPoint(0, -120),
                                                Qt.NoButton, Qt.NoModifier, Qt.NoScrollPhase, False))
    QTest.qWait(30)
QTest.qWait(600)
y, h, c = win.property("flickY"), win.property("flickHeight"), win.property("flickContent")
check("page scrolls to the bottom", y > 0 and abs(y + h - c) < 20, (y, h, c))

# ---------- 3) Looks ----------
looks = load("looks.qml")
QTest.qWait(600)
shot(looks, "variants.png")

print("--- QML warnings ---")
print("\n".join(warnings) or "none")
check("no QML warnings", not warnings)
print(f"\n{len(failures)} failed" if failures else "\nAll tests passed")
sys.exit(1 if failures else 0)
