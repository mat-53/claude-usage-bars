import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

// Beschriftungen und Balken untereinander. Wird in der Taskleiste und in der Vorschau der Einstellungen benutzt.
ColumnLayout {
    id: anzeige
    property var zeilen: []
    property var werte: ({})
    property color textFarbe: "#D97757"
    property color balkenFarbe: "#D97757"
    property color hintergrund: "#55595e"
    property string form: "round"
    property int schriftGroesse: 8
    property int labelBreite: 12
    property int balkenHoehe: 9

    // Prozentanzeige
    property string prozentModus: "off"      // "off", "inside" (im Balken), "outside" (neben dem Balken)
    property string prozentSeite: "right"    // "left" oder "right"
    property bool prozentZeichen: true       // mit "%" oder nur die Zahl
    property color prozentFarbe: "#FFFFFF"
    property int prozentGroesse: 7

    // Countdown to the reset, next to the bar ("45m", "2h", "3d")
    property string resetModus: "off"        // "off" or "outside"
    property var resets: ({})                // reset time (Unix seconds) by row key
    property real jetzt: Date.now() / 1000

    function countdown(zeit) {
        var s = zeit - jetzt;
        if (!zeit || s <= 0) return "–";
        var m = Math.ceil(s / 60);
        if (m < 60) return m + "m";
        var h = Math.floor(m / 60);
        if (h < 24) return h + "h";
        return Math.floor(h / 24) + "d";
    }
    readonly property int resetBreite: Math.ceil(resetMessung.advanceWidth)

    // Gleich breite Schrift (wie beim Programmieren): jedes Zeichen gleich breit, 1 so breit wie 8, H so breit wie W
    property bool gleichBreit: true
    readonly property string schriftArt: gleichBreit ? Kirigami.Theme.fixedWidthFont.family : Kirigami.Theme.defaultFont.family

    // Feste Breite fuer die Zahl daneben, damit alle Balken gleich lang bleiben
    readonly property int prozentBreite: Math.ceil(messung.advanceWidth)

    spacing: 3

    TextMetrics {
        id: resetMessung
        font.pixelSize: anzeige.schriftGroesse
        font.bold: true
        font.family: anzeige.schriftArt
        text: "59m"
    }

    TextMetrics {
        id: messung
        font.pixelSize: anzeige.prozentGroesse
        font.bold: true
        font.family: anzeige.schriftArt
        text: anzeige.prozentZeichen ? "100%" : "100"
    }

    Repeater {
        model: anzeige.zeilen
        delegate: RowLayout {
            id: zeile
            required property var modelData
            readonly property real wert: anzeige.werte[modelData.key] || 0
            readonly property string prozentText: Math.round(wert) + (anzeige.prozentZeichen ? "%" : "")
            readonly property bool daneben: anzeige.prozentModus === "outside"
            Layout.fillWidth: true
            spacing: 3

            Text {
                text: modelData.label
                color: anzeige.textFarbe
                font.pixelSize: anzeige.schriftGroesse
                font.bold: true
                font.family: anzeige.schriftArt
                Layout.preferredWidth: anzeige.labelBreite
                Layout.minimumWidth: anzeige.labelBreite
                Layout.maximumWidth: anzeige.labelBreite
                // Zeile nur so hoch wie der Balken, damit "Abstand" wirklich der Abstand zwischen den Balken ist
                Layout.preferredHeight: anzeige.balkenHoehe
                Layout.maximumHeight: anzeige.balkenHoehe
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }

            // Prozent links, zwischen Beschriftung und Balken
            Text {
                visible: zeile.daneben && anzeige.prozentSeite === "left"
                text: zeile.prozentText
                color: anzeige.prozentFarbe
                font.pixelSize: anzeige.prozentGroesse
                font.bold: true
                font.family: anzeige.schriftArt
                Layout.preferredWidth: anzeige.prozentBreite
                Layout.minimumWidth: anzeige.prozentBreite
                Layout.preferredHeight: anzeige.balkenHoehe
                Layout.maximumHeight: anzeige.balkenHoehe
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }

            Balken {
                id: balken
                Layout.fillWidth: true
                Layout.preferredHeight: anzeige.balkenHoehe
                value: zeile.wert
                fuellFarbe: anzeige.balkenFarbe
                hintergrund: anzeige.hintergrund
                form: anzeige.form

                // Prozent im Balken
                Text {
                    readonly property real rand: anzeige.form === "round" ? Math.max(2, balken.height / 3) : 2
                    visible: anzeige.prozentModus === "inside"
                    text: zeile.prozentText
                    color: anzeige.prozentFarbe
                    font.pixelSize: anzeige.prozentGroesse
                    font.bold: true
                    font.family: anzeige.schriftArt
                    anchors.verticalCenter: parent.verticalCenter
                    x: anzeige.prozentSeite === "right" ? parent.width - width - rand : rand
                }
            }

            // Prozent rechts neben dem Balken
            Text {
                visible: zeile.daneben && anzeige.prozentSeite === "right"
                text: zeile.prozentText
                color: anzeige.prozentFarbe
                font.pixelSize: anzeige.prozentGroesse
                font.bold: true
                font.family: anzeige.schriftArt
                Layout.preferredWidth: anzeige.prozentBreite
                Layout.minimumWidth: anzeige.prozentBreite
                Layout.preferredHeight: anzeige.balkenHoehe
                Layout.maximumHeight: anzeige.balkenHoehe
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }

            // Countdown to the reset, at the far right
            Text {
                visible: anzeige.resetModus === "outside"
                text: anzeige.countdown(anzeige.resets[modelData.key] || 0)
                color: anzeige.textFarbe
                font.pixelSize: anzeige.schriftGroesse
                font.bold: true
                font.family: anzeige.schriftArt
                Layout.preferredWidth: anzeige.resetBreite
                Layout.minimumWidth: anzeige.resetBreite
                Layout.preferredHeight: anzeige.balkenHoehe
                Layout.maximumHeight: anzeige.balkenHoehe
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
