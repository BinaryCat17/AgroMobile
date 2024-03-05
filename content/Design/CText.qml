import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property string cText: ""
    property int cWrapMode: Text.Wrap
    property int cVAlignment: Text.AlignTop
    property int cHAlignment: Text.AlignLeft

    Layout.fillWidth: true
    Layout.preferredHeight: text.contentHeight

    Text {
        id: text
        anchors.fill: parent
        verticalAlignment: cVAlignment
        horizontalAlignment: cHAlignment
        text: cText
        wrapMode: cWrapMode
        font.family: 'SansProFont'
    }
}
