import QtQuick 6.2
import QtQuick.Layouts
import '../Design'

Item {
    id: root
    property var cAdditionalData
    property var cDataManager: cAdditionalData.dataManager
    property var cWorkspace: cAdditionalData.workspace

    ColumnLayout {
        id: documentList
        width: parent.width

        CHeader {
            width: parent.width
            height: 50 * m_ratio
            cText: 'Список документов'
        }

        CHSeparator {}

        Item {
            width: parent.width
            CButton {
                width: parent.width
                height: 50 * m_ratio
                cIcon: 'add.png'
                cText: 'Создать документ'
                state: 'opened'

                cOnClicked: function() {
                    cWorkspace.cDocumentMode = 'create'
                }
            }
        }
    }
}
