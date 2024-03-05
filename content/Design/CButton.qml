import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string cIcon
    property string cText // only for expanded state
    property bool cSelected: false
    property var cControlItem
    property var cOnClicked
    property color cSelectedColor: '#ffd89d'
    property color cSelectedHoveredColor: '#ffa216'
    property color cColor: '#ffffff'
    property color cHoveredColor: '#f0f0f0'

    Layout.preferredWidth: 50 * m_ratio
    Layout.preferredHeight: 50 * m_ratio
    radius: 10
    state: 'middle'

    function selectColor() {
        if(cSelected) {
            return menuMouseArea.containsMouse ? cSelectedHoveredColor : cSelectedColor
        } else {
            return menuMouseArea.containsMouse ? cHoveredColor : cColor
        }
    }

    color: selectColor()

    RowLayout {
        CIcon {
            id: icon
            height: root.height
            cIcon: root.cIcon
        }

        CText {
            id: title
            cText: root.cText
        }
    }

    MouseArea {
        id: menuMouseArea
        hoverEnabled: true
        anchors.fill: parent
        onClicked: {
            if (cControlItem !== undefined) {
                if (cControlItem.state === 'close')
                    cControlItem.state = 'open';
                else
                    cControlItem.state = 'close';
            }
            if (root.cOnClicked !== undefined) {
                root.cOnClicked()
            }
        }
    }

    // Button expanding -----------------------------------------------------------------------------------------------------

    states: [
        State {
            name: 'left'
            PropertyChanges {
                target: root
                Layout.leftMargin: 10 * m_ratio
                Layout.preferredWidth: 125 * m_ratio
            }
            PropertyChanges {
                target: title
                opacity: 1
            }
        },
        State {
            name: 'middle'
            PropertyChanges {
                target: root
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
}
