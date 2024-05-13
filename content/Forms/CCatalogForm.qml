import QtQuick 2.15
import QtQuick.Layouts
import '../Design'

Item {
    id: root
    property string cInputValue: 'uuid'
    property string cDesc: 'undefined'

    CText {
        width: 130 * m_ratio
        cText: cDesc
    }
}
