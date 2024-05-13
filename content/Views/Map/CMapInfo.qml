import QtQuick 6.2
import QtQuick.Layouts
import '../Design'
import '../Core'
import '../utils.js' as Utils

Item {
    id: root
    property real cOpenWidth: 300 * m_ratio
    property real cOpenHeight: 50 * repeater.model.length * m_ratio
    property var cAdditionalData;
    property var cDataManager: cAdditionalData.dataManager;
    property var cInfoTables: cAdditionalData.infoTables
    property var cSelectedItem: cDataManager.cSelectedItem

    CViewManager {
        id: viewManager
        cAdditionalData: ({})
    }

    Connections {
        target: viewManager
        function onUpdated() {
            for (var j = 0; j < viewManager.cComponents.length; ++j) {
                var initedItem = viewManager.cComponents[j]
                var prop = viewManager.get(initedItem['name'])
                prop.cDesc = initedItem['desc']
                if (initedItem['type'] === 'Catalog') {
                    prop.cCatalogTable = initedItem['catalog']
                }
            }

            repeater.model = viewManager.cComponents
        }
    }

    onCSelectedItemChanged: function() {
        var viewModel = []
        if (cInfoTables !== undefined) {
            var objectModel = cInfoTables[cSelectedItem.type]

            for (var i = 0; i < objectModel.length; ++i) {
                var item = objectModel[i]

                var componentPath = ''
                if (item['type'] === 'String') {
                    componentPath = 'Forms/CStringForm'
                } else if (item['type'] === 'Catalog') {
                    componentPath = 'Forms/CCatalogForm'
                }

                viewModel.push({desc: item['desc'], name: item['name'], component: componentPath, type: item['type']})
            }
        } else {
            viewModel.push({desc: 'Объект не выбран', name: 'not_selected', component: 'Forms/CStringForm'})
        }

        repeater.model = []
        viewManager.cComponents = viewModel
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.bottomMargin: 10 * m_ratio

        Repeater {
            id: repeater
            model: []
            CView {
                property var cName: modelData.name
                cStatic: true
                cViewManager: viewManager
                cActiveView: cName
                height: 40 * m_ratio
            }
        }
    }
}
