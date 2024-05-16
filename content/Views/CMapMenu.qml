import QtQuick 6.2
import '../Core'
import '../Design'

Item {
    id: root
    property var cAdditionalData

    CViewManager {
        id: viewManager
        cComponents: [
            {name: 'Layers', component: 'Views/CMapLayers'},
            //{name: 'Info', component: 'Views/CMapInfo'}
        ]
        cAdditionalData: root.cAdditionalData
    }

    CViewMenu {
        anchors.fill: parent
        cAlignment: Qt.AlignRight
        cViewManager: viewManager
        cInitModel: [
            //{panel: 'Info', icon: 'info.png'},
            {panel: 'Layers', icon: 'layer.png'}
        ]
    }
}
