import QtQuick 2.15
import QtQuick.Layouts
import '../Design'

Item {
    id: root
    property var cAdditionalData
    property string cTableName
    property string cFormName
    property var cFormModel // example [{name: 'Имя', 'propName': 'name', type: 'String', model: componentItem}]
    property var cForms: ({})

    onCAdditionalDataChanged: function() {
        for (var item in cForms) {
            if('cAdditionalData' in cForms[item].item) {
                cForms[item].item.cAdditionalData = root.cAdditionalData
            }
        }
    }

    Item {
        id: addPanel
        width: root.width
        height: 50 * m_ratio

        CText {
            height: 50 * m_ratio
            cText: 'Каталог'
            cVAlignment: Text.AlignVCenter
            x: 10 * m_ratio
        }

        RowLayout {
            anchors.right: parent.right
            Layout.preferredHeight: 50 * m_ratio

            CHider {
                id: addHider
                cControlItem: saveButton

                CButton {
                    id: saveButton
                    height: 50 * m_ratio
                    width: 50 * m_ratio
                    cIcon: 'save.png'
                    opacity: 0

                    cOnClicked: function() {
                        var record = { id: Utils.generateUUID() }

                        for (var name in CForms) {
                            var form = cForms[propName];
                            record[form['propName']] = form['item'].inputValue
                        }

                        cDatabase.transaction(function(tx) {
                            cDatabase.insertInTable(tx, cTableName,  [record])
                        });

                        addHider.state = 'close'
                        newHider.state = 'close'
                        workYearsModel.append(record)
                    }
                }
            }

            CButton {
                cIcon: 'add.png'
                cOnClicked: function() {
                    if(newHider.state === 'open') {
                        addHider.state = 'close'
                        newHider.state = 'close'
                    } else if(newHider.state === 'close') {
                        addHider.state = 'open'
                        newHider.state = 'open'
                    }
                }
            }
        }
    }

    CHider {
        id: newHider
        anchors.top: addPanel.bottom
        cControlItem: inputPanel
        cAnimateHeight: true
        width: root.width
        cOpenHeight: 50 * m_ratio

        Rectangle {
            id: inputPanel
            border.color: "#efefef"

            Component.onCompleted: function () {
                for (var i = 0; i < root.cFormModel.length; ++i) {
                    var item = root.cFormModel[i]
                    var type = item['type']

                    var co = undefined
                    var componentItem = undefined
                    var path = 'undefined'

                    if (type === 'String') {
                        path = '/qt/qml/content/Forms/StringForm.qml'
                    } else if (type.startsWith('Catalog/')) {
                        path = '/qt/qml/content/Forms/CatalogForm.qml'
                    }

                    co = Qt.createComponent(path)
                    componentItem = co.createObject(propColumn)

                    if (co.status === Component.Ready) {
                        if ('cAdditionalData' in componentItem) {
                            componentItem.cAdditionalData = root.cAdditionalData
                        }

                        cForms[item['name']] = {index: i, item: componentItem, propName: item['propName']}

                        if (type.startsWith('Catalog/')) {
                            componentItem.cCatalog = type.split('/')[1]
                        }
                    } else {
                        console.log(type + " is not supported right now, please call us later.")
                    }
                }
            }

            ColumnLayout {
                id: propColumn
                anchors.fill: parent
            }
        }
    }
}
