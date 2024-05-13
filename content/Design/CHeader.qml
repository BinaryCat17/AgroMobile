import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property string cText: ''

    CText {
        id: text
        width: cContentWidth
        anchors.centerIn: parent
        cText: root.cText
    }
}
