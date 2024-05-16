import QtQuick 2.15
import QtQuick.Layouts
import '../Design'

Item {
    id: root
    property var cInputValue
    property var cSetValue

    CText {
        width: 130 * m_ratio
        cText: 'None'
    }
}
