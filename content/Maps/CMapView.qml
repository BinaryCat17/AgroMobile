import QtQuick 6.2
import QtPositioning
import QtLocation
import QtQuick
import QtQuick.Controls
import Qt.labs.animation
import '../Design'
import '../Core'
import '../utils.js' as Utils

Item {
    id: root

    property var cAdditionalData
    property var cDataManager: cAdditionalData.dataManager
    property var cWorkspace: cAdditionalData.workspace
    property var cConfig: cAdditionalData.config
    property bool cCoreInitialized: cAdditionalData.initialized
    property bool cDrawMode: cWorkspace.cDrawMode
    property var cDocumentMode: cWorkspace.cDocumentMode

    property var cCenter: QtPositioning.coordinate(46.414, 41.362)
    property real cZoomLevel: 14
    property real cMinimumZoomLevel: 2
    property real cMaximumZoomLevel: 16
    property var cCurrentCoordinate: QtPositioning.coordinate(46.414, 41.362)
    property var cCurrentSelectedItem: cWorkspace.cCurrentSelectedItem

    property var cHeaderForm
    property var cRecordsForm
    property var cRecordRows

    property int cHoveredPoint: -1
    property int cTappedPoint: -1
    property int cTappedPoly: cWorkspace.cTappedPoly

    ListModel {
        id: unfinishedPoints
    }

    ListModel {
        id: viewPolygons
    }

    onCCoreInitializedChanged: function() {
        function onLayerActivated(layer, value) {
            if(layer === 'tile_servers') {
                if('map' in view.cItems) {
                    var oldMap = view.get('map')
                    oldMap.deactivate()
                }

                view.cComponents = [{
                    'name': 'map',
                    'component': mapComponent.createObject(view, {cName: value.name, cHost: value.host})
                }]
                view.updateView()

                var newMap = view.get('map')
                if (newMap !== undefined) {
                    newMap.activate()
                }
            }
        }

        if(cCoreInitialized) {
            cWorkspace.layerActivated.connect(onLayerActivated)
            cWorkspace.activateLayer('tile_servers', 'scheme')
        }
    }

    onCDrawModeChanged: function() {
        cTappedPoint = -1
        if (cCurrentSelectedItem !== undefined) {
            if (cDrawMode) {
                var shape = cCurrentSelectedItem['shape'].input
                if (shape !== '') {
                    var ashape = JSON.parse(shape)
                    for (var j = 0; j < ashape.length; ++j) {
                        unfinishedPoints.append({
                            latitude: ashape[j][0],
                            longitude: ashape[j][1]
                        })
                        view.get('map').updateUnfinishedPolygon()
                    }
                }
            } else {
                if (unfinishedPoints.count > 0) {
                    var res = '['
                    for (var i = 0; i < unfinishedPoints.count; ++i) {
                        var point = unfinishedPoints.get(i)
                        res += `[${point.latitude}, ${point.longitude}],`
                    }
                    res = res.substring(0, res.length - 1) + ']'
                    cCurrentSelectedItem['shape'].input = res
                    cRecordsForm.rows[cWorkspace.cTappedPoly] = cCurrentSelectedItem

                    unfinishedPoints.clear()
                    viewMenu.get('Info').updateLayout()
                    view.get('map').updateUnfinishedPolygon()
                    updateLayout()
                }
            }
        }
    }

    onCDocumentModeChanged: function() {
        if (cDocumentMode === 'view') {
            cTappedPoint = -1
            unfinishedPoints.clear()
            view.get('map').updateUnfinishedPolygon()
        }
    }

    onCTappedPolyChanged: function() {
        updateLayout()
    }

    function updateLayout() {
        if (cRecordsForm !== undefined) {
            cWorkspace.cCurrentSelectedItem = cRecordsForm.rows[cWorkspace.cTappedPoly]
        }

        viewMenu.get('Info').cRecordRows = root.cRecordRows
        viewMenu.get('Info').cRecordsForm = root.cRecordsForm
        viewMenu.get('Info').updateLayout()

        viewPolygons.clear()

        if (cRecordsForm !== undefined && cRecordsForm.rows !== undefined) {
            for (var i = 1; i < cRecordsForm.rows.length; ++i) {
                var shape = cRecordsForm.rows[i].shape.input
                var polyColor = '#800000FF'
                if ('color' in cRecordsForm.rows[i]) {
                    polyColor = cRecordsForm.rows[i].color.input
                }

                if (shape !== '') {
                    var color = 'darkviolet'
                    var bwidth = 2
                    if ('deleted' in cRecordsForm.rows[i].shape && cRecordsForm.rows[i].shape.deleted) {
                        color = 'red'
                        bwidth = 4
                    } else if (cWorkspace.cTappedPoly === i) {
                        color = 'coral'
                        bwidth = 4
                    }
                    viewPolygons.append({'shape': shape, 'borderColor': color, 'borderWidth': bwidth, 'polyColor': polyColor})

                }
            }
        }
    }

    function calcRadius(z) {
        return z * z * 10000000000 * (1 / (screenSize.width * screenSize.height)) / (Math.exp(z / 1.1) * m_ratio)
    }

    CView {
        id: view
        anchors.fill: parent
        cActiveView: 'map'
    }

    CViewMenu {
        id: viewMenu
        anchors.margins: 15 * m_ratio
        anchors.top: parent.top
        anchors.right: parent.right
        width: 500 * m_ratio
        height: 500 * m_ratio
        cTextColor: cConfig.colors('primaryText')
        cColor: cConfig.colors('background')
        cIconColor: cConfig.colors('icon')

        cAlignment: Qt.AlignRight
        cComponents: [
            {name: 'Layers', component: 'Maps/CMapLayers'},
            {name: 'Info', component: 'Maps/CMapInfo'}
        ]
        cAdditionalData: root.cAdditionalData
        cInitModel: [
            {panel: 'Info', icon: 'info.png'},
            {panel: 'Layers', icon: 'layer.png'}
        ]
    }

    // Map -----------------------------------------------------------------------------------------------------------------------------

    Component {
        id: mapComponent

        Map {
            id: map;
            property bool cDataManagerInitialized: cDataManager.cInitialized

            function activate() {
                center = cCenter
                zoomLevel = cZoomLevel
            }

            function deactivate() {
                cCenter = center
                cZoomLevel = zoomLevel
            }

            onZoomLevelChanged: function() {
                cZoomLevel = zoomLevel
                br.returnToBounds();
                if (!pinchAdjustingZoom) resetPinchMinMax()
            }

            // onCenterChanged: function() {
            //     cCenter = center
            // }

            onCDataManagerInitializedChanged: function() {
                if(cDataManager !== undefined && cDataManagerInitialized) {
                    // pointsView.model = cDataManager.get('Points').model
                    // polysView.model = cDataManager.get('Polys').model
                }
            }

            property var cName;
            property var cHost;

            property var pointHovered;
            property variant unfinishedItem: undefined;
            property variant referenceSurface: QtLocation.ReferenceSurface.Map;
            property vector3d animDest;

            width: parent.width
            height: parent.height
            zoomLevel: cZoomLevel
            center: QtPositioning.coordinate(46.414, 41.362)
            plugin: Plugin {
                name: "osm"
                PluginParameter { name: "osm.mapping.custom.host"; value: cHost }
                PluginParameter { name: "osm.mapping.highdpi_tiles"; value: true }
                PluginParameter { name: "osm.mapping.cache.directory"; value: `${applicationDirPath}/cache/${cName}/`}
                PluginParameter { name: "osm.mapping.offline.directory"; value: `${applicationDirPath}/offline_tiles/${cName}/`}
            }

            activeMapType: map.supportedMapTypes[map.supportedMapTypes.length - 1]

            function updateUnfinishedPolygon() {
                unfinishedPolygon.path = []
                if (unfinishedPoints.count >= 3) {
                    for (var i = 0; i < unfinishedPoints.count; ++i) {
                        var point = unfinishedPoints.get(i)
                        unfinishedPolygon.addCoordinate(point)
                    }
                }
            }

            // Controls ------------------------------------------------------------------------------------------------------------

            HoverHandler {
                id: hoverHandler
                grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfDifferentType

                onPointChanged: {
                    root.cCurrentCoordinate = map.toCoordinate(hoverHandler.point.position)

                    if (cTappedPoint !== -1) {
                        unfinishedPoints.set(cTappedPoint, cCurrentCoordinate)
                        updateUnfinishedPolygon()
                    }
                }
            }

            TapHandler {
                id: tapHandler
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onSingleTapped: (eventPoint, button) => {
                    if (button === Qt.RightButton) {

                    } else if (button === Qt.LeftButton) {
                        if (cWorkspace.cDrawMode) {
                            if (cTappedPoint === -1 && cHoveredPoint === -1) {
                                unfinishedPoints.append({
                                    latitude: cCurrentCoordinate.latitude,
                                    longitude: cCurrentCoordinate.longitude
                                })

                                updateUnfinishedPolygon()
                            }
                        }
                    }
                }
            }

            tilt: tiltHandler.persistentTranslation.y / -5
            property bool pinchAdjustingZoom: false

            BoundaryRule on zoomLevel {
                id: br
                minimum: map.minimumZoomLevel
                maximum: 16
            }

            function resetPinchMinMax() {
                pinch.persistentScale = 1
                pinch.scaleAxis.minimum = Math.pow(2, root.cMinimumZoomLevel - map.zoomLevel + 1)
                pinch.scaleAxis.maximum = Math.pow(2, root.cMaximumZoomLevel - map.zoomLevel - 1)
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

            MapCircle {
                enabled: cWorkspace.cDrawMode && cHoveredPoint === -1 && cTappedPoint === -1
                visible: cWorkspace.cDrawMode && cHoveredPoint === -1 && cTappedPoint === -1
                center: root.cCurrentCoordinate
                radius: root.calcRadius(root.cZoomLevel, screenSize)
                color: 'green'
                border.width: 2
            }

            MapPolygon {
                id: unfinishedPolygon
            }

            MapItemView {
                id: unifinishedPointsView
                model: unfinishedPoints
                z: 1

                delegate: MapCircle {
                    center {
                        latitude: latitude
                        longitude: longitude
                    }
                    radius: root.calcRadius(map.zoomLevel, screenSize)
                    color: 'green'
                    border.color: hhPoint.hovered ? "magenta" : Qt.darker(color)
                    border.width: 2

                    HoverHandler {
                        id: hhPoint
                        onHoveredChanged: function() {
                            if (hhPoint.hovered) {
                                root.cHoveredPoint = index
                            } else {
                                root.cHoveredPoint = -1
                            }
                        }
                    }

                    TapHandler {
                        id: thPoint
                        onTapped: function() {
                            if (index !== cTappedPoint) {
                                root.cTappedPoint = index
                            } else {
                                root.cTappedPoint = -1
                            }
                        }
                    }
                }
            }

            MapItemView {
                id: polysView
                model: viewPolygons
                delegate: MapPolygon {
                    id: polysDelegate
                    property var cPolyColor: polyColor
                    property var cBorderColor: borderColor
                    property var cBorderWidth: borderWidth
                    enabled: !map.pointHovered
                    color: cPolyColor
                    border.width: cBorderWidth
                    border.color: hhPolygon.hovered ? "magenta" : cBorderColor

                    Component.onCompleted: function() {
                        var ashape = JSON.parse(shape)
                        for (var i in shape) {
                            if (ashape[i] !== undefined) {
                                addCoordinate(QtPositioning.coordinate(ashape[i][0], ashape[i][1]))
                            }
                        }
                    }

                    HoverHandler {
                        id: hhPolygon
                    }

                    TapHandler {
                        id: thPolygon
                        onTapped: function() {
                            if (!cDrawMode) {
                                cWorkspace.cTappedPoly = index + 1
                                cWorkspace.cCurrentSelectedItem = cRecordsForm.rows[index + 1]
                                viewMenu.cPanel = 'Info'
                                updateLayout()
                            }
                        }
                    }
                }
            }
        }
    }
}
