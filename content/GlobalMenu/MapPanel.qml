import QtQuick
import QtQuick.Layouts
import '../Design'

Item {
    id: root
    property real cWidth: 500 * m_ratio
    property real cHeight: 50 * m_ratio
    property var cAdditionalData
    property var cMap: cAdditionalData.map

    width: cWidth
    height: cHeight

    Item {
        anchors.fill: parent
        anchors.leftMargin: 10

        RowLayout {
            ColumnLayout {

                CButton {
                    cControlItem: hider
                    cIcon: 'add.png'
                }

                CHider {
                    id: hider
                    cControlItem: addButtons

                    ColumnLayout {
                        id: addButtons
                        opacity: 0

                        CButton {
                            cIcon: 'point.png'
                            cOnClicked: function() {
                                root.cMap.addGeoItem('Map/CircleItem')
                            }
                        }
                        CButton {
                            cIcon: 'polygon.png'
                            cOnClicked: function() {
                                root.cMap.addGeoItem('Map/PolygonItem')
                            }
                        }
                    }
                }
            }


            CButton {
                cIcon: 'edit.png'
                cOnClicked: function() {
                    root.cMap.editGeoItem()
                }
            }
            CButton {
                id: rmBut
                cIcon: 'delete.png'
                cOnClicked: function() {
                    root.cMap.removeGeoItem()
                }
            }
        }
    }
}
