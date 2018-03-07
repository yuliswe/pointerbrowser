import QtQuick 2.9
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.3
import "controls" as C
import QtGraphicalEffects 1.0

Item {
    id: form
    Rectangle {
        id: background
        color: ctl.palette.button
        border.width: 0
        anchors.fill: form
        opacity: 0.95
    }
    property alias docviewSwitchFocusPolicy: docviewSwitch.focusPolicy
    property alias tabsList: tabsList
    property alias tabsSearch: tabsSearch

    Control {
        id: ctl
    }

    C.TextField {
        id: tabsSearch
        height: 25
        placeholderText: "Search Tabs"
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.right: newTabButton.left
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        selectByMouse: true
    }

    C.Button {
        id: newTabButton
        x: 550
        y: 5
        width: 25
        height: 25
        text: qsTr("+")
        anchors.right: parent.right
        anchors.rightMargin: 5
    }

    TabsList {
        id: tabsList
        anchors.bottom: docviewSwitch.top
        anchors.top: tabsSearch.bottom
        anchors.topMargin: 5
        anchors.bottomMargin: 5
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
