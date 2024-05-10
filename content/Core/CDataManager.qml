import QtQuick 6.2
import '../utils.js' as Utils

Item {
    id: root
    property var cDatabase
    property var cConfig
    property bool cInitialized: false

    property var cDocumentListeners: ({})
    property var cHeaderListeners: ({})
    property var cRecordsListeners: ({})
    property var cActiveLayers: ({})
    property var cSelectedItem

    Component.onCompleted: function() {
        var cfg = Utils.openFile('resources/config.json')
        cConfig = JSON.parse(cfg)

        cInitialized = true

        for (var i = 0; i < cConfig['map_layers'].length; ++i) {
            var layer = cConfig['map_layers'][i]
            activateLayer(layer.name, layer.children[0].name)
        }
    }

    // selectors --------------------------------------------------------------------------------------------------

    function select(name, id) {
        var model = root.get(name).model
        for (var j = 0; j < model.count; ++j) {
            var listItem = model.get(j);
            if (listItem.id === id) {
                cSelectedItem = listItem
                break
            }
        }
    }

    signal layerActivated(layer: string, value: variant)

    function activateLayer(layer, value) {
        for (var i = 0; i < cConfig['map_layers'].length; ++i) {
            if(cConfig['map_layers'][i].name === layer) {
                for (var j = 0; j < cConfig['map_layers'][i].children.length; ++j) {
                    var child = cConfig['map_layers'][i].children[j]
                    if(child['name'] === value) {
                        cActiveLayers[layer.name] = child
                        layerActivated(layer, child)
                    }
                    return
                }
            }
        }
    }

    // documents --------------------------------------------------------------------------------------------------

    function getDocumentType(type) {
        for (var i in cConfig['documents']) {
            var doc = cConfig['documents'][i]
            if(doc['name'] === type) {
                return doc
            }
        }
        console.log(`document ${type} is not exist`)
        return undefined
    }

    function listDocumentPropNames(document, prop_type) {
        var result = []
        for (var i in document[prop_type]) {
            var item = document[prop_type][i]
            result.push(item[name])
        }
    }

    function prepareProps(props, values) {
        var result = {}

        for (var i = 0; i < props.length; ++i) {
            var item = props[i]
            if (!(item.name in values)) {
                console.log(`${document['name']} item must contain ${item_name}`)
                return
            }
            var value = values[item.name]

            if(item.type === 'datetime') {
                result[item.name] = Utils.dateTimeToStr(value)
            } else if (item.type === 'coord') {
                result[item.name + '_longitude'] = value['longitude']
                result[item.name + '_latitude'] = value['latitude']
            } else if (item.type === 'poly') {
                var shapeLoop = value
                shapeLoop.push(value.shape[0])
                result[item.name] = JSON.stringify(shapeLoop)
            } else {
                result[item.name] = value
            }
        }

        return result
    }

    function prepareHeaders(document, values) {
        var headers = [
            {'name': 'id', 'type': 'string', 'desc': 'Идентификатор'},
            {'name': 'name', 'type': 'string', 'desc': 'Имя'},
            {'name': 'organization_id', 'type': 'string', 'desc': 'Организация'},
            {'name': 'created_at', 'type': 'datetime', 'desc': 'Время создания'},
        ]

        for (var i = 0; i < document['headers'].length; ++i) {
            headers.push(document['headers'][i])
        }

        return prepareProps(headers, values)
    }

    function prepareRecordRow(document, values) {
        var recordRow = [
            {'name': 'id', 'type': 'string', 'desc': 'Идентификатор'},
            {'name': 'doc_id', 'type': 'string', 'desc': 'Документ'}
        ]

        for (var i = 0; i < document['records'].length; ++i) {
            recordRow.push(document['records'][i])
        }

        return prepareProps(recordRow, values)
    }

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
        var prep = prepareHeaders(getDocumentType(type), header_values)
        cDatabase.transaction(function(tx) {
            cDatabase.insertInTable(tx, type + 'Documents', header_values.keys(), [prep])
        })
        updateDocumentListeners(type)
        updateHeaderListeners(header_values['id'])
    }

    function updateDocument(type, header_values) {
        var prep = prepareHeaders(getDocumentType(type), header_values)
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
        var prep = prepareRecordRow(getDocumentType(type), record_values)
        record_values['doc_id'] = doc_id
        cDatabase.transaction(function(tx) {
            cDatabase.insertInTable(tx, type + 'Records', record_values.keys(), [prep])
        })
        updateRecordsListeners(doc_id)
    }

    function updateRecord(type, doc_id, record_values) {
        var prep = prepareRecordRow(getDocumentType(type), record_values)
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
                var keys = listDocumentPropNames(getDocumentType(cType), 'headers')
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
                var keys = listDocumentPropNames(getDocumentType(cType), 'headers')
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
                var keys = listDocumentPropNames(getDocumentType(cType), 'records')
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

    function listDocumentTypes() {
        return cConfig['documents']
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
