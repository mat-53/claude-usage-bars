import QtQuick
import QtQuick.Controls
import "../package/contents/ui" as W

// Renders a few widget variants at 4x size, for screenshots
ApplicationWindow {
    id: fenster
    width: 3 * (90 * 4 + 40) + 40
    height: 2 * 160 + 60
    visible: true
    color: "#202326"
    readonly property real jetzt: Date.now() / 1000

    Grid {
        x: 20
        y: 20
        columns: 3
        spacing: 40
        Repeater {
            model: [
                { form: "round", prozent: "off", seite: "right", reset: "off", mono: true },
                { form: "round", prozent: "inside", seite: "right", reset: "off", mono: true },
                { form: "round", prozent: "outside", seite: "left", reset: "outside", mono: true },
                { form: "square", prozent: "outside", seite: "right", reset: "off", mono: false },
                { form: "mixed", prozent: "inside", seite: "right", reset: "outside", resetSeite: "left", resetFarbe: "#cacaca", mono: true },
                { form: "round", prozent: "off", seite: "right", reset: "outside", mono: true, extra: true }
            ]
            delegate: Item {
                required property var modelData
                width: 90 * 4
                height: 40 * 4
                W.Anzeige {
                    width: 90
                    scale: 4
                    transformOrigin: Item.TopLeft
                    spacing: 1
                    zeilen: modelData.extra
                        ? [{ "label": "H", "key": "five" }, { "label": "W", "key": "week" }, { "label": "$", "key": "spend_limit" }]
                        : [{ "label": "H", "key": "five" }, { "label": "W", "key": "week" }]
                    werte: ({ "five": 11, "week": 88, "spend_limit": 40 })
                    resets: ({ "five": fenster.jetzt + 2 * 3600 + 600, "week": fenster.jetzt + 3 * 86400, "spend_limit": fenster.jetzt + 45 * 60 })
                    jetzt: fenster.jetzt
                    labelBreite: 10
                    form: modelData.form
                    prozentModus: modelData.prozent
                    prozentSeite: modelData.seite
                    prozentFarbe: modelData.prozent === "inside" ? "#FFFFFF" : "#D97757"
                    resetModus: modelData.reset
                    resetSeite: modelData.resetSeite || "right"
                    resetFarbe: modelData.resetFarbe || "#D97757"
                    gleichBreit: modelData.mono
                }
            }
        }
    }
}
