import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import Backend 1.0

Item {
    id: form
    //            color: "black"
    property alias titleBar: titleBar
    property alias rightResizer: horiRSizer
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
    property alias loader: loader

    readonly property var palette: active ? Palette.selected : Palette.normal

    Draggable {
        id: vertiTSizer
        height: form.resizerThreshold
        hoverEnabled: true
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        z: 2
        cursorShape: Qt.SplitVCursor
        anchors.right: diagTRSizer.left
        anchors.left: diagTLSizer.right
        anchors.top: parent.top
    }

    Draggable {
        id: horiLSizer
        width: form.resizerThreshold
        anchors.bottomMargin: 0
        anchors.topMargin: 0
        hoverEnabled: true
        z: 2
        cursorShape: Qt.SplitHCursor
        anchors.top: diagTLSizer.bottom
        anchors.bottom: diagBLSizer.top
        anchors.left: parent.left
    }

    Draggable {
        id: vertiBSizer
        x: 0
        y: 475
        height: resizerThreshold
        hoverEnabled: true
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        anchors.right: diagBRSizer.left
        anchors.left: diagBLSizer.right
        anchors.bottom: parent.bottom
        z: 2
        cursorShape: Qt.SplitVCursor
    }

    Draggable {
        id: horiRSizer
        x: 635
        y: 0
        width: resizerThreshold
        hoverEnabled: true
        anchors.bottomMargin: 0
        anchors.topMargin: 0
        anchors.bottom: diagBRSizer.top
        anchors.top: diagTRSizer.bottom
        anchors.right: parent.right
        z: 2
        cursorShape: Qt.SplitHCursor
    }

    Draggable {
        id: diagBRSizer
        x: 635
        y: 475
        width: resizerThreshold * 2
        height: resizerThreshold * 2
        hoverEnabled: true
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        z: 2
        cursorShape: Qt.SizeFDiagCursor
    }

    Draggable {
        id: diagTLSizer
        width: resizerThreshold * 2
        height: resizerThreshold * 2
        hoverEnabled: true
        z: 2
        cursorShape: Qt.SizeFDiagCursor
        anchors.left: parent.left
        anchors.top: parent.top
    }

    Draggable {
        id: diagBLSizer
        width: resizerThreshold * 2
        height: resizerThreshold * 2
        hoverEnabled: true
        z: 2
        cursorShape: Qt.SizeBDiagCursor
        anchors.left: parent.left
        anchors.bottom: parent.bottom
    }

    Draggable {
        id: diagTRSizer
        width: resizerThreshold * 2
        height: resizerThreshold * 2
        hoverEnabled: true
        z: 2
        cursorShape: Qt.SizeBDiagCursor
        anchors.right: parent.right
        anchors.top: parent.top
    }

    Item {
        anchors.rightMargin: form.loaderMargin
        anchors.leftMargin: form.loaderMargin
        anchors.bottomMargin: form.loaderMargin
        anchors.topMargin: form.loaderMargin
        anchors.fill: parent

        TitleBar {
            id: titleBar
            height: 20
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
        }

        Rectangle {
            color: palette.window_background
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.top: titleBar.bottom
            Loader {
                id: loader
                anchors.fill: parent
            }
        }
    }
}
