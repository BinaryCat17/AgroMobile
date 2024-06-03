import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import '../Design'

Item {
    id: root
    property var cAdditionalData
    property var cSetValue
    property var cInputValue
    property color cTextColor: 'black'
    property string cMode: 'read'

    onCSetValueChanged: function() {
        input.text = cSetValue
    }

    ScrollView {
        height: 50 * m_ratio
        width: parent.width

        Item {
            width: root.width
            height: 50 * m_ratio

            Flickable {
                contentWidth: input.contentWidth
                width: parent.width - 20 * m_ratio
                height: parent.height

                TextInput {
                    id: input
                    onTextChanged: function() {
                        cInputValue = text
                    }

                    autoScroll: false
                    verticalAlignment: TextInput.AlignVCenter
                    readOnly: cMode === 'read'
                    selectByMouse: true
                    padding: 12
                    height: 50 * m_ratio
                    width: Math.max(contentWidth, root.width)
                    color: root.cTextColor
                }
            }
        }
    }
}
