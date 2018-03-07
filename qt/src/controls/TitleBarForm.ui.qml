import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

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

    SystemPalette {
        id: activePalette
        colorGroup: SystemPalette.Active
    }

    width: 400
    height: 400
    Draggable {
        id: mouseArea
        anchors.fill: parent
        drag.target: titleBar
    }

    Rectangle {
        id: topRec
        radius: 3
        color: activePalette.mid
        anchors.fill: titleBar
    }

    Rectangle {
        height: topRec.radius / 2
        width: topRec.radius / 2
        anchors.bottom: titleBar.bottom
        color: topRec.color
        anchors.left: parent.left
        anchors.leftMargin: 0
        opacity: topRec.opacity
    }

    RowLayout {
        id: rowLayout
        width: 54
        height: 100
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        TitleBarButton {
            id: closeBtn
            active: titleBar.active
        }
        TitleBarButton {
            id: minBtn
            active: titleBar.active
            activeColor: "#ffcc00"
            activeBorderColor: "#ffcc00"
            hoverText: "-"
        }

        TitleBarButton {
            id: maxBtn
            active: titleBar.active
            activeColor: "#00cc44"
            activeBorderColor: "#00aa33"
            hoverText: titleBar.fullscreened ? "*" : "+"
        }
    }

    Rectangle {
        height: topRec.radius / 2
        width: topRec.radius / 2
        anchors.bottom: titleBar.bottom
        color: topRec.color
        anchors.right: parent.right
        anchors.rightMargin: 0
        opacity: topRec.opacity
    }
}
