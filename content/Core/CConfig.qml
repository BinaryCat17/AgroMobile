import QtQuick 6.2
import '../utils.js' as Utils

Item {
    id: root
    property var cConfig
    property bool cInitialized: false

    Component.onCompleted: function() {
        var cfg = Utils.openFile('resources/config.json')
        cConfig = JSON.parse(cfg)
        cInitialized = true
    }

    // map -----------------------------------------------------------------------------------------------------

    function listMapLayers() {
        return cConfig['map_layers']
    }

    // menu

    function listSideMenuTabs() {
        return cConfig['side_menu']
    }

    // documents ------------------------------------------------------------------------------------------------

    function listDocumentTypes() {
        return cConfig['documents']
    }

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

        var props = []
        if(prop_type === 'headers') {
            props = getDocumentHeaders(document)
        } else if(prop_type === 'records') {
            props = getDocumentRecordRow(document)
        }

        for (var i in props) {
            var item = props[i]
            result.push(item['name'])
        }

        return result
    }

    function prepareDocumentProps(props, values) {
        var result = {}

        for (var i = 0; i < props.length; ++i) {
            var item = props[i]
            if (!(item.name in values)) {
                console.log(`document item must contain ${item.name}`)
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

    function getDocumentHeaders(document) {
        var headers = [
            {'name': 'id', 'type': 'string', 'desc': 'Идентификатор', 'mode': 'read', 'visible': false},
            {'name': 'name', 'type': 'string', 'desc': 'Имя', 'mode': 'write', 'visible': true},
            {'name': 'organization_id', 'type': 'string', 'desc': 'Организация', 'mode': 'read', 'visible': true},
            {'name': 'created_at', 'type': 'datetime', 'desc': 'Время создания', 'mode': 'read', 'visible': true},
            {'name': 'updated_at', 'type': 'datetime', 'desc': 'Время изменения', 'mode': 'read', 'visible': true}
        ]

        if ('headers' in document) {
            for (var i = 0; i < document['headers'].length; ++i) {
                var header = document['headers'][i]
                if (!('visible' in header)) {
                    header['visible'] = true
                }
                if (!('mode' in header)) {
                    header['mode'] = 'write'
                }
                headers.push(header)
            }
        }

        return headers
    }

    function getDocumentRecordRow(document) {
        var recordRow = [
            {'name': 'id', 'type': 'string', 'desc': 'Идентификатор'},
            {'name': 'doc_id', 'type': 'string', 'desc': 'Документ'}
        ]

        if ('records' in document) {
            for (var i = 0; i < document['records'].length; ++i) {
                recordRow.push(document['records'][i])
            }
        }
        return recordRow
    }
}
