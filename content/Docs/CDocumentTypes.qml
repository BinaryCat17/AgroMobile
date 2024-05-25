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

        var documentTypes = cConfig.getViewTypes()
        for (var i = 0; i < documentTypes.length; ++i) {
            var document = documentTypes[i]
        }
        groupRepeater.model = cConfig.getSideMenuTabs()
    }

    ColumnLayout {
        Repeater {
            id: groupRepeater

            ColumnLayout {
                id: parentLayer
                spacing: 0

                property var cName: modelData.name
                property var cDesc: modelData.desc
                property var cIcon: modelData.icon
                property var cChildren: modelData.children

                CButton {
                    cOpenedWidth: 160 * m_ratio
                    height: 50 * m_ratio
                    cText: parentLayer.cDesc
                    cIcon: parentLayer.cIcon
                    state: 'opened'

                    cOnClicked: function() {
                        for (var i = 0; i < cButtonList.length; ++i) {
                            if (cButtonList[i].cParentName === cName) {
                                cButtonList[i].height = 50 * m_ratio
                                cButtonList[i].visible = true
                                cButtonList[i].enabled = true
                            } else {
                                cButtonList[i].height = 0 * m_ratio
                                cButtonList[i].visible = false
                                cButtonList[i].enabled = false
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: openPanel

                    Repeater {
                        id: repeater
                        model: parentLayer.cChildren

                        CButton {
                            id: childLayer
                            property var cParentName: parentLayer.cName
                            property var cChildName: modelData.name
                            property var cChildDesc: modelData.desc
                            property var cChildIcon: modelData.icon

                            state: 'opened'
                            cOpenedWidth: 140 * m_ratio
                            cOpenedMargin: 20 * m_ratio
                            visible: false
                            enabled: false

                            cText: childLayer.cChildDesc
                            cIcon: cChildIcon

                            Component.onCompleted: function() {
                                cButtonList.push(this)
                            }

                            cOnClicked: function() {
                                if (cWorkspace.cDocumentMode === '' || cWorkspace.cDocumentMode === 'view') {
                                    cWorkspace.cActiveDocument = ''
                                    cWorkspace.cDocumentMode = ''
                                    for (var i = 0; i < cButtonList.length; ++i) {
                                        cButtonList[i].cSelected = false
                                    }
                                    cSelected = true

                                    cWorkspace.cActiveDocumentType = cChildName
                                    cWorkspace.cActiveDocumentTypeIcon = modelData.icon
                                    cWorkspace.cActiveDocumentTypeDesc = modelData.desc
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
