import QtQuick 2.15
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

    TextInput {
        id: input
        onTextChanged: function() {
            cInputValue = text
        }

        verticalAlignment: TextInput.AlignVCenter
        readOnly: cMode === 'read'
        selectByMouse: true
        padding: 12
        height: 50 * m_ratio
        width: parent.width
        color: root.cTextColor
    }
}
