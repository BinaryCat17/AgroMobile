import QtQuick 6.2

Item {
    id: root
    property bool cInitialized: false
    property var cConfig
    property var cConfigInitialized: cConfig.cInitialized
    property var cMapLayers
    property var cActiveLayers: ({})

    property string cActiveDocumentType
    property string cActiveDocumentTypeIcon
    property string cActiveDocumentTypeDesc
    property string cActiveDocument

    property string cSelectDocumentType
    property string cSelectDocumentTypeIcon
    property string cSelectDocumentTypeDesc
    property string cSelectDocument

    property string cDocumentMode
    property string cViewType: 'table'

    property var cCurrentSelectedItem
    property string cCurrentSelectedMode
    property string cCurrentSelectedColumn
    property string cCurrentSelectedRow

    property var cDocumentViewState: ({})
    property var cSelectViewState: ({})

    property bool cDrawMode
    property int cTappedPoly: -1

    onCConfigInitializedChanged: function() {
        if (!cConfigInitialized) { return }

        cMapLayers = cConfig.getMapLayers()
        for (var i = 0; i < cMapLayers.length; ++i) {
            var layer = cMapLayers[i]
            activateLayer(layer.name, layer.children[0].name)
        }
        cInitialized = true
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
