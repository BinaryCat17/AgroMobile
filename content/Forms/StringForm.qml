import QtQuick 2.15
import QtQuick.Layouts
import '../Design'

Item {
    property string propName: 'undefined'
    property var inputValue: input.text

    RowLayout {
        anchors.left: inputPanel.left
        anchors.leftMargin: 10 * m_ratio
        height: inputPanel.height

        CText {
            width: 130 * m_ratio
            cText: propName
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
