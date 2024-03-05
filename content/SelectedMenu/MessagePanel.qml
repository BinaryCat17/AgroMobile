import QtQuick
import '../Design'

Rectangle {
    property var cAdditionalData
    property var cParentStack
    property var cSelected: cAdditionalData.map.selectedItem
    property real cWidth: 250 * m_ratio
    property real cHeight: 50 * m_ratio

    width: cWidth
    height: cHeight
    radius: cAdditionalData.stackRadius

    onCSelectedChanged: function() {
        if(cSelected.id !== 'undefined') {
            cParentStack.activatePanel('SelectedMenu/InfoPanel')
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: 10 * m_ratio
        CText {
            anchors.fill: parent
            cVAlignment: Text.AlignVCenter
            cHAlignment: Text.AlignHCenter
            cText: 'Выберите компонент'
        }
    }
}
