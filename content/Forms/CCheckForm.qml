import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls
import '../Design'

Item {
    property string cDesc: ''
    property var cInputValue: checkBox.checked

    RowLayout {
        CText {
            width: 130 * m_ratio
            cText: cDesc
        }

        CheckBox {
            id: checkBox
            checked: false
        }
    }
}
