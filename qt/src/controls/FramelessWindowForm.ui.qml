import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.3

Item {
    id: form
    //            color: "black"
    property alias titleBar: titleBar
    property alias resizer: resizer
    property alias sourceComponent: loader.sourceComponent
    property bool active: false

    TitleBar {
        id: titleBar
        height: 20
                anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        z: 1
        active: form.active
    }

    Loader {
        id: loader
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

    Item {
        anchors.fill: parent
        Draggable {
            id: resizer
            anchors.fill: parent
            z: 0
        }
    }
}
