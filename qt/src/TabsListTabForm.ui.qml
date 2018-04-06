import QtQuick 2.9
import QtQuick.Controls 2.3

ItemDelegate {
    id: tabButton
    property alias closeButton: closeButton

    SystemPalette {
        id: actPal
        colorGroup: SystemPalette.Active
    }
    SystemPalette {
        id: inaPal
        colorGroup: SystemPalette.Inactive
    }

    readonly property var pal: highlighted ? actPal : inaPal

    highlighted: true // preview
    background: Rectangle {
        id: rectangle
        color: tabButton.highlighted ? actPal.highlight : (tabButton.hovered ? actPal.midlight : "#00000000")
        width: parent.width
        radius: 2
        RoundButton {
            id: closeButton
            width: 15
            height: 15
            padding: 4
            anchors.verticalCenterOffset: 1
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            z: 2
            visible: true // preview
            icon {
                source: "icon/cross.svg"
                color: tabButton.highlighted ? pal.light : pal.dark
            }
            background: Item {
            }
        }
        Text {
            color: tabButton.highlighted ? pal.highlightedText : pal.buttonText
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
