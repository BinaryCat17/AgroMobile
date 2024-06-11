import QtQuick 6.2
import QtQuick.Layouts
import '../Core'
import '../Design'
import '../utils.js' as Utils

Rectangle {
    id: root
    property var cAdditionalData
    property bool cCoreInitialized: cAdditionalData.initialized
    property var cDataManager: cAdditionalData.dataManager
    property var cWorkspace: cAdditionalData.workspace
    property var cConfig: cAdditionalData.config
    color: cConfig.colors('background')

    property var cViewType: cWorkspace.cViewType
    property var cDocumentMode: cWorkspace.cDocumentMode
    property string cCurrentDocument: ''
    property string cCurrentDocumentType: ''

    property var cState
    property var cHeaderModel
    property var cRecordsModel

    Component.onCompleted: function() {
        cWorkspace.onCActiveDocumentTypeChanged.connect(prepareState)
        cWorkspace.onCActiveDocumentChanged.connect(prepareState)
        cWorkspace.onCSelectDocumentTypeChanged.connect(prepareState)
        cWorkspace.onCSelectDocumentChanged.connect(prepareState)
    }

    onCCurrentDocumentTypeChanged: function() {
        cHeaderModel = undefined
        cRecordsModel = undefined
        updateLayout()
    }

    onCDocumentModeChanged: function() {
        if (cState !== undefined) {
            if(cState.cHeaderForm !== undefined && view.get(cViewType).cHeaderForm !== undefined) {
                cState.cHeaderForm.rows = view.get(cViewType).cHeaderForm.rows
            }
            if(cState.cRecordsForm !== undefined && view.get(cViewType).cRecordsForm !== undefined) {
                cState.cRecordsForm.rows = view.get(cViewType).cRecordsForm.rows
            }
        }

        if (cDocumentMode !== '' && prepareState() && (cState.cHeaderForm === undefined || cDocumentMode === 'view')) {
            updateData(cState)
        }

        if ((cDocumentMode === 'edit' || cDocumentMode === 'create')) {
            if(cWorkspace.cCurrentSelectedItem !== undefined) {
                updateSelected()
            }
        }

        updateLayout()
    }

    onCCurrentDocumentChanged: function() {
        if (prepareState() && (cDocumentMode === 'view' || cDocumentMode === 'select')) {
            updateData(cState)
        }
        updateLayout()
    }

    onCViewTypeChanged: updateLayout()

    function prepareState() {
        if (!cCoreInitialized) { return false }

        if (cDocumentMode === 'select') {
            cState = cWorkspace.cSelectViewState
            cCurrentDocumentType = cWorkspace.cSelectDocumentType
            cCurrentDocument = cWorkspace.cSelectDocument
            if (cWorkspace.cSelectDocumentType === '' || cWorkspace.cSelectDocument === '') { return false }
        } else {
            cState = cWorkspace.cDocumentViewState
            cCurrentDocumentType = cWorkspace.cActiveDocumentType
            cCurrentDocument = cWorkspace.cActiveDocument
            if (cWorkspace.cActiveDocumentType === '' || (cWorkspace.cActiveDocument === '' && cDocumentMode !== 'create' && cDocumentMode !== '')) { return false }
        }

        var document = cConfig.getViewType(cCurrentDocumentType)
        cState.cHeaders = cConfig.getViewProps(document, 'headers')
        cState.cRecordRows = cConfig.getViewProps(document, 'records')

        if (cCurrentDocument !== '' && cDocumentMode !== 'create') {
            if (cHeaderModel !== undefined && cHeaderModel !== null) { cHeaderModel.close() }
            cHeaderModel = cDataManager.getHeaders(cCurrentDocumentType, cCurrentDocument)

            if (cRecordsModel !== undefined && cRecordsModel !== null) { cRecordsModel.close() }
            cRecordsModel = cDataManager.getRecords(cCurrentDocumentType, cCurrentDocument)
        }

        return true
    }

    function updateSelected() {
        var row = cState.cRecordRows[Number.parseInt(cWorkspace.cCurrentSelectedColumn) - 1]
        if (cWorkspace.cCurrentSelectedMode === 'headers') {
            var headerItem = cState.cHeaderForm.rows[cWorkspace.cCurrentSelectedRow]['value']
            headerItem['id'] = cWorkspace.cCurrentSelectedItem['index'].id

            headerItem['input'] = cWorkspace.cCurrentSelectedItem[row['select']['prop']].input

        } else if (cWorkspace.cCurrentSelectedMode === 'records') {
            var recordsItem = cState.cRecordsForm.rows[cWorkspace.cCurrentSelectedRow][row.name]
            recordsItem['id'] = cWorkspace.cCurrentSelectedItem['index'].id
            recordsItem['input'] = cWorkspace.cCurrentSelectedItem[row['select']['prop']].input
            recordsItem['saved'] = false

        }
        //cWorkspace.cCurrentSelectedItem = undefined
        cWorkspace.cCurrentSelectedMode = ''
        cWorkspace.cCurrentSelectedRow = ''
        cWorkspace.cCurrentSelectedColumn = ''
    }

    function updateComboBox() {
        var model = ['Таблица']
        if (cState.cRecordRows === undefined) { return }
        for (var i = 0; i < cState.cRecordRows.length; ++i) {
            if (cState.cRecordRows[i].name === 'shape') {
                model = model.concat(['Карта'])
                break
            }
        }
        comboBox.cModel = model

        if (cViewType === 'table') {
            comboBox.select(0)
        } else if (cViewType === 'map') {
            comboBox.select(1)
        }
    }

    function updateLayout() {
        if (cState !== undefined && (cWorkspace.cActiveDocument !== '' || cDocumentMode === 'create' || cDocumentMode === 'select')) {
            view.cActiveView = cViewType
            updateComboBox()
            view.get(cViewType).cRecordRows = cState.cRecordRows
            view.get(cViewType).cHeaderForm = cState.cHeaderForm
            view.get(cViewType).cRecordsForm = cState.cRecordsForm
            view.get(cViewType).updateLayout()
        } else {
            view.cActiveView = 'list'
        }
    }

    function updateData() {
        // prepare headers -----------------------------------------------------------------------------------------------------------
        var headers = []
        for (var i = 0; i < cState.cHeaders.length; ++i) {
            var header = cState.cHeaders[i]
            if (cDocumentMode !== 'create' || (cDocumentMode === 'create' && header.write)) {
                var prop = {
                    'prop': {
                        'type': 'string',
                        'input': header.desc,
                        'mode': 'read',
                        'name': header.prop
                    },
                    'value': {
                        'type': header.type, 'saved': cDocumentMode !== 'create',
                        'input': cDocumentMode === 'create' ? '' : cHeaderModel.get(header.name, 0),
                        'mode': (cDocumentMode === 'create' || cDocumentMode === 'edit') && header.write ? 'write' : 'read',
                        'id': cDocumentMode === 'create' ? '' : cHeaderModel.get(header.prop, 0)
                    }
                }
                headers.push(prop)
            }
        }
        cState.cHeaderForm = {'rows': headers}
        view.get(cViewType).cHeaderForm = cState.cHeaderForm

        // prepare records -----------------------------------------------------------------------------------------------------------
        if (cDocumentMode !== 'create') {
            var recordRow = {}
            recordRow['index'] = { 'saved': true, 'type': 'string', 'input': 'Idx', 'mode': 'read'}
            for (var j = 0; j < cState.cRecordRows.length; ++j) {
                var recordColumn = cState.cRecordRows[j]
                recordRow[recordColumn.name] = { 'type': 'string', 'input': recordColumn.desc, 'mode': 'read'}
            }

            var recordsArr = [recordRow]
            for (var l = 0; l < cRecordsModel.cData.length; ++l) {
                recordRow = {
                    'index': { 'id': cRecordsModel.get('id', l), 'type': 'string', 'input': `${l + 1}`, 'mode': 'read'}
                }

                for (var f = 0; f < cState.cRecordRows.length; ++f) {
                    var viewRow = cState.cRecordRows[f]
                    recordRow[viewRow.name] = {
                        'type': viewRow.type,
                        'input': cRecordsModel.get(viewRow.name, l),
                        'mode': cDocumentMode === 'edit' && viewRow.write ? 'write' : 'read',
                        'id': cRecordsModel.get(viewRow.prop, l)}
                }
                recordsArr.push(recordRow)
            }
            cState.cRecordsForm = {'rows': recordsArr }
            view.get(cViewType).cRecordRows = cState.cRecordRows
            view.get(cViewType).cRecordsForm = cState.cRecordsForm
        }
    }

    function saveDocument() {
        var headerValues = {}
        cState.cHeaderForm = view.get(cViewType).cHeaderForm
        cState.cRecordsForm = view.get(cViewType).cRecordsForm

        // получаем значения документов из основной модели
        if (cHeaderModel !== undefined && cHeaderModel !== null) {
            var props = cConfig.getDataProps(cConfig.getDataType(cCurrentDocumentType), 'headers')

            for (var j = 0; j < props.length; ++j) {
                headerValues[cHeaderModel.cKeys[j]] = cHeaderModel.get(props[j].name, 0)
            }
        }

        // записываем пользовательские значения
        for (var i = 0; i < cState.cHeaderForm.rows.length; ++i) {
            var obj = cState.cHeaderForm.rows[i]
            if (Utils.isUpperCase(obj.value.type[0])) {
                headerValues[obj.prop.name] = obj.value.id
            } else {
                headerValues[obj.prop.name] = obj.value.input
            }
        }

        if (cDocumentMode === 'create') {
            headerValues['organization_id'] = 'Сальская Степь'
            headerValues['id'] = Utils.generateUUID()
            headerValues['created_at'] = Utils.timeNow()
            headerValues['updated_at'] = Utils.timeNow()
            cDataManager.createDocument(cCurrentDocumentType, headerValues)
        } else if (cDocumentMode === 'edit') {
            headerValues['updated_at'] = Utils.timeNow()
            cDataManager.updateDocument(cCurrentDocumentType, headerValues)
        }

        // save records --------------------------------------------------------------------

        for (var k = 1; cDocumentMode !== 'create' && k < cState.cRecordsForm.rows.length; ++k) {
                var row = cState.cRecordsForm.rows[k]

            var savingRow = {}
            var action = ''
            var isEmpty = false

            for (var l = 0; l < cState.cRecordRows.length; ++l) {
                var record = cState.cRecordRows[l]
                var item = row[record.name]
                if (!Utils.isWhitespaceString(item.input)) {
                    if (!(record.prop in savingRow) || ((record.prop in savingRow) && item.mode === 'write')) {
                        if (Utils.isUpperCase(item.type[0])) {
                            savingRow[record.prop] = item.id
                        } else {
                            savingRow[record.prop] = item.input
                        }

                        if ('deleted' in item && item.deleted) {
                            action = 'delete'
                            isEmpty = true
                        } else if('created' in item && item.created) {
                            action = 'create'
                        } else if('saved' in item && !item.saved) {
                            action = 'update'
                        }
                    }

                } else {
                    action = ''
                    if (record.write) {
                        console.log('Can not save row with empty values')
                        isEmpty = true
                        break
                    }
                }
            }

            if (row === cWorkspace.cCurrentSelectedItem && isEmpty) {
                cWorkspace.cCurrentSelectedItem = undefined
            }

            savingRow['doc_id'] = cCurrentDocument
            if (action === 'create') {
                savingRow['id'] = Utils.generateUUID()
                if(!cDataManager.createRecord(cCurrentDocumentType, cCurrentDocument, savingRow)) {
                    if (row === cWorkspace.cCurrentSelectedItem) {
                        cWorkspace.cCurrentSelectedItem = undefined
                    }
                }
            } else if (action === 'update') {
                savingRow['id'] = row['index'].id
                cDataManager.updateRecord(cCurrentDocumentType, cCurrentDocument, savingRow)
            } else if (action === 'delete') {
                cDataManager.removeRecord(cCurrentDocumentType, cCurrentDocument, row['index'].id)
            }
        }

        cWorkspace.cActiveDocument = headerValues['id']
        cWorkspace.cDocumentMode = 'view'
        cWorkspace.cDrawMode = false
    }

    Rectangle {
        id: topHeader
        width: parent.width
        height: 50 * m_ratio

        color: cConfig.colors('background')

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
                } else if (cDocumentMode === 'select') {
                    return 'Выбор записи'
                } else {
                    return 'Документ не выбран'
                }
            }
            cColor: cConfig.colors('primaryText')
            cText: getTitle()
            cTextWidth: 300 * m_ratio
            width: 300 * m_ratio
            height: 50 * m_ratio
        }

        RowLayout {
            anchors.right: parent.right

            CComboBox {
                id: comboBox
                enabled: cCurrentDocument !== '' && (cWorkspace.cDocumentMode === 'view')
                visible: cCurrentDocument !== '' && (cWorkspace.cDocumentMode === 'view')
                width: 160 * m_ratio
                height: 50 * m_ratio
                cColor: cConfig.colors('background')
                cTextColor: cConfig.colors('primaryText')
                cBorderColor: cConfig.colors('border')
                cActivated: function(val) {
                    if(val === 'Таблица') {
                        cWorkspace.cViewType = 'table'
                        view.cActiveView = 'table'
                    } else if(val === 'Карта') {
                        cWorkspace.cViewType = 'map'
                        view.cActiveView = 'map'
                    }
                }
            }

            CButton {
                enabled: cCurrentDocument !== '' && (cWorkspace.cDocumentMode === 'view')
                visible: cCurrentDocument !== '' && (cWorkspace.cDocumentMode === 'view')
                cOpenedWidth: 160 * m_ratio
                height: 50 * m_ratio
                state: 'opened'
                cIcon: 'edit.png'
                cText: 'Изменить'
                cColor: cConfig.colors('background')
                cIconColor: cConfig.colors('icon')
                cTextColor: cConfig.colors('primaryText')

                cOnClicked: function() {
                    cWorkspace.cDocumentMode = 'edit'
                    prepareState()
                    updateData()
                    updateLayout()
                }
            }

            CButton {
                enabled: cCurrentDocument !== '' && (cWorkspace.cDocumentMode === 'view')
                visible: cCurrentDocument !== '' && (cWorkspace.cDocumentMode === 'view')
                cOpenedWidth: 160 * m_ratio
                height: 50 * m_ratio
                state: 'opened'
                cIcon: 'delete.png'
                cText: 'Удалить'
                cColor: cConfig.colors('background')
                cIconColor: cConfig.colors('icon')
                cTextColor: cConfig.colors('primaryText')

                cOnClicked: function() {
                    cDataManager.removeDocument(cCurrentDocumentType, cCurrentDocument)
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
                cIcon: 'save.png'
                cText: 'Сохранить'
                cColor: cConfig.colors('background')
                cIconColor: cConfig.colors('icon')
                cTextColor: cConfig.colors('primaryText')

                cOnClicked: function() {
                    saveDocument()
                }
            }

            CButton {
                enabled: cCurrentDocumentType !== '' && cWorkspace.cActiveDocument === '' && cDocumentMode !== 'create' && cDocumentMode !== 'select'
                visible: cCurrentDocumentType !== '' && cWorkspace.cActiveDocument === '' && cDocumentMode !== 'create' && cDocumentMode !== 'select'
                height: 50 * m_ratio
                cOpenedWidth: 230 * m_ratio
                radius: 0
                cIcon: 'add.png'
                cText: 'Создать документ'
                state: 'opened'
                cColor: cConfig.colors('background')
                cIconColor: cConfig.colors('icon')
                cTextColor: cConfig.colors('primaryText')

                cOnClicked: function() {
                    cWorkspace.cDocumentMode = 'create'
                    prepareState()
                    updateData(cState)
                    updateLayout()
                }
            }
        }
    }

    CHSeparator { id: sep; anchors.top: topHeader.bottom; color: config.colors('border') }

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
