import QtQuick
import QtQuick.Layouts
import '../Design'
import '../utils.js' as Utils

Item {
    id: root

    width: cViewWidth
    property var cComponents
    property var cAdditionalData
    property bool cViewInitialized: view.cInitialized
    property string cActiveView: view.cActiveView
    property var cInitModel: [] // example [{icon: 'icon.png', panel: 'panelName'}]
    property var cModel: []
    property int cAlignment: Qt.AlignLeft
    property var cColor
    property var cIconColor
    property var cTextColor
    property string cHiderState: 'close'
    property string cPanel

    Component.onCompleted: function() {
        cModel = cInitModel
        if(cAlignment === Qt.AlignRight) {
            rowLayout.anchors.right = header.right
            rect.anchors.right = body.right
        }
    }

    function get(getView) {
        return view.get(getView)
    }

    onCPanelChanged: function() {
        view.cActiveView = cPanel
        if(view.cActiveView !== '') {
            cHiderState = 'open'
        }
    }

    property var cViewWidth: (cViewInitialized && cActiveView !== '') ? view.get(cActiveView).cOpenWidth : 0
    property var cViewHeight: (cViewInitialized && cActiveView !== '') ? view.get(cActiveView).cOpenHeight : 0

    CHider {
        id: hider
        state: cHiderState
        cControlItem: rect
        cOpenWidth: cViewWidth
        cOpenHeight: cViewHeight
    }

    ColumnLayout {
        Item {
            id: header
            height: 50 * m_ratio
            width: root.width

            RowLayout {
                id: rowLayout
                CButton {
                    width: 50 * m_ratio
                    height: 50 * m_ratio
                    cColor: root.cColor
                    cIconColor: root.cIconColor
                    cTextColor: root.cTextColor
                    cIcon: hider.state === 'close' ? 'down.png' : 'up.png'
                    cOnClicked: function() {
                        if(hider.state === 'open') {
                            cHiderState = 'close'
                        } else if(view.cActiveView !== '') {
                            cHiderState = 'open'
                        }
                    }
                }

                Repeater {
                    model: cModel
                    CButton {
                        width: 50 * m_ratio
                        height: 50 * m_ratio
                        cColor: root.cColor
                        cIconColor: root.cIconColor
                        cTextColor: root.cTextColor
                        property var cPanel: modelData.panel
                        property var cView: view
                        property var cHider: hider

                        cIcon: modelData.icon
                        cOnClicked: function() {
                            root.cPanel = cPanel
                        }
                    }
                }
            }
        }

        Item {
            id: body
            width: root.width
            Rectangle {
                id: rect
                opacity: 0
                radius: 10 * m_ratio

                CView {
                    id: view
                    anchors.fill: parent
                    cComponents: root.cComponents
                    cAdditionalData: root.cAdditionalData
                }
            }
        }
    }
}
