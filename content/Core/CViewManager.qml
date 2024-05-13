import QtQuick 6.2

Item {
    id: root
    property bool cInitialized: false
    property var cComponents: [] // [name: 'componentName', component: 'component/path' or componentId]
    property var cItems: ({})
    property var cAdditionalData

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
            cItems[item].opacity = 0
            cItems[item].enabled = false
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

            componentItem.opacity = 0
            componentItem.enabled = false

            if ('cAdditionalData' in componentItem) {
                componentItem.cAdditionalData = root.cAdditionalData
            }

            cItems[item.name] = componentItem
        }

        if(cComponents.length > 0) {
            cInitialized = true
        }

        updated()
    }

    onCAdditionalDataChanged: function() {
        for (var item in cItems) {
            if('cAdditionalData' in cItems[item]) {
                cItems[item].cAdditionalData = root.cAdditionalData
            }
        }
    }
}
