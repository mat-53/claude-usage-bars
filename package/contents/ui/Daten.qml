import QtQuick
import "texte.js" as Texte

// Turns the helper's data into values, reset times, rows and tooltip text.
// Needs no Plasma, so it can be tested on its own (see tests/).
QtObject {
    id: daten

    // From the helper file: {name: {pct, resets_at}}, e.g. five_hour, seven_day, spend_limit
    property var limits: ({})
    property bool hatDaten: false
    property real jetzt: Date.now() / 1000      // current time in seconds
    property string sprache: "auto"
    property string labelsJson: ""
    property bool autoExtra: true

    function t(text) {
        return Texte.t(text, sprache);
    }
    // Row keys "five"/"week" are the 5-hour and weekly windows
    function limitName(key) {
        return key === "five" ? "five_hour" : key === "week" ? "seven_day" : key;
    }
    // A window counts while its reset time has not passed
    function aktiv(name) {
        var l = limits[name];
        return !!l && !(l.resets_at && l.resets_at <= jetzt);
    }
    function prozentVon(key) {
        var name = limitName(key);
        return aktiv(name) ? limits[name].pct : 0;
    }
    function resetVon(key) {
        var name = limitName(key);
        return aktiv(name) ? (limits[name].resets_at || 0) : 0;
    }
    // Short label for limits that appear by themselves
    function kurzName(name) {
        if (name === "spend_limit") return "$";
        var teil = name.indexOf("seven_day_") === 0 ? name.substring(10) : name;
        return teil.charAt(0).toUpperCase();
    }
    function langName(name) {
        if (name === "five_hour") return t("5-hour limit");
        if (name === "seven_day") return t("Weekly limit");
        if (name === "spend_limit") return t("Spend limit");
        if (name.indexOf("seven_day_") === 0) return t("Weekly limit") + " (" + name.substring(10) + ")";
        return name;
    }
    function dauer(sekunden) {
        var m = Math.max(0, Math.ceil(sekunden / 60));
        var d = Math.floor(m / 1440), h = Math.floor((m % 1440) / 60), min = m % 60;
        if (d > 0) return d + " " + t("d") + " " + h + " " + t("h");
        if (h > 0) return h + " " + t("h") + " " + min + " " + t("min");
        return min + " " + t("min");
    }
    function resetText(name) {
        var zeit = limits[name].resets_at;
        if (!zeit) return "";
        var ort = Qt.locale(Texte.language(sprache) === "de" ? "de_DE" : "en_US");
        return " · " + t("resets") + " " + new Date(zeit * 1000).toLocaleString(ort, "ddd HH:mm")
            + " (" + t("in") + " " + dauer(zeit - jetzt) + ")";
    }

    // Values and reset times by row key
    readonly property var werte: {
        var w = { "five": prozentVon("five"), "week": prozentVon("week") };
        for (var n in limits) w[n] = prozentVon(n);
        return w;
    }
    readonly property var resets: {
        var r = { "five": resetVon("five"), "week": resetVon("week") };
        for (var n in limits) r[n] = resetVon(n);
        return r;
    }

    // Configured rows, plus extra limits while Claude Code reports them
    readonly property var zeilen: {
        var liste;
        try {
            liste = JSON.parse(labelsJson);
        } catch (e) {
            liste = [{ "label": "5H", "key": "five" }, { "label": "W", "key": "week" }];
        }
        if (autoExtra) {
            for (var n in limits)
                if (n !== "five_hour" && n !== "seven_day" && aktiv(n))
                    liste = liste.concat([{ "label": kurzName(n), "key": n }]);
        }
        return liste;
    }

    readonly property string tooltip: {
        if (!hatDaten)
            return t("No data yet. Connect Claude Code in the settings, then use Claude Code once.");
        var zeilenText = [];
        for (var n in limits) {
            if (aktiv(n))
                zeilenText.push(langName(n) + ": " + limits[n].pct + "%" + resetText(n));
            else
                zeilenText.push(langName(n) + ": 0% (" + t("reset done") + ")");
        }
        return zeilenText.join("\n");
    }

    // Reads the helper file content; older helper versions only wrote five/week
    function laden(text) {
        try {
            var d = JSON.parse(text);
            limits = d.limits || { "five_hour": { "pct": d.five }, "seven_day": { "pct": d.week } };
            hatDaten = true;
        } catch (e) {
            hatDaten = false;
        }
        jetzt = Date.now() / 1000;
    }
}
