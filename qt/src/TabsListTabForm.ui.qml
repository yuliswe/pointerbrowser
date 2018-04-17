import QtQuick 2.7
import QtQuick.Controls 2.2
import Backend 1.0

ItemDelegate {
    id: tabButton
    property alias closeButton: closeButton
    property alias rectangle: rectangle

    readonly property var pal: highlighted ? Palette.selected : hovered ? Palette.hovered : Palette.normal
    hoverEnabled: true
    property bool showCloseButton: true
    background: Rectangle {
        id: rectangle
        width: parent.width
        radius: 2
        color: pal.list_item_background
        RoundButton {
            id: closeButton
            width: 15
            height: 15
            padding: 4
            anchors.verticalCenterOffset: 1
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
        Text {
            color: highlighted ? pal.list_item_text : pal.button_text
            text: (model.title || "Loading") + " - " + model.url
            anchors.rightMargin: 5
            anchors.right: parent.right
            font.pointSize: 10
            textFormat: Text.PlainText
            anchors.left: closeButton.right
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
        }
    }
}
