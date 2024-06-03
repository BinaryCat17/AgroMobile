import QtQuick 6.2
import '../Core'
import '../Design'

Rectangle {
    id: root
    property var cAdditionalData
    property bool cCoreInitialized: cAdditionalData.initialized
    property var cConfig: cAdditionalData.config
    property var cDataManager: cAdditionalData.dataManager
    property var cWorkspace: cAdditionalData.workspace

    property string cCurrentDocument: ''
    property string cCurrentDocumentType: ''
    property string cCurrentDocumentTypeDesc
    property string cCurrentDocumentTypeIcon
    property var cDocumentMode: cWorkspace.cDocumentMode
    color: cConfig.colors('background')

    function updateLayout() {
        if (cDocumentMode === 'select') {
            if (cWorkspace.cSelectDocumentType === '') { return false }
            cCurrentDocumentType = cWorkspace.cSelectDocumentType
            cCurrentDocument = cWorkspace.cSelectDocument
        } else {
            if (cWorkspace.cActiveDocumentType === '' ) { return false }
            cCurrentDocumentType = cWorkspace.cActiveDocumentType
            cCurrentDocument = cWorkspace.cActiveDocument
        }

        if (cCurrentDocumentType !== '') {
            cCurrentDocumentTypeDesc = cConfig.getSideMenuProp(cCurrentDocumentType, 'desc')
            cCurrentDocumentTypeIcon = cConfig.getSideMenuProp(cCurrentDocumentType, 'icon')
        }

        if (cDocumentMode === '') {
            view.cActiveView = 'types'
        } else {
            view.cActiveView = 'list'
        }
    }

    onCDocumentModeChanged: updateLayout()

    Item {
        id: headerMenu
        width: parent.width
        height: 50 * m_ratio

        CButton {
            id: menuButton
            enabled: cCurrentDocument !== '' || cDocumentMode === 'create' || cDocumentMode === 'select'
            visible: cCurrentDocument !== '' || cDocumentMode === 'create' || cDocumentMode === 'select'
            width: 50 * m_ratio
            height: 50 * m_ratio
            cIcon: 'left.png'

            cColor: cConfig.colors('background')
            cTextColor: cConfig.colors('primaryText')
            cIconColor: cConfig.colors('icon')

            cOnClicked: function() {
                if (cDocumentMode === 'select') {
                    if (cWorkspace.cActiveDocument === '') {
                        cWorkspace.cDocumentMode = 'create'
                    } else {
                        cWorkspace.cDocumentMode = 'edit'
                    }
                    cWorkspace.cSelectDocument = ''
                } else if (cDocumentMode === 'view') {
                    cWorkspace.cActiveDocument = ''
                    cWorkspace.cDocumentMode = ''
                } else if (cDocumentMode === 'create') {
                    cWorkspace.cDocumentMode = ''
                } else {
                    cWorkspace.cDocumentMode = 'view'
                }
                cWorkspace.cDrawMode = false
            }
        }

        CHeader {
            id: headerText
            enabled: cCurrentDocument === ''  && cDocumentMode !== 'create'  && cDocumentMode !== 'select'
            visible: cCurrentDocument === ''  && cDocumentMode !== 'create' && cDocumentMode !== 'select'
            anchors.fill: parent
            height: 50 * m_ratio
            cText: 'Меню'
            cColor: cConfig.colors('primaryText')
        }

        CButton {
            id: headerButton
            anchors.left: menuButton.right
            anchors.right: parent.right
            height: parent.height
            enabled: cCurrentDocument !== ''  || cDocumentMode === 'create' || cDocumentMode === 'select'
            visible: cCurrentDocument !== ''  || cDocumentMode === 'create' || cDocumentMode === 'select'
            cIcon: cCurrentDocumentTypeIcon
            cText: cCurrentDocumentTypeDesc
            state: 'opened'
            cColor: cConfig.colors('background')
            cHoveredColor: cConfig.colors('background')
            cTextColor: cConfig.colors('primaryText')
        }
    }

    CHSeparator { id: sep; anchors.top: headerMenu.bottom; color: config.colors('border') }

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
