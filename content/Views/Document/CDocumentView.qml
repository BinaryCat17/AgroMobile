import QtQuick 6.2
import QtQuick.Layouts
import '../../Forms'

Item {
    id: root
    property real cOpenWidth: 500 * m_ratio
    property real cOpenHeight: 800 * m_ratio
    property var cAdditionalData
    property var cDataManager: cAdditionalData.dataManager
    property var cActiveDocumentType: cDataManager.cActiveDocumentType
    property var cForm
    property var cValues

    onCActiveDocumentTypeChanged: function() {
        if(cActiveDocumentType === undefined) { return }

        var document = cDataManager.getDocumentType(cActiveDocumentType)
        cForm = cDataManager.getDocumentHeaders(document)
    }

    ColumnLayout {
        Repeater {
            id: repeater
            model: cForm

            CFormSelector {
                property var cModelName: modelData.name
                property var cModelDesc: modelData.desc
                property var cModelType: modelData.type

                cDesc: cModelDesc
                cType: cModelType
            }
        }
    }
}
