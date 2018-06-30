import QtQuick 2.7
import QtQuick.Layouts 1.3
import Backend 1.0
import "qrc:/controls"

Item {
    id: titleBar
    property alias mouseArea: mouseArea
    property alias rectangle: topRec
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

    Rectangle {
        id: topRec
        radius: 5
        border.width: 0
        color: pal.window_background
        anchors.fill: titleBar

        Rectangle {
            id: leftRec
            x: 397
            y: 399
            height: topRec.radius
            width: topRec.radius
            color: topRec.color
            smooth: false
            enabled: false
            anchors.bottomMargin: 0
            anchors.bottom: parent.bottom
            border.width: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            opacity: topRec.opacity
            z: 2
        }

        Rectangle {
            id: rightRec
            width: topRec.radius
            height: topRec.radius
            color: topRec.color
            enabled: false
            smooth: false
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            border.width: 0
            opacity: topRec.opacity
            z: 2
        }
    }

    RowLayout {
        id: rowLayout
        anchors.verticalCenterOffset: 1
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
