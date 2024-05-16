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
        if (!(type in cDocumentListeners)) { return }
        for (var i = 0; i < cDocumentListeners[type].length; ++i) {
            cDocumentListeners[type][i].update()
        }
    }

    function updateHeaderListeners(doc_id) {
        if (!(doc_id in cHeaderListeners)) { return }
        for (var i = 0; i < cHeaderListeners[doc_id].length; ++i) {
            cHeaderListeners[doc_id][i].update()
        }
    }

    function closeHeaderListeners(doc_id) {
        if (!(doc_id in cHeaderListeners)) { return }
        for (var i = 0; i < cHeaderListeners[doc_id].length; ++i) {
            cHeaderListeners[doc_id][i].close()
        }
    }

    function updateRecordsListeners(doc_id) {
        if (!(doc_id in cRecordsListeners)) { return }
        for (var i = 0; i < cRecordsListeners[doc_id].length; ++i) {
            cRecordsListeners[doc_id][i].update()
        }
    }

    function closeRecordsListeners(doc_id) {
        if (!(doc_id in cRecordsListeners)) { return }
        for (var i = 0; i < cRecordsListeners[doc_id].length; ++i) {
            cRecordsListeners[doc_id][i].close()
        }
    }

    function createDocument(type, header_values) {
        var headers = cConfig.getDocumentHeaders(cConfig.getDocumentType(type))
        var prep = cConfig.prepareDocumentProps(headers, header_values)
        cDatabase.transaction(function(tx) {
            cDatabase.insertInTable(tx, type + 'Documents', Object.keys(header_values), [prep])
        })
        updateDocumentListeners(type)
        updateHeaderListeners(header_values['id'])
    }

    function updateDocument(type, header_values) {
        var headers = cConfig.getDocumentHeaders(cConfig.getDocumentType(type))
        var prep = cConfig.prepareDocumentProps(headers, header_values)
        cDatabase.transaction(function(tx) {
            cDatabase.updateTable(tx, type + 'Documents', Object.keys(header_values), [prep])
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
        record_values['doc_id'] = doc_id
        var prep = cConfig.prepareDocumentProps(recordRow, record_values)
        cDatabase.transaction(function(tx) {
            cDatabase.insertInTable(tx, type + 'Records', Object.keys(record_values), [prep])
        })
        updateRecordsListeners(doc_id)
    }

    function updateRecord(type, doc_id, record_values) {
        var recordRow = cConfig.getDocumentRecordRow(cConfig.getDocumentType(type))
        record_values['doc_id'] = doc_id
        var prep = cConfig.prepareDocumentProps(recordRow, record_values)
        cDatabase.transaction(function(tx) {
            cDatabase.updateTable(tx, type + 'Records', Object.keys(record_values), [prep])
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

        Item {
            property string cType: ''
            property var cKeys: []
            property var cData: []

            function clear() {
                cData = []
            }

            signal updated()

            function update() {
                cKeys = cConfig.listDocumentPropNames(cConfig.getDocumentType(cType), 'headers')
                cDatabase.transaction(function(tx) {
                    cDatabase.getListFromTable(tx, cType + 'Documents', cKeys, cData)
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

        Item {
            property string cType
            property string cDocId
            property var cData: []
            property var cKeys: []

            function clear() {
                cData = []
            }

            signal updated()
            function update() {
                cKeys = cConfig.listDocumentPropNames(cConfig.getDocumentType(cType), 'headers')
                cDatabase.transaction(function(tx) {
                    cDatabase.getItemFromTable(tx, cType + 'Documents', cKeys, cData, [cDatabase.filterEq('id', cDocId)])
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

        Item {
            property string cType: ''
            property string cDocId
            property var cData: []
            property var cKeys: []


            function clear() {
                cData = []
            }

            signal updated()
            function update() {
                cKeys = cConfig.listDocumentPropNames(cConfig.getDocumentType(cType), 'records')
                cDatabase.transaction(function(tx) {

                    cDatabase.getListFromTable(tx, cType + 'Records', cKeys, cData, [cDatabase.filterEq('doc_id', cDocId)])
                })
                updated()
            }

            signal closed()
            function close() {
                for (var i = 0; i < cRecordsListeners[cDocId].length; ++i) {
                    var listener = cRecordsListeners[cDocId][i]
                    if (listener === this) {
                       cRecordsListeners[cDocId][i].destroy()
                       cRecordsListeners[cDocId].splice(i, 1)
                       break
                    }
                }
                closed()
            }
        }
    }

    function listDocuments(type) {
        var model = documentListener.createObject(root, {cType: type})
        if (!(type in cDocumentListeners)) {
            cDocumentListeners[type] = []
        }

        cDocumentListeners[type].push(model)
        model.update()
        return model
    }

    function listDocumentHeaders(type, doc_id) {
        if (!(doc_id in cDocumentListeners)) {
            cHeaderListeners[doc_id] = []
        }

        var model = headerListener.createObject(root, {cType: type, cDocId: doc_id})
        cHeaderListeners[doc_id].push(model)
        model.update()
        return model
    }

    function listRecords(type, doc_id) {
        if (!(doc_id in cDocumentListeners)) {
            cRecordsListeners[doc_id] = []
        }

        var model = recordsListener.createObject(root, {cType: type, cDocId: doc_id})
        cRecordsListeners[doc_id].push(model)
        model.update()
        return model
    }
}
