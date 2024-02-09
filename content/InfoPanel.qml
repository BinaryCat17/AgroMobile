import QtQuick
import QtQuick.Layouts

Rectangle {
    id: infoMobile
    property var map
    radius: 10
    Layout.fillWidth: true

    ColumnLayout {
        spacing: 10 * m_ratio
        CText {
            text: 'Id: ' + map.selectedItem.id
            Layout.leftMargin: 10 * m_ratio

        }
        Item {
            width: sideInfo.width - 10 * m_ratio
            Layout.minimumHeight: 20 * m_ratio
            Layout.leftMargin: 10 * m_ratio
            CText {
                anchors.fill: parent
                text: 'Описание: ' + map.selectedItem.desc
                wrapMode: Text.WrapAnywhere
            }
        }
        CText {
            Layout.leftMargin: 10 * m_ratio
            visible: map.selectedItem.type === 'Point'
            text: 'Широта ' + map.selectedItem.latitude
        }
        CText {
            Layout.leftMargin: 10 * m_ratio
            visible: map.selectedItem.type === 'Point'
            text: "Долгота "  + map.selectedItem.longitude
        }
    }
}
