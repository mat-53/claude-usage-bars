.pragma library
// Translations. The English text is the key, German below.
// To add a language: add a table like `de` and an entry in `tables`.

var de = {
    "Preview:": "Vorschau:",
    "Language:": "Sprache:",
    "Claude Code:": "Claude Code:",
    "Connected": "Verbunden",
    "Not connected yet": "Noch nicht verbunden",
    "Connect": "Verbinden",
    "Disconnect": "Trennen",
    "Checking…": "Prüfe…",
    "Bars": "Balken",
    "Rows:": "Zeilen:",
    "Text": "Text",
    "5-hour limit": "5-Stunden-Limit",
    "Weekly limit": "Wochenlimit",
    "Remove": "Entfernen",
    "Add bar": "Balken hinzufügen",
    "New": "Neu",
    "Colors": "Farben",
    "Bar:": "Balken:",
    "Empty part:": "Leerer Teil:",
    "Text:": "Schrift:",
    "Shape": "Form",
    "Ends:": "Enden:",
    "Round": "Rund",
    "Square": "Eckig",
    "Mixed": "Gemischt",
    "Font:": "Schriftart:",
    "Normal": "Normal",
    "Monospace (like in code)": "Gleich breit (wie beim Programmieren)",
    "Percent": "Prozent",
    "Show:": "Anzeigen:",
    "Off": "Aus",
    "Inside the bar": "Im Balken",
    "Next to the bar": "Neben dem Balken",
    "Next to the bar (45m, 2h, 3d)": "Neben dem Balken (45m, 2h, 3d)",
    "Side:": "Seite:",
    "Left": "Links",
    "Left (between text and bar)": "Links (zwischen Text und Balken)",
    "Right": "Rechts",
    "Format:": "Format:",
    "Number only (42)": "Nur Zahl (42)",
    "With sign (42%)": "Mit Zeichen (42%)",
    "Color:": "Farbe:",
    "Font size:": "Schriftgröße:",
    "Size and spacing": "Größe und Abstände",
    "Widget width:": "Breite des Widgets:",
    "Bar height:": "Balkenhöhe:",
    "Space between rows:": "Abstand zwischen den Zeilen:",
    "Label width:": "Breite der Beschriftung:",
    "Width:": "Breite:",
    "Automatic": "Automatisch",
    "Orange (default)": "Orange (Standard)",
    "Blue": "Blau",
    "Green": "Grün",
    "Red": "Rot",
    "Gray": "Grau",
    "White": "Weiß",
    "Custom color": "Eigene Farbe",
    "Done": "Fertig",
    "Reset": "Reset",
    "Countdown:": "Countdown:",
    "The exact reset time is shown when you hover over the widget.":
        "Die genaue Reset-Zeit siehst du, wenn du mit der Maus über das Widget fährst.",
    "Extra limits:": "Weitere Limits:",
    "Show automatically": "Automatisch zeigen",
    "Hide": "Ausblenden",
    "Extra limits appear by themselves while Claude Code reports them (for example a spend limit) and disappear again.":
        "Weitere Limits erscheinen von selbst, solange Claude Code sie meldet (zum Beispiel ein Ausgabenlimit), und verschwinden wieder.",
    "Spend limit": "Ausgabenlimit",
    "resets": "Reset",
    "in": "in",
    "d": "T",
    "h": "Std",
    "min": "Min",
    "reset done": "zurückgesetzt",
    "No data yet. Connect Claude Code in the settings, then use Claude Code once.":
        "Noch keine Daten. In den Einstellungen Claude Code verbinden und Claude Code einmal benutzen."
};

var tables = { "de": de };

// setting: "auto", "en" or "de"
function language(setting) {
    if (setting && setting !== "auto")
        return setting;
    var code = Qt.locale().name.split("_")[0];
    return tables[code] ? code : "en";
}

function t(text, setting) {
    var table = tables[language(setting)];
    return table && table[text] !== undefined ? table[text] : text;
}
