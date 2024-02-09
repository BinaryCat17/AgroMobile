import QtQuick
import QtQuick.Layouts

Rectangle {
    property string showIcon
    property var map
    Layout.fillWidth: true
    Layout.preferredHeight: 50 * m_ratio
    radius: 10

    RowLayout {
        anchors.fill: parent
        CText {
            text: map.selectedItem.id === 'undefined' ? 'Выберите элемент' : map.selectedItem.type
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 10 * m_ratio
        }

        OpenButton {
            item: sideInfo
            icon: showIcon
            Layout.alignment: Qt.AlignRight
        }
    }
}
