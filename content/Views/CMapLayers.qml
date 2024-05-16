import QtQuick 6.2
import QtQuick.Layouts
import QtQuick.Controls
import '../Design'

Item {
    id: root
    anchors.margins: 10 * m_ratio
    property real cOpenWidth: 150 * m_ratio
    property real cOpenHeight: 45 * calcHeight() * m_ratio
    property var cAdditionalData
    property bool cCoreInitialized: cAdditionalData.initialized
    property var cWorkspace: cAdditionalData.workspace
    property var cConfig: cAdditionalData.config
    property var cLayerModel: []

    onCCoreInitializedChanged: function() {
        if (!cCoreInitialized) {return}
        cLayerModel = cConfig.listMapLayers()
    }

    function calcHeight() {
        var len = 0
        for (var i = 0; i < cLayerModel.length; ++i) {
            len = len + cLayerModel[i].children.length + 1
        }
        return len
    }

    ColumnLayout {
        anchors.fill: parent

        Repeater {
            model: cLayerModel

            ColumnLayout {
                id: parentLayer
                property var cName: modelData.name
                property var cDesc: modelData.desc
                property var cChildren: modelData.children

                Component.onCompleted: function() {
                    repeater.itemAt(0).checked = true
                }

                ButtonGroup {
                    id: childGroup

                    onClicked: function(button) {
                        cWorkspace.activateLayer(cName, button.cChildName)
                    }
                }

                CText {
                    id: parentBox
                    cText: parentLayer.cDesc
                }

                ColumnLayout {
                    Repeater {
                        id: repeater
                        model: parentLayer.cChildren
                        RadioButton {
                            id: childLayer
                            property var cChildName: modelData.name
                            property var cChildDesc: modelData.desc

                            height: 40 * m_ratio
                            text: childLayer.cChildDesc
                            ButtonGroup.group: childGroup
                        }
                    }
                }
            }
        }
    }
}
