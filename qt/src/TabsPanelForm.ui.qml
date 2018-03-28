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
        color: actPal.button
        border.width: 0
        anchors.fill: form
        opacity: 0.95
    }

    RowLayout {
        id: topControls
        x: 5
        y: 5
        height: 25
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        Layout.maximumHeight: 25
        Layout.fillWidth: true
        Layout.margins: 5

        C.Button {
            id: newTabButton
            width: 25
            height: 25
            text: qsTr("+")
            font.bold: true
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

    Text {
        id: text1
        color: actPal.mid
        text: qsTr("Open Tabs")
        anchors.top: topControls.bottom
        anchors.topMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        topPadding: 5
        bottomPadding: 5
        leftPadding: 5
        font.bold: false
        font.capitalization: Font.AllUppercase
        font.pixelSize: 9
    }

    TabsList {
        id: tabsList
        height: 100
        tabHeight: form.tabHeight
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: text1.bottom
        anchors.topMargin: 0
        interactive: false
        highlightFollowsCurrentItem: false
        Layout.fillHeight: false
        Layout.fillWidth: true
    }

    Text {
        id: text2
        color: actPal.mid
        text: qsTr("Saved")
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: tabsList.bottom
        anchors.topMargin: 0
        bottomPadding: 5
        leftPadding: 5
        topPadding: 5
        font.capitalization: Font.AllUppercase
        font.bold: false
        font.pixelSize: 9
    }

    TabsList {
        id: searchList
        tabHeight: form.tabHeight
        anchors.top: text2.bottom
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        Layout.fillHeight: true
        Layout.fillWidth: true
        showCloseButton: false
    }

    RowLayout {
        id: bottomControls
        x: 0
        y: 452
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        Layout.maximumHeight: 25
        Layout.fillWidth: true
        Layout.margins: 5

        Switch {
            id: docviewSwitch
            checked: true
        }
    }

    SystemPalette {
        id: actPal
        colorGroup: SystemPalette.Active
    }

    property alias tabsSearch: tabsSearch
    property alias newTabButton: newTabButton
    property alias tabsList: tabsList
    property alias searchList: searchList
    property alias tabsModel: tabsList.tabsModel
    property alias searchListHeight: searchList.height
    property int tabHeight: 30
    property alias tabsListHeight: tabsList.height
}
