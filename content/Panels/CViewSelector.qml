import QtQuick 6.2
import '../Core'
import '../Views/Document'
import '../Views/Map'
import '../Design'

Item {
    id: root
    property var cAdditionalData
    property var cDataManager: cAdditionalData.dataManager

    CViewManager {
        id: viewManager
        cAdditionalData: root.cAdditionalData
        cComponents: [
            {'name': 'document', 'component': 'Views/Document/CDocumentView'},
            {'name': 'map', 'component': 'Views/Map/CMapView'}
        ]
    }

    CView {
        anchors.fill: parent
        cViewManager: viewManager
        cActiveView: 'document'
    }
}
