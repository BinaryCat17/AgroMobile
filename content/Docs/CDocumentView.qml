import QtQuick 6.2
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels
import '../Forms'
import '../Design'

Item {
    id: root
    property var cAdditionalData
    property bool cCoreInitialized: cAdditionalData.initialized
    property var cDataManager: cAdditionalData.dataManager
    property var cConfig: cAdditionalData.config
    property var cWorkspace: cAdditionalData.workspace

    property var cState
    property var cDocumentMode: cWorkspace.cDocumentMode
    property var cTableModel

    function updateLayout() {
        if (cState.cHeaderForm === undefined) { return }

        headersMainTable.cModel.rows = cState.cHeaderForm.slice(0, 5)
        headersCustomTable.cModel.rows = cState.cHeaderForm.slice(5, cState.cHeaderForm.length)

        var tableModelCode = `
            import QtQuick 6.2
            import Qt.labs.qmlmodels
            TableModel { property var cAdditionalData; TableModelColumn { display: "index" }`

        for (var j = 0; j < cState.cRecordRows.length; ++j) {
            var recordColumn = cState.cRecordRows[j]
            tableModelCode += `\nTableModelColumn { display: "${recordColumn.prop}" }`
        }
        tableModelCode += '}'
        cTableModel = Qt.createQmlObject(tableModelCode, root, 'dynamicModel')
        cTableModel.cAdditionalData = root.cAdditionalData

        cTableModel.rows = cState.cRecordsForm.rows
        tableOverlayRepeater.model = cState.cRecordsForm.rows
        cState.cRecordsForm = cTableModel
        rowsTable.cModel = cTableModel


    }

    Item {
        id: headerView
        anchors.top: parent.top
        anchors.topMargin: 10 * m_ratio
        anchors.left: parent.left
        anchors.leftMargin: 10 * m_ratio
        width: Math.max(headersMainTable.cContentWidth, headersCustomTable.cContentWidth)
        height: Math.max(headersMainTable.cContentHeight, headersCustomTable.cContentHeight)

        CTable {
            id: headersMainTable
            cAdditionalData: root.cAdditionalData
            width: cContentWidth
            height: cContentHeight

            cColumnWidths: Array(cColumns).fill(250 * m_ratio)
            cItemHeight: 50 * m_ratio

            cModel: TableModel {
                TableModelColumn { display: "prop" }
                TableModelColumn { display: "value" }
            }
        }

        CTable {
            id: headersCustomTable
            cAdditionalData: root.cAdditionalData
            width: cContentWidth
            height: cContentHeight
            anchors.leftMargin: 50 * m_ratio
            anchors.left: headersMainTable.right

            cColumnWidths: Array(cColumns).fill(250 * m_ratio)
            cItemHeight: 50 * m_ratio

            cModel: TableModel {
                TableModelColumn { display: "prop" }
                TableModelColumn { display: "value" }
            }
        }
    }

    Item {
        id: rowsTableWrap
        visible: cDocumentMode !== 'create' && cDocumentMode !== ''
        enabled: cDocumentMode !== 'create' && cDocumentMode !== ''
        anchors.left: parent.left
        anchors.leftMargin: 10 * m_ratio
        anchors.top: headerView.bottom
        anchors.topMargin: 50 * m_ratio

        CTable {
            id: rowsTable
            cColumnWidths: cColumns > 0 ? [50 * m_ratio].concat(Array(cColumns - 1).fill(250 * m_ratio)) : []
            cItemHeight: 50 * m_ratio
            width: cContentWidth
            height: cContentHeight

            onCContentWidthChanged: rowsTableWrap.width = cContentWidth
            onCContentHeightChanged: rowsTableWrap.height = cContentHeight
        }

        ColumnLayout {
            id: tableOverlay
            z: -1
            anchors.top: rowsTable.top
            anchors.topMargin: 50 * m_ratio
            spacing: 0

            Repeater {
                id: tableOverlayRepeater

                Item {
                    width: rowsTable.width
                    height: 50 * m_ratio
                    property var cId: modelData[0]

                    MouseArea {
                        id: mouseArea
                        hoverEnabled: true
                        width: parent.width
                        height: parent.height
                    }

                    CButton {
                        id: delButton
                        anchors.left: parent.left
                        anchors.leftMargin: rowsTable.width
                        visible: cDocumentMode === 'edit' && (mouseArea.containsMouse || cHovered)
                        enabled: cDocumentMode === 'edit' && (mouseArea.containsMouse|| cHovered)
                        width: 50 * m_ratio
                        height: 50 * m_ratio
                        cIcon: 'delete.png'

                        cOnClicked: function() {
                            var itemCopy = JSON.parse(JSON.stringify(cState.cRecordsForm.rows[index + 1]))
                            for (var it in itemCopy) {
                                itemCopy[it].deleted = true
                            }
                            cState.cRecordsForm.rows = cState.cRecordsForm.rows.slice(0, index + 1)
                                .concat([itemCopy], cState.cRecordsForm.rows.slice(index + 2, cState.cRecordsForm.rows.length))
                        }
                    }
                }
            }
        }
    }

    Item {
        anchors.top: rowsTableWrap.bottom
        anchors.topMargin: 5 * m_ratio
        anchors.left: parent.left
        anchors.leftMargin: 10 * m_ratio
        width: rowsTable.width
        height: 50 * m_ratio

        CButton {
            id: createButton
            anchors.fill: parent
            enabled: cDocumentMode === 'edit'
            visible: cDocumentMode === 'edit'
            cIcon: 'add.png'
            cText: 'Создать запись'
            state: 'opened'

            cOnClicked: function() {
                var recordRow = {}
                recordRow['index'] = { 'created': 'true', 'type': 'string', 'input': `${cState.cRecordsForm.rows.length}`, 'mode': 'read'}

                for (var j = 0; j < cState.cRecordRows.length; ++j) {
                    var record = cState.cRecordRows[j]
                    recordRow[record.prop] = {
                        'created': 'true', 'saved': false, 'type': 'string', 'input':  '', 'mode': 'write'}
                }
                cState.cRecordsForm.rows = cState.cRecordsForm.rows.concat([recordRow])
            }
        }
    }
}
