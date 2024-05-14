import QtQuick 6.2
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels
import '../../Forms'
import '../../Design'

Item {
    id: root
    property var cAdditionalData
    property bool cCoreInitialized: cAdditionalData.initialized
    property var cDataManager: cAdditionalData.dataManager
    property var cConfig: cAdditionalData.config
    property var cWorkspace: cAdditionalData.workspace

    property var cDocumentMode: cWorkspace.cDocumentMode
    property var cActiveDocumentType: cWorkspace.cActiveDocumentType
    property var cTableModel
    property var cMainHeaderForm: []
    property var cCustomHeaderForm: []
    property var cRecordsForm: []

    function updateLayout() {
            if(!cCoreInitialized || cActiveDocumentType === '') { return }
            if (cTableModel !== undefined) {
                cTableModel.destroy()
            }

            var document = cConfig.getDocumentType(cActiveDocumentType)

            // подготовка заголовков
            var headers = cConfig.getDocumentHeaders(document)

            var mainHeaders = []
            var numHeaders = 1
            if (cDocumentMode === 'view') {
                numHeaders = 4
            }

            for (var i = 1; i < 1 + numHeaders; ++i) {
                var mainHeader = headers[i]
                mainHeaders.push({
                    'prop': { 'type': 'string', 'input': mainHeader.desc, 'mode': 'read' },
                    'value': { 'type': mainHeader.type, 'input': 'empty', 'mode': 'write' }
                })
            }
            cMainHeaderForm = mainHeaders

            var customHeaders = []
            for (var k = 5; k < headers.length; ++k) {
                var customHeader = headers[k]
                customHeaders.push({
                    'prop': { 'type': 'string', 'input': customHeader.desc, 'mode': 'read' },
                    'value': { 'type': customHeader.type, 'input': 'empty', 'mode': 'write' }
                })
            }
            cCustomHeaderForm = customHeaders

            // подготовка таблицы

            var tableModelCode = `
                import QtQuick 6.2
                import Qt.labs.qmlmodels
                TableModel { `

            var recordRow = {}
            var records = cConfig.getDocumentRecordRow(document)

            for (var j = 2; j < records.length; ++j) {
                var record = records[j]
                recordRow[record.name] = { 'type': 'string', 'input': record.desc, 'mode': 'read'}
                tableModelCode += `\nTableModelColumn { display: "${record.name}" }`
            }
            tableModelCode += '}'

            var recordsArr = [recordRow]

            if(cTableModel !== undefined) {
                cTableModel.destroy()
            }

            cTableModel = Qt.createQmlObject(tableModelCode, root, 'dynamicModel')
            cTableModel.rows = recordsArr
            rowsTable.cModel = cTableModel
        }

    onCActiveDocumentTypeChanged: updateLayout()
    onCDocumentModeChanged: updateLayout()

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width
            CHeader {
                function getTitle() {
                    if (cDocumentMode === 'view') {
                        return 'Просмотр документа'
                    } else if (cDocumentMode === 'create') {
                        return 'Создание документа'
                    } else if (cDocumentMode === 'edit') {
                        return 'Редактирование документа'
                    } else {
                        return 'Undefined'
                    }
                }

                cTextWidth: 200 * m_ratio
                width: 200 * m_ratio
                height: 50 * m_ratio
                cText: getTitle()
            }

            CButton {
                Layout.alignment: Qt.AlignRight
                cOpenedWidth: 180 * m_ratio
                height: 50 * m_ratio
                state: 'opened'
                cIcon: 'save.png'
                cText: 'Сохранить'
            }
        }

        CHSeparator {}

        Item {
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

                    cItemWidth: 200 * m_ratio
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

                    cItemWidth: 200 * m_ratio
                    cItemHeight: 50 * m_ratio

                    cModel: TableModel {
                        TableModelColumn { display: "prop" }
                        TableModelColumn { display: "value" }
                        rows: cCustomHeaderForm
                    }
                }
            }

            CTable {
                id: rowsTable
                visible: cDocumentMode !== 'create'
                enabled: cDocumentMode !== 'create'
                anchors.left: parent.left
                anchors.leftMargin: 10 * m_ratio
                anchors.top: headerView.bottom
                anchors.topMargin: 50 * m_ratio
                cItemWidth: 200 * m_ratio
                cItemHeight: 50 * m_ratio
            }
        }
    }
}
