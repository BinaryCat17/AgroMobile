import QtQuick
import QtQuick.Layouts
import '../utils.js' as Utils

Item {
    id: root

    property var cPanelModel: [] // example [{icon: 'icon.png', panel: 'Menus/Menu'}]
    property var cAdditionalData
    property string cActivePanel: stack.cActivePanel
    property string cOpenIcon
    property string cCloseIcon
    readonly property bool cOpened: hider.state === 'open'

    property color cButtonColor: 'white'
    property color cPanelBackgroundColor: "white"
    property bool cPanelFill: false
    property int cPanelRadius: 10 * m_ratio

    property int cPanelMargin: 10 * m_ratio
    property int cOrientation: Qt.AlignLeft
    property int cDirection: Qt.AlignLeading

    function updateLayout() {
        Utils.clearAnchors(grid)
        Utils.clearAnchors(buttonColumn)
        Utils.clearAnchors(hider)
        hider.anchors.margins = 0

        if(cOrientation === Qt.AlignLeft) {
            buttonColumn.anchors.left = root.left
            hider.anchors.left = buttonColumn.right
            hider.anchors.leftMargin = cPanelMargin
        } else if (cOrientation === Qt.AlignRight) {
            buttonColumn.anchors.right = root.right
            hider.anchors.right = buttonColumn.left
            hider.anchors.rightMargin = cPanelMargin
        } else if (cOrientation === Qt.AlignTop) {
            buttonColumn.anchors.top = root.top
            hider.anchors.top = buttonColumn.bottom
            hider.anchors.topMargin = cPanelMargin
        } else if (cOrientation === Qt.AlignBottom) {
            buttonColumn.anchors.bottom = root.bottom
            hider.anchors.bottom = buttonColumn.top
            hider.anchors.bottomMargin = cPanelMargin
        }

        if(cOrientation === Qt.AlignLeft || cOrientation === Qt.AlignRight) {
            if(cDirection === Qt.AlignTrailing) {
                buttonColumn.anchors.bottom = root.bottom
                grid.anchors.bottom = buttonColumn.bottom
                hider.anchors.bottom = root.bottom
            }
            buttonColumn.height = cPanelFill ? root.height: buttonColumn.childrenRect.height
            buttonColumn.width = 50 * m_ratio
            hider.cAnimateHeight = false
            hider.cAnimateWidth = true
        } else if (cOrientation ===  Qt.AlignTop || cOrientation === Qt.AlignBottom) {
            if(cDirection === Qt.AlignTrailing) {
                buttonColumn.anchors.right = root.right
                grid.anchors.right = buttonColumn.right
                hider.anchors.right = root.right
            }
            buttonColumn.width = cPanelFill ? root.width : buttonColumn.childrenRect.width
            buttonColumn.height = 50 * m_ratio
            if(cOrientation ===  Qt.AlignTop) {
                hider.cAnimateWidth = false
                hider.cAnimateHeight = true
            } else {
                hider.cAnimateWidth = false
                hider.cAnimateHeight = false
            }
        }
    }

    onCOrientationChanged: updateLayout()
    onCDirectionChanged:  updateLayout()
    onCPanelMarginChanged: updateLayout()
    onCPanelFillChanged: updateLayout()
    onCActivePanelChanged: updateLayout()

    Rectangle {
        id: buttonColumn
        color: cPanelBackgroundColor
        radius: cPanelRadius

        GridLayout {
            id: grid
            flow: cOrientation === Qt.AlignLeft || cOrientation === Qt.AlignRight ? GridLayout.TopToBottom : GridLayout.LeftToRight

            function prepareButtonRow() {
                var buttonModel = [{icon: hider.state === 'close' ? cOpenIcon : cCloseIcon, panel: '_Menu'}]

                for (var i = 0; i < cPanelModel.length; ++i) {
                    if(cPanelModel[i].icon !== undefined) {
                        buttonModel.push(cPanelModel[i])
                    }
                }

                if(cDirection === Qt.AlignTrailing) {
                    buttonModel.reverse()
                }

                return buttonModel
            }

            Repeater {
                id: columnItems
                model: parent.prepareButtonRow()

                CButton {
                    property var cPanel: modelData.panel
                    property var cStack: stack
                    property var cHider: hider


                    cIcon: modelData.icon
                    cOnClicked: function() {
                        if(cPanel !== '_Menu') {
                            cStack.activatePanel(cPanel)
                            if(cStack.cActivePanel !== '') {
                                cHider.state = 'open'
                            }
                        } else {
                            if(cHider.state === 'open') {
                                cHider.state = 'close'
                            } else if(cStack.cActivePanel !== '') {
                                cHider.state = 'open'
                            }
                        }
                    }
                }
            }
        }
    }

    CHider {
        id: hider
        width: stack.cWidth
        height: stack.cHeight
        cControlItem: stackRect

        Item {
            id: stackRect
            anchors.fill: parent
            opacity: 0

            CStack {
                id: stack
                anchors.fill: parent

                function extractPanelNames() {
                    var panelNames = []
                    for (var i = 0; i < root.cPanelModel.length; ++i) {
                        panelNames.push(root.cPanelModel[i].panel)
                    }
                    return panelNames
                }

                cPanelComponents: extractPanelNames()
                cAdditionalData: root.cAdditionalData
            }
        }
    }
}
