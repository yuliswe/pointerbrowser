import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.3

Item {
    id: form
    //            color: "black"
    property alias titleBar: titleBar
    property alias rightResizer: horiRSizer
    property alias sourceComponent: loader.sourceComponent
    property bool active: false
    property int resizerThreshold: 5
    property int loaderMargin: form.resizerThreshold / 2
    property alias bResizer: vertiBSizer
    property alias lResizer: horiLSizer
    property alias tResizer: vertiTSizer
    property alias rResizer: horiRSizer
    property alias brResizer: diagBRSizer
    property alias blResizer: diagBLSizer
    property alias tlResizer: diagTLSizer
    property alias trResizer: diagTRSizer

    Rectangle {
        id: rectangle
        color: "#02ffffff"
        anchors.fill: parent

        Draggable {
            id: vertiTSizer
            height: form.resizerThreshold
            anchors.rightMargin: resizerThreshold * 2
            anchors.leftMargin: resizerThreshold * 2
            z: 3
            cursorShape: Qt.SplitVCursor
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
        }

        Draggable {
            id: horiLSizer
            width: form.resizerThreshold
            anchors.topMargin: resizerThreshold * 2
            anchors.bottomMargin: resizerThreshold * 2
            hoverEnabled: false
            z: 1
            cursorShape: Qt.SplitHCursor
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
        }

        Draggable {
            id: vertiBSizer
            x: 0
            y: 475
            height: resizerThreshold
            anchors.leftMargin: resizerThreshold * 2
            anchors.rightMargin: resizerThreshold * 2
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            z: 1
            cursorShape: Qt.SplitVCursor
        }

        Draggable {
            id: horiRSizer
            x: 635
            y: 0
            width: resizerThreshold
            anchors.bottomMargin: resizerThreshold * 2
            anchors.topMargin: resizerThreshold * 2
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            anchors.right: parent.right
            z: 1
            cursorShape: Qt.SplitHCursor
        }

        Loader {
            id: loader
            x: 5
            y: 25
            anchors.leftMargin: form.loaderMargin
            anchors.rightMargin: form.loaderMargin
            anchors.bottomMargin: form.loaderMargin
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.top: titleBar.bottom
            z: 0
        }

        TitleBar {
            id: titleBar
            height: 25
            anchors.topMargin: form.loaderMargin
            anchors.rightMargin: form.loaderMargin
            anchors.leftMargin: form.loaderMargin
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            z: 1
            active: form.active
        }

        Draggable {
            id: diagBRSizer
            x: 635
            y: 475
            width: resizerThreshold * 2
            height: resizerThreshold * 2
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            z: 1
            cursorShape: Qt.SizeFDiagCursor
        }

        Draggable {
            id: diagTLSizer
            width: resizerThreshold * 2
            height: resizerThreshold * 2
            cursorShape: Qt.SizeFDiagCursor
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
        }

        Draggable {
            id: diagBLSizer
            width: resizerThreshold * 2
            height: resizerThreshold * 2
            cursorShape: Qt.SizeBDiagCursor
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
        }

        Draggable {
            id: diagTRSizer
            width: resizerThreshold * 2
            height: resizerThreshold * 2
            cursorShape: Qt.SizeBDiagCursor
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
        }
    }
}
