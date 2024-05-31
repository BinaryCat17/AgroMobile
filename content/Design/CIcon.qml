import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    property string cIcon: '';
    property color cColor: 'black';
    Layout.preferredHeight: 50 * m_ratio
    Layout.preferredWidth: 50 * m_ratio

    onCIconChanged: function() {
        if (cIcon !== '') {
            img.source = '/qt/qml/content/resources/icons/' + root.cIcon
        }
    }

    IconImage {
        id: img
        color: cColor
        sourceSize: Qt.size(30 * m_ratio, 30 * m_ratio)
        anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
    }
}
