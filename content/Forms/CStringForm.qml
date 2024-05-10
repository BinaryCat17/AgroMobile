import QtQuick 2.15
import QtQuick.Layouts
import '../Design'

Item {
    property string cDesc: 'undefined'
    property string cInputValue: input.text

    RowLayout {

        CText {
            width: 130 * m_ratio
            cText: cDesc
        }

        TextInput {
            id: input
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
