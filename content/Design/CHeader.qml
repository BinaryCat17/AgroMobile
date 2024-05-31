import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property string cText: ''
    property var cTextWidth: text.cContentWidth
    property color cColor: "black"

    CText {
        id: text
        width: cTextWidth
        anchors.centerIn: parent
        cText: root.cText
        cVAlignment: Text.AlignVCenter
        cColor: root.cColor
    }
}
