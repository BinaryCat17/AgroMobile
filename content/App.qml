import QtQuick 6.2
import QtQuick.Controls
import QtQuick.Layouts
import agromobile

import "Core"
import "Panels"
import "Views/Document"
import "Design"

ApplicationWindow {
    id: root
    visible: true
    width: 500
    height: 1000
    visibility: Window.Maximized
    title: "agromobile"

    CDatabase {
        id: database
    }

    CConfig {
        id: config
    }

    CWorkspace {
        id: workspace
        cConfig: config
    }

    CDataManager {
        id: dataManager
        cDatabase: database
        cConfig: config
    }

    property var cAdditionalData: ({
        m_mobileOrientation: height > width,
        config: config,
        workspace: workspace,
        dataManager: dataManager,
        initialized: config.cInitialized && workspace.cInitialized && dataManager.cInitialized
    })

    Item {
        id: overlay
        anchors.fill: parent

        SplitView {
            anchors.fill: parent
            orientation: Qt.Horizontal

            handle: CSplitHandler {}

            Item {
                SplitView.minimumWidth: 200
                SplitView.maximumWidth: 200

                CDocumentTypes {
                    width: parent.width
                    cAdditionalData: root.cAdditionalData
                }
            }

            Item {
                id: centerItem
                SplitView.minimumWidth: 300 * m_ratio
                SplitView.maximumWidth: 600 * m_ratio

                CDocumentList {
                    width: parent.width
                    cAdditionalData: root.cAdditionalData
                }
            }

            Item {
                SplitView.fillWidth: true

                CViewSelector {
                    width: parent.width
                    cAdditionalData: root.cAdditionalData
                }
            }
        }
    }
}
