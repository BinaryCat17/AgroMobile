import QtQuick 6.2
import QtQuick.Controls
import QtLocation
import QtPositioning
import agromobile

import "Core"
import "Design"
import "Views"

ApplicationWindow {
    id: appWindow
    visible: true
    width: 500
    height: 1000
    visibility: Window.Maximized
    title: "agromobile"

    property bool m_mobileOrientation: height > width;

    CDataManager {
        id: dataManager
        cDatabase: CDatabase {}
    }

    CViewManager {
        id: objectViewManager
        cComponents: [
            {name: 'ObjectInfo', component: 'Views/CObjectInfoView'}
        ]
        cAdditionalData: ({
            dataManager: dataManager,
            infoTables: {
                "Points": [
                    {name: "longitude", type: "String", desc: "Долгота"},
                    {name: "latitude", type: "String", desc: "Широта"},
                    {name: "desc", type: "String", desc: "Описание"}],
                "Polys": [
                    {name: "shape", type: "String", desc: "Форма"},
                    {name: "desc", type: "String", desc: "Описание"}]
            }
        })
    }

    CViewManager {
        id: menuViewManager
        cComponents: [
            {name: 'Layers', component: 'Views/CMapLayersView'}
        ]
        cAdditionalData: ({
            dataManager: dataManager
        })
    }

    CMapView {
        anchors.fill: parent
        cDataManager: dataManager
        cAdditionalData: ({
            mapServers: [
                {name: 'scheme', host: 'http://92.63.178.4:8080/tile/%z/%x/%y.png'},
                {name: 'landsat', host: 'http://92.63.178.4:8081/tiles/landsat/%z/%x/%y.png'},
                {name: 'sentinel-2a', host: 'http://92.63.178.4:8081/tiles/sentinel-2a/%z/%x/%y.png'}
            ]
        })
    }

    Item {
        id: overlay
        anchors.fill: parent

        CPanel {
            width: 300 * m_ratio
            height: 500 * m_ratio
            anchors.left: parent.left
            anchors.top: parent.top

            cViewManager: objectViewManager
            cInitModel: [
                {panel: 'ObjectInfo', icon: 'info.png'}
            ]
        }

        CPanel {
            cAlignment: Qt.AlignRight
            width: 300 * m_ratio
            height: 500 * m_ratio
            anchors.right: parent.right
            anchors.top: parent.top
            cViewManager: menuViewManager
            cInitModel: [
                {panel: 'Layers', icon: 'map.png'}
            ]
        }
    }
}
