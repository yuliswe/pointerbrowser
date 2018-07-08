import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.11
import Backend 1.0

Window {
    id: mainWindow
    visible: true
    width: 800
    height: 600
    minimumWidth: 200
    minimumHeight: 200
    readonly property var palette: active ? Palette.normal : Palette.disabled
    readonly property int contentTopMargin: 20

    color: "transparent"
    Rectangle {
        anchors.fill: parent
        color: palette.window_background
    }
    MacWindow {
        id: win
    }
    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: contentTopMargin
        onDoubleClicked: {
            win.zoom(mainWindow)
        }
    }

}
