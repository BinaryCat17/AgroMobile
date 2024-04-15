import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property real cWidth: 0
    property real cHeight: 0
    property var cPanelComponents: []
    property string cActivePanel: ''
    property var cAdditionalData
    property var cCurrentIndex: stackLayout.currentIndex

    function activatePanel(cname) {
        if (cname === '') {
            cActivePanel = ''
            stackLayout.currentIndex = -1
            root.cWidth = 0
            root.cHeight = 0
        } else if (cname in view.panels) {
            cActivePanel = cname
            stackLayout.currentIndex = view.panels[cActivePanel].index
        } else {
            console.log(cname + " is not supported right now, please call us later.")
        }
    }

    onCAdditionalDataChanged: function() {
        for (var item in view.panels) {
            if('cAdditionalData' in view.panels[item].item) {
                view.panels[item].item.cAdditionalData = root.cAdditionalData
            }
        }
    }

    onCActivePanelChanged: function() {
        if (cActivePanel !== '') {
            for (var item in view.panels) {
                if('cOpened' in view.panels[item].item) {
                    view.panels[item].item.cOpened = (cActivePanel === item)
                }
            }
            root.cWidth = view.panels[cActivePanel].item.cWidth
            root.cHeight = view.panels[cActivePanel].item.cHeight
        }
    }

    Item {
        id: view
        property var panels: ({})
        anchors.fill: parent

        Component.onCompleted: function () {
            for (var i = 0; i < root.cPanelComponents.length; ++i) {
                var item = root.cPanelComponents[i]
                var co = 'undefined'
                var name = 'undefined'

                if(typeof(item) === 'string') {
                    name = item
                    co = Qt.createComponent('/qt/qml/content/'+name+'.qml')
                } else {
                    name = co.name
                    co = name
                }

                if (co.status === Component.Ready) {
                    var componentItem = co.createObject(stackLayout)
                    if ('cAdditionalData' in componentItem) {
                        componentItem.cAdditionalData = root.cAdditionalData
                    }
                    if ('cParentStack' in componentItem) {
                        componentItem.cParentStack = root
                    }
                    if ('cOpened' in componentItem) {
                        componentItem.cOpened = (cActivePanel === name)
                    }

                    panels[name] = {index: i, item: componentItem}
                } else {
                    console.log(name + " is not supported right now, please call us later.")
                }
            }
            root.activatePanel(root.cActivePanel)
        }

        StackLayout {
            id: stackLayout
            anchors.fill: parent
        }
    }
}
