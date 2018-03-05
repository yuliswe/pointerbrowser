import QtQuick 2.4
import QtQuick.Controls 2.3

Button {
    id: tab
    height: 30
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.left: parent.left
    anchors.leftMargin: 0
    background: Rectangle {
        color: index === tabsList.selected ? main.theme.control_on : (tab.hovered ? main.theme.control_hover : "transparent")
        Text {
            color: index === tabsList.selected ? "#ffffff" : "default"
            text: modelData.title + " - " + modelData.url
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
}
