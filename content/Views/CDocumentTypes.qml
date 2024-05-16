import QtQuick 6.2
import QtQuick.Layouts
import '../Design'

Item {
    id: root
    property var cAdditionalData
    property bool cCoreInitialized: cAdditionalData.initialized
    property var cConfig: cAdditionalData.config
    property var cWorkspace: cAdditionalData.workspace

    property var cButtonList: []

    onCCoreInitializedChanged: function() {
        if (!onCCoreInitializedChanged) { return }

        var documentTypes = cConfig.listDocumentTypes()
        for (var i = 0; i < documentTypes.length; ++i) {
            var document = documentTypes[i]
        }
        groupRepeater.model = cConfig.listSideMenuTabs()
    }

    ColumnLayout {
        id: sideMenu
        spacing: 0
        width: parent.width

        CHeader {
            width: parent.width
            height: 50 * m_ratio
            cText: 'Меню'
        }

        CHSeparator {}

        Item {
            ColumnLayout {
                anchors.fill: parent

                Repeater {
                    id: groupRepeater

                    ColumnLayout {
                        id: parentLayer
                        property var cName: modelData.name
                        property var cDesc: modelData.desc
                        property var cIcon: modelData.icon
                        property var cChildren: modelData.children

                        CButton {
                            cOpenedWidth: 160 * m_ratio
                            cText: parentLayer.cDesc
                            cIcon: parentLayer.cIcon
                            state: 'opened'
                        }

                        ColumnLayout {
                            Repeater {
                                id: repeater
                                model: parentLayer.cChildren

                                CButton {
                                    id: childLayer
                                    property var cChildName: modelData.name
                                    property var cChildDesc: modelData.desc
                                    property var cChildIcon: modelData.icon

                                    Component.onCompleted: function() {
                                        cButtonList.push(this)
                                    }

                                    cOnClicked: function() {
                                        if (cWorkspace.cDocumentMode === '' || cWorkspace.cDocumentMode === 'view') {
                                            cWorkspace.cActiveDocument = ''
                                            cWorkspace.cDocumentMode = ''
                                            cWorkspace.cActiveDocumentType = cChildName
                                            for (var i = 0; i < cButtonList.length; ++i) {
                                                cButtonList[i].cSelected = false
                                            }
                                            cSelected = true
                                        }
                                    }

                                    state: 'opened'
                                    cOpenedWidth: 140 * m_ratio
                                    cOpenedMargin: 20 * m_ratio
                                    height: 40 * m_ratio
                                    cText: childLayer.cChildDesc
                                    cIcon: cChildIcon
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
