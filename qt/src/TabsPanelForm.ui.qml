import QtQuick 2.4
import QtQuick.Controls 2.3

Rectangle {
    id: item1
    color: "#f6f6f6"

    TextField {
        id: textField
        height: 30
        text: qsTr("Text Field")
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        selectByMouse: true
    }

    TabsList {
        id: tabsList
        anchors.top: textField.bottom
        anchors.topMargin: 41
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
    }
}
