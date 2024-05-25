import QtQuick 2.15
import QtQuick.Layouts
import '../Design'

Item {
    id: root
    property var cAdditionalData
    property var cConfig: cAdditionalData.config
    property var cInputValue
    property var cSetValue
    property var cType
    property var cColor
    property string cMode: 'read'

    CButton {
        anchors.fill: parent
        cColor: root.cColor
        radius: 0
        state: 'opened'
        cOpenedWidth: parent.width
        cIcon: cConfig.getSideMenuProp(cType, 'icon')
        cText: cInputValue === undefined || cInputValue === '' ? cConfig.getSideMenuProp(cType, 'desc') : cInputValue
    }
}
