import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "texte.js" as Texte

// Farbkreise zum Anklicken, dazu ein Feld fuer eigene Hex-Farben
RowLayout {
    id: reihe
    property var farben: []          // [{name, farbe}]
    property string wert: ""
    property string sprache: "auto"
    signal gewaehlt(string farbe)
    spacing: Kirigami.Units.largeSpacing

    function t(text) {
        return Texte.t(text, sprache);
    }

    function gleich(a, b) {
        return String(a).toLowerCase() === String(b).toLowerCase();
    }

    onWertChanged: hex.text = wert

    function inListe() {
        for (var i = 0; i < farben.length; i++)
            if (gleich(farben[i].farbe, wert))
                return true;
        return false;
    }

    Row {
        spacing: Kirigami.Units.smallSpacing
        Repeater {
            model: reihe.farben
            delegate: Rectangle {
                id: kreis
                required property var modelData
                readonly property bool aktiv: reihe.gleich(reihe.wert, modelData.farbe)
                width: 28
                height: 28
                radius: 14
                color: "transparent"
                border.width: 2
                border.color: aktiv ? Kirigami.Theme.highlightColor : "transparent"

                Rectangle {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    radius: 10
                    color: kreis.modelData.farbe
                    border.width: 1
                    border.color: Qt.rgba(0.5, 0.5, 0.5, 0.7)
                }
                MouseArea {
                    id: maus
                    objectName: "farbe:" + kreis.modelData.farbe
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: reihe.gewaehlt(kreis.modelData.farbe)
                }
                ToolTip.visible: maus.containsMouse
                ToolTip.text: reihe.t(kreis.modelData.name)
                ToolTip.delay: 300
            }
        }

        // Eigene Farbe: oeffnet den Farbwaehler
        Rectangle {
            id: eigene
            width: 28
            height: 28
            radius: 14
            color: "transparent"
            border.width: 2
            border.color: !reihe.inListe() ? Kirigami.Theme.highlightColor : "transparent"

            Rectangle {
                anchors.centerIn: parent
                width: 20
                height: 20
                radius: 10
                border.width: 1
                border.color: Qt.rgba(0.5, 0.5, 0.5, 0.7)
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
            MouseArea {
                id: eigeneMaus
                objectName: "eigeneFarbe"
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: fenster.opened ? fenster.close() : fenster.open()
            }
            ToolTip.visible: eigeneMaus.containsMouse && !fenster.opened
            ToolTip.text: reihe.t("Custom color")
            ToolTip.delay: 300

            Popup {
                id: fenster
                y: eigene.height + Kirigami.Units.smallSpacing
                x: eigene.width / 2 - width / 2
                margins: Kirigami.Units.smallSpacing
                padding: Kirigami.Units.largeSpacing
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                onAboutToShow: {
                    waehler.farbe = reihe.wert;
                    waehler.laden();
                }

                contentItem: ColumnLayout {
                    spacing: Kirigami.Units.largeSpacing
                    Farbwaehler {
                        id: waehler
                        onGewaehlt: farbe => reihe.gewaehlt(farbe)
                    }
                    Button {
                        objectName: "fertig"
                        Layout.alignment: Qt.AlignRight
                        text: reihe.t("Done")
                        icon.name: "dialog-ok"
                        onClicked: fenster.close()
                    }
                }
            }
        }
    }

    TextField {
        id: hex
        text: reihe.wert
        placeholderText: "#RRGGBB"
        Layout.preferredWidth: Kirigami.Units.gridUnit * 5
        onEditingFinished: {
            if (/^#[0-9a-fA-F]{6}$/.test(text)) reihe.gewaehlt(text);
            else text = reihe.wert;
        }
    }
}
