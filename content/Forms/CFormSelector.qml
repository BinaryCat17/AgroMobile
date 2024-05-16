import QtQuick 6.2
import QtQuick.Layouts
import '../Design'
import '../Core'
import '../utils.js' as Utils

Rectangle {
    id: root
    height: 40 * m_ratio
    property var cType
    property var cInputValue
    property var cSetValue
    property string cMode: 'read'

    CViewManager {
        id: viewManager
        cAdditionalData: ({})
    }

    Component.onCompleted: function() {
        var componentPath = ''
        if (cType === 'string') {
            componentPath = 'Forms/CStringForm'
        } else if (cType === 'datetime') {
            componentPath = 'Forms/CStringForm'
        } else if (Utils.isUpperCase(cType[0])) {
            componentPath = 'Forms/CCatalogForm'
        }

        viewManager.cComponents = [{name: 'view', component: componentPath}]
        view.cActiveView = 'view'

        var item = viewManager.get('view')
        if ('cSetValue' in item) {
            item.cSetValue = cSetValue
        }
        if ('cType' in item) {
            item.cType = cType
        }
        if ('cMode' in item) {
            item.cMode = cMode
        }
        if ('cInputValue' in item) {
            //cInputValue = item.cInputValue
            item.onCInputValueChanged.connect(function(v) {
                cInputValue = item.cInputValue
            })
        }
    }

    onCSetValueChanged: function() {
        if (viewManager.cInitialized) {
            var item = viewManager.get('view')
            if ('cSetValue' in item) {
                item.cSetValue = cSetValue
            }
        }
    }

    onCTypeChanged: function() {
        if (viewManager.cInitialized) {
            var item = viewManager.get('view')
            if ('cType' in item) {
                item.cType = cType
            }
        }
    }

    onCModeChanged: function() {
        if (viewManager.cInitialized) {
            var item = viewManager.get('view')
            if ('cMode' in item) {
                item.cMode = cMode
            }
        }
    }

    CView {
        id: view
        anchors.fill: parent
        cStatic: true
        cViewManager: viewManager
    }
}
