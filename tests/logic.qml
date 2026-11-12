import QtQuick
import "../package/contents/ui" as W

// Data logic and countdown, without any window
Item {
    readonly property real t0: 1000000

    W.Daten {
        objectName: "data"
        jetzt: 1000000
        hatDaten: true
        sprache: "en"
        labelsJson: '[{"label":"5H","key":"five"},{"label":"W","key":"week"}]'
        limits: ({
            "five_hour": { "pct": 33, "resets_at": 1000000 + 7800 },
            "seven_day": { "pct": 74, "resets_at": 1000000 + 3 * 86400 + 3600 },
            "spend_limit": { "pct": 12, "resets_at": 1000000 + 500 },
            "seven_day_opus": { "pct": 50, "resets_at": 999000 }
        })
    }

    W.Anzeige {
        objectName: "display"
        jetzt: 1000000
    }
}
