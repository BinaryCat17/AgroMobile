import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property string cIcon: '';
    Layout.preferredHeight: 50 * m_ratio
    Layout.preferredWidth: 50 * m_ratio

    onCIconChanged: function() {
        if (cIcon !== '') {
            img.source = '/qt/qml/content/resources/icons/' + root.cIcon
        }
    }

    Image {
        id: img
        sourceSize: Qt.size(30 * m_ratio, 30 * m_ratio)
        anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
    }
}
