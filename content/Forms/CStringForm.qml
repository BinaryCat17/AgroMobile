import QtQuick 2.15
import QtQuick.Layouts
import '../Design'

Item {
    property var cInputValue: input.text
    property string cMode: 'read'

    TextInput {
        id: input
        verticalAlignment: TextInput.AlignVCenter
        readOnly: cMode === 'read'
        text: cInputValue
        selectByMouse: true
        padding: 12
        height: 50 * m_ratio
    }
}
