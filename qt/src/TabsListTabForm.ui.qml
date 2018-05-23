import QtQuick 2.7
import QtQuick.Controls 2.2
import Backend 1.0
import "qrc:/controls" as C

ItemDelegate {
    id: tabButton
    property alias closeButton: closeButton
    property alias rectangle: rectangle

    state: Qt.platform.os

    readonly property var pal: highlighted ? Palette.selected : hovered ? Palette.hovered : Palette.normal
    hoverEnabled: true
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
    background: Rectangle {
        id: rectangle
        width: parent.width
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
                //                color: pal.button_icon
            }
            background: Item {
            }
        }
        C.Text {
            id: text1
            color: highlighted ? pal.list_item_text : pal.button_text
            text: (model.title || model.url)
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
