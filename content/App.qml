    // Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.2
import QtQuick.Controls
import QtLocation
import QtPositioning
import agromobile
import "Map" as Map
import "Database"
import "Design"
import "SelectedMenu"

ApplicationWindow {
    id: appWindow
    visible: true
    width: 500
    height: 1000
    visibility: Window.Maximized
    title: "agromobile"

    property bool m_mobileOrientation: height > width;

    onM_mobileOrientationChanged: function() {
        if(m_mobileOrientation) {
            selectedMenu.anchors.top = undefined
            selectedMenu.anchors.bottom = overlay.bottom
            selectedMenu.anchors.margins = 0
        } else {
            selectedMenu.anchors.bottom = undefined
            selectedMenu.anchors.top = overlay.top
            selectedMenu.anchors.margins = 20 * m_ratio
        }
    }

    Item {
        id: overlay
        parent: Overlay.overlay
        width: appWindow.width
        height: appWindow.height

        CPanelSelector {
            id: globalMenu
            width: m_mobileOrientation ? parent.width : 500 * m_ratio
            height: 300 * m_ratio
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: m_mobileOrientation ? 0 : 20 * m_ratio

            cOrientation: Qt.AlignLeft
            cPanelRadius: m_mobileOrientation ? 0 : 10 * m_ratio
            cPanelMargin: m_mobileOrientation ? 0 : 10 * m_ratio

            cAdditionalData: ({
                map: mapComponent,
                stackRadius: m_mobileOrientation ? 0 : 10 * m_ratio
            })

            cPanelModel: [
                {panel: 'GlobalMenu/MapPanel', icon: 'map.png'},
                {panel: 'GlobalMenu/TimePanel', icon: 'time.png'},
                {panel: 'GlobalMenu/CatalogPanel', icon: 'catalog.png'},
            ]
            cOpenIcon: 'right.png'
            cCloseIcon: 'left.png'
        }

        CPanelSelector {
            id: selectedMenu
            anchors.right: parent.right

            width: m_mobileOrientation ? parent.width : 500 * m_ratio
            height: 350 * m_ratio

            cOrientation: m_mobileOrientation ? Qt.AlignBottom : Qt.AlignTop
            cDirection: Qt.AlignTrailing

            cPanelFill: m_mobileOrientation
            cPanelMargin: m_mobileOrientation ? 0 : 10 * m_ratio
            cPanelRadius: m_mobileOrientation ? 0 : 10 * m_ratio

            cAdditionalData: ({
                map: mapComponent,
                stackRadius: m_mobileOrientation ? 0 : 10 * m_ratio
            })

            cPanelModel: [
                {panel: 'SelectedMenu/InfoPanel', icon: 'info.png'},
                {panel: 'SelectedMenu/CropsPanel', icon: 'wheat.png'},
                {panel: 'SelectedMenu/MessagePanel'},
            ]
            cOpenIcon: m_mobileOrientation ? 'up.png' : 'down.png'
            cCloseIcon: m_mobileOrientation ? 'down.png' : 'up.png'
        }
    }

    Map.MapComponent {
        id: mapComponent
        anchors.fill: parent
        database: Database {
            id: database
        }
    }
}
