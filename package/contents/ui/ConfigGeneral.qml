import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasma5support as P5Support
import "texte.js" as Texte

// SimpleKCM gives scrolling and margins, like KDE's own widgets
KCM.SimpleKCM {
    id: seite

    property string cfg_labelsJson
    property string cfg_barColor
    property string cfg_trackColor
    property string cfg_textColor
    property string cfg_barShape
    property int cfg_fontSize
    property int cfg_labelWidth
    property int cfg_barHeight
    property int cfg_rowSpacing
    property int cfg_widgetWidth
    property string cfg_percentMode
    property string cfg_percentSide
    property bool cfg_percentSymbol
    property string cfg_percentColor
    property int cfg_percentFontSize
    property bool cfg_monoFont
    property string cfg_language
    property string cfg_resetMode
    property bool cfg_autoExtra

    function t(text) {
        return Texte.t(text, cfg_language);
    }

    // Fixed colors to click. Note: the name "palette" is already taken by Qt.
    readonly property var farbListe: [
        { name: "Orange (default)", farbe: "#D97757" },
        { name: "Blue", farbe: "#3B82F6" },
        { name: "Green", farbe: "#22C55E" },
        { name: "Red", farbe: "#EF4444" },
        { name: "Gray", farbe: "#55595e" },
        { name: "White", farbe: "#FFFFFF" }
    ]

    readonly property real jetzt: Date.now() / 1000

    // Rows [{label, key}]
    property var zeilen: []

    function speichern() {
        cfg_labelsJson = JSON.stringify(zeilen);
    }
    // Functions of the page, because the remove button is destroyed together with its row
    function zeileEntfernen(i) {
        var z = zeilen.slice();
        z.splice(i, 1);
        cfg_labelsJson = JSON.stringify(z);
        zeilen = z;
    }
    function zeileHinzufuegen() {
        var z = zeilen.concat([{ label: t("New"), key: "five" }]);
        cfg_labelsJson = JSON.stringify(z);
        zeilen = z;
    }
    function farbeOder(wert, standard) {
        return /^#[0-9a-fA-F]{6}$/.test(wert) ? wert : standard;
    }
    function zeilenAusText(text) {
        try {
            return JSON.parse(text);
        } catch (e) {
            return [];
        }
    }

    // ---- Connection to Claude Code (runs contents/code/setup.py) ----
    property string verbindung: "checking"     // "checking", "ok", "missing"
    readonly property string setupSkript: decodeURIComponent(Qt.resolvedUrl("../code/setup.py").toString().replace("file://", ""))

    function setupBefehl(aktion) {
        return "python3 '" + setupSkript + "' " + aktion;
    }
    function verbindungPruefen() {
        verbindung = "checking";
        befehl.connectSource(setupBefehl("status"));
    }

    P5Support.DataSource {
        id: befehl
        engine: "executable"
        onNewData: function (quelle, daten) {
            disconnectSource(quelle);
            if (quelle === seite.setupBefehl("status"))
                seite.verbindung = daten["stdout"].trim() === "ok" ? "ok" : "missing";
            else
                seite.verbindungPruefen();
        }
    }

    Component.onCompleted: {
        zeilen = zeilenAusText(cfg_labelsJson);
        verbindungPruefen();
    }

    // SpinBox with "px" behind the number
    component PxFeld: SpinBox {
        editable: true
        textFromValue: function (wert) { return wert + " px"; }
        valueFromText: function (text) { return parseInt(text) || 0; }
    }

    // A row of radio buttons, exactly one is on
    component AuswahlReihe: RowLayout {
        id: auswahl
        property var optionen: []        // [{name, wert}]
        property string wert: ""
        property string sprache: "auto"
        property var umbenennen: ({})    // {wert: other English text}, changes the text without rebuilding
        signal gewaehlt(string wert)
        spacing: Kirigami.Units.gridUnit

        ButtonGroup { id: gruppe }
        Repeater {
            model: auswahl.optionen
            delegate: RadioButton {
                required property var modelData
                objectName: "wahl:" + modelData.wert
                text: Texte.t(auswahl.umbenennen[modelData.wert] || modelData.name, auswahl.sprache)
                ButtonGroup.group: gruppe
                checked: auswahl.wert === modelData.wert
                onToggled: if (checked) auswahl.gewaehlt(modelData.wert)
            }
        }
    }

    Kirigami.FormLayout {
        // ---------- Preview ----------
        Item {
            Kirigami.FormData.label: seite.t("Preview:")
            implicitWidth: rahmen.width
            implicitHeight: rahmen.height + Kirigami.Units.largeSpacing

            Rectangle {
                id: rahmen
                y: Kirigami.Units.largeSpacing
                width: vorschau.width * 2 + 32
                height: vorschau.implicitHeight * 2 + 24
                radius: 8
                color: "#202326"
                border.width: 1
                border.color: Qt.rgba(0.5, 0.5, 0.5, 0.4)

                Anzeige {
                    id: vorschau
                    x: 16
                    y: 12
                    width: seite.cfg_widgetWidth
                    scale: 2
                    transformOrigin: Item.TopLeft
                    spacing: seite.cfg_rowSpacing
                    zeilen: seite.zeilenAusText(seite.cfg_labelsJson)
                    werte: ({ "five": 35, "week": 70 })
                    textFarbe: seite.farbeOder(seite.cfg_textColor, "#D97757")
                    balkenFarbe: seite.farbeOder(seite.cfg_barColor, "#D97757")
                    hintergrund: seite.farbeOder(seite.cfg_trackColor, "#55595e")
                    form: seite.cfg_barShape
                    schriftGroesse: seite.cfg_fontSize
                    labelBreite: seite.cfg_labelWidth
                    balkenHoehe: seite.cfg_barHeight
                    prozentModus: seite.cfg_percentMode
                    prozentSeite: seite.cfg_percentSide
                    prozentZeichen: seite.cfg_percentSymbol
                    prozentFarbe: seite.farbeOder(seite.cfg_percentColor, "#FFFFFF")
                    prozentGroesse: seite.cfg_percentFontSize
                    gleichBreit: seite.cfg_monoFont
                    resetModus: seite.cfg_resetMode
                    jetzt: seite.jetzt
                    resets: ({ "five": seite.jetzt + 2 * 3600 + 600, "week": seite.jetzt + 3 * 86400 })
                }
            }
        }

        AuswahlReihe {
            sprache: seite.cfg_language
            Kirigami.FormData.label: seite.t("Language:")
            // Fixed names: this row must not rebuild itself while one of its buttons is being clicked
            optionen: [
                { name: "Auto", wert: "auto" },
                { name: "English", wert: "en" },
                { name: "Deutsch", wert: "de" }
            ]
            wert: seite.cfg_language
            onGewaehlt: wert => seite.cfg_language = wert
        }

        RowLayout {
            Kirigami.FormData.label: seite.t("Claude Code:")
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                visible: seite.verbindung !== "checking"
                source: seite.verbindung === "ok" ? "checkmark" : "dialog-warning"
            }
            Label {
                objectName: "verbindungText"
                text: seite.verbindung === "ok" ? seite.t("Connected")
                    : seite.verbindung === "missing" ? seite.t("Not connected yet") : seite.t("Checking…")
            }
            Button {
                objectName: "verbinden"
                visible: seite.verbindung !== "checking"
                text: seite.verbindung === "ok" ? seite.t("Disconnect") : seite.t("Connect")
                icon.name: seite.verbindung === "ok" ? "network-disconnect" : "network-connect"
                onClicked: {
                    var aktion = seite.verbindung === "ok" ? "uninstall" : "install";
                    seite.verbindung = "checking";
                    befehl.connectSource(seite.setupBefehl(aktion));
                }
            }
        }

        // ---------- Bars ----------
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: seite.t("Bars")
        }

        ColumnLayout {
            Kirigami.FormData.label: seite.t("Rows:")
            spacing: Kirigami.Units.smallSpacing

            Repeater {
                model: seite.zeilen
                delegate: RowLayout {
                    required property var modelData
                    required property int index
                    spacing: Kirigami.Units.smallSpacing

                    TextField {
                        text: modelData.label
                        placeholderText: seite.t("Text")
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                        // change the list in place, without rebuilding the rows
                        onTextEdited: {
                            seite.zeilen[index].label = text;
                            seite.speichern();
                        }
                    }
                    ComboBox {
                        objectName: "limitWahl"
                        textRole: "text"
                        valueRole: "value"
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 9
                        model: [
                            { text: seite.t("5-hour limit"), value: "five" },
                            { text: seite.t("Weekly limit"), value: "week" }
                        ]
                        currentIndex: modelData.key === "week" ? 1 : 0
                        // A new model (other language) resets the selection, so set it again
                        onModelChanged: Qt.callLater(() => currentIndex = (modelData.key === "week" ? 1 : 0))
                        onActivated: {
                            seite.zeilen[index].key = currentValue;
                            seite.speichern();
                        }
                    }
                    Button {
                        objectName: "entfernen"
                        icon.name: "edit-delete"
                        text: seite.t("Remove")
                        onClicked: seite.zeileEntfernen(index)
                    }
                }
            }

            Button {
                objectName: "hinzufuegen"
                text: seite.t("Add bar")
                icon.name: "list-add"
                onClicked: seite.zeileHinzufuegen()
            }
        }

        // ---------- Colors ----------
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: seite.t("Colors")
        }

        Farbreihe {
            Kirigami.FormData.label: seite.t("Bar:")
            sprache: seite.cfg_language
            farben: seite.farbListe
            wert: seite.cfg_barColor
            onGewaehlt: farbe => seite.cfg_barColor = farbe
        }
        Farbreihe {
            Kirigami.FormData.label: seite.t("Empty part:")
            sprache: seite.cfg_language
            farben: seite.farbListe
            wert: seite.cfg_trackColor
            onGewaehlt: farbe => seite.cfg_trackColor = farbe
        }
        Farbreihe {
            Kirigami.FormData.label: seite.t("Text:")
            sprache: seite.cfg_language
            farben: seite.farbListe
            wert: seite.cfg_textColor
            onGewaehlt: farbe => seite.cfg_textColor = farbe
        }

        // ---------- Shape ----------
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: seite.t("Shape")
        }

        ButtonGroup { id: formGruppe }

        RowLayout {
            Kirigami.FormData.label: seite.t("Ends:")
            spacing: Kirigami.Units.gridUnit

            Repeater {
                // Static model: texts are translated in place, so a language change rebuilds nothing
                model: [
                    { name: "Round", wert: "round" },
                    { name: "Square", wert: "square" },
                    { name: "Mixed", wert: "mixed" }
                ]
                delegate: ColumnLayout {
                    required property var modelData
                    spacing: Kirigami.Units.smallSpacing

                    Balken {
                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 12
                        Layout.alignment: Qt.AlignHCenter
                        value: 60
                        form: modelData.wert
                        fuellFarbe: seite.farbeOder(seite.cfg_barColor, "#D97757")
                        hintergrund: seite.farbeOder(seite.cfg_trackColor, "#55595e")
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                knopf.checked = true;
                                seite.cfg_barShape = modelData.wert;
                            }
                        }
                    }
                    RadioButton {
                        id: knopf
                        objectName: "form:" + modelData.wert
                        text: seite.t(modelData.name)
                        Layout.alignment: Qt.AlignHCenter
                        ButtonGroup.group: formGruppe
                        checked: seite.cfg_barShape === modelData.wert
                        onToggled: if (checked) seite.cfg_barShape = modelData.wert
                    }
                }
            }
        }

        AuswahlReihe {
            sprache: seite.cfg_language
            Kirigami.FormData.label: seite.t("Font:")
            optionen: [
                { name: "Normal", wert: "normal" },
                { name: "Monospace (like in code)", wert: "mono" }
            ]
            wert: seite.cfg_monoFont ? "mono" : "normal"
            onGewaehlt: wert => seite.cfg_monoFont = (wert === "mono")
        }

        // ---------- Percent ----------
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: seite.t("Percent")
        }

        AuswahlReihe {
            sprache: seite.cfg_language
            Kirigami.FormData.label: seite.t("Show:")
            optionen: [
                { name: "Off", wert: "off" },
                { name: "Inside the bar", wert: "inside" },
                { name: "Next to the bar", wert: "outside" }
            ]
            wert: seite.cfg_percentMode
            onGewaehlt: wert => seite.cfg_percentMode = wert
        }
        AuswahlReihe {
            sprache: seite.cfg_language
            Kirigami.FormData.label: seite.t("Side:")
            enabled: seite.cfg_percentMode !== "off"
            optionen: [
                { name: "Left", wert: "left" },
                { name: "Right", wert: "right" }
            ]
            umbenennen: seite.cfg_percentMode === "outside" ? ({ "left": "Left (between text and bar)" }) : ({})
            wert: seite.cfg_percentSide
            onGewaehlt: wert => seite.cfg_percentSide = wert
        }
        AuswahlReihe {
            sprache: seite.cfg_language
            Kirigami.FormData.label: seite.t("Format:")
            enabled: seite.cfg_percentMode !== "off"
            optionen: [
                { name: "Number only (42)", wert: "number" },
                { name: "With sign (42%)", wert: "percent" }
            ]
            wert: seite.cfg_percentSymbol ? "percent" : "number"
            onGewaehlt: wert => seite.cfg_percentSymbol = (wert === "percent")
        }
        Farbreihe {
            Kirigami.FormData.label: seite.t("Color:")
            enabled: seite.cfg_percentMode !== "off"
            sprache: seite.cfg_language
            farben: seite.farbListe
            wert: seite.cfg_percentColor
            onGewaehlt: farbe => seite.cfg_percentColor = farbe
        }
        PxFeld {
            Kirigami.FormData.label: seite.t("Font size:")
            enabled: seite.cfg_percentMode !== "off"
            from: 5
            to: 14
            value: seite.cfg_percentFontSize
            onValueModified: seite.cfg_percentFontSize = value
        }

        // ---------- Reset ----------
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: seite.t("Reset")
        }

        AuswahlReihe {
            sprache: seite.cfg_language
            Kirigami.FormData.label: seite.t("Countdown:")
            optionen: [
                { name: "Off", wert: "off" },
                { name: "Next to the bar (45m, 2h, 3d)", wert: "outside" }
            ]
            wert: seite.cfg_resetMode
            onGewaehlt: wert => seite.cfg_resetMode = wert
        }
        Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: seite.t("The exact reset time is shown when you hover over the widget.")
        }
        AuswahlReihe {
            sprache: seite.cfg_language
            Kirigami.FormData.label: seite.t("Extra limits:")
            optionen: [
                { name: "Show automatically", wert: "auto" },
                { name: "Hide", wert: "hide" }
            ]
            wert: seite.cfg_autoExtra ? "auto" : "hide"
            onGewaehlt: wert => seite.cfg_autoExtra = (wert === "auto")
        }
        Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: seite.t("Extra limits appear by themselves while Claude Code reports them (for example a spend limit) and disappear again.")
        }

        // ---------- Size ----------
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: seite.t("Size and spacing")
        }

        PxFeld {
            Kirigami.FormData.label: seite.t("Widget width:")
            from: 30
            to: 200
            value: seite.cfg_widgetWidth
            onValueModified: seite.cfg_widgetWidth = value
        }
        PxFeld {
            Kirigami.FormData.label: seite.t("Bar height:")
            from: 4
            to: 20
            value: seite.cfg_barHeight
            onValueModified: seite.cfg_barHeight = value
        }
        PxFeld {
            Kirigami.FormData.label: seite.t("Space between rows:")
            from: 0
            to: 20
            value: seite.cfg_rowSpacing
            onValueModified: seite.cfg_rowSpacing = value
        }
        PxFeld {
            Kirigami.FormData.label: seite.t("Font size:")
            from: 6
            to: 16
            value: seite.cfg_fontSize
            onValueModified: seite.cfg_fontSize = value
        }
        PxFeld {
            Kirigami.FormData.label: seite.t("Label width:")
            from: 8
            to: 40
            value: seite.cfg_labelWidth
            onValueModified: seite.cfg_labelWidth = value
        }
    }
}
