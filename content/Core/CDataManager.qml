import QtQuick 6.2
import '../utils.js' as Utils

Item {
    id: root
    property bool cInitialized: cDatabase.cInitialized && cConfig.cInitialized
    property var cDatabase
    property var cConfig
    property var cDocumentListeners: ({})
    property var cHeaderListeners: ({})
    property var cRecordsListeners: ({})

    // data --------------------------------------------------------------------------------------------------

    function updateDocumentListeners(type) {
        for (var i = 0; i < cDocumentListeners[type].length; ++i) {
            cDocumentListeners[type][i].update()
        }
    }

    function updateHeaderListeners(doc_id) {
        for (var i = 0; i < cHeaderListeners[doc_id].length; ++i) {
            cHeaderListeners[doc_id][i].update()
        }
    }

    function closeHeaderListeners(doc_id) {
        for (var i = 0; i < cHeaderListeners[doc_id].length; ++i) {
            cHeaderListeners[doc_id][i].close()
        }
    }

    function updateRecordsListeners(doc_id) {
        for (var i = 0; i < cRecordsListeners[doc_id].length; ++i) {
            cRecordsListeners[doc_id][i].update()
        }
    }

    function closeRecordsListeners(doc_id) {
        for (var i = 0; i < cRecordsListeners[doc_id].length; ++i) {
            cRecordsListeners[doc_id][i].close()
        }
    }

    function createDocument(type, header_values) {
        var headers = cConfig.getDocumentHeaders(cConfig.getDocumentType(type))
        var prep = cConfig.prepareDocumentProps(headers, header_values)
        cDatabase.transaction(function(tx) {
            cDatabase.insertInTable(tx, type + 'Documents', header_values.keys(), [prep])
        })
        updateDocumentListeners(type)
        updateHeaderListeners(header_values['id'])
    }

    function updateDocument(type, header_values) {
        var headers = cConfig.getDocumentHeaders(cConfig.getDocumentType(type))
        var prep = cConfig.prepareDocumentProps(headers, header_values)
        cDatabase.transaction(function(tx) {
            cDatabase.updateTable(tx, type + 'Documents', header_values.keys(), [prep])
        })
        updateDocumentListeners(type)
        updateHeaderListeners(header_values['id'])
    }

    function removeDocument(type, id) {
        cDatabase.transaction(function(tx) {
            cDatabase.removeFromTable(tx, type + 'Documents', [{"id": id}])
        })
        updateDocumentListeners(type)
        closeHeaderListeners(id)
        closeRecordsListeners(id)
    }

    function createRecord(type, doc_id, record_values) {
        var recordRow = cConfig.getDocumentRecordRow(cConfig.getDocumentType(type))
        var prep = cConfig.prepareDocumentProps(recordRow, record_values)
        record_values['doc_id'] = doc_id
        cDatabase.transaction(function(tx) {
            cDatabase.insertInTable(tx, type + 'Records', record_values.keys(), [prep])
        })
        updateRecordsListeners(doc_id)
    }

    function updateRecord(type, doc_id, record_values) {
        var recordRow = cConfig.getDocumentRecordRow(cConfig.getDocumentType(type))
        var prep = cConfig.prepareDocumentProps(recordRow, record_values)
        record_values['doc_id'] = doc_id
        cDatabase.transaction(function(tx) {
            cDatabase.updateTable(tx, type + 'Records', record_values.keys(), [prep])
        })
        updateRecordsListeners(doc_id)
    }

    function removeRecord(type, doc_id, id) {
        cDatabase.transaction(function(tx) {
            cDatabase.removeFromTable(tx, type + 'Records', [{"id": id}])
        })
        updateRecordsListeners(doc_id)
    }

    // queries -------------------------------------------------------------------------------------------------

    Component {
        id: documentListener

        ListModel {
            property string cType: ''

            signal updated()
            function update() {
                var keys = cConfig.listDocumentPropNames(getDocumentType(cType), 'headers')
                cDatabase.transaction(function(tx) {
                    cDatabase.getListFromTable(tx, type + 'Documents', keys, this)
                })
                updated()
           }

            signal closed()
            function close() {
                for (var i = 0; i < cDocumentListeners[cType].length; ++i) {
                    var listener = cDocumentListeners[cType][i]
                    if (listener === this) {
                        cDocumentListeners[cType][i].destroy()
                        cDocumentListeners[cType].splice(i, 1)
                       break
                    }
                }
                closed()
            }
        }
    }

    Component {
        id: headerListener

        ListModel {
            property string cType
            property string cDocId

            signal updated()
            function update() {
                var keys = cConfig.listDocumentPropNames(getDocumentType(cType), 'headers')
                cDatabase.transaction(function(tx) {
                    cDatabase.getItemFromTable(tx, type + 'Documents', keys, this, [cDatabase.filterEq('id', cDocId)])
                })
                updated()
            }

            signal closed()
            function close() {
                for (var i = 0; i < cHeaderListeners[cDocId].length; ++i) {
                    var listener = cHeaderListeners[cDocId]
                    if (listener === this) {
                        cHeaderListeners[cDocId][i].destroy()
                        cHeaderListeners[cDocId].splice(i, 1)
                        break
                    }
                }
                closed()
            }
        }
    }

    Component {
        id: recordsListener

        ListModel {
            property string cType: ''
            property string cDocId

            signal updated()
            function update() {
                var keys = cConfig.listDocumentPropNames(getDocumentType(cType), 'records')
                cDatabase.transaction(function(tx) {
                    cDatabase.getListFromTable(tx, type + 'Records', keys, this, [cDatabase.filterEq('doc_id', cDocId)])
                })
                updated()
            }

            signal closed()
            function close() {
                for (var i = 0; i < cRecordsListeners[cDocId].length; ++i) {
                    var listener = cRecordsListeners[cDocId][i]
                    if (listener === this) {
                       cRecordsListeners[cDocId][i].destroy()
                       cRecordsListeners[cType].splice(i, 1)
                       break
                    }
                }
                closed()
            }
        }
    }

    function listDocuments(type) {
        var model = documentListener.createObject(root, {cType: type})
        cDocumentListeners[type].push(model)
        model.update()
        return model
    }

    function listDocumentHeaders(type, doc_id) {
        var model = headerListener.createObject(root, {cType: type, cDocId: doc_id})
        cHeaderListeners[type].push(model)
        model.update()
        return model
    }

    function listRecords(type, doc_id) {
        var model = recordsListener.createObject(root, {cType: type, cDocId: doc_id})
        cRecordsListeners[type].push(model)
        model.update()
        return model
    }
}
