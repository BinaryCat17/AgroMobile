import QtQuick 6.2
import QtQuick.Layouts
import Qt.labs.qmlmodels
import "../Forms"
import '../Design'
import '../Core'
import '../utils.js' as Utils

Item {
    id: root
    property real cOpenWidth: 300 * m_ratio
    property real cOpenHeight: table.height + (cDocumentMode === 'edit' ? 50 * m_ratio : 0)
    property var cAdditionalData
    property bool cCoreInitialized: cAdditionalData.initialized
    property var cDataManager: cAdditionalData.dataManager
    property var cWorkspace: cAdditionalData.workspace
    property var cDocumentMode: cWorkspace.cDocumentMode
    property var cCurrentSelectedItem: cWorkspace.cCurrentSelectedItem
    property bool cDrawMode: cWorkspace.cDrawMode
    property var cRecordRows
    property var cRecordsForm

    function updateLayout() {
        if (!cCoreInitialized || cRecordRows === undefined) { return }
        if (cCurrentSelectedItem === undefined) {
            table.cModel.rows = []
            return
        }

        var tableRows = []
        for (var j = 0; j < cRecordRows.length; ++j) {
            var record = cRecordRows[j]
            tableRows.push({
                'prop': { 'prop': record.prop, 'type': 'string', 'input': record.desc, 'mode': 'read'},
                'value': cCurrentSelectedItem[record.prop]
            })
        }
        table.cModel.rows = tableRows
    }

    onCCurrentSelectedItemChanged: function() {
        updateLayout()
    }

    CTable {
        id: table
        cAdditionalData: root.cAdditionalData
        width: cContentWidth
        height: cContentHeight
        cColor: cConfig.colors('accent')
        cTextColor: cConfig.colors('primaryText')
        cBorderColor: cConfig.colors('border')

        cColumnWidths: [100 * m_ratio, parent.width - 100 * m_ratio]
        cItemHeight: 50 * m_ratio

        onFormUpdated: function() {
            for (var i = 0; i < cRecordsForm.rows.length; ++i) {
                var row = cRecordsForm.rows[i]
                if (row === cCurrentSelectedItem) {
                    for (var k = 0; k < table.cModel.rows.length; ++k) {
                        var tableRow = table.cModel.rows[k]
                        row[tableRow.prop.prop].input = tableRow.value.input
                        row[tableRow.prop.prop].saved = false
                        cCurrentSelectedItem[tableRow.prop.prop].input = tableRow.value.input
                        cCurrentSelectedItem[tableRow.prop.prop].saved = false
                    }
                    break
                }
            }
        }

        cModel: TableModel {
            TableModelColumn { display: "prop" }
            TableModelColumn { display: "value" }
        }
    }

    Item {
        width: parent.width
        height: 50 * m_ratio
        anchors.top: table.bottom

        CButton {
            id: createButton
            anchors.right: parent.right
            enabled: cDocumentMode === 'edit' && !cDrawMode
            visible: cDocumentMode === 'edit' && !cDrawMode
            width: cDrawMode ? 0 : 50 * m_ratio
            height: 50 * m_ratio
            cIcon: 'add.png'
            cColor: cConfig.colors('background')
            cIconColor: cConfig.colors('icon')
            cTextColor: cConfig.colors('primaryText')

            cOnClicked: function() {
                var recordRow = {}
                recordRow['index'] = { 'created': 'true', 'type': 'string', 'input': `${cRecordsForm.rows.length}`, 'mode': 'read'}

                for (var j = 0; j < cRecordRows.length; ++j) {
                    var record = cRecordRows[j]
                    recordRow[record.prop] = {
                        'created': 'true', 'saved': false, 'type': record.type, 'input':  '', 'mode': 'write'}
                }
                cRecordsForm.rows = cRecordsForm.rows.concat([recordRow])
                cWorkspace.cCurrentSelectedItem = cRecordsForm.rows[cRecordsForm.rows.length - 1]
                cWorkspace.cTappedPoly = cRecordsForm.rows.length - 1
                cWorkspace.cDrawMode = true
            }
        }

        CButton {
            id: drawButton
            anchors.right: createButton.left
            enabled: cDocumentMode === 'edit' && cCurrentSelectedItem !== undefined
            visible: cDocumentMode === 'edit' && cCurrentSelectedItem !== undefined
            height: 50 * m_ratio
            width: 50 * m_ratio
            cIcon: cDrawMode ? 'apply.png' : 'draw.png'
            cColor: cConfig.colors('background')
            cIconColor: cConfig.colors('icon')
            cTextColor: cConfig.colors('primaryText')

            cOnClicked: function() {
                if (!cWorkspace.cDrawMode) {
                    cWorkspace.cDrawMode = true
                } else {
                    cWorkspace.cDrawMode = false
                }
            }
        }

        CButton {
            id: deleteButton
            anchors.right: drawButton.left
            enabled: cDocumentMode === 'edit' && !cDrawMode && cCurrentSelectedItem !== undefined
            visible: cDocumentMode === 'edit' && !cDrawMode && cCurrentSelectedItem !== undefined
            height: 50 * m_ratio
            width: 50 * m_ratio
            cIcon: 'delete.png'
            cColor: cConfig.colors('background')
            cIconColor: cConfig.colors('icon')
            cTextColor: cConfig.colors('primaryText')

            cOnClicked: function() {
                var itemCopy = JSON.parse(JSON.stringify(cRecordsForm.rows[cWorkspace.cTappedPoly]))
                for (var it in itemCopy) {
                    itemCopy[it].deleted = true
                }
                cRecordsForm.rows = cRecordsForm.rows.slice(0, cWorkspace.cTappedPoly)
                    .concat([itemCopy], cRecordsForm.rows.slice(cWorkspace.cTappedPoly + 1, cRecordsForm.rows.length))
                cWorkspace.cTappedPoly = -1
            }
        }
    }
}
