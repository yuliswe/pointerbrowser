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
        anchors.rightMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        selectByMouse: true
    }
}
