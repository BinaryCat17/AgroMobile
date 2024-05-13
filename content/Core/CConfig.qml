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
        for (var i in document[prop_type]) {
            var item = document[prop_type][i]
            result.push(item[name])
        }
    }

    function prepareDocumentProps(props, values) {
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

    function getDocumentHeaders(document) {
        var headers = [
            {'name': 'id', 'type': 'string', 'desc': 'Идентификатор'},
            {'name': 'name', 'type': 'string', 'desc': 'Имя'},
            {'name': 'organization_id', 'type': 'string', 'desc': 'Организация'},
            {'name': 'created_at', 'type': 'datetime', 'desc': 'Время создания'},
            {'name': 'updated_at', 'type': 'datetime', 'desc': 'Время изменения'}
        ]

        if ('headers' in document) {
            for (var i = 0; i < document['headers'].length; ++i) {
                headers.push(document['headers'][i])
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
