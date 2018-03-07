import QtQuick 2.9
Item {
    property alias mouseArea: mouseArea
    id: titleBar
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
        height: topRec.radius
        width: titleBar.width
        anchors.bottom: titleBar.bottom
        color: topRec.color
    }
}
