import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.3

Item {
    id: form
    //            color: "black"
    property alias titleBar: titleBar
    property alias rightResizer: rightSizer
    property alias bottomResizer: bottomSizer
    property alias diagnalResizer: diagSizer
    property alias sourceComponent: loader.sourceComponent
    property bool active: false
    property int resizerThreshold: 5

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
        z: 0
    }

    Item {
        id: item1
        anchors.fill: parent
        Draggable {
            id: rightSizer
            width: resizerThreshold
            anchors.bottom: parent.bottom
            anchors.bottomMargin: resizerThreshold
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            z: 1
            cursorShape: Qt.SplitHCursor
            hoverEnabled: true
        }
        Draggable {
            id: bottomSizer
            height: resizerThreshold
            anchors.right: parent.right
            anchors.rightMargin: resizerThreshold
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            z: 1
            cursorShape: Qt.SplitVCursor
            hoverEnabled: true
        }
        Draggable {
            id: diagSizer
            width: resizerThreshold
            height: resizerThreshold
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            z: 1
            cursorShape: Qt.SizeFDiagCursor
            hoverEnabled: true
        }
    }
}
