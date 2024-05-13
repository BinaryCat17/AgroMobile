import QtQuick 6.2

Item {
    id: root
    property bool cInitialized: false
    property var cConfig
    property var cConfigInitialized: cConfig.cInitialized
    property var cMapLayers
    property var cActiveLayers: ({})
    property var cSelectedItem

    property string cActiveDocumentType
    property string cDocumentMode

    onCConfigInitializedChanged: function() {
        if (!cConfigInitialized) { return }

        cMapLayers = cConfig.listMapLayers()
        for (var i = 0; i < cMapLayers.length; ++i) {
            var layer = cMapLayers[i]
            activateLayer(layer.name, layer.children[0].name)
        }
        cInitialized = true
    }

    function select(name, id) {
        var model = root.get(name).model
        for (var j = 0; j < model.count; ++j) {
            var listItem = model.get(j);
            if (listItem.id === id) {
                cSelectedItem = listItem
                break
            }
        }
    }

    signal layerActivated(layer: string, value: variant)

    function activateLayer(layer, value) {
        for (var i = 0; i <cMapLayers.length; ++i) {
            if(cMapLayers[i].name === layer) {
                for (var j = 0; j < cMapLayers[i].children.length; ++j) {
                    var child = cMapLayers[i].children[j]
                    if(child['name'] === value) {
                        cActiveLayers[layer.name] = child
                        layerActivated(layer, child)
                        return
                    }
                }
            }
        }
    }
}
