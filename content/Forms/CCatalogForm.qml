import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls
import '../Design'

Item {
    id: root
    property var cAdditionalData
    property var cConfig: cAdditionalData.config
    property var cWorkspace: cAdditionalData.workspace
    property var cInputValue
    property var cSetValue
    property var cType
    property color cColor: "white"
    property color cTextColor: 'black'
    property string cMode: 'read'

    property string cCurrentSelectedMode
    property string cCurrentSelectedColumn
    property string cCurrentSelectedRow

    onCSetValueChanged: function() {
        if (cSetValue === undefined || cSetValue === '') {
            if (cConfig !== undefined) {
                text.cText = cConfig.getSideMenuProp(cType, 'desc')
            }
        } else {
            text.cText = cSetValue
        }
    }

    ScrollView {
        id: textWrap
        height: 50 * m_ratio
        width: cMode === 'write' ? parent.width - 100 : parent.width

        Item {
            width: cMode === 'write' ? parent.width - 100 : parent.width
            height: 50 * m_ratio

            Flickable {
                contentWidth: text.cContentWidth
                width: parent.width - 20 * m_ratio
                height: parent.height

                CButton {
                    id: text
                    cColor: root.cColor
                    cTextColor: root.cTextColor
                    cIconColor: root.cTextColor
                    cHoveredColor: root.cColor
                    radius: 0
                    state: 'opened'
                    width: Math.max(cContentWidth, parent.width - 20 * m_ratio)
                    height: 50 * m_ratio
                    cIcon: cConfig.getSideMenuProp(cType, 'icon')
                    cText: cInputValue === undefined || cInputValue === '' ? cConfig.getSideMenuProp(cType, 'desc') : cInputValue
                }
            }
        }
    }

    CButton {
        id: select
        enabled: cMode === 'write' && (cWorkspace.cDocumentMode === 'create' || cWorkspace.cDocumentMode === 'edit')
        visible: cMode === 'write' && (cWorkspace.cDocumentMode === 'create' || cWorkspace.cDocumentMode === 'edit')
        anchors.left: textWrap.right
        width: 50 * m_ratio
        height: 50 * m_ratio
        cColor: root.cColor
        cIconColor: root.cTextColor
        cTextColor: root.cTextColor
        cIcon: 'paper.png'

        cOnClicked: function() {
            cWorkspace.cSelectDocumentType = cType
            cWorkspace.cDocumentMode = 'select'

            cWorkspace.cCurrentSelectedMode = root.cCurrentSelectedMode
            cWorkspace.cCurrentSelectedColumn = root.cCurrentSelectedColumn
            cWorkspace.cCurrentSelectedRow = root.cCurrentSelectedRow
        }
    }

    CButton {
        enabled: cMode === 'write' && (cWorkspace.cDocumentMode === 'create' || cWorkspace.cDocumentMode === 'edit')
        visible: cMode === 'write' && (cWorkspace.cDocumentMode === 'create' || cWorkspace.cDocumentMode === 'edit')
        anchors.left: select.right
        width: 50 * m_ratio
        height: 50 * m_ratio
        cColor: root.cColor
        cIconColor: root.cTextColor
        cTextColor: root.cTextColor
        cIcon: 'down.png'
    }
}
