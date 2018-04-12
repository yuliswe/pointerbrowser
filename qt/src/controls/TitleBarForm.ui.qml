import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Backend 1.0

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
    clip: true

    readonly property var pal: active ? Palette.selected : Palette.normal

    Draggable {
        id: mouseArea
        anchors.fill: parent
        drag.target: titleBar
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
        width: 54
        height: 100
        anchors.verticalCenterOffset: 1
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        TitleBarButton {
            id: closeBtn
            active: true
            icon {
                source: "icon/cross2.svg"
            }
        }
        TitleBarButton {
            id: minBtn
            active: true
            activeColor: "#ffcc00"
            activeBorderColor: "#ffcc00"
            icon {
                source: "icon/minus2.svg"
            }
        }

        TitleBarButton {
            id: maxBtn
            active: true
            activeColor: "#00cc44"
            activeBorderColor: "#00aa33"
            icon {
                source: "icon/plus2.svg"
            }
        }
    }
}
