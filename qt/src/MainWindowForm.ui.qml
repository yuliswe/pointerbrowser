import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.3
import "controls" as C

Item {
    id: item1
    property alias titleBar: titleBar
    property alias resizer: resizer

    TitleBar {
        id: titleBar
        height: 30
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        z: 1
    }

    Browser {
        id: browser
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: titleBar.bottom
        anchors.topMargin: 0
        z: 1
    }

    C.Draggable {
        id: resizer
        anchors.fill: parent
        z: 0
    }
}
