import QtQuick
import QtQuick.Layouts

Item {
    id: sideInfo

    property var mapComponent
    width: 500 * m_ratio
    Layout.fillHeight: true
    state: 'open'

    states: [
        State {
            name: 'open'

            PropertyChanges {
                target: infoDesk
                enabled: true
            }
            PropertyChanges {
                target: infoMobile
                enabled: true
            }
        },
        State {
            name: 'close'

            PropertyChanges {
                target: infoDesk
                enabled: false
            }
            PropertyChanges {
                target: infoMobile
                enabled: false
            }
        }
    ]

    transitions: [
        Transition {
            from: 'close'
            to: 'open'

            NumberAnimation {
                target: infoDesk
                properties: 'opacity'
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: infoMobile
                properties: 'opacity'
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.InOutSine
            }
        },
        Transition {
            from: 'open'
            to: 'close'

            NumberAnimation {
                target: infoDesk
                properties: 'opacity'
                from: 1
                to: 0
                duration: 300
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: infoMobile
                properties: 'opacity'
                from: 1
                to: 0
                duration: 300
                easing.type: Easing.InOutSine
            }
        }
    ]

    ColumnLayout {
        width: parent.width
        enabled: !m_mobileOrientation
        visible: !m_mobileOrientation

        StatusPanel {
            showIcon: 'down.png'
            map: mapComponent
        }

        InfoPanel {
            id: infoDesk
            map: mapComponent
            enabled: mapComponent.selectedItem !== undefined && mapComponent.selectedItem.id !== 'undefined'
            visible: mapComponent.selectedItem !== undefined && mapComponent.selectedItem.id !== 'undefined'
            Layout.preferredHeight: sideInfo.height / 3 * m_ratio
        }
    }

    ColumnLayout {
        anchors.bottom: sideInfo.bottom
        width: parent.width
        enabled: m_mobileOrientation
        visible: m_mobileOrientation

        InfoPanel {
            id: infoMobile
            enabled: mapComponent.selectedItem !== undefined && mapComponent.selectedItem.id !== 'undefined'
            visible: mapComponent.selectedItem !== undefined && mapComponent.selectedItem.id !== 'undefined'
            map: mapComponent
            Layout.preferredHeight: sideInfo.height / 3
        }

        StatusPanel {
            showIcon: 'up.png'
            map: mapComponent
        }
    }
}
