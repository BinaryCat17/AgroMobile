import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Item {
    id: sideBar

    property int closeWidth: 105
    property int openWidth: 200

    width: closeWidth * m_ratio
    state: 'close'

    states: [
        State {
            name: 'open'

            PropertyChanges {
                target: sideBar
                width: openWidth * m_ratio
            }

            PropertyChanges {
                target: timer
                index: 0
            }
        },
        State {
            name: 'close'

            PropertyChanges {
                target: sideBar
                width: closeWidth * m_ratio
            }

            PropertyChanges {
                target: timer
                index: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: 'close'
            to: 'open'

            NumberAnimation {
                properties: 'width'
                duration: 300
                easing.type: Easing.OutCubic
            }

            ScriptAction {
                script: {
                    timer.start();
                }
            }
        },
        Transition {
            from: 'open'
            to: 'close'

            SequentialAnimation {

                ScriptAction {
                    script: {
                        timer.start();
                    }
                }

                PauseAnimation {
                    duration: 600
                }

                NumberAnimation {
                    properties: 'width'
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }
        }
    ]

    Timer {
        id: timer

        property int index: 0

        interval: 10

        onTriggered: {
            if (sideBar.state === 'open')
                columnItems.itemAt(index).state = 'left';
            else
                columnItems.itemAt(index).state = 'middle';

            if (++index !== columnItems.count)
                timer.start();
        }
    }

    ColumnLayout {
        id: buttonColumn
        width: parent.width
        spacing: 10 * m_ratio
        anchors.top: sideBar.top

        OpenButton {
            item: sideBar
            icon: 'Menu.svg'
        }

        Repeater {
            id: columnItems
            Layout.preferredWidth: 50 * m_ratio
            model: ['Search', 'Home', 'Explore']
            delegate: Rectangle {
                id: button
                Layout.preferredWidth: 50 * m_ratio
                Layout.preferredHeight: 50 * m_ratio
                radius: 10
                color: buttonMouseArea.containsMouse ? '#f0f0f0' : '#ffffff'
                Layout.alignment: Qt.AlignLeft
                state: 'middle'
                Behavior on color {
                    ColorAnimation {
                        duration: openWidth * m_ratio
                    }
                }
                states: [
                    State {
                        name: 'left'
                        PropertyChanges {
                            target: button
                            Layout.leftMargin: 10 * m_ratio
                            Layout.preferredWidth: openWidth * m_ratio
                        }
                        PropertyChanges {
                            target: title
                            opacity: 1
                        }
                    },
                    State {
                        name: 'middle'
                        PropertyChanges {
                            target: button
                            Layout.preferredWidth: 50 * m_ratio
                        }
                        PropertyChanges {
                            target: title
                            opacity: 0
                        }
                    }
                ]
                transitions: [
                    Transition {
                        from: 'middle'
                        to: 'left'
                        NumberAnimation {
                            properties: 'Layout.leftMargin, Layout.preferredWidth, opacity'
                            duration: 300
                            easing.type: Easing.InOutSine
                        }
                    },
                    Transition {
                        from: 'left'
                        to: 'middle'
                        NumberAnimation {
                            properties: 'Layout.leftMargin, Layout.preferredWidth, opacity'
                            duration: 300
                            easing.type: Easing.InOutSine
                        }
                    }
                ]
                MouseArea {
                    id: buttonMouseArea
                    hoverEnabled: true
                    anchors.fill: parent
                }
                Image {
                    id: icon
                    source: 'icons/' + modelData + '.svg'
                    sourceSize: Qt.size(30 * m_ratio, 30 * m_ratio)
                    anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10 * m_ratio }
                }
                CText {
                    id: title
                    text: modelData
                    anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 55 * m_ratio }
                }
            }
        }
    }
}
