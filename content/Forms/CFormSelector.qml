import QtQuick 6.2
import QtQuick.Layouts
import '../Design'
import '../Core'
import '../utils.js' as Utils

Rectangle {
    id: root
    height: 40 * m_ratio
    property var cAdditionalData
    property var cType
    property var cInputValue
    property var cSetValue
    property string cMode: 'read'
    property color cTextColor: 'black'

    property string cCurrentSelectedMode
    property string cCurrentSelectedColumn
    property string cCurrentSelectedRow

    Component.onCompleted: function() {
        var componentPath = ''
        if (cType === 'string' || cType === 'poly') {
            componentPath = 'Forms/CStringForm'
        } else if (cType === 'datetime') {
            componentPath = 'Forms/CStringForm'
        } else if (Utils.isUpperCase(cType[0])) {
            componentPath = 'Forms/CCatalogForm'
        }

        view.cComponents = [{name: 'view', component: componentPath}]
        view.cActiveView = 'view'

        var item = view.get('view')
        if ('cSetValue' in item) {
            item.cSetValue = cSetValue
        }

        if ('cType' in item) {
            item.cType = cType
        }

        if ('cMode' in item) {
            item.cMode = cMode
        }

        if ('cColor' in item) {
            item.cColor = color
        }

        if ('cTextColor' in item) {
            item.cTextColor = cTextColor
        }

        if ('cAdditionalData' in item) {
            item.cAdditionalData = cAdditionalData
        }

        if ('cTextColor' in item) {
            item.cTextColor = cTextColor
        }

        if ('cCurrentSelectedMode' in item) {
            item.cCurrentSelectedMode = cCurrentSelectedMode
        }

        if ('cCurrentSelectedRow' in item) {
            item.cCurrentSelectedRow = cCurrentSelectedRow
        }

        if ('cCurrentSelectedColumn' in item) {
            item.cCurrentSelectedColumn = cCurrentSelectedColumn
        }

        if ('cInputValue' in item) {
            item.onCInputValueChanged.connect(function(v) {
                cInputValue = item.cInputValue
            })
        }
    }

    onCSetValueChanged: function() {
        if (view.cInitialized) {
            var item = view.get('view')
            if ('cSetValue' in item) {
                item.cSetValue = cSetValue
            }
        }
    }

    onCTypeChanged: function() {
        if (view.cInitialized) {
            var item = view.get('view')
            if ('cType' in item) {
                item.cType = cType
            }
        }
    }

    onCModeChanged: function() {
        if (view.cInitialized) {
            var item = view.get('view')
            if ('cMode' in item) {
                item.cMode = cMode
            }
        }
    }

    onColorChanged: function() {
        if (view.cInitialized) {
            var item = view.get('view')
            if ('cColor' in item) {
                item.cColor = color
            }
        }
    }

    onCAdditionalDataChanged: function() {
        if (view.cInitialized) {
            var item = view.get('view')
            if ('cAdditionalData' in item) {
                item.cAdditionalData = cAdditionalData
            }
        }
    }

    onCCurrentSelectedModeChanged: function() {
        if (view.cInitialized) {
            var item = view.get('view')
            if ('cCurrentSelectedMode' in item) {
                item.cCurrentSelectedMode = cCurrentSelectedMode
            }
        }
    }

    onCCurrentSelectedColumnChanged: function() {
        if (view.cInitialized) {
            var item = view.get('view')
            if ('cCurrentSelectedColumn' in item) {
                item.cCurrentSelectedColumn = cCurrentSelectedColumn
            }
        }
    }

    onCCurrentSelectedRowChanged: function() {
        if (view.cInitialized) {
            var item = view.get('view')
            if ('cCurrentSelectedRow' in item) {
                item.cCurrentSelectedRow = cCurrentSelectedRow
            }
        }
    }

    CView {
        id: view
        anchors.fill: parent
    }
}
