import QtQuick 2.7
import QtQuick.Controls 2.2
import Backend 1.0
import "qrc:/controls" as C

MouseArea {
    id: tabButton
    property alias closeButton: closeButton
    property alias rectangle: rectangle
    property alias displayText: text1.text

    state: Qt.platform.os

    property bool highlighted: false
    property var pal: highlighted ? Palette.selected : hovered ? Palette.hovered : Palette.normal
    //    hoverEnabled: true
    property bool showCloseButton: true
    states: [
        State {
            name: "windows"

            PropertyChanges {
                target: text1
                font.pixelSize: 11
                renderType: Text.NativeRendering
            }

            PropertyChanges {
                target: rectangle
                radius: 0
            }
        }
    ]
    Rectangle {
        id: rectangle
        anchors.fill: parent
        radius: 2
        color: pal.list_item_background
        RoundButton {
            id: closeButton
            width: 15
            height: 15
            anchors.leftMargin: 2
            padding: 4
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            visible: tabButton.hovered && tabButton.showCloseButton
            z: 2
            contentItem: Image {
                source: "icon/cross.svg"
            }
            background: Item {
            }
        }
        C.Text {
            id: text1
            color: highlighted ? pal.list_item_text : pal.button_text
            font.pixelSize: 11
            anchors.rightMargin: 10
            anchors.right: parent.right
            textFormat: Text.PlainText
            anchors.left: closeButton.right
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
        }
    }
}
