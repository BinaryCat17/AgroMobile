import QtQuick 6.2
import QtQuick.Layouts
import '../Core'
import '../Design'
import '../utils.js' as Utils

Item {
    id: root
    property var cAdditionalData
    property bool cCoreInitialized: cAdditionalData.initialized
    property var cDataManager: cAdditionalData.dataManager
    property var cWorkspace: cAdditionalData.workspace
    property var cConfig: cAdditionalData.config

    property var cState
    property var cViewType: cWorkspace.cViewType
    property var cDocumentMode: cWorkspace.cDocumentMode
    property var cActiveDocument: cWorkspace.cActiveDocument
    property var cActiveDocumentType: cWorkspace.cActiveDocumentType
    property var cSelectType: cWorkspace.cSelectType

    property var cHeaderModel
    property var cRecordsModel

    function updateModels(state) {
        if (cActiveDocumentType === '' || cActiveDocument === '') { return }

        if (cHeaderModel !== undefined && cHeaderModel !== null) { cHeaderModel.close() }
        cHeaderModel = cDataManager.getHeaders(cActiveDocumentType, cActiveDocument)

        if (cRecordsModel !== undefined && cRecordsModel !== null) { cRecordsModel.close() }
        cRecordsModel = cDataManager.getRecords(cActiveDocumentType, cActiveDocument)
    }

    function updateData(state) {
        if (cActiveDocumentType === '' || cActiveDocument === '') { return }

        var document = cConfig.getViewType(cActiveDocumentType)
        state.cHeaders = cConfig.getViewProps(document, 'headers')

        // prepare headers

        var headers = []
        for (var i = 0; i < state.cHeaders.length; ++i) {
            var header = state.cHeaders[i]
            if (cDocumentMode !== 'create' || (cDocumentMode === 'create' && header.write)) {
                headers.push({
                    'prop': { 'type': 'string', 'input': header.desc,
                              'mode': 'read', 'name': header.prop },
                    'value': { 'type': header.type,
                               'input': cDocumentMode === 'create' ? '' : cHeaderModel.get(header.prop, 0),
                               'saved': cDocumentMode !== 'create',
                               'mode': cDocumentMode === 'create' || (cDocumentMode === 'edit' && header.write) ? 'write' : 'read'}
                })
            }
        }
        state.cHeaderForm = headers

        // preapre records

        var recordRow = {}
        state.cRecordRows = cConfig.getViewProps(document, 'records')
        recordRow['index'] = { 'saved': true, 'type': 'string', 'input': 'Idx', 'mode': 'read'}
        for (var j = 0; j < state.cRecordRows.length; ++j) {
            var recordColumn = state.cRecordRows[j]
            recordRow[recordColumn.name] = { 'type': 'string', 'input': recordColumn.desc, 'mode': 'read'}
        }

        var recordsArr = [recordRow]
        for (var l = 0; l < cRecordsModel.cData.length; ++l) {
            recordRow = {}
            recordRow['index'] = { 'id': cRecordsModel.get('id', l), 'type': 'string', 'input': `${l + 1}`, 'mode': 'read'}

            for (var f = 0; f < state.cRecordRows.length; ++f) {
                var viewRow = state.cRecordRows[f]
                recordRow[viewRow.name] = { 'type': 'string', 'input': cRecordsModel.get(viewRow.prop, l), 'mode': cDocumentMode === 'edit' ? 'write' : 'read'}
            }
            recordsArr.push(recordRow)
        }
        state.cRecordsForm = {'rows': recordsArr }
    }

    function saveDocument() {
        var headerValues = { 'id': cHeaderModel.get('id', 0)}

        for (var i = 0; i < cState.cHeaderForm.length; ++i) {
            var obj = cState.cHeaderForm[i]
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

        for (var k = 1; k < cState.cRecordsForm.rows.length; ++k) {
            var row = cState.cRecordsForm.rows[k]

            var savingRow = {}
            var action = ''

            for (var l = 0; l < cState.cRecordRows.length; ++l) {
                var record = cState.cRecordRows[l]
                var item = row[record.prop]
                if (!Utils.isWhitespaceString(item.input)) {
                    savingRow[record.prop] = item.input

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

        cWorkspace.cDocumentMode = 'view'
        cWorkspace.cActiveDocument = headerValues['id']
        updateData(cState)
        updateLayout()
    }

    function updateLayout() {
        cState = cSelectType !== '' ? cWorkspace.cSelectViewState : cWorkspace.cDocumentViewState

        if (cActiveDocument !== '' || cDocumentMode === 'create') {
            view.cActiveView = cViewType
            view.get(cViewType).cState = cState
            view.get(cViewType).updateLayout()
        } else {
            view.cActiveView = 'list'
        }
    }

    onCViewTypeChanged: updateLayout()
    onCActiveDocumentTypeChanged: updateLayout()
    onCDocumentModeChanged: updateLayout()

    onCActiveDocumentChanged: function() {
        updateModels(cWorkspace.cDocumentViewState)
        updateData(cWorkspace.cDocumentViewState)
        updateLayout()
    }

    onCSelectTypeChanged: function() {
        updateModels(cWorkspace.cSelectViewState)
        updateData(cWorkspace.cSelectViewState)
        updateLayout()
    }

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
                enabled: cActiveDocument !== '' && (cWorkspace.cDocumentMode === 'view')
                visible: cActiveDocument !== '' && (cWorkspace.cDocumentMode === 'view')
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
                enabled: cActiveDocument !== '' && (cWorkspace.cDocumentMode === 'view')
                visible: cActiveDocument !== '' && (cWorkspace.cDocumentMode === 'view')
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
                enabled: cActiveDocument !== '' && (cWorkspace.cDocumentMode === 'view')
                visible: cActiveDocument !== '' && (cWorkspace.cDocumentMode === 'view')
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
                    saveDocument()
                }
            }

            CButton {
                enabled: cActiveDocumentType !== '' && cActiveDocument === '' && cDocumentMode !== 'create'
                visible: cActiveDocumentType !== '' && cActiveDocument === ''&& cDocumentMode !== 'create'
                height: 50 * m_ratio
                cOpenedWidth: 230 * m_ratio
                radius: 0
                cIcon: 'add.png'
                cText: 'Создать документ'
                state: 'opened'

                cOnClicked: function() {
                    cWorkspace.cDocumentMode = 'create'
                }
            }
        }
    }

    CHSeparator { id: sep; anchors.top: topHeader.bottom }

    CView {
        id: view
        width: parent.width
        anchors.top: sep.bottom
        anchors.bottom: parent.bottom
        cAdditionalData: root.cAdditionalData
        cActiveView: 'table'

        cComponents: [
            {'name': 'table', 'component': 'Docs/CDocumentView'},
            {'name': 'map', 'component': 'Maps/CMapView'},
            {'name': 'list', 'component': 'Docs/CDocumentList'}
        ]
    }
}
