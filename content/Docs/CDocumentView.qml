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

    property var cRecordRows
    property var cHeaderForm
    property var cRecordsForm
    property var cDocumentMode: cWorkspace.cDocumentMode
    property var cTableModel

    Item {
        id: headerRowsWrapper

        function calcRows() {
            rows = headersMainTable.cModel.rows.concat(headersCustomTable.cModel.rows)
        }

        property var rows
    }

    function updateLayout() {
        if (cDocumentMode === 'select' && cWorkspace.cSelectDocument === '') {
            headersMainTable.cModel.rows = []
            headersCustomTable.cModel.rows = []
            if (cTableModel !== undefined) {
                cTableModel.rows = []
            }
            return
        }

        if (cHeaderForm === undefined || cHeaderForm.rows === undefined) { return }

        var numSlice = 4
        if (cDocumentMode === 'create') {
            numSlice = 100
        }

        headersMainTable.cModel.rows = cHeaderForm.rows.slice(0, numSlice)
        headersCustomTable.cModel.rows = cHeaderForm.rows.slice(numSlice, cHeaderForm.rows.length)

        if (cRecordRows !== undefined && cDocumentMode !== 'create') {
            var tableModelCode = `
                import QtQuick 6.2
                import Qt.labs.qmlmodels
                TableModel { property var cAdditionalData; TableModelColumn { display: "index" }`

            for (var j = 0; j < cRecordRows.length; ++j) {
                var recordColumn = cRecordRows[j]
                tableModelCode += `\nTableModelColumn { display: "${recordColumn.prop}" }`
            }
            tableModelCode += '}'
            cTableModel = Qt.createQmlObject(tableModelCode, root, 'dynamicModel')
            cTableModel.cAdditionalData = root.cAdditionalData

            cTableModel.rows = cRecordsForm.rows
            tableOverlayRepeater.model = cRecordsForm.rows.slice(0, cRecordsForm.rows.length - 1)
            cRecordsForm = cTableModel
            rowsTable.cModel = cTableModel
        }

        cHeaderForm = headerRowsWrapper
        cRecordsForm = cTableModel
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
            cColor: cConfig.colors('accent')
            cTextColor: cConfig.colors('primaryText')
            cBorderColor: cConfig.colors('border')

            onFormUpdated: headerRowsWrapper.calcRows()

            cColumnWidths: Array(cColumns).fill(250 * m_ratio)
            cItemHeight: 50 * m_ratio

            cCurrentSelectedMode: 'headers'

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
            cColor: cConfig.colors('accent')
            cTextColor: cConfig.colors('primaryText')
            cBorderColor: cConfig.colors('border')

            onFormUpdated: headerRowsWrapper.calcRows()

            cColumnWidths: Array(cColumns).fill(250 * m_ratio)
            cItemHeight: 50 * m_ratio

            cCurrentSelectedMode: 'headers'
            cCurrentSelectedBaseRowIndex: cDocumentMode === 'edit' ? 4 : 0

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
            cColor: cConfig.colors('accent')
            cTextColor: cConfig.colors('primaryText')
            cBorderColor: cConfig.colors('border')

            cCurrentSelectedMode: 'records'

            onCContentWidthChanged: rowsTableWrap.width = cContentWidth
            onCContentHeightChanged: rowsTableWrap.height = cContentHeight
        }

        ColumnLayout {
            id: tableOverlay
            anchors.left: rowsTable.left
            anchors.top: rowsTable.top
            anchors.topMargin: 50 * m_ratio
            spacing: 0

            Repeater {
                id: tableOverlayRepeater

                Item {
                    width: rowsTable.width
                    height: 50 * m_ratio
                    property var cId: modelData[0]

                    HoverHandler {
                        id: mouseArea
                    }

                    Rectangle {
                        id: overlay
                        visible: rowsTable.cRows > 0
                        enabled: rowsTable.cRows > 0
                        height: 50 * m_ratio
                        width: 50 * m_ratio
                        opacity: 10
                        color: mouseArea.hovered ? cConfig.colors('overlay') : 'transparent'
                    }

                    CButton {
                        id: delButton
                        anchors.left: parent.left
                        anchors.leftMargin: rowsTable.width
                        visible: cDocumentMode === 'edit' && (mouseArea.hovered || cHovered)
                        enabled: cDocumentMode === 'edit' && (mouseArea.hovered|| cHovered)
                        width: 50 * m_ratio
                        height: 50 * m_ratio
                        cIcon: 'delete.png'
                        cColor: cConfig.colors('background')
                        cIconColor: cConfig.colors('icon')

                        cOnClicked: function() {
                            var itemCopy = JSON.parse(JSON.stringify(cRecordsForm.rows[index + 1]))
                            for (var it in itemCopy) {
                                itemCopy[it].deleted = true
                            }
                            cRecordsForm.rows = cRecordsForm.rows.slice(0, index + 1)
                                .concat([itemCopy], cRecordsForm.rows.slice(index + 2, cRecordsForm.rows.length))
                        }
                    }

                    CButton {
                        id: selectButton
                        anchors.left: parent.left
                        anchors.leftMargin: rowsTable.width
                        visible: cDocumentMode === 'select' && (mouseArea.hovered || cHovered)
                        enabled: cDocumentMode === 'select' && (mouseArea.hovered|| cHovered)
                        width: 50 * m_ratio
                        height: 50 * m_ratio
                        cIcon: 'select.png'
                        cColor: cConfig.colors('background')
                        cIconColor: cConfig.colors('icon')

                        cOnClicked: function() {
                            cWorkspace.cCurrentSelectedItem = cRecordsForm.rows[index + 1]
                            cWorkspace.cSelectDocument = ''

                            if (cWorkspace.cActiveDocument === '') {
                                cWorkspace.cDocumentMode = 'create'
                            } else {
                                cWorkspace.cDocumentMode = 'edit'
                            }
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
                recordRow['index'] = { 'created': 'true', 'type': 'string', 'input': `${cRecordsForm.rows.length}`, 'mode': 'read'}

                for (var j = 0; j < cRecordRows.length; ++j) {
                    var record = cRecordRows[j]
                    recordRow[record.prop] = {
                        'created': 'true', 'saved': false, 'type': 'string', 'input':  '', 'mode': 'write'}
                }
                cRecordsForm.rows = cRecordsForm.rows.concat([recordRow])
            }
        }
    }
}
