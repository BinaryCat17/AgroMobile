pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

Item {
    id: root
    property var cModel
    property var cActivated
    property color cColor: 'transparent'
    property color cTextColor: 'black'
    property color cBorderColor: 'black'

    function select(index) {
        control.currentIndex = index
    }

    ComboBox {
        id: control
        anchors.fill: parent
        model: cModel

        onActivated: function(index) {
            cActivated(cModel[index])
        }

        delegate: ItemDelegate {
            id: delegate

            required property var model
            required property int index

            width: control.width
            contentItem: Text {
                text: delegate.model[control.textRole]
                color: cTextColor
                font: control.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            highlighted: control.highlightedIndex === index
        }

        indicator: Canvas {
            id: canvas
            x: control.width - width - control.rightPadding
            y: control.topPadding + (control.availableHeight - height) / 2
            width: 12
            height: 8
            contextType: "2d"

            Connections {
                target: control
                function onPressedChanged() { canvas.requestPaint(); }
            }

            onPaint: {
                context.reset();
                context.moveTo(0, 0);
                context.lineTo(width, 0);
                context.lineTo(width / 2, height);
                context.closePath();
                context.fillStyle = cBorderColor
                context.fill();
            }
        }

        contentItem: Text {
            leftPadding: 10
            rightPadding: control.indicator.width + control.spacing

            text: control.displayText
            font: control.font
            color: cTextColor
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 120
            implicitHeight: 40
            color: cColor
            border.color: cBorderColor
            border.width: control.visualFocus ? 2 : 1
            radius: 2
        }

        popup: Popup {
            y: control.height - 1
            width: control.width
            implicitHeight: contentItem.implicitHeight
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: control.popup.visible ? control.delegateModel : null
                currentIndex: control.highlightedIndex

                ScrollIndicator.vertical: ScrollIndicator { }
            }

            background: Rectangle {
                color: cColor
                border.color: cBorderColor
                radius: 2
            }
        }
    }
}
