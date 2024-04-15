import QtQuick
import QtQuick.Layouts
import '../Design'
import '../Forms'
import '../utils.js' as Utils

Rectangle {
    id: root
    property real cWidth: 500 * m_ratio
    property real cHeight: 200 * m_ratio
    property var cAdditionalData
    property var cDatabase: cAdditionalData.map.database

    width: cWidth
    height: cHeight
    radius: cAdditionalData.stackRadius

    onCDatabaseChanged: function() {
        cDatabase.transaction(function(tx){
            cDatabase.getFromCatalog(tx, 'WorkYears', workYearsModel)
        })
    }

    ListModel {
        id: workYearsModel
    }

    Component {
        id: workYearDelegate

        RowLayout {
            spacing: 10
            CText { cText: name }
        }
    }

    Item {
        anchors.fill: parent

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
                    id: addWorkYearHider
                    cControlItem: saveWorkYearButton

                    CButton {
                        id: saveWorkYearButton
                        height: 50 * m_ratio
                        width: 50 * m_ratio
                        cIcon: 'save.png'
                        opacity: 0

                        cOnClicked: function() {
                            var record = { id: Utils.generateUUID(), name: workYearInput.text }
                            cDatabase.transaction(function(tx) {
                                cDatabase.insertInCatalog(tx, 'WorkYears',  [record])
                            });
                            addWorkYearHider.state = 'close'
                            newWorkYearHider.state = 'close'
                            workYearsModel.append(record)
                        }
                    }
                }

                CButton {
                    cIcon: 'add.png'
                    cOnClicked: function() {
                        if(addWorkYearHider.state === 'open') {
                            addWorkYearHider.state = 'close'
                            newWorkYearHider.state = 'close'
                        } else if(addWorkYearHider.state === 'close') {
                            addWorkYearHider.state = 'open'
                            newWorkYearHider.state = 'open'
                        }
                    }
                }
            }
        }

        CHider {
            id: newWorkYearHider
            anchors.top: addPanel.bottom
            cControlItem: newWorkYearPanel
            cAnimateHeight: true
            width: root.width
            cOpenHeight: 50 * m_ratio

            Rectangle {
                id: newWorkYearPanel
                width: root.width
                opacity: 0
                border.color: "#efefef"

                RowLayout {
                    anchors.left:  newWorkYearPanel.left
                    anchors.leftMargin: 10 * m_ratio
                    height: parent.height

                    CText {
                        id: workYearText
                        width: 130 * m_ratio
                        cText: 'Наименование:'
                    }

                    TextInput {
                        id: workYearInput
                        selectByMouse: true
                        padding: 12
                        height: 50 * m_ratio

                        Rectangle {
                            anchors.fill: parent
                            color: "#efefef"
                            z: -1
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.top: newWorkYearHider.bottom

            width: root.width
            height: 300 * m_ratio

            ListView {
                anchors.fill: parent
                model: workYearsModel
                delegate: workYearDelegate
            }
        }
    }
}
