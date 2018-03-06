import QtQuick 2.4
import QtQuick.Controls 2.3

ItemDelegate {
    id: tabButton
    highlighted: true
    background: Rectangle {
        color: tabButton.hovered ? palette.midlight : "transparent"
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
    }
    Text {
        color: index === tabsList.selected ? "#ffffff" : "default"
        text: model.title + " - " + model.url
        font.pointSize: 10
        font.family: "Segoe UI"
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignTop
        horizontalAlignment: Text.AlignLeft
    }
}
