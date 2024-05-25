import QtQuick 6.2
import '../Core'
import '../Design'

Item {
    id: root
    property var cAdditionalData
    property bool cCoreInitialized: cAdditionalData.initialized
    property var cDataManager: cAdditionalData.dataManager
    property var cWorkspace: cAdditionalData.workspace
    property var cActiveDocument: cWorkspace.cActiveDocument
    property var cDocumentMode: cWorkspace.cDocumentMode

    function updateLayout() {
        if (!cCoreInitialized || !view.cInitialized) { return }
        if (cActiveDocument === '' && cDocumentMode !== 'create') {
            view.cActiveView = 'types'
        } else {
            view.cActiveView = 'list'
        }
    }

    onCActiveDocumentChanged: updateLayout()
    onCDocumentModeChanged: updateLayout()

    Item {
        id: headerMenu
        width: parent.width
        height: 50 * m_ratio

        CButton {
            id: menuButton
            enabled: cActiveDocument !== ''
            visible: cActiveDocument !== ''
            width: 50 * m_ratio
            height: 50 * m_ratio
            cIcon: 'left.png'
            cOnClicked: function() {
                cWorkspace.cActiveDocument = ''
            }
        }

        CHeader {
            id: headerText
            anchors.fill: parent
            height: 50 * m_ratio
            cText: 'Меню'
        }
    }

    CHSeparator { id: sep; anchors.top: headerMenu.bottom }

    CView {
        id: view
        anchors.top: sep.bottom
        anchors.bottom: parent.bottom
        width: parent.width

        cAdditionalData: root.cAdditionalData
        cActiveView: 'types'

        cComponents: [
            {'name': 'types', 'component': 'Docs/CDocumentTypes'},
            {'name': 'list', 'component': 'Docs/CDocumentList'}
        ]
    }
}
