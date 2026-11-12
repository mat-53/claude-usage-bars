import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

// Farbwaehler: grosses Feld fuer Saettigung (links/rechts) und Helligkeit (oben/unten),
// darunter eine Regenbogen-Leiste fuer den Farbton
ColumnLayout {
    id: waehler
    property string farbe: "#D97757"     // Startfarbe, wird mit laden() uebernommen
    property real farbton: 0             // 0..1
    property real saettigung: 1          // 0..1
    property real helligkeit: 1          // 0..1
    readonly property string aktuell: Qt.hsva(farbton, saettigung, helligkeit, 1).toString()
    signal gewaehlt(string farbe)
    spacing: Kirigami.Units.largeSpacing

    function laden() {
        var c = Qt.color(farbe);
        if (c.hsvHue >= 0)          // Grau/Weiss/Schwarz haben keinen Farbton, dann den alten behalten
            farbton = c.hsvHue;
        saettigung = c.hsvSaturation;
        helligkeit = c.hsvValue;
    }
    function begrenzen(x) {
        return Math.max(0, Math.min(1, x));
    }

    Component.onCompleted: laden()

    RowLayout {
        spacing: Kirigami.Units.largeSpacing

        // Gewaehlte Farbe gross
        Rectangle {
            Layout.preferredWidth: 64
            Layout.preferredHeight: 150
            radius: 6
            color: waehler.aktuell
            border.width: 1
            border.color: Qt.rgba(0.5, 0.5, 0.5, 0.5)
        }

        Item {
            id: feld
            Layout.preferredWidth: 230
            Layout.preferredHeight: 150

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: Qt.hsva(waehler.farbton, 1, 1, 1)
                // nach links weiss
                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0; color: "#FFFFFFFF" }
                        GradientStop { position: 1; color: "#00FFFFFF" }
                    }
                }
                // nach unten schwarz
                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    gradient: Gradient {
                        GradientStop { position: 0; color: "#00000000" }
                        GradientStop { position: 1; color: "#FF000000" }
                    }
                }
            }
            // Der Punkt
            Rectangle {
                width: 18
                height: 18
                radius: 9
                x: waehler.saettigung * feld.width - 9
                y: (1 - waehler.helligkeit) * feld.height - 9
                color: waehler.aktuell
                border.width: 2
                border.color: "white"
            }
            MouseArea {
                objectName: "feld"
                anchors.fill: parent
                preventStealing: true
                cursorShape: Qt.CrossCursor
                function setzen(maus) {
                    waehler.saettigung = waehler.begrenzen(maus.x / width);
                    waehler.helligkeit = 1 - waehler.begrenzen(maus.y / height);
                    waehler.gewaehlt(waehler.aktuell);
                }
                onPressed: maus => setzen(maus)
                onPositionChanged: maus => setzen(maus)
            }
        }
    }

    // Regenbogen fuer den Farbton
    Item {
        id: leiste
        Layout.fillWidth: true
        Layout.preferredHeight: 20

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 10
            radius: 5
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0 / 6; color: "#FF0000" }
                GradientStop { position: 1 / 6; color: "#FFFF00" }
                GradientStop { position: 2 / 6; color: "#00FF00" }
                GradientStop { position: 3 / 6; color: "#00FFFF" }
                GradientStop { position: 4 / 6; color: "#0000FF" }
                GradientStop { position: 5 / 6; color: "#FF00FF" }
                GradientStop { position: 6 / 6; color: "#FF0000" }
            }
        }
        Rectangle {
            width: 20
            height: 20
            radius: 10
            y: 0
            x: waehler.farbton * leiste.width - 10
            color: Qt.hsva(waehler.farbton, 1, 1, 1)
            border.width: 2
            border.color: "white"
        }
        MouseArea {
            objectName: "regenbogen"
            anchors.fill: parent
            preventStealing: true
            cursorShape: Qt.PointingHandCursor
            function setzen(maus) {
                waehler.farbton = Math.min(0.999, waehler.begrenzen(maus.x / width));
                waehler.gewaehlt(waehler.aktuell);
            }
            onPressed: maus => setzen(maus)
            onPositionChanged: maus => setzen(maus)
        }
    }
}
