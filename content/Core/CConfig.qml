import QtQuick 6.2
import '../utils.js' as Utils

Item {
    id: root
    property var cConfig
    property var cData
    property var cViews
    property var cColors
    property bool cInitialized: false

    property string cActiveTheme

    Component.onCompleted: function() {
        var config = Utils.openFile('resources/config.json')
        cConfig = JSON.parse(config)

        var data = Utils.openFile('resources/data.json')
        cData = JSON.parse(data)

        var views = Utils.openFile('resources/views.json')
        cViews = JSON.parse(views)

        var clrs = Utils.openFile('resources/colors.json')
        cColors = JSON.parse(clrs)
        cActiveTheme = cColors['active']

        cInitialized = true
    }

    // config --------------------------------------------------------------------------------------------------------------------

    function colors(name) {
        return cColors[cActiveTheme][name]
    }

    function getMapLayers() {
        return cConfig['map_layers']
    }

    function getSideMenuTabs() {
        return cConfig['side_menu']
    }

    function getSideMenuProp(type, prop) {
        var menu = getSideMenuTabs()
        for (var i = 0; i < menu.length; ++i) {
            for (var j = 0; j < menu[i].children.length; ++j) {
                var item = menu[i].children[j]
                if (item.name === type) {
                    return item[prop]
                }
            }
        }
        return undefined
    }

    // data ----------------------------------------------------------------------------------------------------------------------

    function getDataTypes() {
        return cData
    }

    function getDataType(type) {
        for (var i in cData) {
            var doc = cData[i]
            if(doc['name'] === type) {
                return doc
            }
        }
        console.log(`data type ${type} is not exist`)
        return undefined
    }

    function getDataProps(document, prop_type) {
        var props = []
        if (prop_type in document) {
            for (var i = 0; i < document[prop_type].length; ++i) {
                var prop = document[prop_type][i]
                props.push(prop)
            }
        }
        return props
    }

    function getDataProp(document, prop_type, name) {
        var dataProps = getDataProps(document, prop_type)
        for (var j = 0; j < dataProps.length; ++j) {
            if (dataProps[j].name === name) {
                return dataProps[j]
            }
        }

        var headerProps = getDataProps(document, 'headers')
        for (var i = 0; i < headerProps.length; ++i) {
            if (headerProps[i].name === name) {
                return headerProps[i]
            }
        }

        console.log(`data ${document.name} prop ${name} is not exist`)
        return undefined
    }

    function hasDataProp(document, prop_type, name) {
        var dataProps = getDataProps(document, prop_type)
        for (var j = 0; j < dataProps.length; ++j) {
            if (dataProps[j].name === name) {
                return true
            }
        }
        return false
    }

    function getDataPropNames(document, prop_type) {
        var result = []

        var props = getDataProps(document, prop_type)
        for (var i in props) {
            var item = props[i]
            result.push(item['name'])
        }

        return result
    }

    // views ---------------------------------------------------------------------------------------------------------------

    function getViewTypes() {
        return cViews
    }

    function getViewType(type) {
        for (var i in cViews) {
            var doc = cViews[i]
            if(doc['name'] === type) {
                return doc
            }
        }
        console.log(`view type ${type} is not exist`)
        return undefined
    }

    function getViewProps(document, prop_type) {
        var result = []

        var props = document[prop_type]
        var dataDoc = getDataType(document['table'])

        for (var i = 0; i < props.length; ++i) {
            var prop = props[i]
            var newProp = {}

            if ('name' in prop) {
                newProp['name'] = prop['name']
            } else if ('view' in prop) {
                newProp['name'] = prop['view']
            } else {
                console.log(`view ${document.name} must contain 'name' or 'view' property`)
            }

            if ('desc' in prop) {
                newProp['desc'] = prop['desc']
            }

            if ('write' in prop) {
                newProp['write'] = prop['write']
            } else {
                newProp['write'] = false
            }

            if ('view' in prop && 'select' in prop) {
                var selectedProp = getDataProp(dataDoc, 'records', prop['select'])
                newProp['select'] = {'table': selectedProp.type, 'prop': prop['view'], 'prop_type': 'records'}

                if ('filter' in prop) {
                    var filterRecordsProp = getDataProp(dataDoc, 'records', prop['filter'])
                    var filterDoc = getDataType(filterRecordsProp.type)

                    if (hasDataProp(dataDoc, 'records', prop['filter'])) {
                        newProp['filter'] = {'table': filterRecordsProp.type, 'prop': prop['filter'], 'prop_type': 'records'}
                    } else if (hasDataProp(dataDoc, 'headers', prop['filter'])) {
                        newProp['filter'] = {'table': filterRecordsProp.type, 'prop': prop['filter'], 'prop_type': 'headers'}
                    } else {
                        console.log(`filter tables ${document['table']} or ${filterRecordsProp.type} don't have property ${prop['filter']}`)
                    }
                }
                newProp['prop'] = prop['select']
                newProp['type'] = getDataProp(dataDoc, prop_type, prop['select']).type
            } else if ('view' in prop) {
                newProp['prop'] = prop['view']
                newProp['type'] = getDataProp(dataDoc, prop_type, prop['view']).type
            } else {
                console.log(`view ${document.name} must contain 'view' property`)
            }

            result.push(newProp)
        }
        return result
    }

    function prepareViewProps(props, values) {
        var result = {}

        for (var i = 0; i < props.length; ++i) {
            var item = props[i]
            if (!(item.prop in values)) {
                console.log(`document item must contain ${item.prop}`)
                return
            }
            var value = values[item.prop]

            if(item.type === 'datetime') {
                result[item.prop] = Utils.dateTimeToStr(value)
            } else if (item.type === 'coord') {
                result[item.prop + '_longitude'] = value['longitude']
                result[item.prop + '_latitude'] = value['latitude']
            } else if (item.type === 'poly') {
                var shapeLoop = value
                shapeLoop.push(value.shape[0])
                result[item.prop] = JSON.stringify(shapeLoop)
            } else {
                result[item.prop] = value
            }
        }

        return result
    }
}
