import QtQuick
import QtQuick.Layouts
import "../Design"
import '../utils.js' as Utils

Rectangle {
    id: root
    property var cAdditionalData
    property var cParentStack
    property var cSelected: cAdditionalData.map.selectedItem
    property real cWidth: 500 * m_ratio
    property real cHeight: 200 * m_ratio
    property bool cOpened: false

    width: cWidth
    height: cHeight
    radius: cAdditionalData.stackRadius

    onCOpenedChanged: function() {
        if (cOpened && cSelected.id === 'undefined') {
            cParentStack.activatePanel('SelectedMenu/MessagePanel')
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: 10 * m_ratio

        ColumnLayout {
            id: info
            width: parent.width
            CText {
                cText: Utils.check(cSelected, 'Id: ' + cSelected.id, '')
            }
            CText {
                cText: Utils.check(cSelected, 'Описание: ' + cSelected.desc, '')
                cWrapMode: Text.WrapAnywhere
            }
            CText {
                visible: cSelected.type === 'Point'
                cText: Utils.check(cSelected, 'Широта ' + cSelected.latitude, '')
            }
            CText {
                visible: cSelected.type === 'Point'
                cText: Utils.check(cSelected, "Долгота "  + cSelected.longitude, '')
            }
        }
    }
}
