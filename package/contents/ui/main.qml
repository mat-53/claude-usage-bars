import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root
    readonly property var cfg: plasmoid.configuration

    // Replace invalid or empty colors with the default
    function farbe(wert, standard) {
        return /^#[0-9a-fA-F]{6}$/.test(wert) ? wert : standard;
    }

    Daten {
        id: daten
        sprache: root.cfg.language
        labelsJson: root.cfg.labelsJson
        autoExtra: root.cfg.autoExtra
    }

    // Keeps the time current, so bars drop to 0 after a reset even while Claude Code is closed
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: daten.jetzt = Date.now() / 1000
    }

    // Reads the file written by the status line helper (see contents/code)
    P5Support.DataSource {
        engine: "executable"
        connectedSources: ["sh -c 'cat \"${XDG_STATE_HOME:-$HOME/.local/state}/claude-limits.json\" 2>/dev/null'"]
        interval: 30000
        onNewData: function (sourceName, data) {
            daten.laden(data["stdout"]);
        }
    }

    toolTipMainText: "Claude Usage Bars"
    toolTipSubText: daten.tooltip

    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        // Fixed width, so the panel never squeezes or stretches the widget
        Layout.minimumWidth: root.cfg.widgetWidth
        Layout.preferredWidth: root.cfg.widgetWidth
        Layout.maximumWidth: root.cfg.widgetWidth

        // Rows as one block in the middle, instead of spread over the panel height
        Anzeige {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: root.cfg.rowSpacing

            zeilen: daten.zeilen
            werte: daten.werte
            resets: daten.resets
            jetzt: daten.jetzt
            textFarbe: root.farbe(root.cfg.textColor, "#D97757")
            balkenFarbe: root.farbe(root.cfg.barColor, "#D97757")
            hintergrund: root.farbe(root.cfg.trackColor, "#55595e")
            form: root.cfg.barShape
            schriftGroesse: root.cfg.fontSize
            labelBreite: root.cfg.labelWidth
            balkenHoehe: root.cfg.barHeight
            prozentModus: root.cfg.percentMode
            prozentSeite: root.cfg.percentSide
            prozentZeichen: root.cfg.percentSymbol
            prozentFarbe: root.farbe(root.cfg.percentColor, "#FFFFFF")
            prozentGroesse: root.cfg.percentFontSize
            gleichBreit: root.cfg.monoFont
            resetModus: root.cfg.resetMode
        }
    }
}
