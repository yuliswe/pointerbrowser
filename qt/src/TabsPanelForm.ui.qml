import QtQuick 2.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.3

Rectangle {
    id: form
    color: "#f6f6f6"
    border.width: 0
    property alias docviewSwitchFocusPolicy: docviewSwitch.focusPolicy
    property alias tabsList: tabsList
    property alias tabsSearch: tabsSearch

    TextField {
        id: tabsSearch
        height: 30
        text: qsTr("Text Field")
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.right: newTabButton.left
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        selectByMouse: true
    }

    Button {
        id: newTabButton
        x: 550
        y: 5
        width: 30
        height: 30
        text: qsTr("+")
        anchors.right: parent.right
        anchors.rightMargin: 5
    }

    TabsList {
        id: tabsList
        anchors.bottom: docviewSwitch.top
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.bottomMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
    }

    Switch {
        id: docviewSwitch
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        checked: true
    }
}
