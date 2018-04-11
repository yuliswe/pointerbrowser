import QtQuick 2.9
import QtQuick.Controls 2.3

ItemDelegate {
    id: tabButton
    property alias closeButton: closeButton
    property alias rectangle: rectangle

    SystemPalette {
        id: actPal
        colorGroup: SystemPalette.Active
    }
    SystemPalette {
        id: inaPal
        colorGroup: SystemPalette.Inactive
    }
    readonly property var pal: highlighted ? actPal : inaPal
    hoverEnabled: true
    property bool showCloseButton: true
    background: Rectangle {
        id: rectangle
        width: parent.width
        radius: 2
        color: highlighted ? actPal.base : (hovered ? actPal.button : "#00000000")
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
            icon {
                source: "icon/cross.svg"
                color: pal.buttonText
            }
            background: Item {
            }
        }
        Text {
            color: highlighted ? pal.alternateBase : pal.buttonText
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
