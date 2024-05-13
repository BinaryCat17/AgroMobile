import QtQuick 6.2

Item {
    id: root
    property bool cStatic: false
    property var cViewManager
    property string cActiveView: ''
    property bool cViewManagerInitialized: cViewManager.cInitialized

    function updateView() {
        if (cActiveView !== '' && cViewManagerInitialized && cViewManager !== undefined && cActiveView !== undefined) {
            if (!cStatic) {
                cViewManager.clearParents()
            }

            cViewManager.get(cActiveView).parent = root
            cViewManager.get(cActiveView).anchors.fill = root
            cViewManager.get(cActiveView).opacity = 100
            cViewManager.get(cActiveView).enabled = true
        }
    }

    onCViewManagerInitializedChanged: updateView()
    onCActiveViewChanged: updateView()
}
