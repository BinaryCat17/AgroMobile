import QtQuick
import QtQuick.Layouts

Rectangle {
    id: menubutton
    property var item
    property string icon
    Layout.preferredWidth: 50 * m_ratio
    Layout.preferredHeight: 50 * m_ratio
    radius: 10
    color: menuMouseArea.containsMouse ? '#f0f0f0' : '#ffffff'

    Image {
        id: menuIcon
        source: 'icons/' + icon
        sourceSize: Qt.size(30 * m_ratio, 30 * m_ratio)
        anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10 * m_ratio }
    }
    MouseArea {
        id: menuMouseArea
        hoverEnabled: true
        anchors.fill: parent
        onClicked: {
            if (item.state === 'close')
                item.state = 'open';
            else
                item.state = 'close';
        }
    }
}
