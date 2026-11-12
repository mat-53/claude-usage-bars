import QtQuick
import QtQuick.Controls
import "../package/contents/ui" as W

ApplicationWindow {
    width: 760
    height: 1200
    visible: true
    // Scroll position of the page, read by the test
    readonly property real flickY: page.flickable ? page.flickable.contentY : -1
    readonly property real flickHeight: page.flickable ? page.flickable.height : -1
    readonly property real flickContent: page.flickable ? page.flickable.contentHeight : -1

    // Item search in QML (PySide crashes when it has to wrap some KDE item types)
    function alle(item, name, praefix, nurSichtbar, liste) {
        for (var i = 0; i < item.children.length; i++) {
            var k = item.children[i];
            var passt = praefix ? k.objectName.indexOf(name) === 0 : k.objectName === name;
            if (passt && (!nurSichtbar || k.visible))
                liste.push(k);
            alle(k, name, praefix, nurSichtbar, liste);
        }
        return liste;
    }
    // The very top item, so popups (they live in the overlay) are found too
    function oben() {
        var it = contentItem;
        while (it.parent)
            it = it.parent;
        return it;
    }
    function finde(name, nurSichtbar) {
        return alle(oben(), name, false, nurSichtbar, []);
    }
    function anzahl(name, nurSichtbar) {
        return finde(name, nurSichtbar).length;
    }
    function anzahlPraefix(praefix) {
        return alle(oben(), praefix, true, false, []).length;
    }
    function stelle(name, index, nurSichtbar, fx, fy) {
        var l = finde(name, nurSichtbar);
        var it = l[index < 0 ? l.length + index : index];
        return it.mapToItem(null, it.width * fx, it.height * fy);
    }
    function wert(name, index, eigenschaft) {
        var l = finde(name, false);
        return l[index < 0 ? l.length + index : index][eigenschaft];
    }

    W.ConfigGeneral {
        id: page
        objectName: "page"
        anchors.fill: parent
        cfg_labelsJson: '[{"label":"5H","key":"five"},{"label":"W","key":"week"}]'
        cfg_barColor: "#D97757"
        cfg_trackColor: "#55595e"
        cfg_textColor: "#D97757"
        cfg_barShape: "round"
        cfg_fontSize: 8
        cfg_labelWidth: 15
        cfg_barHeight: 9
        cfg_rowSpacing: 1
        cfg_widgetWidth: 70
        cfg_percentMode: "off"
        cfg_percentSide: "right"
        cfg_percentSymbol: true
        cfg_percentColor: "#FFFFFF"
        cfg_percentFontSize: 7
        cfg_monoFont: true
        cfg_language: "en"
        cfg_resetMode: "outside"
        cfg_autoExtra: true
    }
}
