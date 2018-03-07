import QtQuick 2.9
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.3
import "controls" as C
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.3

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


    RowLayout {
        id: rowLayout
        height: 25
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5

        C.Button {
            id: newTabButton
            x: 550
            width: 25
            height: 25
            text: qsTr("+")
            Layout.fillHeight: true
        }

        C.TextField {
            id: tabsSearch
            height: 25
            Layout.fillHeight: true
            Layout.fillWidth: true
            placeholderText: "Search Tabs"
            selectByMouse: true
        }

    }

    TabsList {
        id: tabsList
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
