import QtQuick 2.15
import QtQuick.Layouts
import '../Design'

Item {
    property string cDesc: 'undefined'

    RowLayout {

        CText {
            width: 200 * m_ratio
            cText: cDesc
        }
    }
}
