import QtQuick 6.2
import '../Core'
import '../Design'

Item {
    id: root
    property var cAdditionalData
    property bool cCoreInitialized: cAdditionalData.initialized
    property var cDataManager: cAdditionalData.dataManager
    property var cWorkspace: cAdditionalData.workspace
    property var cViewType: cWorkspace.cViewType

    onCViewTypeChanged: function() {
        if (!cCoreInitialized) { return }
        view.cActiveView = cViewType
    }

    CViewManager {
        id: viewManager
        cAdditionalData: root.cAdditionalData
        cComponents: [
            {'name': 'table', 'component': 'Views/CDocumentView'},
            {'name': 'map', 'component': 'Views/CMapView'}
        ]
    }

    CView {
        id: view
        anchors.fill: parent
        cViewManager: viewManager
        cActiveView: 'table'
    }
}
