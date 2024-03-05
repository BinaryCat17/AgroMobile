import QtQuick
import '../Design'

Rectangle {
    id: root
    property real cWidth: 500 * m_ratio
    property real cHeight: 200 * m_ratio
    property var cAdditionalData

    width: cWidth
    height: cHeight
    radius: cAdditionalData.stackRadius

    CText {
        cText: 'Time'
    }
}
