import QtQuick
import QtQuick.Layouts
import '../Design'
import '../utils.js' as Utils

Item {
    id: root

    width: cViewWidth
    property var cViewManager
    property bool cViewManagerInitialized: cViewManager.cInitialized
    property string cActiveView: view.cActiveView
    property var cInitModel: [] // example [{icon: 'icon.png', panel: 'panelName'}]
    property var cModel: []
    property int cAlignment: Qt.AlignLeft

    Component.onCompleted: function() {
        cModel = cInitModel
        if(cAlignment === Qt.AlignRight) {
            rowLayout.anchors.right = header.right
            rect.anchors.right = body.right
        }
    }

    property var cViewWidth: (cViewManagerInitialized && cActiveView !== '') ? cViewManager.get(cActiveView).cOpenWidth : 0
    property var cViewHeight: (cViewManagerInitialized && cActiveView !== '') ? cViewManager.get(cActiveView).cOpenHeight : 0

    CHider {
        id: hider
        cControlItem: rect
        cAnimateHeight: true
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
                    cIcon: hider.state === 'close' ? 'down.png' : 'up.png'
                    cOnClicked: function() {
                        if(hider.state === 'open') {
                            hider.state = 'close'
                        } else if(view.cActiveView !== '') {
                            hider.state = 'open'
                        }
                    }
                }

                Repeater {
                    model: cModel
                    CButton {
                        property var cPanel: modelData.panel
                        property var cView: view
                        property var cHider: hider

                        cIcon: modelData.icon
                        cOnClicked: function() {
                            cView.cActiveView = cPanel
                            if(cView.cActiveView !== '') {
                                cHider.state = 'open'
                            }
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
                    anchors.margins: 10 * m_ratio
                    cViewManager: root.cViewManager
                }
            }
        }
    }
}
