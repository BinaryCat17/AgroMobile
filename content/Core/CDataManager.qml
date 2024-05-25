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
        var headers = cConfig.getViewProps(cConfig.getViewType(type), 'headers')
        var prep = cConfig.prepareViewProps(headers, header_values)
        prep['id'] = header_values['id']

        cDatabase.transaction(function(tx) {
            cDatabase.insertInTable(tx, type + 'Documents', Object.keys(header_values), [prep])
        })
        updateDocumentListeners(type)
        updateHeaderListeners(header_values['id'])
    }

    function updateDocument(type, header_values) {
        var headers = cConfig.getViewProps(cConfig.getViewType(type), 'headers')
        var prep = cConfig.prepareViewProps(headers, header_values)
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
        var recordRow = cConfig.getViewProps(cConfig.getViewType(type), 'records')
        var prep = cConfig.prepareViewProps(recordRow, record_values)
        prep['id'] = record_values['id']
        prep['doc_id'] = doc_id
        cDatabase.transaction(function(tx) {
            cDatabase.insertInTable(tx, type + 'Records', Object.keys(prep), [prep])
        })
        updateRecordsListeners(doc_id)
    }

    function updateRecord(type, doc_id, record_values) {
        var recordRow = cConfig.getViewProps(cConfig.getViewType(type), 'records')
        record_values['doc_id'] = doc_id
        var prep = cConfig.prepareViewProps(recordRow, record_values)
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

    function prepareViewPropNames(dataProps, viewProps) {
        var props = []

        for (var j = 0; j < dataProps.length; ++j) {
            props.push(dataProps[j].name)
        }

        for (var i = 0; i < viewProps.length; ++i) {
            if(props.indexOf(viewProps[i]['prop']) < 0) {
                props.push(viewProps[i]['prop'])
            }
        }
        return props
    }

    function prepareViewPropKeys(dataProps, viewProps) {
        var keys = []

        for (var j = 0; j < dataProps.length; ++j) {
            keys.push(dataProps[j].name)
        }

        for (var i = 0; i < viewProps.length; ++i) {
            var propName = ''
            if ('name' in viewProps[i]) {
                propName = viewProps[i]['name']
            } else {
                propName = viewProps[i]['prop']
            }

            if(keys.indexOf(propName) < 0) {
                keys.push(propName)
            }
        }
        return keys
    }

    function prepareViewJoins(viewProps) {
        var joins = []
        for (var i = 0; i < viewProps.length; ++i) {
            var prop = viewProps[i]
            if ('selected' in prop) {
                var tableName = ''

                if (prop['selected'].prop_type === 'records') {
                    tableName = prop['selected'].table + "Records"
                } else if (prop['selected'].prop_type === 'headers') {
                    tableName = prop['selected'].table + "Documents"
                }

                joins.push({"table": tableName, "column": prop['prop'], "ref_column": prop['selected'].prop})
            }
        }
        return joins
    }

    Component {
        id: listenerComponent

        Item {
            property string cComponentType
            property string cType: ''
            property string cDocId
            property var cKeys: []
            property var cData: []

            function get(prop, index) {
                for (var i = 0; i < cKeys.length; ++i) {
                    if (cKeys[i] === prop) {
                        return cData[index][i]
                    }
                }
                return undefined
            }

            function clear() {
                cData = []
            }

            signal updated()

            function update() {
                var viewType = cConfig.getViewType(cType)
                var propType = cComponentType === 'Records' ? 'records' : 'headers'
                var tableType = cComponentType === 'Records' ? 'Records' : 'Documents'

                var dataProps = cConfig.getDataProps(cConfig.getDataType(viewType.table), propType)
                var viewProps = cConfig.getViewProps(viewType, propType)
                var propNames = prepareViewPropNames(dataProps, viewProps)
                cKeys = prepareViewPropKeys(dataProps, viewProps)

                var joins = prepareViewJoins(viewProps)

                var filters = []
                if (cComponentType === 'Headers') {
                    filters = [cDatabase.filterEq('id', cDocId)]
                } else if (cComponentType === 'Records') {
                    filters = [cDatabase.filterEq('doc_id', cDocId)]
                }

                cDatabase.transaction(function(tx) {
                    cDatabase.getListFromTable(tx, cType + tableType, propNames, cData, joins, filters)
                })
                updated()
           }

            signal closed()

            function close() {
                var listeners
                var listenerId
                if (cComponentType === 'Documents') {
                    listeners = cDocumentListeners
                    listenerId = cType
                } else if (cComponentType === 'Headers') {
                    listeners = cHeaderListeners
                    listenerId = cDocId
                } else if (cComponentType === 'Records') {
                    listeners = cRecordsListeners
                    listenerId = cDocId
                }

                for (var i = 0; i < listeners[listenerId].length; ++i) {
                    var listener = listeners[listenerId][i]
                    if (listener === this) {
                        listeners[listenerId][i].destroy()
                        listeners[listenerId].splice(i, 1)
                       break
                    }
                }
                closed()
            }
        }
    }

    function getDocuments(type) {
        var model = listenerComponent.createObject(root, { cComponentType: 'Documents', cType: type})
        if (!(type in cDocumentListeners)) {
            cDocumentListeners[type] = []
        }

        cDocumentListeners[type].push(model)
        model.update()
        return model
    }

    function getHeaders(type, doc_id) {
        if (!(doc_id in cDocumentListeners)) {
            cHeaderListeners[doc_id] = []
        }

        var model = listenerComponent.createObject(root, {cComponentType: 'Headers', cType: type, cDocId: doc_id})
        cHeaderListeners[doc_id].push(model)
        model.update()
        return model
    }

    function getRecords(type, doc_id) {
        if (!(doc_id in cDocumentListeners)) {
            cRecordsListeners[doc_id] = []
        }

        var model = listenerComponent.createObject(root, {cComponentType: 'Records', cType: type, cDocId: doc_id})
        cRecordsListeners[doc_id].push(model)
        model.update()
        return model
    }
}
