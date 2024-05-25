import QtQuick 6.2

Item {
    id: root
    property string cActiveView: ''
    property bool cInitialized: false
    property var cComponents: [] // [name: 'componentName', component: 'component/path' or componentId]
    property var cAdditionalData
    property var cItems: ({})

    signal updated()

    function get(name) {
        if (name in cItems) {
            return cItems[name]
        } else {
            console.log(name + " is not supported right now, please call us later.")
            return undefined
        }
    }

    function clear() {
        for (var item in cItems) {
             cItems[item].destroy()
        }
        cItems = ({})
    }

    function clearParents() {
        for (var item in cItems) {
            cItems[item].parent = root
            cItems[item].enabled = false
            cItems[item].visible = false
        }
    }

    function updateView() {
        if (cActiveView !== undefined && cActiveView !== '' && cInitialized) {
            clearParents()
            get(cActiveView).parent = root
            get(cActiveView).anchors.fill = root
            get(cActiveView).visible = true
            get(cActiveView).enabled = true
        }
    }

    onCComponentsChanged: function() {
        clear()
        for (var i = 0; i < cComponents.length; ++i) {
            var item = cComponents[i]
            var co = 'undefined'

            var componentItem
            if(typeof(item.component) === 'string') {
                co = Qt.createComponent('/qt/qml/content/'+item.component+'.qml')
                if (co.status === Component.Ready) {
                    componentItem = co.createObject(root)
                } else {
                    console.log([item.component] + " is not supported right now, please call us later.")
                    return
                }
            } else {
                componentItem = item.component
            }

            if(item.name === cActiveView) {
                componentItem.enabled = true
                componentItem.visible = true
            } else {
                componentItem.enabled = false
                componentItem.visible = false
            }


            if ('cAdditionalData' in componentItem) {
                componentItem.cAdditionalData = root.cAdditionalData
            }

            cItems[item.name] = componentItem
        }

        if(cComponents.length > 0) {
            cInitialized = true
        }

        updateView()
        updated()
    }

    onCActiveViewChanged: updateView()

    onCAdditionalDataChanged: function() {
        for (var item in cItems) {
            if('cAdditionalData' in cItems[item]) {
                cItems[item].cAdditionalData = root.cAdditionalData
            }
        }
    }
}
