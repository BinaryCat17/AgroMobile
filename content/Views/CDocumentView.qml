import QtQuick 6.2
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels
import '../Forms'
import '../Design'
import '../utils.js' as Utils

Item {
    id: root
    property var cAdditionalData
    property bool cCoreInitialized: cAdditionalData.initialized
    property var cDataManager: cAdditionalData.dataManager
    property var cConfig: cAdditionalData.config
    property var cWorkspace: cAdditionalData.workspace

    property var cDocumentMode: cWorkspace.cDocumentMode
    property var cActiveDocumentType: cWorkspace.cActiveDocumentType
    property var cActiveDocument: cWorkspace.cActiveDocument
    property var cMainHeaderForm: []
    property var cCustomHeaderForm: []
    property var cRecordsForm: []
    property var cTableModel
    property var cHeaderModel
    property var cRecordsModel
    property var cHeaders
    property var cRecordRows

    function updateLayout() {
        if(!cCoreInitialized) { return }
        if(cTableModel !== undefined && cTableModel !== null) {
            cTableModel.destroy()
        }
        if(cActiveDocumentType === '') {
            return
        }

        var document = cConfig.getDocumentType(cActiveDocumentType)

        if (cHeaderModel !== undefined && cRecordsModel !== null) { cHeaderModel.close() }
        cHeaderModel = cDataManager.listDocumentHeaders(cActiveDocumentType, cActiveDocument)

        if (cRecordsModel !== undefined && cRecordsModel !== null) { cRecordsModel.close() }
        cRecordsModel = cDataManager.listRecords(cActiveDocumentType, cActiveDocument)
        tableOverlayRepeater.model = cRecordsModel.cData

        // подготовка заголовков ------------------------------------------------------------------------------------------------------
        cHeaders = cConfig.getDocumentHeaders(document)

        var mainHeaders = []

        for (var i = 0; i < 5; ++i) {
            var mainHeader = cHeaders[i]
            if (mainHeader.visible && (cDocumentMode !== 'create' || (cDocumentMode === 'create' && mainHeader.mode === 'write'))) {
                mainHeaders.push({
                    'prop': { 'type': 'string', 'input': mainHeader.desc,
                              'mode': 'read', 'name': mainHeader.name },
                    'value': { 'type': mainHeader.type, 'input': cDocumentMode === 'create' ? '' : cHeaderModel.cData[i],
                               'mode': cDocumentMode === 'create' || (cDocumentMode === 'edit' && mainHeader.mode === 'write') ? 'write' : 'read'}
                })
            }
        }
        cMainHeaderForm = mainHeaders

        var customHeaders = []
        for (var k = 5; k < cHeaders.length; ++k) {
            var customHeader = cHeaders[k]
            if (customHeader.visible && (cDocumentMode !== 'create' || (cDocumentMode === 'create' && customHeader.mode === 'write'))) {
                customHeaders.push({
                    'prop': { 'type': 'string', 'input': customHeader.desc,
                              'mode': 'read', 'name': customHeader.name },
                    'value':{ 'type': customHeader.type, 'input': cDocumentMode === 'create' ? '' : cHeaderModel.cData[k],
                              'mode': cDocumentMode === 'create' || (cDocumentMode === 'edit' && customHeader.mode === 'write') ? 'write' : 'read' }
                })
            }
        }
        cCustomHeaderForm = customHeaders

        // подготовка таблиц ----------------------------------------------------------------------------------------------------------

        var tableModelCode = `
            import QtQuick 6.2
            import Qt.labs.qmlmodels
            TableModel { TableModelColumn { display: "index" }`

        var recordRow = {}
        cRecordRows = cConfig.getDocumentRecordRow(document)

        recordRow['index'] = { 'saved': true, 'type': 'string', 'input': 'Idx', 'mode': 'read'}
        for (var j = 2; j < cRecordRows.length; ++j) {
            var recordColumn = cRecordRows[j]
            recordRow[recordColumn.name] = { 'type': 'string', 'input': recordColumn.desc, 'mode': 'read'}
            tableModelCode += `\nTableModelColumn { display: "${recordColumn.name}" }`
        }
        tableModelCode += '}'
        cTableModel = Qt.createQmlObject(tableModelCode, root, 'dynamicModel')

        var recordsArr = [recordRow]
        for (var l = 0; l < cRecordsModel.cData.length; ++l) {
            var record = cRecordsModel.cData[l]

            recordRow = {}
            recordRow['index'] = { 'id': record[0], 'type': 'string', 'input': `${l + 1}`, 'mode': 'read'}
            for (var f = 2; f < cRecordRows.length; ++f) {
                recordRow[cRecordRows[f].name] = { 'type': 'string', 'input': record[f], 'mode': cDocumentMode === 'edit' ? 'write' : 'read'}
            }
            recordsArr.push(recordRow)
        }

        cTableModel.rows = recordsArr
        rowsTable.cModel = cTableModel
    }

    onCActiveDocumentTypeChanged: updateLayout()
    onCDocumentModeChanged: updateLayout()
    onCActiveDocumentChanged: updateLayout()

    Item {
        width: parent.width

        Item {
            id: topHeader
            width: parent.width
            height: 50 * m_ratio
            CHeader {
                id: titleHeader
                anchors.left: parent.left
                anchors.leftMargin: 15 * m_ratio

                function getTitle() {
                    if (cDocumentMode === 'view') {
                        return 'Просмотр документа'
                    } else if (cDocumentMode === 'create') {
                        return 'Создание документа'
                    } else if (cDocumentMode === 'edit') {
                        return 'Редактирование документа'
                    } else {
                        return 'Документ не выбран'
                    }
                }
                cText: getTitle()
                cTextWidth: 300 * m_ratio
                width: 300 * m_ratio
                height: 50 * m_ratio
            }

            RowLayout {
                anchors.right: parent.right

                CComboBox {
                    enabled: cWorkspace.cDocumentMode === 'view'
                    visible: cWorkspace.cDocumentMode === 'view'
                    width: 160 * m_ratio
                    height: 50 * m_ratio
                    cModel: ['Таблица', 'Карта']
                    cActivated: function(val) {
                        if(val === 'Таблица') {
                            cWorkspace.cViewType = 'table'
                        } else if(val === 'Карта') {
                            cWorkspace.cViewType = 'map'
                        }
                    }
                }

                CButton {
                    enabled: cWorkspace.cDocumentMode === 'view'
                    visible: cWorkspace.cDocumentMode === 'view'
                    cOpenedWidth: 160 * m_ratio
                    height: 50 * m_ratio
                    state: 'opened'
                    cIcon: 'edit.png'
                    cText: 'Изменить'

                    cOnClicked: function() {
                        cWorkspace.cDocumentMode = 'edit'
                    }
                }

                CButton {
                    enabled: cWorkspace.cDocumentMode === 'view'
                    visible: cWorkspace.cDocumentMode === 'view'
                    cOpenedWidth: 160 * m_ratio
                    height: 50 * m_ratio
                    state: 'opened'
                    cIcon: 'delete.png'
                    cText: 'Удалить'

                    cOnClicked: function() {
                        cDataManager.removeDocument(cActiveDocumentType, cActiveDocument)
                        cWorkspace.cActiveDocument = ''
                        cWorkspace.cDocumentMode = ''
                    }
                }

                CButton {
                    enabled: cWorkspace.cDocumentMode === 'create' || cWorkspace.cDocumentMode === 'edit'
                    visible: cWorkspace.cDocumentMode === 'create' || cWorkspace.cDocumentMode === 'edit'
                    cOpenedWidth: 160 * m_ratio
                    height: 50 * m_ratio
                    state: 'opened'
                    cIcon: 'cancel.png'
                    cText: 'Отменить'

                    cOnClicked: function() {
                        if (cWorkspace.cActiveDocument !== '') {
                            cWorkspace.cDocumentMode = 'view'
                        } else {
                            cWorkspace.cDocumentMode = ''
                        }
                    }
                }

                CButton {
                    enabled: cWorkspace.cDocumentMode === 'create' || cWorkspace.cDocumentMode === 'edit'
                    visible: cWorkspace.cDocumentMode === 'create' || cWorkspace.cDocumentMode === 'edit'
                    cOpenedWidth: 160 * m_ratio
                    height: 50 * m_ratio
                    state: 'opened'
                    cIcon: 'save.png'
                    cText: 'Сохранить'

                    cOnClicked: function() {
                        // save headers --------------------------------------------------------------------

                        var headerValues = {}
                        for (var j = 0; j < cHeaders.length; ++j) {
                            headerValues[cHeaders[j].name] = cHeaderModel.cData[j]
                        }

                        for (var i = 0; i < headersMainTable.cModel.rowCount; ++i) {
                            var obj = headersMainTable.cModel.getRow(i)
                            headerValues[obj.prop.name] = obj.value.input
                        }

                        if (cDocumentMode === 'create') {
                            headerValues['organization_id'] = 'Сальская Степь'
                            headerValues['id'] = Utils.generateUUID()
                            headerValues['created_at'] = Utils.timeNow()
                            headerValues['updated_at'] = Utils.timeNow()
                            cDataManager.createDocument(cActiveDocumentType, headerValues)
                        } else if (cDocumentMode === 'edit') {
                            headerValues['updated_at'] = Utils.timeNow()
                            cDataManager.updateDocument(cActiveDocumentType, headerValues)
                        }

                        // save records --------------------------------------------------------------------

                        for (var k = 1; k < cTableModel.rowCount; ++k) {
                            var row = cTableModel.getRow(k)

                            var savingRow = {}
                            var action = ''

                            for (var l = 2; l < cRecordRows.length; ++l) {
                                var record = cRecordRows[l]
                                var item = row[record.name]

                                if (!Utils.isWhitespaceString(item.input)) {
                                    savingRow[record.name] = item.input

                                    if ('deleted' in item && item.deleted) {
                                        action = 'delete'
                                    } else if('created' in item && item.created) {
                                        action = 'create'
                                    } else if ('saved' in item && item.saved === false) {
                                        action = 'update'
                                    }

                                } else {
                                    action = ''
                                    console.log('Can not save row with empty values')
                                    break
                                }
                            }

                            savingRow['doc_id'] = cActiveDocument
                            if (action === 'create') {
                                savingRow['id'] = Utils.generateUUID()
                                cDataManager.createRecord(cActiveDocumentType, cActiveDocument, savingRow)
                            } else if (action === 'update') {
                                savingRow['id'] = row['index'].id
                                cDataManager.updateRecord(cActiveDocumentType, cActiveDocument, savingRow)
                            } else if (action === 'delete') {
                                cDataManager.removeRecord(cActiveDocumentType, cActiveDocument, row['index'].id)
                            }
                        }

                        // back to view ------------------------------------------------------------------

                        cWorkspace.cDocumentMode = 'view'
                        cWorkspace.cActiveDocument = headerValues['id']

                    }
                }
            }
        }

        CHSeparator { id: sep; anchors.top: topHeader.bottom }

        Item {
            anchors.top: sep.bottom
            enabled: cWorkspace.cDocumentMode !== ''
            visible: cWorkspace.cDocumentMode !== ''
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
                    width: cContentWidth
                    height: cContentHeight

                    cColumnWidths: Array(cColumns).fill(250 * m_ratio)
                    cItemHeight: 50 * m_ratio

                    cModel: TableModel {
                        TableModelColumn { display: "prop" }
                        TableModelColumn { display: "value" }
                        rows: cMainHeaderForm
                    }
                }

                CTable {
                    id: headersCustomTable
                    width: cContentWidth
                    height: cContentHeight
                    anchors.leftMargin: 50 * m_ratio
                    anchors.left: headersMainTable.right

                    cColumnWidths: Array(cColumns).fill(250 * m_ratio)
                    cItemHeight: 50 * m_ratio

                    cModel: TableModel {
                        TableModelColumn { display: "prop" }
                        TableModelColumn { display: "value" }
                        rows: cCustomHeaderForm
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
                                    var itemCopy = JSON.parse(JSON.stringify(cTableModel.getRow(index + 1)))
                                    for (var it in itemCopy) {
                                        itemCopy[it].deleted = true
                                    }
                                    cTableModel.rows = cTableModel.rows.slice(0, index + 1).concat([itemCopy], cTableModel.rows.slice(index + 2, cTableModel.rowCount))
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
                        recordRow['index'] = { 'created': 'true', 'type': 'string', 'input': `${cTableModel.rowCount}`, 'mode': 'read'}

                        for (var j = 2; j < cRecordRows.length; ++j) {
                            var record = cRecordRows[j]
                            recordRow[record.name] = { 'created': 'true', 'saved': false, 'type': 'string', 'input': '', 'mode': 'write'}
                        }
                        cTableModel.rows = cTableModel.rows.concat([recordRow])
                    }
                }
            }
        }
    }
}
