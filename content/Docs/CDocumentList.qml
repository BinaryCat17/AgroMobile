import QtQuick 6.2
import QtQuick.Layouts
import '../Design'

Item {
    id: root
    property var cAdditionalData
    property bool cCoreInitialized: cAdditionalData.initialized
    property var cDataManager: cAdditionalData.dataManager
    property var cWorkspace: cAdditionalData.workspace
    property var cCurrentDocumentType: cWorkspace.cActiveDocumentType
    property var cCurrentDocument: cWorkspace.cActiveDocument
    property var cActiveDocumentType: cWorkspace.cActiveDocumentType
    property var cDocumentMode: cWorkspace.cDocumentMode
    property var cModel

    function updateModel() {
        var result = []
        for (var i = 0; i < cModel.cData.length; ++i) {
            var dict = {}
            for (var j = 0; j < cModel.cKeys.length; ++j) {
                dict[cModel.cKeys[j]] = cModel.cData[i][j]
            }
            result.push(dict)
        }
        repeater.model = result
    }

    function updateLayout() {
        if (!cCoreInitialized) { return }

        if (cDocumentMode === 'select') {
            if (cCurrentDocument !== cWorkspace.cSelectDocument) { cCurrentDocument = cWorkspace.cSelectDocument }
            if (cCurrentDocumentType !== cWorkspace.cSelectDocumentType) { cCurrentDocumentType = cWorkspace.cSelectDocumentType }
        } else {
            if (cCurrentDocument !== cWorkspace.cActiveDocument) { cCurrentDocument = cWorkspace.cActiveDocument }
            if (cCurrentDocumentType !== cWorkspace.cActiveDocumentType) { cCurrentDocumentType = cWorkspace.cActiveDocumentType }
        }

        if(cCurrentDocumentType === '') { return }
        if (cModel !== undefined && cModel !== null) {
            cModel.close()
        }

        cModel = cDataManager.getDocuments(cCurrentDocumentType)
        updateModel()
        cModel.updated.connect(updateModel)
    }

    onCActiveDocumentTypeChanged: updateLayout()
    onCCurrentDocumentTypeChanged: updateLayout()
    onCDocumentModeChanged: updateLayout()
    anchors.fill: parent

    ColumnLayout {
        width: parent.width
        spacing: 0

        Repeater {
            id: repeater

            Item {
                id: docRow
                Layout.fillWidth: true
                height: 50 * m_ratio

                property var cId: modelData.id
                property var cName: modelData.name
                property var cCreatedAt: modelData.created_at

                HoverHandler {
                    id: hoverHandler
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: function() {
                        if (cDocumentMode === '' || cDocumentMode === 'view') {
                            cWorkspace.cActiveDocument = cId
                            cWorkspace.cViewType = 'table'
                        } else if (cDocumentMode === 'select') {
                            cWorkspace.cSelectDocument = cId
                            cWorkspace.cViewType = 'table'
                        }

                        if (cDocumentMode === '') {
                            cWorkspace.cDocumentMode = 'view'
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent

                    color: cId === cWorkspace.cActiveDocument || cId === cWorkspace.cSelectedDocument || hoverHandler.hovered ? cConfig.colors('selected') : cConfig.colors('accent')

                    Item {
                        anchors.fill: parent
                        anchors.margins: 10 * m_ratio
                        CText {
                            id: nameText
                            height: parent.height
                            width: 200 * m_ratio
                            cVAlignment: Text.AlignVCenter
                            cText: cName
                            cColor: cConfig.colors('primaryText')
                        }

                        CText {
                            height: parent.height
                            width: 200 * m_ratio
                            anchors.left: nameText.right
                            cVAlignment: Text.AlignVCenter
                            cText: cCreatedAt
                            cColor: cConfig.colors('primaryText')
                        }
                    }
                }
                CHSeparator { anchors.top: docRow.bottom; color:  cConfig.colors('border') }
            }
        }
    }
}
