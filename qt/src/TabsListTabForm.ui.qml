import QtQuick 2.9
import QtQuick.Controls 2.3

ItemDelegate {
    id: tabButton
    highlighted: true
    background: Rectangle {
        id: rectangle
        color: tabButton.hovered ? palette.midlight : "transparent"
        width: parent.width
        Text {
            color: index === tabsList.selected ? palette.highlightedText : palette.buttonText
            text: model.title + " - " + model.url
            anchors.right: parent.right
            anchors.rightMargin: 5
            font.pointSize: 10
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.leftMargin: 15
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
        anchors.leftMargin: 1
        anchors.verticalCenter: parent.verticalCenter
        z: 2
        visible: tabButton.hovered
    }
}
