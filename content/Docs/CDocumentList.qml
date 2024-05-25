import QtQuick 6.2
import QtQuick.Layouts
import '../Design'

Item {
    id: root
    property var cAdditionalData
    property bool cCoreInitialized: cAdditionalData.initialized
    property var cDataManager: cAdditionalData.dataManager
    property var cWorkspace: cAdditionalData.workspace
    property var cActiveDocumentType: cWorkspace.cActiveDocumentType
    property var cActiveDocument: cWorkspace.cActiveDocument
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
        if(!cCoreInitialized || cActiveDocumentType === '') { return }
        if (cModel !== undefined && cModel !== null) {
            cModel.close()
        }
        cModel = cDataManager.getDocuments(cActiveDocumentType)
        updateModel()
        cModel.updated.connect(updateModel)
    }

    onCActiveDocumentTypeChanged: updateLayout()

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
                        if (cDocumentMode === '') {
                            cWorkspace.cDocumentMode = 'view'
                        }

                        if (cDocumentMode === 'view') {
                            cWorkspace.cViewType = 'table'
                            cWorkspace.cActiveDocument = cId
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: hoverHandler.hovered ? '#f0f0f0' : 'white'

                    CText {
                        id: nameText
                        height: parent.height
                        width: 200 * m_ratio
                        cVAlignment: Text.AlignVCenter
                        cText: cName
                    }

                    CText {
                        height: parent.height
                        width: 200 * m_ratio
                        anchors.left: nameText.right
                        cVAlignment: Text.AlignVCenter
                        cText: cCreatedAt
                    }
                }
                CHSeparator { anchors.top: docRow.bottom }
            }
        }
    }
}
