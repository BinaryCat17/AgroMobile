import QtQuick 6.2
import QtQuick.Layouts
import '../Design'
import '../Core'
import '../utils.js' as Utils

Item {
    id: root
    height: 40 * m_ratio
    property var cType
    property string cDesc: ''
    property var cInputValue
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
        item.cDesc = cDesc
        if ('cType' in item) {
            item.cType = cType
        }
    }

    CView {
        id: view
        anchors.fill: parent
        cStatic: true
        cViewManager: viewManager
    }
}
