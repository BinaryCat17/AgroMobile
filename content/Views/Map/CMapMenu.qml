import QtQuick 6.2
import '../Core'
import '../Design'

Item {
    id: root
    property var cAdditionalData

    CViewManager {
        id: viewManager
        cComponents: [
            {name: 'Layers', component: 'Views/CMapLayersView'},
            {name: 'Info', component: 'Views/CRecordInfoView'}
        ]
        cAdditionalData: root.cAdditionalData
    }

    CPanel {
        anchors.fill: parent
        cAlignment: Qt.AlignRight
        cViewManager: viewManager
        cInitModel: [
            {panel: 'Info', icon: 'info.png'},
            {panel: 'Layers', icon: 'layer.png'}
        ]
    }
}
