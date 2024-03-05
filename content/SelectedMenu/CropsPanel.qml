import QtQuick
import QtQuick.Layouts
import '../Design'

Rectangle {
    id: root
    property var cAdditionalData
    property real cWidth: 200 * m_ratio
    property real cHeight: 100 * m_ratio

    width: cWidth
    height: cHeight
    radius: cAdditionalData.stackRadius

    CText {
        cText: 'Crops'
    }
}
