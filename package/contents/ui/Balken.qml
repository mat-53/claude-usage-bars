import QtQuick

// Ein Fortschrittsbalken.
// form: "round" = Enden als Halbkreis, "square" = eckig, "mixed" = leicht abgerundete Ecken
Rectangle {
    id: balken
    property real value: 0
    property color fuellFarbe: "#D97757"
    property color hintergrund: "#55595e"
    property string form: "round"

    radius: form === "square" ? 0 : (form === "mixed" ? Math.min(2, height / 2) : height / 2)
    color: hintergrund

    Rectangle {
        readonly property real anteil: Math.max(0, Math.min(100, balken.value)) / 100
        // Bei runden Enden mindestens so breit wie hoch, sonst wird der Halbkreis verzerrt
        width: anteil <= 0 ? 0 : Math.max(balken.form === "round" ? balken.height : 0, balken.width * anteil)
        height: balken.height
        radius: balken.radius
        color: balken.fuellFarbe
    }
}
