    // Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.2
import QtQuick.Controls
import QtQuick.Layouts
import QtLocation
import QtPositioning
import agromobile

ApplicationWindow {
    id: appWindow
    visible: true
    width: 500
    height: 1000
    visibility: Window.Maximized
    title: "agromobile"

    property bool m_mobileOrientation: height > width;

    Item {
        id: overlay
        parent: Overlay.overlay
        width: parent.width
        height: parent.height

        Item {
            anchors { fill: parent; topMargin: 30; bottomMargin: 10 * m_ratio;  leftMargin: 10 * m_ratio; rightMargin: 10 * m_ratio }

            RowLayout {
                anchors.fill: parent
                enabled: !m_mobileOrientation
                visible: !m_mobileOrientation

                SideBar {
                    Layout.alignment: Qt.AlignTop
                }

                SideInfo {
                    mapComponent: map
                    Layout.alignment:  Qt.AlignRight | Qt.AlignTop
                }
            }

            ColumnLayout {
                anchors.fill: parent
                enabled: m_mobileOrientation
                visible: m_mobileOrientation

                SideBar {
                    Layout.alignment: Qt.AlignTop
                }

                SideInfo {
                    mapComponent: map
                    Layout.alignment: Qt.AlignBottom
                    Layout.preferredWidth: parent.width
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent

        MapComponent {
            id: map
            Layout.fillWidth: true
            Layout.fillHeight: true

            database: Database {
                id: database
            }
        }
    }
}
