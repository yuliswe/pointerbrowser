import QtQuick 2.7
import QtQuick.Layouts 1.3
import Backend 1.0
import "qrc:/controls"

Item {
    id: titleBar
    property alias mouseArea: mouseArea
    property bool active: false
    property alias minBtn: minBtn
    property alias clsBtn: closeBtn
    property alias maxBtn: maxBtn
    property bool maximized: false
    property bool fullscreened: false

    readonly property var pal: active ? Palette.selected : Palette.normal

    Draggable {
        id: mouseArea
        anchors.fill: parent
        drag.target: titleBar
        hoverEnabled: true
    }

    RowLayout {
        id: rowLayout
        anchors.verticalCenterOffset: 2
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        property bool hover: closeBtn.hovered || minBtn.hovered
                             || maxBtn.hovered

        RoundButton {
            id: closeBtn
            padding: 3
            Layout.preferredHeight: 12
            Layout.preferredWidth: 12
            image.source: "icons/cross2.svg"
            overlay.visible: rowLayout.hover
            rectangle {
                border.width: 1
                border.color: "#ee4444"
                color: "#ff5555"
            }
        }
        RoundButton {
            id: minBtn
            padding: 2
            Layout.preferredHeight: 12
            Layout.preferredWidth: 12
            Layout.fillHeight: true
            rectangle {
                border.width: 1
                border.color: "#eebb00"
                color: "#ffcc11"
            }
            overlay.visible: rowLayout.hover
            image.source: "icons/minus2.svg"
        }
        RoundButton {
            id: maxBtn
            padding: 2
            Layout.preferredHeight: 12
            Layout.preferredWidth: 12
            Layout.fillHeight: true
            rectangle {
                border.width: 1
                border.color: "#00bb33"
                color: "#11cc44"
            }
            overlay.visible: rowLayout.hover
            image.source: "icons/plus2.svg"
        }
    }
}
