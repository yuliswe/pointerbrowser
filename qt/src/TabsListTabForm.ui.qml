import QtQuick 2.9
import QtQuick.Controls 2.3

ItemDelegate {
    id: tabButton
    property alias closeButton: closeButton

    SystemPalette {
        id: actPal
        colorGroup: SystemPalette.Active
    }

    highlighted: true // preview
    background: Rectangle {
        id: rectangle
        color: tabButton.highlighted ? actPal.highlight : (tabButton.hovered ? actPal.midlight : actPal.button)
        width: parent.width
        radius: 2
        Text {
            color: actPal.buttonText
            text: (modelTitle || "Loading") + " - " + model.url
            anchors.right: parent.right
            anchors.rightMargin: 10
            font.pointSize: 10
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
        }
    }
    RoundButton {
        id: closeButton
        width: 15
        height: 15
        text: "x"
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        z: 2
        visible: true // preview
        background: Item {
        }
    }
}
