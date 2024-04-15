import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels

Item {
    id: root
    property var cColumns: [] // example [{name: 'icon.png', type: 'Menus/Menu'}]

    TableView {
        anchors.fill: parent
        columnSpacing: 1
        rowSpacing: 1
        boundsBehavior: Flickable.StopAtBounds

        model: TableModel {
            TableModelColumn { display: "checked" }
            TableModelColumn { display: "amount" }
            TableModelColumn { display: "fruitType" }
            TableModelColumn { display: "fruitName" }
            TableModelColumn { display: "fruitPrice" }

            // Each row is one type of fruit that can be ordered
            rows: [
                {
                    // Each property is one cell/column.
                    checked: false,
                    amount: 1,
                    fruitType: "Apple",
                    fruitName: "Granny Smith",
                    fruitPrice: 1.50
                },
                {
                    checked: true,
                    amount: 4,
                    fruitType: "Orange",
                    fruitName: "Navel",
                    fruitPrice: 2.50
                },
                {
                    checked: false,
                    amount: 1,
                    fruitType: "Banana",
                    fruitName: "Cavendish",
                    fruitPrice: 3.50
                }
            ]
        }
        delegate: DelegateChooser {
            DelegateChoice {
                column: 0
                delegate: CheckBox {
                    checked: model.display
                    onToggled: model.display = checked
                }
            }
            DelegateChoice {
                column: 1
                delegate: SpinBox {
                    value: model.display
                    onValueModified: model.display = value
                }
            }
            DelegateChoice {
                delegate: TextField {
                    text: model.display
                    selectByMouse: true
                    implicitWidth: 140
                    onAccepted: model.display = text
                }
            }
        }
    }
}
