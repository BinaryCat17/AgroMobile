import QtQuick
import QtQuick.Layouts
import '../Core'

Rectangle {
    id: root
    property var cAdditionalData

    property int cRows: tableView.rows
    property int cColumns: tableView.columns
    property string cCurrentSelectedMode
    property int cCurrentSelectedBaseColumnIndex: 0
    property int cCurrentSelectedBaseRowIndex: 0

    property var cColumnWidths: []
    property var cItemHeight
    property var cModel
    property color cColor: 'white'
    property color cTextColor: 'black'
    property color cBorderColor: 'black'

    signal formUpdated()

    function calcContentWidth() {
        var sum = 0
        for (var i = 0; i < cColumnWidths.length; ++i) {
            sum += cColumnWidths[i]
        }
        return sum
    }
    property real cContentWidth: calcContentWidth()
    property real cContentHeight: cItemHeight * cRows

    function updateLayout() {
        tableView.forceLayout()
    }

    Component {
        id: itemDelegate
        Item {
            implicitHeight: cItemHeight
            implicitWidth: 1

            Canvas{ //Create a canvas to draw the left vertical line of the rectangular box
                width: 1
                height: parent.height
                anchors.left: parent.left
                visible: column === 0
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.strokeStyle = cBorderColor;
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
                    ctx.strokeStyle = cBorderColor;
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
                    ctx.strokeStyle = cBorderColor;
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
                    ctx.strokeStyle = cBorderColor;
                    ctx.beginPath();
                    ctx.moveTo(0,0);
                    ctx.lineTo(0,height);
                    ctx.stroke();
                }
            }

            CFormSelector {
                id: selector
                cAdditionalData: root.cAdditionalData
                height: cItemHeight
                width: parent.width
                cType: display.type
                cMode:  display.mode
                cTextColor: root.cTextColor
                z: -1

                function selectColor() {
                    if ('deleted' in display && display.deleted) {
                        color = 'lightcoral'
                    }  else if ('saved' in display && !display.saved) {
                        color = 'lightYellow'
                    } else if (cMode === 'write') {
                        color = 'lightGreen'
                    }  else {
                        color = root.cColor
                    }
                }
                color: selectColor()

                Component.onCompleted: function() {
                    if(display.input !== undefined) {
                        cSetValue = JSON.parse(JSON.stringify(display.input))
                    }

                    selector.cCurrentSelectedMode = root.cCurrentSelectedMode
                    selector.cCurrentSelectedColumn = cCurrentSelectedBaseColumnIndex + column
                    selector.cCurrentSelectedRow = cCurrentSelectedBaseRowIndex + row
                }

                onCInputValueChanged: function() {
                    var index = tableView.model.index(row, column)
                    var item = tableView.model.data(index, 'display')
                    item['input'] = cInputValue

                    if (cSetValue !== '') {
                        if (cSetValue === cInputValue) {
                            if('saved' in display) {
                                item['saved'] = display.saved
                            }
                        } else {
                            item['saved'] = false
                        }
                    }

                    display = item
                    selectColor()
                    formUpdated()
                }
            }
        }
    }

    TableView {
        id: tableView
        columnWidthProvider: function (column) {return cColumnWidths[column] }
        width: cContentWidth
        height: cContentHeight
        interactive: false

        model: cModel
        delegate: itemDelegate
    }
}
