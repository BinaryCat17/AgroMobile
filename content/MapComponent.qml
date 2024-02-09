import QtQuick 6.2
import QtPositioning
import QtLocation
import QtQuick
import QtQuick.Controls
import 'utils.js' as Utils

Map {
    id: map
    property var database;
    zoomLevel: 14

    center: QtPositioning.coordinate(46.414, 41.362)
    plugin: Plugin {
        name: "osm"
        PluginParameter { name: "osm.mapping.custom.host"; value: "http://92.63.178.4:8080/tile/%z/%x/%y.png" }
        PluginParameter { name: "osm.mapping.highdpi_tiles"; value: true }
        PluginParameter { name: "osm.mapping.offline.directory"; value: `${applicationDirPath}/cache/offline_tiles/`}
    }
    activeMapType: supportedMapTypes[supportedMapTypes.length - 1]

    Component.onCompleted: function() {
        selectedItem = {
            id: 'undefined',
            latitude: 'undefined',
            longitude: 'undefined',
            desc: 'undefined',
            type: 'undefined'
        }
        database.transaction(function(tx){
            database.findPolys(tx, polysModel)
            database.findPoints(tx, pointsModel)
        })
        console.log('map initialized')
    }

    // Visualisation --------------------------------------------------------------------------------------------------------

    function calcRadius(z) {
        return z * z * 10000000000 * (1 / (screenSize.width * screenSize.height)) / (Math.exp(z / 1.1) * m_ratio)
    }

    property var selectedItem
    property var pointHovered

    ListModel {
        id: pointsModel
    }

    MapItemView {
        model: pointsModel
        z: 1
        delegate: MapCircle {
            center {
                latitude: latitude
                longitude: longitude
            }
            radius: calcRadius(zoomLevel)
            color: 'green'
            border.color: hhPoint.hovered ? "magenta" : Qt.darker(color)
            border.width: 2

            HoverHandler {
                id: hhPoint
                onHoveredChanged: function(val) {
                    pointHovered = hhPoint.hovered
                }
            }
            TapHandler {
                id: thPoint
                onTapped: function() {
                    selectedItem = {id: id, latitude: latitude, longitude: longitude, desc: desc, type: 'Point'}
                }
            }
        }
    }

    ListModel {
        id: polysModel
    }

    MapItemView {
        model: polysModel
        delegate: MapPolygon {
            id: polysDelegate
            enabled: !pointHovered
            color: '#800000FF'
            border.width: 2
            border.color: hhPolygon.hovered ? "magenta" : Qt.darker(color)
            Component.onCompleted: function() {
                for (var i in poly.shape) {
                    addCoordinate(QtPositioning.coordinate(poly.shape[i][0], poly.shape[i][1]))
                }
            }

            HoverHandler {
                id: hhPolygon
            }
            TapHandler {
                id: thPolygon
                onTapped: function() {
                    selectedItem = {id: poly.id, latitude: poly.latitude, longitude: poly.longitude, desc: poly.desc, type: 'Polygon'}
                }
            }
        }
    }

    // Map controls --------------------------------------------------------------------------------------------------------------

    property geoCoordinate startCentroid

    PinchHandler {
        id: pinch
        target: null
        onActiveChanged: if (active) {
            map.startCentroid = map.toCoordinate(pinch.centroid.position, false)
        }
        onScaleChanged: (delta) => {
            map.zoomLevel += Math.log2(delta)
            map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
        }
        onRotationChanged: (delta) => {
            map.bearing -= delta
            map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
        }
        grabPermissions: PointerHandler.TakeOverForbidden
    }

    WheelHandler {
        id: wheel
        // workaround for QTBUG-87646 / QTBUG-112394 / QTBUG-112432:
        // Magic Mouse pretends to be a trackpad but doesn't work with PinchHandler
        // and we don't yet distinguish mice and trackpads on Wayland either
        acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                         ? PointerDevice.Mouse | PointerDevice.TouchPad
                         : PointerDevice.Mouse
        rotationScale: 1/120
        property: "zoomLevel"
    }

    DragHandler {
        id: drag
        target: null
        onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
    }

    Shortcut {
        enabled: map.zoomLevel < map.maximumZoomLevel
        sequence: StandardKey.ZoomIn
        onActivated: map.zoomLevel = Math.round(map.zoomLevel + 1)
    }

    Shortcut {
        enabled: map.zoomLevel > map.minimumZoomLevel
        sequence: StandardKey.ZoomOut
        onActivated: map.zoomLevel = Math.round(map.zoomLevel - 1)
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onDoubleTapped: (eventPoint, button) => {
            var preZoomPoint = map.toCoordinate(eventPoint.position);
            if (button === Qt.LeftButton)
                map.zoomLevel = Math.floor(map.zoomLevel + 1)
            else
                map.zoomLevel = Math.floor(map.zoomLevel - 1)
            var postZoomPoint = map.toCoordinate(eventPoint.position);
            var dx = postZoomPoint.latitude - preZoomPoint.latitude;
            var dy = postZoomPoint.longitude - preZoomPoint.longitude;
            map.center = QtPositioning.coordinate(map.center.latitude - dx,
                                                       map.center.longitude - dy);
        }
    }

    // Drawing ----------------------------------------------------------------------------------------------

    property variant unfinishedItem: undefined
    property variant referenceSurface: QtLocation.ReferenceSurface.Map
    property variant lastCoordinate

    function addGeoItem(item)
    {
        var co = Qt.createComponent('mapitems/'+item+'.qml')
        if (co.status === Component.Ready) {
            unfinishedItem = co.createObject(map)
            unfinishedItem.setGeometry(map.lastCoordinate)
            unfinishedItem.addGeometry(hoverHandler.currentCoordinate, false)
            map.addMapItem(unfinishedItem)
        } else {
            console.log(item + " is not supported right now, please call us later.")
        }
    }

    function finishGeoItem()
    {
        unfinishedItem.finishAddGeometry()
        if (unfinishedItem.geojsonType === 'Point') {
            var point = {
                id: Utils.generateUUID(),
                longitude: unfinishedItem.center.longitude,
                latitude: unfinishedItem.center.latitude,
                desc: `${unfinishedItem.radius}`
            }

            database.transaction(function(tx){
                database.insertPoints(tx, [point])
            })
            pointsModel.append(point)
        } else if (unfinishedItem.geojsonType === 'Polygon') {
            var shape = []

            for (var i in unfinishedItem.path) {
                var p = unfinishedItem.path[i]

                shape.push([p.latitude, p.longitude])
            }

            var poly = {
                id: Utils.generateUUID(),
                shape: shape,
                desc: `${shape}`
            }

            database.transaction(function(tx){
                database.insertPolys(tx, [poly])
            })

            polysModel.append({poly: poly})
        }

        map.removeMapItem(unfinishedItem)
        unfinishedItem = undefined
    }

    Menu {
        id: mapPopupMenu

        property variant coordinate

        MenuItem {
            text: qsTr("Point")
            onTriggered: addGeoItem("CircleItem")
        }
        MenuItem {
            text: qsTr("Polygon")
            onTriggered: addGeoItem("PolygonItem")
        }

        function show(coordinate) {
            mapPopupMenu.coordinate = coordinate
            mapPopupMenu.popup()
        }
    }

    // Drawing Controls -------------------------------------------------------------------------------------------------------

    HoverHandler {
        id: hoverHandler
        property variant currentCoordinate
        grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfDifferentType

        onPointChanged: {
            currentCoordinate = map.toCoordinate(hoverHandler.point.position)
            if (unfinishedItem !== undefined)
                unfinishedItem.addGeometry(map.toCoordinate(hoverHandler.point.position), true)
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onSingleTapped: (eventPoint, button) => {
            map.lastCoordinate = map.toCoordinate(point.position)
            if (button === Qt.RightButton) {
                if (unfinishedItem !== undefined) {
                    finishGeoItem()
                } else {
                    mapPopupMenu.show(map.lastCoordinate)
                }
            } else if (button === Qt.LeftButton) {
                if (unfinishedItem !== undefined) {
                    if (unfinishedItem.addGeometry(map.toCoordinate(point.position), false)) {
                        finishGeoItem()
                    }
                }
            }
        }
    }
}
