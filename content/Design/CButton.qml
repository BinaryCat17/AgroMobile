import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string cIcon
    property string cText // only for expanded state
    property bool cSelected: false
    property var cControlItem
    property var cOnClicked
    property color cIconColor: 'black'
    property color cSelectedColor: '#ffd89d'
    property color cSelectedHoveredColor: cSelectedColor.darker(1.1)
    property color cColor: '#ffffff'
    property color cHoveredColor: cColor.darker(1.1)
    property color cTextColor: 'black'
    property real cOpenedWidth: 125 * m_ratio
    property real cOpenedMargin: 0
    property bool cHovered: hoverHandler.hovered
    property int cContentWidth: title.cContentWidth + 50 * m_ratio

    radius: 10
    state: 'closed'

    function selectColor() {
        if(cSelected) {
            return cHovered? cSelectedHoveredColor : cSelectedColor
        } else {
            return cHovered ? cHoveredColor : cColor
        }
    }

    color: selectColor()

    RowLayout {
        CIcon {
            id: icon
            height: root.height
            cIcon: root.cIcon
            cColor: root.cIconColor
        }

        CText {
            id: title
            cText: root.cText
            cColor: root.cTextColor
        }
    }

    HoverHandler {
        id: hoverHandler
    }

    MouseArea {
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
            name: 'opened'
            PropertyChanges {
                target: root
                Layout.leftMargin: cOpenedMargin
                Layout.preferredWidth: cOpenedWidth
            }
            PropertyChanges {
                target: title
                opacity: 1
            }
        },
        State {
            name: 'closed'
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
            from: 'closed'
            to: 'opened'
            NumberAnimation {
                properties: 'Layout.leftMargin, Layout.preferredWidth, opacity'
                duration: 300
                easing.type: Easing.InOutSine
            }
        },
        Transition {
            from: 'closed'
            to: 'opened'
            NumberAnimation {
                properties: 'Layout.leftMargin, Layout.preferredWidth, opacity'
                duration: 300
                easing.type: Easing.InOutSine
            }
        }
    ]
}
