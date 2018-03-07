import QtQuick 2.9

Rectangle {
    property alias mouseArea: mouseArea
    id: titleBar
    SystemPalette {
        id: activePalette
        colorGroup: SystemPalette.Active
    }

    width: 400
    height: 400
    color: activePalette.mid
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        drag.target: titleBar
    }
}
