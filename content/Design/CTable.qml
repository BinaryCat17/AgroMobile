import QtQuick
import QtQuick.Layouts
import '../Core'
import '../Forms'

Item {
    id: root

    property int cRows: tableView.rows
    property int cColumns: tableView.columns
    property real cContentWidth: cItemWidth * cColumns
    property real cContentHeight: cItemHeight * cRows

    property var cItemWidth
    property var cItemHeight
    property var cModel

    Component {
        id: itemDelegate
        Item {
            implicitWidth: cItemWidth
            implicitHeight: cItemHeight

            Canvas{ //Create a canvas to draw the left vertical line of the rectangular box
                width: 1
                height: parent.height
                anchors.left: parent.left
                visible: column === 0
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.beginPath();
                    ctx.moveTo(0,0);
                    ctx.lineTo(0,height);
                    ctx.stroke();
                }
            }

            Canvas{ //Create a canvas to draw the top horizontal line of the rectangular box
                width: parent.width
                height: 1
                anchors.top: parent.top
                visible: row === 0
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.beginPath();
                    ctx.moveTo(0,0);
                    ctx.lineTo(width, 0);
                    ctx.stroke();
                }
            }

            Canvas{ //Draw the bottom line of the rectangle, each item must be drawn
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.beginPath();
                    ctx.moveTo(0,0);
                    ctx.lineTo(width,0);
                    ctx.stroke();
                }
            }

            Canvas{ //Draw a vertical line on the right side of the rectangle, each item must be drawn
                width: 1
                height: parent.height
                anchors.right: parent.right
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.beginPath();
                    ctx.moveTo(0,0);
                    ctx.lineTo(0,height);
                    ctx.stroke();
                }
            }

            CFormSelector {
                cInputValue: display.input
                cType: display.type
                cMode:  display.mode
            }
        }
    }

    TableView {
        id: tableView
        width: cContentWidth
        height: cContentHeight
        interactive: false

        model: cModel
        delegate: itemDelegate
    }
}
