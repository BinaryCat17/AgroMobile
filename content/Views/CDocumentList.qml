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

    onCActiveDocumentTypeChanged: function() {
        if(!cCoreInitialized || cActiveDocumentType === '') { return }

        if (cModel !== undefined && cModel !== null) {
            cModel.close()
        }
        cModel = cDataManager.listDocuments(cActiveDocumentType)
        updateModel()
        cModel.updated.connect(updateModel)
    }

    ColumnLayout {
        id: documentList
        width: parent.width
        spacing: 0

        CHeader {
            width: parent.width
            height: 50 * m_ratio
            cText: 'Список документов'
        }

        CHSeparator {}

        Item {
            width: parent.width
            CButton {
                id: createButton
                enabled: cActiveDocumentType !== '' && (cDocumentMode === 'view' || cDocumentMode === '')
                visible: cActiveDocumentType !== '' && (cDocumentMode === 'view' || cDocumentMode === '')
                width: parent.width
                height: cActiveDocumentType !== '' && (cDocumentMode === 'view' || cDocumentMode === '') ? 50 * m_ratio : 0
                radius: 0
                cIcon: 'add.png'
                cText: 'Создать документ'
                state: 'opened'

                cOnClicked: function() {
                    cWorkspace.cDocumentMode = 'create'
                }
            }


            CHSeparator {
                id: sep;
                anchors.top: createButton.bottom
                enabled: cActiveDocumentType !== '' && (cDocumentMode === 'view' || cDocumentMode === '')
                visible: cActiveDocumentType !== '' && (cDocumentMode === 'view' || cDocumentMode === '')
            }

            ColumnLayout {
                anchors.top: sep.bottom
                width: parent.width
                spacing: 0

                Repeater {
                    id: repeater

                    Item {
                        id: docRow
                        width: parent.width
                        height: 50 * m_ratio
                        property var cId: modelData.id
                        property var cName: modelData.name
                        property var cCreatedAt: modelData.created_at

                        MouseArea {
                            id: mouseArea
                            hoverEnabled: true
                            anchors.fill: parent

                            onClicked: function() {
                                if (cDocumentMode === '') {
                                    cWorkspace.cDocumentMode = 'view'
                                }

                                if (cDocumentMode === 'view') {
                                    cWorkspace.cActiveDocument = cId
                                }
                            }
                        }
                        Rectangle {
                            anchors.fill: parent
                            color: mouseArea.containsMouse ? '#f0f0f0' : 'white'

                            RowLayout {
                                anchors.margins: 5 * m_ratio
                                anchors.fill: parent
                                CText {
                                    cVAlignment: Text.AlignVCenter
                                    cText: cName
                                }
                                CText {
                                    cVAlignment: Text.AlignVCenter
                                    cText: cCreatedAt
                                }
                            }
                        }
                        CHSeparator { anchors.top: docRow.bottom }
                    }
                }
            }
        }
    }
}
