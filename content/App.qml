import QtQuick 6.2
import QtQuick.Controls
import QtQuick.Layouts
import agromobile

import "Core"
import "Design"
import "Layout"

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

        CDocSelector {
            id: docSelector
            width: workspace.cActiveDocument === '' && workspace.cDocumentMode !== 'create' ? 200 * m_ratio : 400 * m_ratio
            height: parent.height
            cAdditionalData: root.cAdditionalData
        }

        CVSeparator { id: sep; anchors.left: docSelector.right }

        CViewSelector {
            height: parent.height
            anchors.left: sep.right
            anchors.right: parent.right
            cAdditionalData: root.cAdditionalData
        }

    }

}
