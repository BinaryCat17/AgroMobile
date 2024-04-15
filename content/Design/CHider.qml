import QtQuick

Item {
    id: root
    property var cControlItem
    property int cOpenHeight: 0
    property int cOpenWidth: 0
    property bool cAnimateOpacity: true
    property bool cAnimateWidth: false
    property bool cAnimateHeight: false

    height: cControlItem.height
    width: cControlItem.width

    Item {
        id: empty
    }

    state: 'close'

    states: [
        State {
            name: 'open'

        },
        State {
            name: 'close'
        }
    ]

    transitions: [
        Transition {
            from: 'close'
            to: 'open'

            NumberAnimation {
                target: cAnimateOpacity ? cControlItem : empty
                properties: 'opacity'
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: cAnimateWidth ? cControlItem : empty
                properties: 'width'
                from: 0
                to: cOpenWidth
                duration: 300
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: cAnimateHeight ? cControlItem : empty
                properties: 'height'
                from: 0
                to: cOpenHeight
                duration: 300
                easing.type: Easing.InOutSine
            }
        },
        Transition {
            from: 'open'
            to: 'close'

            NumberAnimation {
                target: cAnimateOpacity ? cControlItem : empty
                properties: 'opacity'
                from: 1
                to: 0
                duration: 300
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: cAnimateWidth ? cControlItem : empty
                properties: 'width'
                from: cOpenWidth
                to: 0
                duration: 300
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: cAnimateHeight ? cControlItem : empty
                properties: 'height'
                from: cOpenHeight
                to: 0
                duration: 300
                easing.type: Easing.InOutSine
            }
       }
    ]
}
