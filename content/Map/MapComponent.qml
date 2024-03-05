import QtQuick 6.2
import QtPositioning
import QtLocation
import QtQuick
import QtQuick.Controls
import Qt.labs.animation
import '../utils.js' as Utils

Item {
    id: view
    property var database;
    property var selectedItem;
    property real minimumZoomLevel: map.minimumZoomLevel
    property real maximumZoomLevel: map.maximumZoomLevel

    Map {
        id: map;

        property var pointHovered;
        property variant unfinishedItem: undefined;
        property variant referenceSurface: QtLocation.ReferenceSurface.Map;
        property vector3d animDest;

        width: parent.width
        height: parent.height
        zoomLevel: 14
        center: QtPositioning.coordinate(46.414, 41.362)
        plugin: Plugin {
            name: "osm"
            PluginParameter { name: "osm.mapping.custom.host"; value: "http://92.63.178.4:8080/tile/%z/%x/%y.png" }
            PluginParameter { name: "osm.mapping.highdpi_tiles"; value: true }
            PluginParameter { name: "osm.mapping.offline.directory"; value: `${applicationDirPath}/cache/offline_tiles/`}
        }
        activeMapType: map.supportedMapTypes[map.supportedMapTypes.length - 1]

        Component.onCompleted: function() {
            view.selectedItem = {
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

        // Controls ------------------------------------------------------------------------------------------------------------

        tilt: tiltHandler.persistentTranslation.y / -5
        property bool pinchAdjustingZoom: false

        BoundaryRule on zoomLevel {
            id: br
            minimum: map.minimumZoomLevel
            maximum: map.maximumZoomLevel
        }

        onZoomLevelChanged: {
            br.returnToBounds();
            if (!pinchAdjustingZoom) resetPinchMinMax()
        }

        function resetPinchMinMax() {
            pinch.persistentScale = 1
            pinch.scaleAxis.minimum = Math.pow(2, view.minimumZoomLevel - map.zoomLevel + 1)
            pinch.scaleAxis.maximum = Math.pow(2, view.maximumZoomLevel - map.zoomLevel - 1)
        }

        PinchHandler {
            id: pinch
            target: null
            property real rawBearing: 0
            onActiveChanged: if (active) {
                flickAnimation.stop()
                pinch.startCentroid = map.toCoordinate(pinch.centroid.position, false)
            } else {
                flickAnimation.restart(centroid.velocity)
                map.resetPinchMinMax()
            }
            onScaleChanged: (delta) => {
                map.pinchAdjustingZoom = true
                map.zoomLevel += Math.log2(delta)
                map.alignCoordinateToPoint(pinch.startCentroid, pinch.centroid.position)
                map.pinchAdjustingZoom = false
            }
            onRotationChanged: (delta) => {
                pinch.rawBearing -= delta
                // snap to 0° if we're close enough
                map.bearing = (Math.abs(pinch.rawBearing) < 5) ? 0 : pinch.rawBearing
                map.alignCoordinateToPoint(pinch.startCentroid, pinch.centroid.position)
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
            onWheel: (event) => {
                const loc = map.toCoordinate(wheel.point.position)
                switch (event.modifiers) {
                    case Qt.NoModifier:
                        map.zoomLevel += event.angleDelta.y / 120
                        break
                    case Qt.ShiftModifier:
                        map.bearing += event.angleDelta.y / 15
                        break
                    case Qt.ControlModifier:
                        map.tilt += event.angleDelta.y / 15
                        break
                }
                map.alignCoordinateToPoint(loc, wheel.point.position)
            }
        }

        DragHandler {
            id: drag
            signal flickStarted // for autotests only
            signal flickEnded
            target: null
            onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
            onActiveChanged: if (active) {
                flickAnimation.stop()
            } else {
                flickAnimation.restart(centroid.velocity)
            }
        }

        onAnimDestChanged: if (flickAnimation.running) {
            const delta = Qt.vector2d(animDest.x - flickAnimation.animDestLast.x, animDest.y - flickAnimation.animDestLast.y)
            map.pan(-delta.x, -delta.y)
            flickAnimation.animDestLast = animDest
        }

        Vector3dAnimation on animDest {
            id: flickAnimation
            property vector3d animDestLast
            from: Qt.vector3d(0, 0, 0)
            duration: 500
            easing.type: Easing.OutQuad
            onStarted: drag.flickStarted()
            onStopped: drag.flickEnded()

            function restart(vel) {
                stop()
                map.animDest = Qt.vector3d(0, 0, 0)
                animDestLast = Qt.vector3d(0, 0, 0)
                to = Qt.vector3d(vel.x / duration * 100, vel.y / duration * 100, 0)
                start()
            }
        }

        DragHandler {
            id: tiltHandler
            minimumPointCount: 2
            maximumPointCount: 2
            target: null
            xAxis.enabled: false
            grabPermissions: PointerHandler.TakeOverForbidden
            onActiveChanged: if (active) flickAnimation.stop()
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

        // Visualisation --------------------------------------------------------------------------------------------------------

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
                radius: calcRadius(map.zoomLevel, screenSize)
                color: 'green'
                border.color: hhPoint.hovered ? "magenta" : Qt.darker(color)
                border.width: 2

                HoverHandler {
                    id: hhPoint
                    onHoveredChanged: function(val) {
                        map.pointHovered = hhPoint.hovered
                    }
                }
                TapHandler {
                    id: thPoint
                    onTapped: function() {
                        view.selectedItem = {id: id, latitude: latitude, longitude: longitude, desc: desc, type: 'Point'}
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
                enabled: !map.pointHovered
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
                        view.selectedItem = {id: poly.id, latitude: poly.latitude, longitude: poly.longitude, desc: poly.desc, type: 'Polygon'}
                    }
                }
            }
        }
    }

    // Drawing ----------------------------------------------------------------------------------------------

    HoverHandler {
        id: hoverHandler
        property variant currentCoordinate
        grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfDifferentType

        onPointChanged: {
            currentCoordinate = map.toCoordinate(hoverHandler.point.position)
            if (map.unfinishedItem !== undefined)
                map.unfinishedItem.addGeometry(map.toCoordinate(hoverHandler.point.position), true)
        }
    }

    TapHandler {
        id: tapHandler
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onSingleTapped: (eventPoint, button) => {
            if (button === Qt.RightButton) {
                if (map.unfinishedItem !== undefined) {
                    finishGeoItem()
                }
            } else if (button === Qt.LeftButton) {
                if (map.unfinishedItem !== undefined) {
                    if (map.unfinishedItem.addGeometry(map.toCoordinate(point.position), false)) {
                        finishGeoItem()
                    }
                }
            }
        }
    }

    // Drawing functions -----------------------------------------------------------------------------------------------------------------

    function calcRadius(z) {
        return z * z * 10000000000 * (1 / (screenSize.width * screenSize.height)) / (Math.exp(z / 1.1) * m_ratio)
    }

    function addGeoItem(item)
    {
        var co = Qt.createComponent('/qt/qml/content/'+item+'.qml')
        if (co.status === Component.Ready) {
            map.unfinishedItem = co.createObject(map)
            map.unfinishedItem.addGeometry(hoverHandler.currentCoordinate, false)
            map.addMapItem(map.unfinishedItem)
        } else {
            console.log(item + " is not supported right now, please call us later.")
        }
    }

    function finishGeoItem()
    {
        map.unfinishedItem.finishAddGeometry()
        if (map.unfinishedItem.geojsonType === 'Point') {
            var point = {
                id: Utils.generateUUID(),
                longitude: map.unfinishedItem.center.longitude,
                latitude: map.unfinishedItem.center.latitude,
                desc: `${map.unfinishedItem.radius}`
            }

            database.transaction(function(tx){
                database.insertPoints(tx, [point])
            })
            pointsModel.append(point)
        } else if (map.unfinishedItem.geojsonType === 'Polygon') {
            var shape = []

            for (var i in map.unfinishedItem.path) {
                var p = map.unfinishedItem.path[i]

                shape.push([p.latitude, p.longitude])
            }

            if (i >= 3) {
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
        }

        map.removeMapItem(map.unfinishedItem)
        map.unfinishedItem = undefined
    }

    function removeGeoItem() {
        if(view.selectedItem !== undefined) {
            database.transaction(function(tx) {
                if(view.selectedItem.type === "Point") {
                    database.removePoints(tx, [{id: view.selectedItem.id}])
                    for(var i = 0; i < pointsModel.count; ++i) {
                        var point = pointsModel.get(i)
                        if(point.id === view.selectedItem.id) {
                            pointsModel.remove(i)
                            break
                        }
                    }
                } else if (view.selectedItem.type === "Polygon") {
                    database.removePolys(tx, [{id: view.selectedItem.id}])
                    for(var j = 0; j < polysModel.count; ++j) {
                        var poly = polysModel.get(j).poly
                        if(poly.id === view.selectedItem.id) {
                            polysModel.remove(j)
                            break
                        }
                    }
                }
            })
            view.selectedItem = {
                id: 'undefined',
                latitude: 'undefined',
                longitude: 'undefined',
                desc: 'undefined',
                type: 'undefined'
            }
        }
    }
}
