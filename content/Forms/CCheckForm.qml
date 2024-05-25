import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls
import '../Design'

Item {
    property var cAdditionalData
    property string cDesc: ''
    property var cSetValue
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
